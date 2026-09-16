import QtQuick
import QtQuick.Layouts
import "../../../../core/theme" as Theme

/*!
    List of available themes with preview color dots.
*/
Item {
    id: root
    implicitHeight: themeColumn.implicitHeight

    signal themeSelected(string themeId)

    ColumnLayout {
        id: themeColumn
        anchors.fill: parent
        spacing: 6

        Repeater {
            model: Theme.ThemeManager.availableThemes

            delegate: Rectangle {
                id: themeItem
                Layout.fillWidth: true
                Layout.preferredHeight: 44

                property bool isActive:  modelData === Theme.ThemeManager.currentTheme
                property bool isHovered: itemMouseArea.containsMouse

                color: isActive
                    ? Theme.Tokens.color.accent
                    : (isHovered ? Theme.Tokens.color.bgHover : Theme.Tokens.color.bg)
                radius: Theme.Tokens.radius.sm
                border.color: Theme.Tokens.color.borderStrong
                border.width: isActive ? 1 : 0

                Behavior on color {
                    ColorAnimation { duration: Theme.Tokens.motion.fast; easing.type: Theme.Tokens.motion.ease }
                }

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 12
                        rightMargin: 12
                    }
                    spacing: 10

                    // Active indicator bar
                    Rectangle {
                        Layout.preferredWidth: 3
                        Layout.preferredHeight: 18
                        radius: 1
                        color: Theme.Tokens.color.accent
                        opacity: themeItem.isActive ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation { duration: Theme.Tokens.motion.fast; easing.type: Theme.Tokens.motion.ease }
                        }
                    }

                    // Theme name
                    Text {
                        Layout.fillWidth: true
                        text: Theme.ThemeManager.getThemeDisplayName(modelData)
                        color: themeItem.isActive
                            ? Theme.Tokens.color.onAccent
                            : Theme.Tokens.color.textMuted
                        font.pixelSize: Theme.Tokens.text.sm
                        font.bold: themeItem.isActive
                        elide: Text.ElideRight

                        Behavior on color {
                            ColorAnimation { duration: Theme.Tokens.motion.fast; easing.type: Theme.Tokens.motion.ease }
                        }
                    }

                    // Color preview dots
                    Row {
                        spacing: 3

                        Repeater {
                            model: Theme.ThemeManager.previewColors(modelData)

                            delegate: Rectangle {
                                width: 12
                                height: 12
                                radius: 2
                                color: modelData
                                border.color: Theme.Tokens.color.border
                                border.width: 1
                                scale: themeItem.isHovered ? 1.1 : 1.0

                                Behavior on scale {
                                    NumberAnimation { duration: Theme.Tokens.motion.fast; easing.type: Theme.Tokens.motion.ease }
                                }
                            }
                        }
                    }

                    // Check icon for active theme
                    Text {
                        text: "󰄬"
                        color: Theme.Tokens.color.textMuted
                        font.pixelSize: Theme.Tokens.text.icon
                        font.family: Theme.Tokens.text.iconFont
                        opacity: themeItem.isActive ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation { duration: Theme.Tokens.motion.fast; easing.type: Theme.Tokens.motion.ease }
                        }
                    }
                }

                MouseArea {
                    id: itemMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!themeItem.isActive)
                            root.themeSelected(modelData)
                    }
                }
            }
        }
    }
}
