import QtQuick
import "../theme" as Theme

/*!
    HoverScale — reusable hover-to-scale interaction.

    A MouseArea that animates `target.scale` between 1.0 and `scaleAmount`
    on hover enter/exit, using the shared fast-duration/standard-easing
    motion tokens. Defaults `target` to its parent, matching the common
    "scale the icon I'm layered over" usage.

    Usage:
        Text {
            id: icon
            HoverScale { anchors.fill: parent }
        }

        Text {
            id: otherIcon
            HoverScale { anchors.fill: someOtherArea; target: otherIcon }
        }
*/
MouseArea {
    id: root

    // Item whose scale is animated on hover. Defaults to the parent.
    property Item target: parent

    // Scale applied while hovered. Normalized to 1.1 across all call sites.
    property real scaleAmount: 1.1

    hoverEnabled: true

    onEntered: {
        _scaleAnimation.to = root.scaleAmount
        _scaleAnimation.start()
    }
    onExited: {
        _scaleAnimation.to = 1.0
        _scaleAnimation.start()
    }

    NumberAnimation {
        id: _scaleAnimation
        target: root.target
        property: "scale"
        duration: Theme.Tokens.motion.fast
        easing.type: Theme.Tokens.motion.ease
    }
}
