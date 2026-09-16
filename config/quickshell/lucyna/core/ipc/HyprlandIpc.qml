pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io

/*!
    HyprlandIpc — Facade for all Hyprland compositor communication.

    Single point of contact with hyprctl. If Hyprland changes its API,
    only this file changes. Exposes domain-semantic methods, never raw
    dispatcher strings.
*/
Singleton {
    id: root

    // Fire-and-forget dispatcher — for commands that produce no output.
    property Component _dispatch: Component {
        Process { onExited: destroy() }
    }

    // Query dispatcher — accumulates stdout, parses JSON, calls callback.
    property Component _query: Component {
        Process {
            id: proc
            property var _callback: null
            property string _buffer: ""

            stdout: SplitParser {
                // Use id reference — parent is not defined for property-assigned objects.
                onRead: function(line) { proc._buffer += line + "\n" }
            }

            onExited: {
                let result = []
                try {
                    result = JSON.parse(proc._buffer)
                } catch (e) {
                    console.warn("HyprlandIpc: JSON parse failed:", e)
                }
                if (proc._callback) proc._callback(result)
                proc.destroy()
            }
        }
    }

    // ── System ────────────────────────────────────────────

    function reload() {
        _dispatch.createObject(root, {
            running: true,
            command: ["hyprctl", "reload"]
        })
    }

    function setKeyword(key, value) {
        _dispatch.createObject(root, {
            running: true,
            command: ["hyprctl", "keyword", key, value]
        })
    }

    // ── Monitors ──────────────────────────────────────────

    // Hyprland socket2 event name constants — owned here, used only here.
    readonly property var _monitorEvents: Object.freeze({
        added:   "monitoradded",
        removed: "monitorremoved"
    })

    /*!
        Queries all monitors (including disconnected) and delivers the raw
        JSON array to callback. Transformation to MonitorState happens in
        MonitorAdapter, not here.
    */
    function getMonitors(callback) {
        _query.createObject(root, {
            command: ["hyprctl", "-j", "monitors", "all"],
            _callback: callback,
            running: true
        })
    }

    // Socket2 listener: monitor plug/unplug events → EventBus signals.
    // Quickshell 0.3.0 API: Hyprland.rawEvent(HyprlandEvent event)
    Connections {
        target: Hyprland
        function onRawEvent(event) {
            if (event.name === root._monitorEvents.added)   EventBus.monitorConnected(event.data)
            if (event.name === root._monitorEvents.removed) EventBus.monitorDisconnected(event.data)
        }
    }
}
