import QtQuick
import QtQuick.Layouts
import "../../../core/theme" as Theme
import "../../../core/services" as Services
import "../../../core/components"

/*!
    Power profile selector component to set different profiles
*/
ExpandableRow {
    id: root

    // Profile color mapping
    readonly property var profileColors: ({
        "power-saver": Theme.Tokens.color.info,
        "balanced": Theme.Tokens.color.warning,
        "performance": Theme.Tokens.color.danger
    })
    
    RowLayout {
        id: profileRow
        anchors.centerIn: parent
        spacing: 15  // raw literal: a spacing token here caused a layout shift
        opacity: root.expanded ? 1 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.Tokens.motion.standard }
        }

        Repeater {
            model: Services.PowerService.profiles
            delegate: Item {
                id: profileButton
                Layout.preferredWidth: buttonContent.implicitWidth
                Layout.preferredHeight: buttonContent.implicitHeight
                
                property bool isActive: modelData.id === Services.PowerService.currentProfile
                property color profileColor: root.profileColors[modelData.id] || Theme.Tokens.color.textPrimary
                
                ColumnLayout {
                    id: buttonContent
                    spacing: 1
                    
                    // Icon
                    Text {
                        id: iconText
                        text: modelData.icon
                        color: profileButton.isActive
                            ? profileButton.profileColor
                            : Theme.Tokens.color.textPrimary
                        font.pixelSize: Theme.Tokens.text.icon
                        font.family: Theme.Tokens.text.iconFont
                        Layout.alignment: Qt.AlignHCenter
                        
                        Behavior on color {
                            ColorAnimation {
                                duration: Theme.Tokens.motion.standard
                                easing.type: Theme.Tokens.motion.ease
                            }
                        }
                    }

                    // Underline indicator
                    Rectangle {
                        Layout.preferredWidth: iconText.implicitWidth
                        Layout.preferredHeight: 2
                        Layout.alignment: Qt.AlignHCenter
                        color: profileButton.profileColor
                        radius: 1
                        opacity: profileButton.isActive ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: Theme.Tokens.motion.standard
                                easing.type: Theme.Tokens.motion.ease
                            }
                        }
                    }
                }
                
                HoverScale {
                    anchors.fill: parent
                    target: iconText
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Services.PowerService.setProfile(modelData.id)
                }
            }
        }
    }
}