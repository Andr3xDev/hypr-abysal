import Quickshell
import QtQuick
import QtQuick.Layouts
import "../../../core/theme" as Theme
import "../../../core/ipc" as Ipc

/*!
    Clock text to show current time & day of the week.
    Clicking it toggles the floating calendar panel via EventBus
*/
Item {
    id: clock
    implicitWidth: clockText.implicitWidth + Theme.Tokens.space.lg
    Layout.fillHeight: true

    // Tracks calendar open/close state via EventBus — no direct module coupling
    property bool _calendarOpen: false

    Connections {
        target: Ipc.EventBus
        function onCalendarVisibilityChanged(visible) {
            clock._calendarOpen = visible
        }
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: clock.updateTime()
    }

    function updateTime() {
        var now = new Date()
        var timeStr = Qt.formatDateTime(now, "hh:mm ap")
        var dateStr = Qt.formatDateTime(now, "dd - ddd")
        clockText.text = timeStr + "   |   " + dateStr
    }

    Text {
        id: clockText
        anchors.centerIn: parent
        font.bold:       true
        font.pixelSize:  Theme.Tokens.text.sm
        color: clock._calendarOpen
            ? Theme.Tokens.color.accent
            : Theme.Tokens.color.textPrimary

        Behavior on color { ColorAnimation { duration: Theme.Tokens.motion.fast } }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape:  Qt.PointingHandCursor
        onClicked:    Ipc.EventBus.calendarToggleRequested()
    }
}
