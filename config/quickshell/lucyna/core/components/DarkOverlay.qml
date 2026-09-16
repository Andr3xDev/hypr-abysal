import QtQuick
import "../theme" as Theme

/*!
    DarkOverlay — reusable backdrop for launchers, modals, and popups.

    Core primitive: no business logic, no service imports.
*/
Rectangle {
    id: root

    // Duration of the fade animation in milliseconds
    property int animationDuration: Theme.Tokens.motion.fast

    // Easing type for the animation
    property int easingType: Theme.Tokens.motion.ease

    // Emitted when the overlay is clicked
    signal clicked()

    anchors.fill: parent
    color: Theme.Tokens.color.scrimBlack
    opacity: visible ? 1.0 : 0.0

    Behavior on opacity {
        NumberAnimation {
            duration: root.animationDuration
            easing.type: root.easingType
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
