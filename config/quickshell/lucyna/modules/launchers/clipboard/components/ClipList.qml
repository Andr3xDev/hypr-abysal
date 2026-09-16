import QtQuick
import QtQuick.Controls
import Quickshell.Io
import "../../../../core/theme" as Theme

/*!
    Virtualised list of clipboard entries.
    Mouse hover and keyboard navigation share a single currentIndex.
*/
ListView {
    id: root

    property var clipState: null

    clip: true
    keyNavigationWraps: true
    highlightMoveDuration: 80
    currentIndex: 0
    model: clipState ? clipState.filtered : null
    onModelChanged: currentIndex = 0

    delegate: Item {
        id: row

        required property int    index
        required property string clipId
        required property string preview
        required property string type
        required property string rawLine

        readonly property bool isCurrent: root.currentIndex === row.index

        width:  root.width
        height: Theme.Tokens.comp.clip.rowH

        // ── Selected background ───────────────────────────
        Rectangle {
            anchors.fill: parent
            radius: Theme.Tokens.radius.lg
            color:  row.isCurrent ? Theme.Tokens.color.bgElevated : Theme.Tokens.color.bg
        }

        // ── Accent bar ────────────────────────────────────
        Rectangle {
            width:  3
            height: parent.height - 12
            anchors { verticalCenter: parent.verticalCenter; left: parent.left; leftMargin: 2 }
            radius:  2
            color:   Theme.Tokens.color.accent
            visible: row.isCurrent
        }

        // ── Content area ──────────────────────────────────
        Item {
            anchors {
                fill:        parent
                leftMargin:  row.isCurrent ? 14 : 10
                rightMargin: row.isCurrent ? 40 : 12
            }

            Behavior on anchors.rightMargin { NumberAnimation { duration: Theme.Tokens.motion.fast; easing.type: Theme.Tokens.motion.ease } }
            Behavior on anchors.leftMargin  { NumberAnimation { duration: Theme.Tokens.motion.fast; easing.type: Theme.Tokens.motion.ease } }

            // Text entry
            Text {
                anchors.fill: parent
                visible:           row.type !== "image"
                text:              row.preview
                color:             row.isCurrent
                    ? Theme.Tokens.color.textPrimary
                    : Theme.Tokens.color.textMuted
                font.pixelSize:    Theme.Tokens.text.md
                elide:             Text.ElideRight
                verticalAlignment: Text.AlignVCenter

                Behavior on color { ColorAnimation { duration: Theme.Tokens.motion.fast } }
            }

            // Image entry
            Row {
                id: _imgRow
                anchors.verticalCenter: parent.verticalCenter
                spacing: Theme.Tokens.space.sm
                visible: row.type === "image"

                property bool ready: false

                Component.onCompleted: {
                    if (row.type === "image") _decode()
                }

                function _decode() {
                    if (_imgProc.running) return
                    _imgProc.command = ["sh", "-c",
                        "cliphist decode " + row.clipId + " > /tmp/qs_clip_" + row.clipId]
                    _imgProc.running = true
                }

                Process {
                    id: _imgProc
                    running: false
                    onExited: _imgRow.ready = true
                }

                Image {
                    width: 36; height: 36
                    anchors.verticalCenter: parent.verticalCenter
                    visible:  _imgRow.ready
                    fillMode: Image.PreserveAspectFit
                    source:   _imgRow.ready ? ("file:///tmp/qs_clip_" + row.clipId) : ""
                    cache:    false
                }

                Text {
                    visible:           !_imgRow.ready
                    text:              "󰋩"
                    font.family:       Theme.Tokens.text.iconFont
                    font.pixelSize:    Theme.Tokens.text.iconLg
                    color:             Theme.Tokens.color.accent
                    verticalAlignment: Text.AlignVCenter
                    height:            Theme.Tokens.comp.clip.rowH
                }

                Text {
                    text:              "Imagen"
                    color:             row.isCurrent
                        ? Theme.Tokens.color.textPrimary
                        : Theme.Tokens.color.textMuted
                    font.pixelSize:    Theme.Tokens.text.md
                    font.italic:       !_imgRow.ready
                    verticalAlignment: Text.AlignVCenter
                    height:            Theme.Tokens.comp.clip.rowH
                }
            }
        }

        // ── ✕ delete button ───────────────────────────────
        Rectangle {
            z:       1
            visible: row.isCurrent
            width:   24
            height:  24
            anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
            radius: Theme.Tokens.radius.lg
            color:  _xHover.containsMouse
                ? Theme.Tokens.color.accentSurface
                : Theme.Tokens.color.bgElevated

            Behavior on color { ColorAnimation { duration: Theme.Tokens.motion.fast } }

            Text {
                anchors.centerIn: parent
                text:           "✕"
                color:          Theme.Tokens.color.accent
                font.pixelSize: Theme.Tokens.text.md
                font.bold:      true
            }

            MouseArea {
                id: _xHover
                anchors.fill: parent
                hoverEnabled: true
                cursorShape:  Qt.PointingHandCursor
                onClicked: mouse => {
                    mouse.accepted = true
                    if (root.clipState)
                        root.clipState.deleteEntry(row.rawLine, row.clipId)
                }
            }
        }

        // ── Main interaction ──────────────────────────────
        MouseArea {
            z:            0
            anchors.fill: parent
            hoverEnabled: true
            onEntered: root.currentIndex = row.index
            onClicked: {
                if (root.clipState)
                    root.clipState.paste(row.clipId)
            }
        }
    }

    ScrollBar.vertical: ScrollBar {
        policy: ScrollBar.AsNeeded
        visible: root.contentHeight > root.height
        contentItem: Rectangle {
            implicitWidth: 4
            radius: 2
            color: Theme.Tokens.color.accent
        }
    }
}
