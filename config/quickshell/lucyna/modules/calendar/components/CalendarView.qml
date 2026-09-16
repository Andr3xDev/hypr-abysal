import "." as Local
import "../../../core/theme" as Theme
import QtQuick
import QtQuick.Layouts

/*!
    Monthly calendar grid with header navigation, weekday labels, and a stable
    6 × 7 day grid. Today and holidays are colour-coded.
*/
Item {
    id: root

    // State
    property int displayMonth: _todayMonth
    property int displayYear: _todayYear
    // Layout constants
    readonly property int _cellSize: 34
    readonly property int _cellGap: 4
    readonly property int _headerH: 36
    readonly property int _weekdayH: 20
    readonly property int _pad: 12
    // Today
    property var _today: new Date()
    readonly property int _todayDay:   _today.getDate()
    readonly property int _todayMonth: _today.getMonth() + 1
    readonly property int _todayYear:  _today.getFullYear()
    readonly property color _todayColor: Theme.Tokens.color.accentSurface
    // Static data
    readonly property var _monthNames: ["January","February","March","April","May","June","July","August","September","October","November","December"]
    readonly property var _weekLabels: ["Su","Mo","Tu","We","Th","Fr","Sa"]

    readonly property var cells: {
        const y = displayYear, m = displayMonth;
        const firstDow   = new Date(y, m - 1, 1).getDay();
        const daysInMonth = new Date(y, m, 0).getDate();
        const prevDays   = new Date(y, m - 1, 0).getDate();
        const prevM = m === 1 ? 12 : m - 1;
        const prevY = m === 1 ? y - 1 : y;
        const nextM = m === 12 ? 1 : m + 1;
        const nextY = m === 12 ? y + 1 : y;
        const out = [];
        for (let i = 0; i < 42; i++) {
            const off = i - firstDow;
            let day, cm, cy;
            if (off < 0) {
                day = prevDays + off + 1; cm = prevM; cy = prevY;
            } else if (off < daysInMonth) {
                day = off + 1; cm = m; cy = y;
            } else {
                day = off - daysInMonth + 1; cm = nextM; cy = nextY;
            }
            const cur = off >= 0 && off < daysInMonth;
            out.push({
                "day": day, "month": cm, "year": cy,
                "isCurrentMonth": cur,
                "isToday": cur && day === _todayDay && cm === _todayMonth && cy === _todayYear,
                "isSunday": (i % 7) === 0,
                "isHoliday": cur && Local.HolidayProvider.isHoliday(cy, cm, day)
            });
        }
        return out;
    }

    function _prevMonth() {
        if (displayMonth === 1) { displayYear--;  displayMonth = 12; }
        else                    { displayMonth--; }
    }

    function _nextMonth() {
        if (displayMonth === 12) { displayYear++; displayMonth = 1; }
        else                     { displayMonth++; }
    }

    function _goToday() {
        displayMonth = _todayMonth;
        displayYear  = _todayYear;
    }

    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: root._today = new Date()
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: root._pad
        spacing: 6

        // Header
        RowLayout {
            Layout.fillWidth: true
            Layout.bottomMargin: 3
            implicitHeight: root._headerH
            spacing: Theme.Tokens.space.xs

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft
                leftPadding: 5
                text: root._monthNames[root.displayMonth - 1] + "  " + root.displayYear
                color: Theme.Tokens.color.textPrimary
                font.pixelSize: Theme.Tokens.text.md
                font.bold: true
            }

            NavButton { label: "Today"; labelColor: Theme.Tokens.color.accent; labelSize: Theme.Tokens.text.xs; onActivated: root._goToday() }
            NavButton { implicitWidth: 26; label: "‹"; onActivated: root._prevMonth() }
            NavButton { implicitWidth: 26; label: "›"; onActivated: root._nextMonth() }
        }

        // Weekday labels
        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: root._cellGap

            Repeater {
                model: root._weekLabels

                Text {
                    width: root._cellSize
                    height: root._weekdayH
                    text: modelData
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: Theme.Tokens.color.textMuted
                    font.pixelSize: Theme.Tokens.text.xs
                    font.bold: true
                }
            }
        }

        // Day grid
        Grid {
            Layout.alignment: Qt.AlignHCenter
            columns: 7
            rowSpacing: root._cellGap
            columnSpacing: root._cellGap

            Repeater {
                model: root.cells

                Item {
                    width: root._cellSize
                    height: root._cellSize

                    Rectangle {
                        anchors.centerIn: parent
                        width: root._cellSize - 4
                        height: root._cellSize - 4
                        radius: (root._cellSize - 4) / 2
                        color: modelData.isToday ? root._todayColor : Theme.Tokens.color.bg
                    }

                    Text {
                        anchors.centerIn: parent
                        text: modelData.day
                        font.pixelSize: Theme.Tokens.text.sm
                        font.bold: modelData.isToday
                        color: !modelData.isCurrentMonth
                            ? Theme.Tokens.color.textMuted
                            : (modelData.isToday || modelData.isSunday || modelData.isHoliday)
                                ? Theme.Tokens.color.accent
                                : Theme.Tokens.color.textPrimary
                    }
                }
            }
        }
    }

    // NavButton inline component
    component NavButton: Rectangle {
        id: btn

        property alias label: lbl.text
        property alias labelColor: lbl.color
        property alias labelSize: lbl.font.pixelSize

        signal activated()

        implicitWidth: lbl.implicitWidth + Theme.Tokens.space.md
        implicitHeight: 26
        radius: Theme.Tokens.radius.md
        color: ma.containsMouse ? Theme.Tokens.color.bgHover : Theme.Tokens.color.bg

        Text {
            id: lbl
            anchors.centerIn: parent
            color: Theme.Tokens.color.textPrimary
            font.pixelSize: Theme.Tokens.text.md
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: btn.activated()
        }

        Behavior on color { ColorAnimation { duration: Theme.Tokens.motion.fast } }
    }
}
