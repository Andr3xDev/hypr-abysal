import QtQuick
import QtQuick.Controls
import "../../../core/theme" as Theme
import "../../../core/components"

/*!
    MonitorCard — Configuration panel for the selected monitor.

    All controls disabled when monitor is disconnected (connected: false).

    Signals:
      aliasChanged(serial, alias)
      modeChanged(name, mode)             — mode: { width, height, refreshRate }
      monitorScaleChanged(name, scale)
      transformChanged(name, transform)
      enabledToggled(name, enabled)
      positionChanged(name, position)     — position: { x, y }
*/
Item {
    id: root

    property var monitor: null   // MonitorState | null

    signal aliasChanged(string serial, string alias)
    signal modeChanged(string name, var mode)
    signal monitorScaleChanged(string name, real scale)
    signal transformChanged(string name, int transform)
    signal enabledToggled(string name, bool enabled)
    signal positionChanged(string name, var position)
    signal cmChanged(string name, string cm)

    readonly property bool _active: monitor !== null && monitor.connected

    // Valid scales: only values where W/scale and H/scale are both integers.
    // Recomputes reactively when the monitor or its active mode changes.
    readonly property var _allowedScales: {
        const candidates = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.25, 2.5, 2.75, 3.0]
        if (!root.monitor || !root.monitor.activeMode) return [1.0]
        const w = root.monitor.activeMode.width
        const h = root.monitor.activeMode.height
        const valid = candidates.filter(function(s) {
            const lw = w / s
            const lh = h / s
            return Math.abs(lw - Math.round(lw)) < 0.001 &&
                   Math.abs(lh - Math.round(lh)) < 0.001
        })
        return valid.length > 0 ? valid : [1.0]
    }

    function _scaleIndex(scale) {
        let best = 0
        let bestDist = Math.abs(_allowedScales[0] - scale)
        for (let i = 1; i < _allowedScales.length; i++) {
            const d = Math.abs(_allowedScales[i] - scale)
            if (d < bestDist) { bestDist = d; best = i }
        }
        return best
    }

    // Click on any non-interactive area removes focus from text fields.
    MouseArea {
        anchors.fill: parent
        z:            -1
        onClicked:    root.forceActiveFocus()
    }

    // Height driven by content; falls back to a minimum when empty.
    implicitHeight: root.monitor !== null ? _mainCol.implicitHeight + 28 : 60

    // Empty state
    QsText {
        anchors.centerIn: parent
        visible:          root.monitor === null
        text:             "Select a monitor"
        role:             "body"
        muted:            true
    }

    Column {
        id: _mainCol
        anchors { top: parent.top; left: parent.left; right: parent.right; margins: 14 }
        spacing:  Theme.Tokens.space.sm
        visible:  root.monitor !== null

        // ── Header ────────────────────────────────────────
        Row {
            width:   parent.width
            spacing: Theme.Tokens.space.sm

            QsText {
                id:        _headerTitle
                text:      root.monitor ? (root.monitor.identity ? root.monitor.identity.alias : root.monitor.name) : ""
                role:      "title"
                font.bold: true
            }

            QsText {
                text:             root.monitor ? root.monitor.name : ""
                role:             "caption"
                muted:            true
                anchors.baseline: _headerTitle.baseline
            }
        }

        Rectangle {
            width:  parent.width
            height: 1
            color:  Theme.Tokens.color.bgElevated
        }

        // ── Alias ─────────────────────────────────────────
        LabelRow {
            label: "Alias"
            StyledTextField {
                id:              aliasField
                width:           parent.width - 90
                enabled:         root._active
                placeholderText: "Monitor alias"
                displayValue:    root.monitor && root.monitor.identity ? root.monitor.identity.alias : ""

                onEditingFinished: {
                    const trimmed = text.trim()
                    if (trimmed.length > 0 && root.monitor && root.monitor.serial)
                        root.aliasChanged(root.monitor.serial, trimmed)
                }
            }
        }

        // ── Mode ──────────────────────────────────────────
        LabelRow {
            label: "Mode"
            QsComboBox {
                id:      modeBox
                width:   parent.width - 90
                enabled: root._active

                model: root.monitor
                    ? root.monitor.availableModes.map(
                          m => `${m.width}×${m.height} @ ${Math.round(m.refreshRate)} Hz`)
                    : []

                currentIndex: root.monitor
                    ? root.monitor.availableModes.findIndex(m =>
                          m.width === root.monitor.activeMode.width &&
                          m.height === root.monitor.activeMode.height &&
                          Math.abs(m.refreshRate - root.monitor.activeMode.refreshRate) < 0.5)
                    : 0

                onActivated: {
                    if (root.monitor)
                        root.modeChanged(root.monitor.name, root.monitor.availableModes[currentIndex])
                }
            }
        }

        // ── Color Management ──────────────────────────────
        LabelRow {
            label: "Color"

            readonly property var _cmValues: ["auto","srgb","dcip3","dp3","adobe","wide","edid","hdr","hdredid"]
            readonly property var _cmLabels: ["Auto","sRGB","DCI-P3","Display P3","Adobe RGB","Wide (BT2020)","EDID","HDR (PQ)","HDR + EDID"]

            QsComboBox {
                id:      cmBox
                width:   parent.width - 90
                enabled: root._active

                model:        parent._cmLabels
                currentIndex: {
                    const v = root.monitor ? (root.monitor.cm || "srgb") : "srgb"
                    const i = parent._cmValues.indexOf(v)
                    return i >= 0 ? i : 1
                }

                onActivated: {
                    if (root.monitor)
                        root.cmChanged(root.monitor.name, parent._cmValues[currentIndex])
                }
            }
        }

        // ── Scale ─────────────────────────────────────────
        LabelRow {
            label: "Scale"
            Row {
                spacing: Theme.Tokens.space.xs
                enabled: root._active

                QsButton {
                    label: "−"
                    onClicked: {
                        if (!root.monitor) return
                        const idx = root._scaleIndex(root.monitor.scale)
                        root.monitorScaleChanged(root.monitor.name,
                            root._allowedScales[Math.max(0, idx - 1)])
                    }
                }

                StyledTextField {
                    id:               scaleField
                    width:            52
                    height:           28
                    horizontalAlignment: TextInput.AlignHCenter
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    displayValue:     root.monitor ? root.monitor.scale.toFixed(2) : "1.00"

                    // Restore if out of valid range on blur (base handles empty case).
                    onActiveFocusChanged: {
                        if (!activeFocus) {
                            const v = parseFloat(text)
                            if (isNaN(v) || v < 0.1 || v > 4.0) text = displayValue
                        }
                    }

                    onEditingFinished: {
                        const v = parseFloat(text)
                        if (!isNaN(v) && v >= 0.1 && v <= 4.0 && root.monitor)
                            root.monitorScaleChanged(root.monitor.name, v)
                    }
                    Keys.onReturnPressed: scaleField.focus = false
                    Keys.onUpPressed: {
                        if (!root.monitor) return
                        const next = root._allowedScales[Math.min(root._allowedScales.length - 1,
                                         root._scaleIndex(root.monitor.scale) + 1)]
                        root.monitorScaleChanged(root.monitor.name, next)
                        scaleField.text = next.toFixed(2)
                        event.accepted  = true
                    }
                    Keys.onDownPressed: {
                        if (!root.monitor) return
                        const next = root._allowedScales[Math.max(0,
                                         root._scaleIndex(root.monitor.scale) - 1)]
                        root.monitorScaleChanged(root.monitor.name, next)
                        scaleField.text = next.toFixed(2)
                        event.accepted  = true
                    }
                }

                QsButton {
                    label: "+"
                    onClicked: {
                        if (!root.monitor) return
                        const idx = root._scaleIndex(root.monitor.scale)
                        root.monitorScaleChanged(root.monitor.name,
                            root._allowedScales[Math.min(root._allowedScales.length - 1, idx + 1)])
                    }
                }
            }
        }

        // ── Transform ─────────────────────────────────────
        LabelRow {
            label: "Rotation"
            Row {
                spacing: Theme.Tokens.space.xs
                enabled: root._active
                Repeater {
                    model: [{ label: "0°", value: 0 }, { label: "90°", value: 1 },
                            { label: "180°", value: 2 }, { label: "270°", value: 3 }]
                    Rectangle {
                        property bool isActive: root.monitor && root.monitor.transform === modelData.value
                        width:        36
                        height:       24
                        radius:       Theme.Tokens.radius.md
                        color:        isActive
                                          ? Theme.Tokens.color.accent
                                          : Theme.Tokens.color.bgElevated
                        border.width: 1
                        border.color: isActive
                                          ? Theme.Tokens.color.accent
                                          : Theme.Tokens.color.border

                        Behavior on color { ColorAnimation { duration: Theme.Tokens.motion.fast } }

                        QsText {
                            anchors.centerIn: parent
                            text:  modelData.label
                            role:  "caption"
                            color: parent.isActive
                                       ? Theme.Tokens.color.bg
                                       : Theme.Tokens.color.textPrimary
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape:  Qt.PointingHandCursor
                            onClicked: {
                                if (root.monitor && root._active)
                                    root.transformChanged(root.monitor.name, modelData.value)
                            }
                        }
                    }
                }
            }
        }

        // ── Enabled ───────────────────────────────────────
        LabelRow {
            label: "Enabled"
            QsToggle {
                checked: root.monitor ? root.monitor.enabled : false
                active:  root._active
                onToggled: function(v) {
                    if (root.monitor) root.enabledToggled(root.monitor.name, v)
                }
            }
        }

        // ── Position ──────────────────────────────────────
        LabelRow {
            label: "Position"
            Row {
                spacing: Theme.Tokens.space.xs
                enabled: root._active

                StyledTextField {
                    id:               posXField
                    width:            72
                    height:           32
                    placeholderText:  "X"
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    displayValue:     root.monitor ? root.monitor.position.x.toString() : "0"

                    onEditingFinished: {
                        const x = parseInt(text)
                        const y = parseInt(posYField.text)
                        if (!isNaN(x) && !isNaN(y) && root.monitor)
                            root.positionChanged(root.monitor.name, { x: x, y: y })
                    }
                    Keys.onReturnPressed: posXField.focus = false
                }

                QsText {
                    text:  "/"
                    role:  "caption"
                    muted: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledTextField {
                    id:               posYField
                    width:            72
                    height:           32
                    placeholderText:  "Y"
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    displayValue:     root.monitor ? root.monitor.position.y.toString() : "0"

                    onEditingFinished: {
                        const x = parseInt(posXField.text)
                        const y = parseInt(text)
                        if (!isNaN(x) && !isNaN(y) && root.monitor)
                            root.positionChanged(root.monitor.name, { x: x, y: y })
                    }
                    Keys.onReturnPressed: posYField.focus = false
                }
            }
        }
    }

    // ── Private sub-components ────────────────────────────

    component LabelRow: Row {
        property string label: ""
        width:   parent ? parent.width : 0
        spacing: 10
        QsText {
            width:  80
            text:   label
            role:   "body"
            muted:  true
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    component StyledTextField: TextField {
        // Source-of-truth value. Text syncs from here when not focused;
        // restores to here on blur if left empty.
        property string displayValue: ""

        Component.onCompleted:      text = displayValue
        onDisplayValueChanged:      if (!activeFocus) text = displayValue

        onActiveFocusChanged: {
            if (activeFocus) {
                deselect()
            } else {
                if (text.trim() === "") text = displayValue
            }
        }

        color:                Theme.Tokens.color.textPrimary
        font.pixelSize:       Theme.Tokens.text.md
        placeholderTextColor: Theme.Tokens.color.textMuted

        background: Rectangle {
            color:        Theme.Tokens.color.bgElevated
            radius:       Theme.Tokens.radius.lg
            border.width: 1
            border.color: parent.activeFocus
                              ? Theme.Tokens.color.accent
                              : Theme.Tokens.color.border
        }
    }

    /*!
        QsToggle — Rounded pill toggle switch using ThemeManager tokens.

        Properties:
          checked  bool    — current on/off state
          active   bool    — whether the control is interactive

        Signal:
          toggled(bool newValue)
    */
    component QsToggle: Item {
        id: toggle

        property bool checked: false
        property bool active:  true

        signal toggled(bool newValue)

        implicitWidth:  36
        implicitHeight: 20

        Rectangle {
            id: _track
            anchors.fill: parent
            radius:       height / 2
            color:        !toggle.active
                              ? Theme.Tokens.color.bgElevated
                              : toggle.checked
                                  ? Theme.Tokens.color.accent
                                  : Theme.Tokens.color.border

            Behavior on color { ColorAnimation { duration: Theme.Tokens.motion.fast } }

            Rectangle {
                id:     _thumb
                width:  height
                height: _track.height - 4
                radius: height / 2
                anchors.verticalCenter: _track.verticalCenter
                x:     toggle.checked ? _track.width - width - 2 : 2
                color: (toggle.active && toggle.checked)
                           ? Theme.Tokens.color.bg
                           : Theme.Tokens.color.textMuted

                Behavior on x     { NumberAnimation { duration: Theme.Tokens.motion.fast; easing.type: Theme.Tokens.motion.easeOut } }
                Behavior on color { ColorAnimation  { duration: Theme.Tokens.motion.fast } }
            }
        }

        MouseArea {
            anchors.fill: parent
            enabled:      toggle.active
            cursorShape:  Qt.PointingHandCursor
            onClicked:    toggle.toggled(!toggle.checked)
        }
    }
}
