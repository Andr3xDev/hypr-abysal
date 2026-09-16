import QtQuick
import "../../../../core/theme" as Theme
import "../state"

/*!
    Search bar for ClipLauncher.
    Binds bidirectionally with ClipState.query.
    Delegates ↑↓↵ to the list reference provided by the parent.
    Ctrl+D deletes the selected entry; Ctrl+Shift+D clears all (with confirmation).
*/
Rectangle {
    id: root

    property var listRef: null

    signal escapePressed()
    signal deleteCurrentRequested()
    signal clearAllConfirmed()

    // ── Clear-all confirmation state ─────────────────────
    property bool _confirmingClear: false

    Timer {
        id: _confirmTimer
        interval: 3000
        onTriggered: root._confirmingClear = false
    }

    function _handleClearAll() {
        if (_confirmingClear) {
            _confirmingClear = false
            _confirmTimer.stop()
            root.clearAllConfirmed()
        } else {
            _confirmingClear = true
            _confirmTimer.restart()
        }
    }

    // ── Appearance ───────────────────────────────────────
    height:       Theme.Tokens.comp.clip.searchH
    color:        Theme.Tokens.color.bgElevated
    radius:       Theme.Tokens.radius.lg
    border.width: 1
    border.color: searchInput.activeFocus
        ? Theme.Tokens.color.accent
        : Theme.Tokens.color.border

    // Search icon
    Text {
        anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 10 }
        text:           " 󰅍 "
        font.family:    Theme.Tokens.text.iconFont
        font.pixelSize: Theme.Tokens.text.xl
        color:          Theme.Tokens.color.accent
    }

    // Search input
    TextInput {
        id: searchInput

        anchors {
            verticalCenter: parent.verticalCenter
            left:  parent.left
            right: parent.right
            leftMargin:  34
            rightMargin: 44
        }

        color:              Theme.Tokens.color.textPrimary
        font.pixelSize:     Theme.Tokens.text.lg
        font.letterSpacing: 0.3
        selectionColor:     Theme.Tokens.color.accent
        clip:               true
        focus:              true

        onTextChanged: ClipState.query = text

        Keys.onEscapePressed: root.escapePressed()
        Keys.onDownPressed:   { if (root.listRef) root.listRef.incrementCurrentIndex() }
        Keys.onUpPressed:     { if (root.listRef) root.listRef.decrementCurrentIndex() }
        Keys.onReturnPressed: {
            if (root.listRef?.currentItem)
                ClipState.paste(root.listRef.currentItem.clipId)
        }
        Keys.onPressed: event => {
            if (event.key === Qt.Key_D && (event.modifiers & Qt.ControlModifier)) {
                if (event.modifiers & Qt.ShiftModifier)
                    root._handleClearAll()
                else
                    root.deleteCurrentRequested()
                event.accepted = true
            }
        }
    }

    // Trash button
    Rectangle {
        id: _trashBtn

        width:  28
        height: 28
        anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
        radius: Theme.Tokens.radius.lg

        color: (_trashHover.containsMouse || root._confirmingClear)
            ? Theme.Tokens.color.accentSurface
            : Theme.Tokens.color.bgElevated

        Behavior on color { ColorAnimation { duration: Theme.Tokens.motion.fast } }

        Text {
            anchors.centerIn: parent
            text:           root._confirmingClear ? "󰄬" : "󰩺"
            font.family:    Theme.Tokens.text.iconFont
            font.pixelSize: Theme.Tokens.text.xl
            color:          Theme.Tokens.color.accent

            Behavior on color { ColorAnimation { duration: Theme.Tokens.motion.fast } }
        }

        MouseArea {
            id: _trashHover
            anchors.fill: parent
            hoverEnabled: true
            cursorShape:  Qt.PointingHandCursor
            onClicked:    root._handleClearAll()
        }
    }

    function forceSearchFocus() {
        searchInput.forceActiveFocus()
    }
}
