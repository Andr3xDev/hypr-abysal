import QtQuick
import QtQuick.Layouts
import "../../../core/theme" as Theme
import "../../../core/components"

/*!
    Toogle sistem to hide information & show it by clicking the square with an icon
*/
Rectangle {
    id: toggleIndicator
    implicitWidth: label !== ""
        ? buttonRow.implicitWidth + (hPad * 2)
        : implicitHeight
    implicitHeight: 20
    readonly property real hPad: Theme.Tokens.space.xs

    // Visuals
    color: expanded
        ? Theme.Tokens.color.accentSurface
        : Theme.Tokens.color.bg
    radius: Theme.Tokens.radius.sm
    border.color: Theme.Tokens.color.borderStrong
    border.width: 1

    // Values to show
    property string icon: ""
    property string label: ""
    property bool expanded: false

    // Animation to open
    Behavior on color {
        ColorAnimation {
            duration: Theme.Tokens.motion.standard
            easing.type: Theme.Tokens.motion.ease
        }
    }

    RowLayout {
        id: buttonRow
        anchors.centerIn: parent
        spacing: Theme.Tokens.space.xs

        Text {
            text: icon
            color: expanded
                ? Theme.Tokens.color.accent
                : Theme.Tokens.color.textPrimary
            font.pixelSize: Theme.Tokens.text.icon
            font.family: Theme.Tokens.text.iconFont
            Layout.alignment: Qt.AlignCenter

            Behavior on color {
                ColorAnimation {
                    duration: Theme.Tokens.motion.standard
                    easing.type: Theme.Tokens.motion.ease
                }
            }
        }

        Text {
            visible: label !== ""
            text: label
            color: expanded
                ? Theme.Tokens.color.accent
                : Theme.Tokens.color.textPrimary
            font.pixelSize: Theme.Tokens.text.sm
            Layout.alignment: Qt.AlignCenter

            Behavior on color {
                ColorAnimation {
                    duration: Theme.Tokens.motion.standard
                    easing.type: Theme.Tokens.motion.ease
                }
            }
        }
    }

    HoverScale {
        anchors.fill: parent
        target: toggleIndicator
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            expanded = !expanded
        }
    }
}
