import Quickshell
import QtQuick
import QtQuick.Layouts
import "../../core/theme" as Theme
import "components"
import "layout"

/*!
    Bar of the system. Shows workspaces, clock, power profiles, metrics and battery.
*/
PanelWindow {
    id: bar
    anchors {
        left: true
        top: true
        right: true
    }
    margins { top: 4; left: 40; right: 40}
    implicitHeight: 32
    color: "transparent" // layer-shell root — must not paint, real bar bg is the Rectangle below

    property var modelData
    screen: modelData

    Rectangle {
        anchors.fill: parent
        border.color: Theme.Tokens.color.border
        color: Theme.Tokens.color.bg
        radius: Theme.Tokens.radius.md
        border.width: 2
    }

    // Left section
    Item {
        id: leftSection
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
        }
        width: Math.max(100, leftContent.implicitWidth + Theme.Tokens.space.xxl)

        RowLayout {
            id: leftContent
            anchors.fill: parent
            spacing: Theme.Tokens.space.sm

            Item { Layout.preferredWidth: Theme.Tokens.space.xs }

            ArchLogo {}

            // Subtle separator
            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: parent.height * 0.7
                Layout.alignment: Qt.AlignVCenter
                color: Theme.Tokens.color.borderMuted
                radius: Theme.Tokens.radius.full
            }

            Item { Layout.preferredWidth: Theme.Tokens.space.sm }

            Clock {}

            Item { Layout.preferredWidth: Theme.Tokens.space.sm; Layout.fillWidth: true }
        }
    }

    // Center section - Clock
    Item {
        id: centerSection
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            bottom: parent.bottom
        }
        width: clockContent.implicitWidth + Theme.Tokens.space.xxl

        RowLayout {
            id: clockContent
            anchors.centerIn: parent
            height: parent.height

            Workspaces {
                screen: bar.screen
            }
        }
    }

    // Right section - Metrics, Controls and Battery
    Item {
        id: rightSection
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        width: rightContent.implicitWidth + 2  // pixel offset, not layout spacing

        RowLayout {
            id: rightContent
            anchors { fill: parent; rightMargin: 1 }  // pixel offset, pairs with rightSection's +2
            spacing: Theme.Tokens.space.sm

            Item { Layout.preferredWidth: Theme.Tokens.space.xs }

            PowerProfile {
                id: powerProfile
                expanded: powerToggle.expanded
            }

            ToggleIndicator {
                id: powerToggle
                icon: "󱐋"
            }

            Item { Layout.preferredWidth: Theme.Tokens.space.xs }

            SystemControls {
                id: systemControls
                expanded: controlsToggle.expanded
            }

            ToggleIndicator {
                id: controlsToggle
                icon: "󰒓"
            }

            Item { Layout.preferredWidth: Theme.Tokens.space.xs }

            SystemTemperatures {
                id: systemTemperatures
                expanded: tempToggle.expanded
            }

            ToggleIndicator {
                id: tempToggle
                icon: "󰔏"
            }

            Item { Layout.preferredWidth: Theme.Tokens.space.xs }

            SystemMetrics {
                id: systemMetrics
                expanded: metricsToggle.expanded
            }

            ToggleIndicator {
                id: metricsToggle
                icon: "󰕮"
            }

            Item { Layout.preferredWidth: Theme.Tokens.space.xs }

            Battery {
                id: batteryWidget
            }

            // fillWidth absorbs the 1px surplus so RowLayout doesn't spread it across cells
            Item { Layout.preferredWidth: Theme.Tokens.space.sm; Layout.fillWidth: true }
        }
    }
}
