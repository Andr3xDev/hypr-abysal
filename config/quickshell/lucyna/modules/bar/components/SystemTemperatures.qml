import QtQuick
import QtQuick.Layouts
import "../../../core/theme" as Theme
import "../../../core/services" as Services
import "../../../core/components"

/*!
    Group of indicators to know the status of the temp in PC's components
*/
ExpandableRow {
    id: root

    /*!
        Return color to indicate warning levels
    */
    function getTempColor(temp) {
        if (temp >= 80) return Theme.Tokens.severity("critical")
        if (temp >= 70) return Theme.Tokens.severity("warn")
        return Theme.Tokens.hue.aquamarine.fill
    }
    
    RowLayout {
        id: tempsRow
        anchors.centerIn: parent
        spacing: 10  // raw literal: a spacing token here caused a layout shift
        opacity: root.expanded ? 1 : 0
        
        Behavior on opacity {
            NumberAnimation { duration: Theme.Tokens.motion.standard }
        }
        
        // CPU Temperature
        RowLayout {
            visible: Services.TemperatureService.cpuTemp > 0
            spacing: Theme.Tokens.space.xs
            
            Text {
                text: "󰍛"
                color: root.getTempColor(Services.TemperatureService.cpuTemp)
                font.pixelSize: Theme.Tokens.text.icon
                font.family: Theme.Tokens.text.iconFont
            }
            
            Text {
                text: `${Math.round(Services.TemperatureService.cpuTemp)}°`
                color: Theme.Tokens.color.textPrimary
                font.pixelSize: Theme.Tokens.text.sm
            }
        }
        
        // GPU Temperature
        RowLayout {
            visible: Services.TemperatureService.hasGPU
            spacing: Theme.Tokens.space.xs
            
            Text {
                text: "󰾲"
                color: root.getTempColor(Services.TemperatureService.gpuTemp)
                font.pixelSize: Theme.Tokens.text.icon
                font.family: Theme.Tokens.text.iconFont
            }
            
            Text {
                text: `${Math.round(Services.TemperatureService.gpuTemp)}°`
                color: Theme.Tokens.color.textPrimary
                font.pixelSize: Theme.Tokens.text.sm
            }
        }
    }
}