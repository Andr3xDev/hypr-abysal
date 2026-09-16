import QtQuick
import QtQuick.Controls
import "../../../core/theme" as Theme
import "../../../core/components"

/*!
    ProfileSelector — Profile list and management.

    Signals:
      profileSelected(id)   — apply this profile
      saveRequested(name)   — create new profile with given name
      deleteRequested(id)   — remove this profile
*/
Item {
    id: root

    property var    profiles:         []
    property var    connectedSerials:  []
    property string activeProfileId:  ""

    signal profileSelected(string id)
    signal saveRequested(string name)
    signal deleteRequested(string id)

    readonly property int _mg: 12   // outer margin

    // ── Header ────────────────────────────────────────────
    QsText {
        id:        _header
        anchors {
            top:        parent.top; topMargin:  _mg
            left:       parent.left; leftMargin: _mg
        }
        text:      "Profiles"
        role:      "title"
        font.bold: true
    }

    Rectangle {
        id: _divider
        anchors {
            top:         _header.bottom; topMargin:   8
            left:        parent.left;    leftMargin:  _mg
            right:       parent.right;   rightMargin: _mg
        }
        height: 1
        color:  Theme.Tokens.color.bgElevated
    }

    // ── Save area — always pinned to bottom ───────────────
    Item {
        id: saveRow
        property bool saving: false

        anchors {
            bottom:      parent.bottom; bottomMargin: _mg
            left:        parent.left;   leftMargin:   _mg
            right:       parent.right;  rightMargin:  _mg
        }
        height: 32

        // Collapsed: outline button
        QsButton {
            anchors.fill: parent
            visible:      !saveRow.saving
            variant:      "outline"
            label:        "+ Save current layout"
            onClicked:    saveRow.saving = true
        }

        // Expanded: text field + confirm
        Row {
            width:   parent.width
            height:  32
            spacing: 6
            visible: saveRow.saving

            TextField {
                id:                  nameField
                width:               parent.width - confirmSaveBtn.width - parent.spacing
                height:              32
                placeholderText:     "Profile name…"
                placeholderTextColor: Theme.Tokens.color.textMuted
                color:               Theme.Tokens.color.textPrimary
                font.pixelSize:      Theme.Tokens.text.md
                background: Rectangle {
                    color:        Theme.Tokens.color.bgElevated
                    radius:       Theme.Tokens.radius.lg
                    border.width: 1
                    border.color: nameField.activeFocus
                                      ? Theme.Tokens.color.accent
                                      : Theme.Tokens.color.border
                }
                Keys.onEscapePressed: { saveRow.saving = false; nameField.clear() }
                Keys.onReturnPressed:  confirmSave()
            }

            QsButton {
                id:        confirmSaveBtn
                variant:   "filled"
                label:     "Save"
                height:    32
                onClicked: confirmSave()
            }
        }
    }

    // ── Profile list — fills remaining space, scrolls ─────
    ListView {
        id: profileList
        anchors {
            top:         _divider.bottom; topMargin:    8
            bottom:      saveRow.top;     bottomMargin: 8
            left:        parent.left;     leftMargin:   _mg
            right:       parent.right;    rightMargin:  _mg
        }
        clip:    true
        model:   root.profiles
        spacing: Theme.Tokens.space.xs

        ScrollIndicator.vertical: ScrollIndicator { }

        delegate: Rectangle {
            id: profileRow
            property var profile: modelData
            readonly property bool isMatch:  root._matchesConnected(profile)
            readonly property bool isActive: root.activeProfileId === profile.id

            width:  profileList.width
            height: 40
            radius: Theme.Tokens.radius.lg
            color:  isActive
                        ? Theme.Tokens.color.accentSurface
                        : rowArea.containsMouse
                            ? Theme.Tokens.color.bgElevated
                            : Theme.Tokens.color.bg

            // Match indicator — bottom line
            Rectangle {
                visible: isMatch && !isActive
                anchors {
                    left: parent.left; leftMargin: 6
                    right: parent.right; rightMargin: 6
                    bottom: parent.bottom
                }
                height: 1
                color:  Theme.Tokens.color.borderStrong
            }

            QsText {
                anchors {
                    left:           parent.left;    leftMargin:  10
                    right:          _actionRow.left; rightMargin: 6
                    verticalCenter: parent.verticalCenter
                }
                text:  profile.name
                role:  "body"
                elide: Text.ElideRight
            }

            // Right: action buttons
            Row {
                id: _actionRow
                anchors {
                    right:          parent.right; rightMargin: 8
                    verticalCenter: parent.verticalCenter
                }
                spacing: Theme.Tokens.space.xs

                QsButton {
                    label:      "Apply"
                    labelColor: Theme.Tokens.color.textMuted
                    onClicked:  root.profileSelected(profile.id)
                }

                QsButton {
                    glyph:      "✕"
                    width:      24
                    labelColor: Theme.Tokens.color.textMuted
                    onClicked:  root.deleteRequested(profile.id)
                }
            }

            MouseArea {
                id: rowArea
                anchors.fill: parent
                hoverEnabled: true
                z: -1
            }
        }
    }

    // ── Public ────────────────────────────────────────────
    function reset() {
        saveRow.saving = false
        nameField.clear()
    }

    // ── Private ───────────────────────────────────────────
    function _matchesConnected(profile) {
        return profile.trigger.require.every(s => root.connectedSerials.includes(s)) &&
               profile.trigger.absent.every(s => !root.connectedSerials.includes(s))
    }

    function confirmSave() {
        const n = nameField.text.trim()
        if (n.length === 0) return
        root.saveRequested(n)
        saveRow.saving = false
        nameField.clear()
    }
}
