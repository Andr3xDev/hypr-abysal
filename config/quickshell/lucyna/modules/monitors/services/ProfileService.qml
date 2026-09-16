pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../infra"

/*!
    ProfileService — Repository + Singleton.

    Pure CRUD over data/profiles.json. No matching logic (see ProfileMatcher).

    Public API:
      save(profile)                → upserts by id, persists
      remove(id)                   → deletes by id, persists
      createFromCurrentState(name) → snapshots MonitorService.monitors as a new profile
      setLastApplied(id)           → persists the last applied profile id

    Signals:
      loaded()   — emitted once the initial load from disk completes
*/
QtObject {
    id: root

    // ── Signals ───────────────────────────────────────────
    signal loaded()

    // ── State ─────────────────────────────────────────────
    property var    profiles:      []    // MonitorProfile[]
    property string lastAppliedId: ""   // persisted across restarts

    // ── Paths ─────────────────────────────────────────────
    readonly property string _dataFile:
        Quickshell.shellDir + "/modules/monitors/data/profiles.json"

    // ── Load script ───────────────────────────────────────
    readonly property string _loadScript: [
        "import sys, json, pathlib",
        "p = pathlib.Path(sys.argv[1])",
        "d = {'version': 1, 'lastAppliedId': '', 'profiles': []}",
        "try:",
        "    s = p.read_text() if p.exists() else ''",
        "    if s.strip(): d = json.loads(s)",
        "except Exception:",
        "    pass",
        "print(json.dumps(d))"
    ].join("\n")

    // ── I/O processes ─────────────────────────────────────
    property Process _loadProc: Process {
        running: false
        command: ["python3", "-c", root._loadScript, root._dataFile]
        stdout: SplitParser {
            onRead: function(line) { root._onLoaded(line) }
        }
    }

    property FileWriter _fileWriter: FileWriter {
        onWriteCompleted: function(ok, errorMessage) {
            if (!ok) console.warn("ProfileService: failed to persist profiles.json —", errorMessage)
        }
    }

    // ── Lifecycle ─────────────────────────────────────────
    Component.onCompleted: {
        _loadProc.running = true
    }

    // ── Private ───────────────────────────────────────────
    function _onLoaded(text) {
        if (text && text.trim()) {
            try {
                const data  = JSON.parse(text)
                profiles      = data.profiles      || []
                lastAppliedId = data.lastAppliedId || ""
            } catch (e) {
                console.warn("ProfileService: failed to parse profiles.json:", e)
            }
        }
        loaded()
    }

    function _persist() {
        _fileWriter.write(
            _dataFile,
            JSON.stringify({ version: 1, lastAppliedId: lastAppliedId, profiles: profiles }, null, 2)
        )
    }

    function _generateId() {
        return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, function(c) {
            const r = Math.random() * 16 | 0
            return (c === "x" ? r : (r & 0x3 | 0x8)).toString(16)
        })
    }

    // ── Public API ────────────────────────────────────────
    function save(profile) {
        const idx = profiles.findIndex(p => p.id === profile.id)
        if (idx >= 0) {
            const updated = profiles.slice()
            updated[idx]  = profile
            profiles      = updated
        } else {
            profiles = profiles.concat([profile])
        }
        _persist()
    }

    function remove(id) {
        profiles = profiles.filter(p => p.id !== id)
        if (lastAppliedId === id) lastAppliedId = ""
        _persist()
    }

    function setLastApplied(id) {
        lastAppliedId = id
        _persist()
    }

    /*!
        Updates an existing profile's monitor entries with the current
        MonitorService state, keeping its id, name and description intact.
        Called when the user applies changes while a profile is active.
    */
    function updateFromCurrentState(id) {
        const existing = profiles.find(function(p) { return p.id === id })
        if (!existing) return

        const connected = MonitorService.monitors.filter(m => m.connected)
        const updated   = Object.assign({}, existing, {
            trigger: {
                require: connected.map(m => m.serial),
                absent:  []
            },
            monitors: connected.map(m => ({
                identitySerial: m.serial,
                alias:          m.identity ? m.identity.alias : m.name,
                mode:           `${m.activeMode.width}x${m.activeMode.height}@${m.activeMode.refreshRate}`,
                position:       `${m.position.x}x${m.position.y}`,
                scale:          m.scale,
                transform:      m.transform,
                enabled:        m.enabled,
                cm:             m.cm || "srgb",
            }))
        })
        save(updated)
    }

    function createFromCurrentState(name) {
        const connected = MonitorService.monitors.filter(m => m.connected)

        const profile = {
            id:          _generateId(),
            name:        name,
            description: "",
            autoApply:   false,
            trigger: {
                require: connected.map(m => m.serial),
                absent:  []
            },
            monitors: connected.map(m => ({
                identitySerial: m.serial,
                alias:          m.identity ? m.identity.alias : m.name,
                mode:           `${m.activeMode.width}x${m.activeMode.height}@${m.activeMode.refreshRate}`,
                position:       `${m.position.x}x${m.position.y}`,
                scale:          m.scale,
                transform:      m.transform,
                enabled:        m.enabled,
                cm:             m.cm || "srgb",
            }))
        }

        save(profile)
        return profile
    }
}
