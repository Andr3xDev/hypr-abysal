pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

/*!
    PanelService — single entry point for opening, closing, and toggling
    SlidePanel instances by name.

    Holds a name -> SlidePanel registry, populated by each SlidePanel's own
    Component.onCompleted/onDestruction (core/components/SlidePanel.qml).
    In-shell callers use PanelService.open()/.close()/.toggle() directly;
    an external caller (Hyprland keybind, `qs ipc call`) reaches the same
    functions through the single embedded IpcHandler, target "panel".

    Also enforces the default mutual-exclusion policy: opening a panel whose
    exclusive prop is true closes whatever other exclusive panel is
    currently open. exclusive: false panels opt out in both directions.

    Usage:
        Services.PanelService.toggle("launcher")
        qs ipc call <configName> panel toggle launcher
*/
Singleton {
    id: root

    property var _panels: ({})

    // currentPanelName is read-only from outside this file — set only by the opened/closed handlers below.
    property string currentPanelName: ""

    function register(name, instance) {
        if (root._panels[name] !== undefined) {
            console.warn("PanelService: panel name '" + name + "' already registered, overwriting")
            root.unregister(name)
        }

        const onOpened = function () {
            if (instance.exclusive)
                root.currentPanelName = name
        }
        const onClosed = function () {
            if (root.currentPanelName === name)
                root.currentPanelName = ""
        }

        instance.opened.connect(onOpened)
        instance.closed.connect(onClosed)
        root._panels[name] = { instance: instance, onOpened: onOpened, onClosed: onClosed }
    }

    function unregister(name) {
        const entry = root._panels[name]
        if (entry) {
            entry.instance.opened.disconnect(entry.onOpened)
            entry.instance.closed.disconnect(entry.onClosed)
        }

        delete root._panels[name]
    }

    function _getPanel(name, action) {
        const entry = root._panels[name]
        if (!entry)
            console.warn("PanelService: " + action + "() called for unregistered panel '" + name + "'")
        return entry ? entry.instance : undefined
    }

    function open(name) {
        const panel = root._getPanel(name, "open")
        if (!panel)
            return

        root._applyExclusion(name, panel)
        panel.show()
    }

    function close(name) {
        const panel = root._getPanel(name, "close")
        if (!panel)
            return

        panel.hide()
    }

    function toggle(name) {
        const panel = root._getPanel(name, "toggle")
        if (!panel)
            return

        if (!panel.active)
            root._applyExclusion(name, panel)
        panel.toggle()
    }

    // Closes the currently-open exclusive panel before a different exclusive
    // panel opens.
    function _applyExclusion(name, panel) {
        if (!panel.exclusive)
            return
        if (root.currentPanelName === "" || root.currentPanelName === name)
            return

        const currentEntry = root._panels[root.currentPanelName]
        if (currentEntry)
            currentEntry.instance.hide()
    }

    IpcHandler {
        target: "panel"

        function toggle(name: string): void { root.toggle(name) }
        function open(name: string): void { root.open(name) }
        function close(name: string): void { root.close(name) }
    }
}
