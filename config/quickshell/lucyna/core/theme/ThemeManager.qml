pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "./primitives" as Primitives

/*!
    ThemeManager — Singleton facade for the design token system.

    Single import point for all consumers. Manages the active theme,
    persists the selection to disk, and exposes the active palette's
    primitives via `p` for Tokens.qml to build the public token API on.
*/
QtObject {
    id: themeManager

    // ── Active theme ──────────────────────────────────────
    property string currentTheme: "abysal-obsidian"
    property string _pendingSaveJson: ""

    readonly property var availableThemes: [
        "abysal-obsidian"
    ]

    // ── Persistence ───────────────────────────────────────
    readonly property string _dataFilePath:
        Quickshell.shellDir + "/core/theme/data/theme.json"

    readonly property string _loadScript:
        "import sys,json,pathlib; p=pathlib.Path(sys.argv[1]); d={'theme':'abysal-obsidian'};\n" +
        "try:\n" +
        " s=p.read_text() if p.exists() else ''\n" +
        " if s.strip():\n" +
        "  raw=json.loads(s)\n" +
        "  d['theme']=raw.get('theme','abysal-obsidian')\n" +
        "except Exception:\n" +
        " pass\n" +
        "print(json.dumps(d))"

    readonly property string _saveScript:
        "import sys,os; p=sys.argv[1]; os.makedirs(os.path.dirname(p), exist_ok=True); open(p,'w').write(sys.argv[2])"

    property Process _loadProc: Process {
        running: false
        command: ["python3", "-c", themeManager._loadScript, themeManager._dataFilePath]
        stdout: SplitParser {
            onRead: data => themeManager._loadPersistedTheme(data)
        }
    }

    property Process _saveProc: Process {
        running: false
        onExited: {
            if (themeManager._pendingSaveJson.length > 0) {
                const nextJson = themeManager._pendingSaveJson
                themeManager._pendingSaveJson = ""
                themeManager._writePersistedTheme(nextJson)
            }
        }
    }

    Component.onCompleted: _loadFromDisk()

    function _loadFromDisk() {
        if (_loadProc.running) return
        _loadProc.running = true
    }

    function _loadPersistedTheme(text) {
        if (!text || !text.trim()) return
        try {
            const data = JSON.parse(text)
            const loaded = data.theme
            if (loaded && availableThemes.includes(loaded))
                currentTheme = loaded
        } catch (e) {}
    }

    function _writePersistedTheme(payloadJson) {
        if (_saveProc.running) {
            _pendingSaveJson = payloadJson
            return
        }
        _saveProc.command = ["python3", "-c", _saveScript, _dataFilePath, payloadJson]
        _saveProc.running = true
    }

    // ── Primitive resolution (layer 1 — new token system, additive) ───
    readonly property var _primitivePalettes: ({
        "abysal-obsidian": Primitives.Nerita
    })

    readonly property QtObject p: _primitivePalettes[currentTheme] ?? Primitives.Nerita

    // ── Public API ────────────────────────────────────────
    function setTheme(themeName) {
        if (!availableThemes.includes(themeName)) return false
        currentTheme = themeName
        _writePersistedTheme(JSON.stringify({ theme: themeName }))
        return true
    }

    function getThemeDisplayName(themeName) {
        const primitive = _primitivePalettes[themeName]
        return primitive ? primitive.name : themeName
    }

    // Preview swatch colors for a given theme id — used by ThemeList to
    // render a dot row per listed theme, not just the active one.
    function previewColors(themeName) {
        const primitive = _primitivePalettes[themeName] ?? Primitives.Nerita
        return [primitive.neutral.bg, primitive.hue.turquoise.fill, primitive.hue.aquamarine.fill]
    }
}
