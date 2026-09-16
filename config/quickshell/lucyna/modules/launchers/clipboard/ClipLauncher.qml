import "../../../core/components"
import "../../../core/theme" as Theme
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "components"
import "state"

/*!
    Full-screen clipboard launcher overlay. Filters entries in real time,
    supports paste on click/Enter, and delete via ✕ button or Ctrl+D.
    Ctrl+Shift+D clears all history (requires confirmation).
*/
PanelWindow {
    id: root

    // Layout constants
    readonly property int cardW:   460
    readonly property int rowH:    Theme.Tokens.comp.clip.rowH
    readonly property int searchH: Theme.Tokens.comp.clip.searchH
    readonly property int pad:     Theme.Tokens.comp.clip.pad
    readonly property int maxRows: 8
    readonly property int minRows: 3
    readonly property int listH:   Math.max(rowH * minRows, Math.min((ClipState.filtered?.count ?? 0) * rowH, rowH * maxRows))
    readonly property int cardH:   pad + searchH + pad + listH + pad

    // Public API
    function toggle() { root.visible ? close() : open() }

    function open() {
        ClipState.refresh()
        root.visible = true
    }

    function close() {
        ClipState.cleanup()
        root.visible = false
    }

    // Visibility
    color: "transparent" // layer-shell root — must not paint, real card bg is the Rectangle below
    visible: false
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "clipLauncher"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore
    onVisibleChanged: {
        if (visible) searchInput.forceSearchFocus()
    }

    anchors { top: true; bottom: true; left: true; right: true }

    // IPC — external keybind
    IpcHandler {
        function handle() { root.toggle() }
        target: "toggleClip"
    }

    // Background overlay
    DarkOverlay {
        visible: root.visible
        onClicked: root.close()
    }

    // Card
    Rectangle {
        id: card

        width:  root.cardW
        height: root.cardH
        anchors.centerIn: parent
        color:        Theme.Tokens.color.bg
        radius:       Theme.Tokens.radius.md
        border.width: 1
        border.color: Theme.Tokens.color.border
        opacity:      root.visible ? 1 : 0
        scale:        root.visible ? 1 : 0.97

        MouseArea { anchors.fill: parent }

        // Empty-state quote
        Column {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 10
            width:   parent.width - (root.pad * 4)
            spacing: 6
            visible: clipList.count === 0

            Text {
                text:                "\"I'm no hero. Never was, never will be\""
                color:               Theme.Tokens.color.textMuted
                font.pixelSize:      Theme.Tokens.text.md
                font.italic:         true
                horizontalAlignment: Text.AlignHCenter
                width:               parent.width
                wrapMode:            Text.WordWrap
            }
            Text {
                text:                "Solid Snake"
                color:               Theme.Tokens.color.textMuted
                font.pixelSize:      Theme.Tokens.text.sm
                horizontalAlignment: Text.AlignHCenter
                width:               parent.width
            }
            Text {
                text:                "Metal Gear Solid 4"
                color:               Theme.Tokens.color.textMuted
                font.pixelSize:      Theme.Tokens.text.sm
                font.italic:         true
                horizontalAlignment: Text.AlignHCenter
                width:               parent.width
            }
        }

        Column {
            spacing: root.pad
            anchors { fill: parent; margins: root.pad }

            ClipSearchBar {
                id: searchInput
                width:    parent.width
                listRef:  clipList
                onEscapePressed:          root.close()
                onDeleteCurrentRequested: {
                    const item = clipList.currentItem
                    if (item) ClipState.deleteEntry(item.rawLine, item.clipId)
                }
                onClearAllConfirmed: ClipState.clearAll()
            }

            ClipList {
                id: clipList
                width:     parent.width
                height:    root.listH
                clipState: ClipState
            }
        }

        Behavior on opacity { NumberAnimation { duration: Theme.Tokens.motion.fast; easing.type: Theme.Tokens.motion.ease } }
        Behavior on scale   { NumberAnimation { duration: Theme.Tokens.motion.fast; easing.type: Theme.Tokens.motion.ease } }
    }

    Connections {
        target: ClipState
        function onPasteCompleted() { root.close() }
    }
}
