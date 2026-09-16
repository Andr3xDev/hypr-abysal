import QtQuick
import "../../../core/theme" as Theme
import "../../../core/components"

/*!
    MonitorCanvas — Drag-and-drop spatial layout of monitors.

    Receives pre-computed viewModels (from MonitorManager via MonitorAdapter).
    Emits Hyprland logical-pixel coordinates on drag end.

    Signals:
      monitorMoved(name, position)   — position: { x, y } in Hyprland logical px
      monitorSelected(name)          — user clicked a monitor rectangle

    NOTE: plan did not include monitorSelected() — added so MonitorManager
    knows which monitor to show in MonitorCard.

    NOTE: PADDING (16) must match MonitorAdapter.toViewModel PADDING constant.
    If changed here, change there too.
*/
Item {
    id: root

    property var    viewModels:   []
    property var    canvasBounds: ({ layout: { x: 0, y: 0, width: 1920, height: 1080 }, canvasWidth: 1, canvasHeight: 1 })
    property string selectedName: ""

    signal monitorMoved(string name, var position)
    signal monitorSelected(string name)

    // Background
    Rectangle {
        anchors.fill: parent
        color:        Theme.Tokens.color.bgElevated
        radius:       Theme.Tokens.radius.md
    }

    // Monitor rectangles
    Repeater {
        id: repeater
        model: root.viewModels

        delegate: Item {
            id: delegateRoot
            property var vm: modelData

            readonly property bool isSelected: root.selectedName === vm.name
            readonly property bool isDisabled: !vm.enabled

            // Position driven by ViewModel unless dragging
            Binding { target: delegateRoot; property: "x"; value: vm.canvasRect.x; when: !monDrag.active }
            Binding { target: delegateRoot; property: "y"; value: vm.canvasRect.y; when: !monDrag.active }

            width:  vm.canvasRect.width
            height: vm.canvasRect.height

            // Monitor rectangle
            Rectangle {
                anchors.fill: parent
                radius:       Theme.Tokens.radius.lg
                color: {
                    if (delegateRoot.isDisabled) return Theme.Tokens.color.bg
                    if (delegateRoot.isSelected) return Theme.Tokens.color.accentSurface
                    return Theme.Tokens.color.bgElevated
                }
                border.width: delegateRoot.isSelected ? 2 : 1
                border.color: delegateRoot.isSelected
                    ? Theme.Tokens.color.accent
                    : Theme.Tokens.color.border

                // Monitor info
                IdentityBadge {
                    anchors.centerIn: parent
                    alias:    vm.alias
                    portName: vm.portName
                }

                // Mode label at bottom
                QsText {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        bottom:           parent.bottom
                        bottomMargin:     6
                    }
                    text:    vm.modeLabel
                    role:    "caption"
                    muted:   true
                    visible: parent.height > 60
                }

                // DISABLED overlay text
                QsText {
                    anchors.centerIn:             parent
                    anchors.verticalCenterOffset: 16
                    text:       "DISABLED"
                    role:       "caption"
                    muted:      true
                    font.bold:  true
                    visible:    delegateRoot.isDisabled
                }
            }

            // Selection click
            MouseArea {
                anchors.fill: parent
                z: 0
                onClicked:    root.monitorSelected(vm.name)
            }

            // Drag
            DragHandler {
                id: monDrag
                onActiveChanged: {
                    if (!active) {
                        const snapped = root._snapToEdge(
                            vm.name,
                            delegateRoot.x, delegateRoot.y,
                            delegateRoot.width, delegateRoot.height
                        )
                        root.monitorMoved(vm.name, root._canvasToHypr(snapped.x, snapped.y))
                    }
                }
            }
        }
    }

    // ── Private: snap dragged monitor to the nearest adjacent edge ──
    /*!
        For each other monitor, generates 8 edge-aligned candidate positions
        (4 adjacencies × 2 axis alignments). Returns the closest candidate
        within THRESHOLD canvas-px; falls back to the original (cx, cy) when
        no candidate is close enough.
    */
    function _snapToEdge(draggedName, cx, cy, dragW, dragH) {
        const THRESHOLD = 60

        let bestDist2 = THRESHOLD * THRESHOLD + 1
        let snapX = cx
        let snapY = cy

        for (let i = 0; i < root.viewModels.length; i++) {
            const vm = root.viewModels[i]
            if (vm.name === draggedName) continue
            const r = vm.canvasRect

            // 8 candidates: 4 edge placements × (free axis | aligned axis)
            const candidates = [
                { x: r.x + r.width, y: cy          },  // left → target right, Y free
                { x: r.x + r.width, y: r.y          },  // left → target right, top-align
                { x: r.x - dragW,   y: cy           },  // right → target left, Y free
                { x: r.x - dragW,   y: r.y          },  // right → target left, top-align
                { x: cx,            y: r.y + r.height }, // top → target bottom, X free
                { x: r.x,           y: r.y + r.height }, // top → target bottom, left-align
                { x: cx,            y: r.y - dragH   }, // bottom → target top, X free
                { x: r.x,           y: r.y - dragH   }, // bottom → target top, left-align
            ]

            for (let j = 0; j < candidates.length; j++) {
                const c = candidates[j]
                const dx = c.x - cx
                const dy = c.y - cy
                const d2 = dx * dx + dy * dy
                if (d2 < bestDist2) {
                    bestDist2 = d2
                    snapX = c.x
                    snapY = c.y
                }
            }
        }

        return { x: snapX, y: snapY }
    }

    // ── Private: inverse transform canvas px → Hyprland logical px ─
    function _canvasToHypr(cx, cy) {
        const PADDING  = 16
        const layout   = canvasBounds.layout
        const availW   = canvasBounds.canvasWidth  - PADDING * 2
        const availH   = canvasBounds.canvasHeight - PADDING * 2
        const fitScale = Math.min(availW / layout.width, availH / layout.height)
        const scaledW  = layout.width  * fitScale
        const scaledH  = layout.height * fitScale
        const offsetX  = PADDING + (availW - scaledW) / 2
        const offsetY  = PADDING + (availH - scaledH) / 2

        return {
            x: Math.round(layout.x + (cx - offsetX) / fitScale),
            y: Math.round(layout.y + (cy - offsetY) / fitScale)
        }
    }
}
