pragma Singleton

import QtQuick

/*!
    Abysal Light (Marble) — light variant of the Abysal palette family.
    Not migrated to the Nerita primitive contract. Unregistered until it
    supplies the 25 primitive keys (7 neutrals + 9 hues x {fill, dark}).
    Kept on disk for its light-theme color research.
*/
QtObject {
    id: palette

    readonly property string id:   "abysal-marble"
    readonly property string name: "Abysal Marble"

    readonly property QtObject tokens: QtObject {
        readonly property color bg:               "#F0F3F4"
        readonly property color bg_dark:           "#FFFFFF"
        readonly property color bg_elevated:        "#D8E0E3"
        readonly property color bg_highlight:       "#C2CDD1"
        readonly property color border_subtle:      "#AEB9BD"
        readonly property color border:             "#8F9DA2"
        readonly property color border_strong:      "#66777D"
        readonly property color border_emphasis:    "#425258"
        readonly property color fg:                 "#0D1518"
        readonly property color fg_secondary:       "#33424A"
        readonly property color fg_muted:           "#54646A"
        readonly property color primary:            "#0D9488"
        readonly property color primary_text:       "#0A6F64"
        readonly property color primary_anchor:     "#14B8A6"
        readonly property color primary_muted:      "#2E8078"
        readonly property color mauve:              "#6B3D7B"
        readonly property color amber:              "#8A5A1D"
        readonly property color coral:              "#C43D22"
        readonly property color red:                "#C13034"
        readonly property color red_anchor:         "#E5484D"
        readonly property color green:              "#2A8049"
        readonly property color green_anchor:       "#3DB667"
        readonly property color seafoam:            "#2E8A63"
        readonly property color blue:               "#2F4EA8"
        readonly property color gold:               "#8A7818"
        readonly property color text_on_solid:      "#F5F6F5"
        readonly property color selection_bg:       "#CBE4E1"
    }
    readonly property QtObject surface: QtObject {
        readonly property color primary:   palette.tokens.bg
        readonly property color secondary: palette.tokens.bg_elevated
        readonly property color overlay:   palette.tokens.bg_dark
    }
    readonly property QtObject on: QtObject {
        readonly property color surface:      palette.tokens.fg
        readonly property color surfaceMuted: palette.tokens.fg_muted
        readonly property color accent:       "#FFFFFF"
    }
    readonly property color accent: palette.tokens.primary
    readonly property QtObject status: QtObject {
        readonly property color error:   palette.tokens.coral
        readonly property color warning: palette.tokens.amber
    }
    readonly property color border:         palette.tokens.border
    readonly property color borderSubtle:   palette.tokens.border_subtle
    readonly property color borderStrong:   palette.tokens.border_strong
    readonly property color borderEmphasis: palette.tokens.border_emphasis
    readonly property color accentMuted:    palette.tokens.primary_muted
    readonly property color detail:         palette.tokens.gold
    readonly property color detailSecondary: palette.tokens.blue
}
