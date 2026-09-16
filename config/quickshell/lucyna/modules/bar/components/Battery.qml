import QtQuick
import QtQuick.Layouts
import "../../../core/theme" as Theme
import "../../../core/services" as Services

/*!
    Battery indicator showing icon and charge percentage.
*/
RowLayout {
    id: root
    spacing: Theme.Tokens.space.xs

    readonly property color _statusColor: Services.BatteryService.isCritical()
        ? Theme.Tokens.color.danger
        : Theme.Tokens.color.textPrimary

    // Battery icon
    Text {
        Layout.alignment: Qt.AlignVCenter
        visible: Services.BatteryService.battery !== null
        text: Services.BatteryService.getBatteryIcon()
        color: root._statusColor
        font.pixelSize: Theme.Tokens.text.icon
        font.family: Theme.Tokens.text.iconFont

        // Animation for critical battery
        SequentialAnimation on color {
            running: Services.BatteryService.isCritical()
            loops: Animation.Infinite
            ColorAnimation { from: Theme.Tokens.color.danger; to: Theme.Tokens.color.textMuted; duration: 800 }
            ColorAnimation { from: Theme.Tokens.color.textMuted; to: Theme.Tokens.color.danger; duration: 800 }
        }
    }

    // Battery percentage
    Text {
        visible: !Services.BatteryService.shouldHideLevel()
        text: Services.BatteryService.battery
            ? Math.round(Services.BatteryService.batteryLevel) + "%"
            : "N/A"
        color: root._statusColor
        font.pixelSize: Theme.Tokens.text.sm
        font.bold: Services.BatteryService.isCritical()
    }
}
