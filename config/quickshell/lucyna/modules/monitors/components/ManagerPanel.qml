import QtQuick
import "../services"
import "../../../core/theme" as Theme
import "../../../core/components"

/*!
    ManagerPanel — Visual panel for the Monitor Manager.

    Contains the top bar, canvas, MonitorCard and ProfileSelector.
    Reads MonitorService and ProfileService directly (singletons).
    Routes all user actions back to MonitorManager via signals.

    Input properties:
      selectedName    string — currently selected monitor name
      activeProfileId string — currently active profile id

    Public functions:
      reset()   — resets the ProfileSelector save input
*/
Rectangle {
    id: root

    property string selectedName:    ""
    property string activeProfileId: ""

    readonly property int _pad: 16

    // ── Routed signals ────────────────────────────────────
    signal closeRequested()
    signal applyRequested()
    signal saveLayoutRequested()

    signal monitorSelected(string name)
    signal monitorMoved(string name, var position)

    signal aliasChanged(string serial, string alias)
    signal modeChanged(string name, var mode)
    signal monitorScaleChanged(string name, real scale)
    signal transformChanged(string name, int transform)
    signal enabledToggled(string name, bool enabled)
    signal positionChanged(string name, var position)
    signal cmChanged(string name, string cm)

    signal profileSelected(string id)
    signal saveRequested(string name)
    signal deleteRequested(string id)

    // ── Appearance ────────────────────────────────────────
    color:        Theme.Tokens.color.bg
    radius:       Theme.Tokens.radius.md
    border.width: 1
    border.color: Theme.Tokens.color.border

    MouseArea { anchors.fill: parent }

    // ── Layout ────────────────────────────────────────────
    Column {
        anchors { fill: parent; margins: root._pad }
        spacing: root._pad

        // ── Top bar ───────────────────────────────────────
        Item {
            width:  parent.width
            height: 30

            QsText {
                id: _titleText
                anchors { left: parent.left; verticalCenter: parent.verticalCenter }
                text:      "Monitor Manager"
                role:      "title"
                font.bold: true
            }

            Row {
                anchors { right: parent.right; verticalCenter: parent.verticalCenter }
                spacing: Theme.Tokens.space.sm

                QsButton {
                    id:        _saveBtn
                    label:     "Save"
                    enabled:   root.activeProfileId !== ""
                    onClicked: root.saveLayoutRequested()
                }

                QsButton {
                    id:        _applyBtn
                    variant:   "filled"
                    label:     "Apply"
                    onClicked: root.applyRequested()
                }

                QsButton {
                    id:        _closeBtn
                    glyph:     "✕"
                    onClicked: root.closeRequested()
                }
            }
        }

        // ── Canvas + right panel ──────────────────────────
        Row {
            width:   parent.width
            height:  parent.height - 30 - root._pad
            spacing: root._pad

            MonitorCanvas {
                width:  parent.width - 280 - root._pad
                height: parent.height

                viewModels: {
                    if (MonitorService.monitors.length === 0) return []
                    const bounds = MonitorService.calcBoundingBox(MonitorService.monitors)
                    const cb = { layout: bounds, canvasWidth: width, canvasHeight: height }
                    return MonitorService.monitors.map(m => MonitorService.toViewModel(m, cb))
                }

                canvasBounds: {
                    if (MonitorService.monitors.length === 0)
                        return { layout: { x: 0, y: 0, width: 1920, height: 1080 }, canvasWidth: width, canvasHeight: height }
                    const bounds = MonitorService.calcBoundingBox(MonitorService.monitors)
                    return { layout: bounds, canvasWidth: width, canvasHeight: height }
                }

                selectedName: root.selectedName

                onMonitorSelected: function(name)     { root.monitorSelected(name) }
                onMonitorMoved:    function(name, pos) { root.monitorMoved(name, pos) }
            }

            Column {
                width:   280
                height:  parent.height
                spacing: root._pad

                MonitorCard {
                    id: _card

                    width:   parent.width
                    monitor: root.selectedName !== ""
                                 ? (MonitorService.monitors.find(m => m.name === root.selectedName) || null)
                                 : null

                    onAliasChanged:        function(serial, alias)   { root.aliasChanged(serial, alias) }
                    onModeChanged:         function(name, mode)      { root.modeChanged(name, mode) }
                    onMonitorScaleChanged: function(name, scale)     { root.monitorScaleChanged(name, scale) }
                    onTransformChanged:    function(name, transform) { root.transformChanged(name, transform) }
                    onEnabledToggled:      function(name, enabled)   { root.enabledToggled(name, enabled) }
                    onPositionChanged:     function(name, position)  { root.positionChanged(name, position) }
                    onCmChanged:           function(name, cm)        { root.cmChanged(name, cm) }
                }

                ProfileSelector {
                    id: _profileSelector

                    width:   parent.width
                    height:  parent.height - _card.height - root._pad

                    profiles:         ProfileService.profiles
                    connectedSerials: MonitorService.monitors
                                          .filter(m => m.connected)
                                          .map(m => m.serial)
                    activeProfileId:  root.activeProfileId

                    onProfileSelected: function(id)   { root.profileSelected(id) }
                    onSaveRequested:   function(name) { root.saveRequested(name) }
                    onDeleteRequested: function(id)   { root.deleteRequested(id) }
                }
            }
        }
    }

    // ── Public ────────────────────────────────────────────
    function reset() { _profileSelector.reset() }
}
