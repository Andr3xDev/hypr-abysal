pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

/*!
    Temperature service gets info by Sensors and allow know real temps
*/
Singleton {
    id: root

    // Public properties
    property real cpuTemp: 0
    property real gpuTemp: 0
    property bool hasGPU: false

    // GPU detection process (runs once on startup)
    property Process _gpuDetector: Process {
        running: true
        command: ["sh", "-c", "nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null"]

        stdout: SplitParser {
            onRead: data => {
                root.hasGPU = data.trim().length > 0
            }
        }

        onExited: running = false
    }

    // Get CPU temperature
    property Process _cpuProcess: Process {
        running: false
        command: ["sh", "-c", "sensors coretemp-isa-0000 2>/dev/null | grep 'Package id 0' | grep -Eo '[0-9]+\\.[0-9]+' | head -n1"]

        stdout: SplitParser {
            onRead: data => {
                const temp = parseFloat(data.trim())
                if (!isNaN(temp) && temp > 0) {
                    root.cpuTemp = temp
                }
            }
        }
    }

    // Get GPU temperature
    property Process _gpuProcess: Process {
        running: false
        command: ["sh", "-c", "nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>/dev/null || echo 0"]

        stdout: SplitParser {
            onRead: data => {
                const temp = parseFloat(data.trim())
                if (!isNaN(temp)) {
                    root.gpuTemp = temp
                }
            }
        }
    }

    // Timer to update all temp information, balanced for gaming variability
    property Timer _pollTimer: Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            _cpuProcess.running = true
            _gpuProcess.running = true
        }
    }
}
