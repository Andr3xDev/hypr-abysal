import QtQuick
import "../theme" as Theme

/*!
    QsButton — polivalent button for module UIs.

    Not for bar widgets (those have active/toggle state and their own components).

    Variants
    --------
    "ghost"   transparent bg, highlight on hover, on.surface text  (default)
    "filled"  accent bg, accent on hover, on.accent text
    "outline" transparent bg + border, highlight on hover, on.surface text
    "danger"  status.error bg, status.error+dim on hover, surface.primary text

    Any variant color can be overridden per-instance:
        QsButton {
            variant:    "filled"
            bgColor:    Theme.Tokens.color.warning
            labelColor: Theme.Tokens.color.bg
            onClicked:  doSomething()
        }
*/
Rectangle {
    id: root

    // ── Variant properties ────────────────────────────────

    // Content
    property string label: ""
    property string glyph: ""

    // Variant
    property string variant: "ghost"

    // Color overrides
    property color bgColor:      _variantBg
    property color hoverColor:   _variantHover
    property color labelColor:   root.enabled ? _variantLabel : Theme.Tokens.comp.qsButton.disabledLabel
    property color hoverLabelColor: _variantHoverLabel

    // Border
    property int   borderWidth: variant === "outline" ? 1 : 0
    property color borderColor: _variantBorder

    signal clicked()

    // Internal variant
    readonly property color _variantBg: {
        switch (variant) {
            case "filled":  return Theme.Tokens.color.accent
            case "danger":  return Theme.Tokens.color.danger
            default:        return Theme.Tokens.color.bgElevated
        }
    }

    readonly property color _variantHover: {
        switch (variant) {
            case "filled":  return Theme.Tokens.color.accent
            case "danger":  return Theme.Tokens.color.dangerSurface
            default:        return Theme.Tokens.color.bgHover
        }
    }

    readonly property color _variantLabel: {
        switch (variant) {
            case "filled":  return Theme.Tokens.color.onAccent
            case "danger":  return Theme.Tokens.color.bg
            default:        return Theme.Tokens.color.textPrimary
        }
    }

    readonly property color _variantHoverLabel: {
        switch (variant) {
            case "danger": return Theme.Tokens.color.danger
            default:       return root.labelColor
        }
    }

    // border.width is already 0 for non-outline variants (see borderWidth
    // above), so this only needs to hold a real value for "outline".
    readonly property color _variantBorder: Theme.Tokens.color.border


    // ── Geometry ──────────────────────────────────────────
    implicitWidth:  _row.implicitWidth  + Theme.Tokens.space.md * 2
    implicitHeight: _row.implicitHeight + Theme.Tokens.space.sm * 2


    // ── Visuals ───────────────────────────────────────────
    color:        _area.containsMouse ? root.hoverColor : root.bgColor
    radius:       Theme.Tokens.radius.sm
    border.width: root.borderWidth
    border.color: root.borderColor

    Behavior on color { ColorAnimation { duration: Theme.Tokens.motion.fast } }

    Row {
        id: _row
        anchors.centerIn: parent
        spacing: Theme.Tokens.space.xs

        Text {
            visible:        root.glyph !== ""
            text:           root.glyph
            color:          _area.containsMouse ? root.hoverLabelColor : root.labelColor
            font.family:    Theme.Tokens.text.iconFont
            font.pixelSize: Theme.Tokens.text.icon
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            visible:        root.label !== ""
            text:           root.label
            color:          _area.containsMouse ? root.hoverLabelColor : root.labelColor
            font.pixelSize: Theme.Tokens.text.sm
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    MouseArea {
        id: _area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape:  Qt.PointingHandCursor
        onClicked:    root.clicked()
    }
}
