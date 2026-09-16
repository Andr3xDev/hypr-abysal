pragma Singleton

import QtQuick
import "./primitives" as Primitives

/*!
    Tokens — Public design-token API (layers 2 + 3).

    Reads the active palette's primitives via ThemeManager.p (layer 1,
    reactive on currentTheme) and the static Scale singleton (layer 1,
    non-color), and exposes the semantic roles consumers should use.

    ThemeManager itself lives in this same directory, so it is visible
    here with no import statement (implicit directory import). Scale
    lives under ./primitives and needs the explicit import above.
*/
QtObject {
    readonly property QtObject color: QtObject {
        readonly property color bg:             ThemeManager.p.neutral.bg
        readonly property color bgElevated:     ThemeManager.p.neutral.bgElevated
        readonly property color bgHover:        ThemeManager.p.neutral.border
        readonly property color border:         ThemeManager.p.neutral.border
        readonly property color borderMuted:    ThemeManager.p.neutral.borderMuted
        readonly property color borderStrong:   ThemeManager.p.neutral.borderStrong
        readonly property color textPrimary:    ThemeManager.p.neutral.textPrimary
        readonly property color textSecondary:  ThemeManager.p.neutral.textSecondary
        readonly property color textMuted:      ThemeManager.p.neutral.textMuted

        readonly property color accent:         ThemeManager.p.hue.turquoise.fill
        readonly property color accentSurface:  ThemeManager.p.hue.turquoise.dark
        readonly property color onAccent:       ThemeManager.p.neutral.bg

        readonly property color danger:         ThemeManager.p.hue.red.fill
        readonly property color dangerSurface:  ThemeManager.p.hue.red.dark
        readonly property color warning:        ThemeManager.p.hue.orange.fill
        readonly property color warningSurface: ThemeManager.p.hue.orange.dark
        readonly property color success:        ThemeManager.p.hue.green.fill
        readonly property color successSurface: ThemeManager.p.hue.green.dark
        readonly property color info:           ThemeManager.p.hue.blue.fill
        readonly property color infoSurface:    ThemeManager.p.hue.blue.dark

        // Transparency is allowed only when the effect is impossible to achieve
        // opaque. Exactly two cases qualify today: (1) the scrim (scrimBlack),
        // which darkens content that is not ours (e.g. DarkOverlay darkening
        // arbitrary wallpaper/windows behind launchers — no palette color can
        // do that); and (2) shadows (shadowBlack), since an opaque shadow does
        // not exist. A third case must justify itself against this same rule,
        // in this same comment block, before being added. Transparency is
        // never permitted on this project's own surfaces, fills, borders, or
        // text.
        readonly property color scrimBlack: Qt.rgba(0, 0, 0, 0.5)

        // Subtle depth cue for RectangularShadow — computed, not themed,
        // alpha-only. Not copied from scrimBlack's 0.5, a different visual job.
        readonly property color shadowBlack: Qt.rgba(0, 0, 0, 0.35)
    }

    // Deliberate layer-1 escape hatch: passthrough to the active palette's raw
    // hue group, for diagnostic/enum maps that need a specific hue with no
    // system-wide role (e.g. per-workspace color coding). Not for general use —
    // prefer `color` roles above for anything with a semantic meaning.
    readonly property QtObject hue: ThemeManager.p.hue

    // Direct passthrough to Scale — these scale names are already role names,
    // so a 1:1 semantic alias would be pure indirection. A semantic alias gets
    // added only when a role diverges from the scale.
    readonly property QtObject space:  Primitives.Scale.space
    readonly property QtObject radius: Primitives.Scale.radius
    readonly property QtObject text:   Primitives.Scale.text
    readonly property QtObject border: Primitives.Scale.border
    readonly property QtObject shadow: Primitives.Scale.shadow

    // Flattened — the one family with real semantic content.
    readonly property QtObject motion: QtObject {
        readonly property int fast:     Primitives.Scale.dur.fast
        readonly property int standard: Primitives.Scale.dur.standard
        readonly property int slow:     Primitives.Scale.dur.slow
        readonly property int ease:     Primitives.Scale.ease.standard
        readonly property int easeOut:  Primitives.Scale.ease.decelerate
        readonly property int easeIn:   Primitives.Scale.ease.accelerate
    }

    // Layer 3 — component-local constants promoted here only once a SECOND
    // file reads the same value; otherwise it stays local to its component.
    // This is the documented exception, never the default.
    readonly property QtObject comp: QtObject {
        readonly property QtObject qsButton: QtObject {
            readonly property color disabledLabel: ThemeManager.p.neutral.textMuted
        }
        readonly property QtObject clip: QtObject {
            readonly property int rowH:    48
            readonly property int searchH: 44
            readonly property int pad:     12
        }
    }

    // Hover rule: use color.bgHover for navigation/list-row hover states;
    // use color.accentSurface for accent-owned affordances (delete, confirm,
    // select) where the hover should read as "this action matters".

    // Shared severity->color decision. Callers keep their own thresholds;
    // only the color mapping is centralized here.
    function severity(level) {
        if (level === "critical") return color.danger
        if (level === "warn")     return color.warning
        return color.accent
    }
}
