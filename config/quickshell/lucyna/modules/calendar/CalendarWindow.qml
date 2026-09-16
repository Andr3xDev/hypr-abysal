import "../../core/ipc" as Ipc
import "../../core/theme" as Theme
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "state"
import "components"

/*!
    Floating calendar panel anchored below the bar.
    Toggled via EventBus (clock click), IpcHandler (external keybind),
    Escape key, or click outside.
*/
PanelWindow {
    id: root

    readonly property int _panelW: 330
    readonly property int _panelH: 310
    // Bar implicitHeight (32) + top margin (4) + bottom margin (4)
    readonly property int _barOffset: 40

    visible: CalendarState.isVisible
    color: "transparent" // layer-shell root — must not paint, real panel bg is the Rectangle below
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "calendar"
    WlrLayershell.keyboardFocus: root.visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    // Notify the bar (Clock) whenever the real open state changes
    Connections {
        target: CalendarState
        function onIsVisibleChanged() { Ipc.EventBus.calendarVisibilityChanged(CalendarState.isVisible) }
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // Listen for toggle requests from other modules (e.g. Clock via EventBus)
    Connections {
        target: Ipc.EventBus
        function onCalendarToggleRequested() { CalendarState.toggle() }
    }

    // Direct IPC keybind (Hyprland / external)
    IpcHandler {
        function handle() { CalendarState.toggle(); }
        target: "toggleCalendar"
    }

    Shortcut {
        sequence: "Escape"
        enabled: root.visible
        onActivated: CalendarState.isVisible = false
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.visible
        z: 0
        onClicked: CalendarState.isVisible = false
    }

    Rectangle {
        id: card

        width: root._panelW
        height: root._panelH
        anchors.top: parent.top
        anchors.topMargin: root._barOffset
        anchors.horizontalCenter: parent.horizontalCenter
        z: 1
        opacity: root.visible ? 1 : 0
        scale: root.visible ? 1 : 0.97
        radius: Theme.Tokens.radius.md
        border.width: 1
        border.color: Theme.Tokens.color.borderStrong
        color: Theme.Tokens.color.bg

        Behavior on opacity {
            NumberAnimation { duration: Theme.Tokens.motion.fast; easing.type: Theme.Tokens.motion.ease }
        }
        Behavior on scale {
            NumberAnimation { duration: Theme.Tokens.motion.fast; easing.type: Theme.Tokens.motion.ease }
        }

        MouseArea { anchors.fill: parent }

        CalendarView {
            anchors.fill: parent
        }
    }
}
