import QtQuick
import "../../../core/theme" as Theme

/*!
    Arch Linux logo icon
*/
Item {
    id: root
    implicitWidth: logoText.implicitWidth
    implicitHeight: parent.height
    
    Text {
        id: logoText
        anchors.centerIn: parent
        text: " 󰣇 "
        color: Theme.Tokens.color.accent
        font.pixelSize: Theme.Tokens.text.lg
        font.family: Theme.Tokens.text.iconFont
    }
}
