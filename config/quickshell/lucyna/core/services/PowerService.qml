pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

/*!
    Power profile service manages power profiles via powerprofilesctl
*/
Singleton {
    id: root

    // Public properties
    property string currentProfile: "balanced"

    // All possible profiles
    readonly property var profiles: [
        { id: "power-saver",  icon: "󰾆", name: "Power Saver" },
        { id: "balanced",     icon: "󰾅", name: "Balanced" },
        { id: "performance",  icon: "󰓅", name: "Performance" }
    ]

    property Process _profileReader: Process {
        running: false
        command: ["powerprofilesctl", "get"]

        stdout: SplitParser {
            onRead: data => {
                const newProfile = data.trim()
                if (newProfile && newProfile !== root.currentProfile) {
                    root.currentProfile = newProfile
                }
            }
        }
    }

    property Process _profileSetter: Process {
        running: false
        onExited: root._profileReader.running = true
    }

    property Timer _pollTimer: Timer {
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root._profileReader.running = true
    }

    /*!
        Set power profile
    */
    function setProfile(profile) {
        if (profile === currentProfile) return

        _profileSetter.command = ["powerprofilesctl", "set", profile]
        _profileSetter.running = true
        currentProfile = profile
    }
}
