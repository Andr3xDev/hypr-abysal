import QtQuick
import "../theme" as Theme

/*!
    QsText — primitive text component.

    Always reads typography and color from ThemeManager semantic tokens.
    No business logic, no service imports.

    Usage:
        QsText { text: "Hello"; role: "title"; muted: true }
*/
Text {
    id: root

    // Visual role: "body" | "subtitle" | "title" | "caption" | "icon"
    property string role: "body"

    // When true, uses the muted (secondary) text color.
    property bool muted: false

    color: muted
        ? Theme.Tokens.color.textMuted
        : Theme.Tokens.color.textPrimary

    font.pixelSize: {
        switch (role) {
            case "caption":  return Theme.Tokens.text.xs
            case "body":     return Theme.Tokens.text.sm
            case "subtitle": return Theme.Tokens.text.md
            case "title":    return Theme.Tokens.text.lg
            default:         return Theme.Tokens.text.sm
        }
    }
}
