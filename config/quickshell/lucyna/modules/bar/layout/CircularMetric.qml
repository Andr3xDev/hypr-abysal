import QtQuick
import "../../../core/theme" as Theme

/*!
    Visual component to support metrics using a circle to represent percentages.
*/
Item {
    id: circularMetric
    width: size
    height: size

    // Base values
    property real value: 0
    property string icon: ""
    property real iconSize: Theme.Tokens.text.xs
    property real size: 24
    property real lineWidth: 2
    readonly property color effectiveColor: value >= 75 ? Theme.Tokens.severity("critical") : Theme.Tokens.hue.aquamarine.fill

    // Circle with progress
    Canvas {
        id: canvas
        anchors.fill: parent
        z: 0
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            // Position
            var centerX = width / 2
            var centerY = height / 2
            var radius = width / 2 - circularMetric.lineWidth

            // Background circle
            ctx.beginPath()
            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
            ctx.lineWidth = circularMetric.lineWidth
            ctx.strokeStyle = circularMetric.effectiveColor
            ctx.globalAlpha = 0.2
            ctx.stroke()

            // Progress arc
            if (circularMetric.value > 0) {
                ctx.beginPath()
                var startAngle = -Math.PI / 2
                var endAngle = startAngle + (circularMetric.value / 100) * 2 * Math.PI
                ctx.arc(centerX, centerY, radius, startAngle, endAngle)
                ctx.lineWidth = circularMetric.lineWidth
                ctx.strokeStyle = circularMetric.effectiveColor
                ctx.globalAlpha = 1
                ctx.stroke()
            }
        }

        Connections {
            target: circularMetric
            function onValueChanged() { canvas.requestPaint() }
            function onEffectiveColorChanged() { canvas.requestPaint() }
        }
    }

    // Icon
    Text {
        anchors.centerIn: parent
        text: circularMetric.icon
        color: circularMetric.effectiveColor
        font.pixelSize: circularMetric.iconSize
        font.family: Theme.Tokens.text.iconFont
        z: 1
    }
}
