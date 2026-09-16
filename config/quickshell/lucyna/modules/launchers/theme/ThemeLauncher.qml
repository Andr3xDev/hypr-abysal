import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import "../../../core/theme" as Theme
import "components"

/*!
    Theme selector popup — toggle between available color themes.
    Toggle via: quickshell ipc call themeLauncher.toggle
*/
PanelWindow {
    id: themeLauncher

    // IPC interface for external control (hyprland keybind)
    IpcHandler {
        target: "themeLauncher"
        function toggle() {
            themeLauncher.visible = !themeLauncher.visible
        }
    }

    // Floating overlay window
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "themeLauncher"
    exclusionMode: ExclusionMode.Ignore

    anchors { bottom: true }

    mask: Region { item: background }

    implicitWidth: 280
    implicitHeight: visible ? background.implicitHeight + 50 : 0
    visible: false
    color: "transparent" // layer-shell root — must not paint, real panel bg is the Rectangle below

    // Script path for external theme changes (hyprland, etc)
    property string externalScriptPath: ""

    Rectangle {
        id: background
        width: 280
        height: contentColumn.implicitHeight + 32
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 50
        color: Theme.Tokens.color.bgElevated
        radius: Theme.Tokens.radius.none
        border.color: Theme.Tokens.color.borderStrong
        border.width: 1

        implicitHeight: contentColumn.implicitHeight + 32

        focus: true
        Keys.onEscapePressed: themeLauncher.visible = false

        ColumnLayout {
            id: contentColumn
            anchors {
                fill: parent
                margins: Theme.Tokens.space.lg
            }
            spacing: Theme.Tokens.space.md

            // Header
            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.Tokens.space.sm

                Text {
                    text: "󰔎"
                    color: Theme.Tokens.color.textMuted
                    font.pixelSize: Theme.Tokens.text.xl
                    font.family: Theme.Tokens.text.iconFont
                }

                Text {
                    text: "Themes"
                    color: Theme.Tokens.color.textPrimary
                    font.pixelSize: Theme.Tokens.text.lg
                    font.bold: true
                }

                Item { Layout.fillWidth: true }

                // Close button
                Rectangle {
                    width: 20
                    height: 20
                    radius: 2
                    color: closeMouseArea.containsMouse
                        ? Theme.Tokens.color.accentSurface
                        : Theme.Tokens.color.bg

                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        color: Theme.Tokens.color.accent
                        font.pixelSize: Theme.Tokens.text.sm
                        font.family: Theme.Tokens.text.iconFont
                    }

                    MouseArea {
                        id: closeMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: themeLauncher.visible = false
                    }
                }
            }

            // Separator
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Theme.Tokens.color.border
            }

            // Theme list
            ThemeList {
                id: themeList
                Layout.fillWidth: true

                onThemeSelected: function(themeId) {
                    Theme.ThemeManager.setTheme(themeId)

                    if (externalScriptPath !== "") {
                        scriptProcess.command = ["bash", externalScriptPath, themeId]
                        scriptProcess.running = true
                    }

                    themeLauncher.visible = false
                }
            }
        }
    }

    // Process for external script execution
    Process {
        id: scriptProcess
        running: false
    }

    function toggle() { visible = !visible }
    function open()   { visible = true }
    function close()  { visible = false }
}
