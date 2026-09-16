pragma Singleton

import QtQuick

/*!
    Scale — layer 1 non-color primitives: spacing, radius, text, motion.

    Merge of the legacy tokens/*.qml files, keeping only the values that
    survived the token-system audit. Entries with no consumer were dropped
    (space.xl, space.barComponents, radius.xl).
*/
QtObject {
    readonly property QtObject space: QtObject {
        readonly property int xs:  4
        readonly property int sm:  8
        readonly property int md:  12
        readonly property int lg:  16
        readonly property int xxl: 32
    }

    readonly property QtObject radius: QtObject {
        readonly property int none: 0
        readonly property int sm:   4
        readonly property int md:   6
        readonly property int lg:   8
        readonly property int full: 9999
    }

    readonly property QtObject text: QtObject {
        readonly property int    xs:       8
        readonly property int    sm:       10
        readonly property int    md:       11
        readonly property int    lg:       13
        readonly property int    xl:       16
        readonly property int    icon:     12
        readonly property int    iconLg:   20
        readonly property string iconFont: "Symbols Nerd Font"
    }

    readonly property QtObject dur: QtObject {
        readonly property int fast:     100
        readonly property int standard: 200
        readonly property int slow:     300
    }

    readonly property QtObject ease: QtObject {
        readonly property int standard:   Easing.OutCubic
        readonly property int decelerate: Easing.OutQuart
        readonly property int accelerate: Easing.InCubic
    }

    readonly property QtObject border: QtObject {
        readonly property int sm: 1
        readonly property int md: 2
        readonly property int lg: 4
    }

    readonly property QtObject shadow: QtObject {
        readonly property int blur:    12
        readonly property int spread:  0
        readonly property int offsetY: 2
    }
}
