import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "services"
import "components"
import "../../core/ipc" as Ipc
import "../../core/components"

/*!
    MonitorManager — Mediator + PanelWindow.

    Single instantiation point for the monitor module. Wires services
    to child components; contains no layout and no business logic.

    Toggle via: qs ipc call monitorManager.handle
*/
PanelWindow {
    id: root

    // ── Layout constants ─────────────────────────────────
    readonly property int _panelW: 900
    readonly property int _panelH: 580

    // ── Internals ─────────────────────────────────────────
    property string _pendingProfileId: ""
    property bool   _startupDone:      false
    property string _selectedName:     ""
    property string _activeProfileId:  ""   // persists across open/close

    // ── Window setup ─────────────────────────────────────
    visible:                     false
    color:                       "transparent" // layer-shell root — must not paint, real panel bg is ManagerPanel
    WlrLayershell.layer:         WlrLayer.Overlay
    WlrLayershell.namespace:     "monitorManager"
    WlrLayershell.keyboardFocus: root.visible
                                     ? WlrKeyboardFocus.Exclusive
                                     : WlrKeyboardFocus.None
    exclusionMode:               ExclusionMode.Ignore

    anchors { top: true; bottom: true; left: true; right: true }

    // ── IPC entry (keybind / external) ───────────────────
    IpcHandler {
        target: "monitorManager"
        function handle() { root.toggle() }
    }

    // ── Service listeners ─────────────────────────────────
    Connections {
        target: MonitorService

        function onCommitted(ok, errorMessage) {
            if (ok) {
                root._pendingProfileId = ""
            } else {
                console.warn("MonitorManager: commit failed —", errorMessage)
            }
        }

        function onMonitorsChanged() { root._tryStartupApply() }
    }

    // Startup restore: fires when ProfileService finishes loading from disk.
    property Connections _profileConnections: Connections {
        target: ProfileService
        function onLoaded() { root._tryStartupApply() }
    }

    // ── Public API ────────────────────────────────────────
    function toggle() { visible ? close() : open() }

    function open() {
        root.visible = true
        MonitorService.refresh()
    }

    function close() {
        root.visible           = false
        root._pendingProfileId = ""
        root._selectedName     = ""
        panel.reset()
    }

    // ── Escape to close ───────────────────────────────────
    Shortcut {
        sequence:    "Escape"
        enabled:     root.visible
        onActivated: root.close()
    }

    // ── Dark overlay (click-outside closes) ──────────────
    DarkOverlay {
        onClicked: root.close()
    }

    // ── Panel ─────────────────────────────────────────────
    ManagerPanel {
        id: panel

        anchors.centerIn: parent
        width:  root._panelW
        height: root._panelH

        selectedName:    root._selectedName
        activeProfileId: root._activeProfileId

        onCloseRequested:      root.close()
        onApplyRequested:       MonitorService.commit()
        onSaveLayoutRequested:  ProfileService.updateFromCurrentState(root._activeProfileId)
        onMonitorSelected:     function(name)     { root._selectedName = name }
        onMonitorMoved:        function(name, pos) { MonitorService.applyEphemeral(name, { position: pos }) }
        onAliasChanged:        function(s, a)      { IdentityService.update(s, { alias: a }); MonitorService.refresh() }
        onModeChanged:         function(name, m)   { MonitorService.applyEphemeral(name, { mode: m }) }
        onMonitorScaleChanged: function(name, s)   { MonitorService.applyEphemeral(name, { scale: s }) }
        onTransformChanged:    function(name, t)   { MonitorService.applyEphemeral(name, { transform: t }) }
        onEnabledToggled:      function(name, e)   { MonitorService.applyEphemeral(name, { enabled: e }) }
        onPositionChanged:     function(name, pos) { MonitorService.applyEphemeral(name, { position: pos }) }
        onCmChanged:           function(name, cm)  { MonitorService.applyEphemeral(name, { cm: cm }) }

        onProfileSelected: function(id) {
            const profile = ProfileService.profiles.find(p => p.id === id)
            if (!profile) return
            root._applyProfileToMonitors(profile, MonitorService.monitors.filter(m => m.connected))
            ProfileService.setLastApplied(id)
            MonitorService.commit()
            root._pendingProfileId = id
            root._activeProfileId  = id
        }

        onSaveRequested:   function(name) { ProfileService.createFromCurrentState(name) }
        onDeleteRequested: function(id)   { ProfileService.remove(id) }
    }

    // ── Startup: restore last applied profile ─────────────
    function _tryStartupApply() {
        if (_startupDone) return
        if (MonitorService.monitors.length === 0) return      // monitors not ready yet

        const id = ProfileService.lastAppliedId
        if (!id) { _startupDone = true; return }              // nothing saved → done

        const profile = ProfileService.profiles.find(function(p) { return p.id === id })
        if (!profile) return                                   // profiles not loaded yet → wait

        _startupDone     = true
        _activeProfileId = id
        _pendingProfileId = id

        const connected = MonitorService.monitors.filter(m => m.connected)
        _applyProfileToMonitors(profile, connected)
        MonitorService.commit()
    }

    // ── Shared: map profile entries → applyEphemeral + alias update ─
    function _applyProfileToMonitors(profile, connected) {
        for (var i = 0; i < connected.length; i++) {
            const mon   = connected[i]
            const entry = profile.monitors.find(function(pm) { return pm.identitySerial === mon.serial })
            if (!entry) continue
            MonitorService.applyProfileEntry(mon.name, entry)
            if (entry.alias) IdentityService.update(mon.serial, { alias: entry.alias })
        }
    }

}
