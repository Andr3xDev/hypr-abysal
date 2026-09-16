import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../../../core/theme" as Theme
import "../../../core/components"

/*!
    A dynamic widget for displaying and switching between Hyprland workspaces.
    This component renders a horizontal row of workspace indicators
    based on the Hyprland workspaces.
*/
Item {
    implicitWidth: workspaceRow.implicitWidth
    width: implicitWidth
    Layout.fillHeight: true

    // multi-monitor values to render property
    property var screen: null
    property string monitorName: screen ? screen.name : ""
    property int numWorkspaces: 10

    /*!
        Normalized local ID from real hyprsplit ID
     */
    function localId(workspaceId) {
        return ((workspaceId - 1) % numWorkspaces) + 1;
    }

    /*!
        Returns the accent color for a workspace state (focused > active),
        or fallback when inactive. Used for both text and border coloring.
    */
    function workspaceColor(workspace, fallback) {
        if (workspace.focused) return Theme.Tokens.color.accent;
        if (workspace.active)  return Theme.Tokens.color.accent;
        return fallback;
    }

    // Show workspaces
    RowLayout {
        id: workspaceRow
        anchors.centerIn: parent

        Repeater {
            model: Hyprland.workspaces
            delegate: Rectangle {
                // Hide special workspaces
                visible: modelData.id > 0 && modelData.monitor !== null && modelData.monitor.name === monitorName

                // Collapse non visible items
                width: visible ? 25 : 0
                height: visible ? 25 : 0

                color: Theme.Tokens.color.bg
                Layout.alignment: Qt.AlignVCenter

                // Workspace indicator: dot for inactive, pill for focused/active
                Rectangle {
                    id: workspaceDot
                    anchors.centerIn: parent
                    width: (modelData.focused || modelData.active) ? 20 : 8
                    height: 8
                    radius: height / 2
                    color: workspaceColor(modelData, Theme.Tokens.color.textMuted)

                    Behavior on width { NumberAnimation { duration: Theme.Tokens.motion.fast } }
                    Behavior on color { ColorAnimation { duration: Theme.Tokens.motion.fast } }
                }

                // Clickable
                HoverScale {
                    anchors.fill: parent
                    target: workspaceDot
                    cursorShape: Qt.PointingHandCursor
                    onClicked: modelData.activate()
                }
            }
        }
    }
}
