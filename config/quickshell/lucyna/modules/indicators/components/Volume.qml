import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import "../../../core/theme" as Theme

Scope {
    id: root

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property bool shouldShowOsd: false

    // Track volume via property binding — avoids Connections signal mismatch
    // when Pipewire.defaultAudioSink?.audio is transiently undefined at startup.
    property real pipelineVolume: Pipewire.defaultAudioSink?.audio?.volume ?? 0
    onPipelineVolumeChanged: {
        root.shouldShowOsd = true
        hideTimer.restart()
    }

    Timer {
        id: hideTimer
        interval: 1000
        onTriggered: root.shouldShowOsd = false
    }

    LazyLoader {
        active: root.shouldShowOsd

        PanelWindow {
            anchors.bottom: true
            margins.bottom: screen.height / 5
            exclusiveZone: 0

            implicitWidth: 400
            implicitHeight: 50
            color: "transparent" // layer-shell root — must not paint, real panel bg is drawn inside

            mask: Region {}

            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: Theme.Tokens.color.bgElevated

                RowLayout {
                    anchors {
                        fill: parent
                        leftMargin: 10
                        rightMargin: 15
                    }

                    Text {
                        width: 30
                        horizontalAlignment: Text.AlignHCenter
                        text: (Pipewire.defaultAudioSink?.audio?.muted ?? false) ? "󰖁"
                            : (root.pipelineVolume > 0.5)                        ? "󰕾"
                            :                                                       "󰖀"
                        color: Theme.Tokens.color.textPrimary
                        font.pixelSize: Theme.Tokens.text.iconLg
                        font.family: Theme.Tokens.text.iconFont
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 10
                        radius: 20
                        color: Theme.Tokens.color.accentSurface

                        Rectangle {
                            anchors {
                                left: parent.left
                                top: parent.top
                                bottom: parent.bottom
                            }
                            implicitWidth: parent.width * (Pipewire.defaultAudioSink?.audio?.volume ?? 0)
                            radius: parent.radius
                            color: Theme.Tokens.color.accent
                        }
                    }
                }
            }
        }
    }
}
