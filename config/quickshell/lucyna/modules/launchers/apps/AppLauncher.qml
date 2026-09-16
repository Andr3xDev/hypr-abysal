import "../../../core/components"
import "../../../core/services" as Services
import "../../../core/theme" as Theme
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import "state"

/*!
    Full-screen app launcher overlay. Shows most-used apps by default
    and filters in real time as the user types.
*/
PanelWindow {
    id: root

    // ── Layout constants ─────────────────────────────────
    readonly property int itemCount: 3
    readonly property int itemHeight: 48
    readonly property int searchH: 44
    readonly property int pad: Theme.Tokens.space.md
    readonly property int cardW: 380
    readonly property int cardH: searchH + (itemHeight * itemCount) + (pad * 3) + 8

    // ── Public API ───────────────────────────────────────
    function toggle() {
        if (root.visible) close();
        else open();
    }

    function open() {
        root.screen = Services.ScreenService.focusedScreen();
        AppLauncherState.query = "";
        root.visible = true;
    }

    function close() {
        AppLauncherState.query = "";
        root.visible = false;
        searchInput.clear();
    }

    // ── Visibility ───────────────────────────────────────
    color: "transparent" // layer-shell root — must not paint, real card bg is the Rectangle below
    visible: false
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "appLauncher"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore
    onVisibleChanged: {
        if (visible) {
            searchInput.forceActiveFocus();
        }
    }

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // ── IPC — external keybind (Hyprland) ────────────────
    IpcHandler {
        function handle() {
            root.toggle();
        }

        target: "toggleLauncher"
    }

    // ── Background overlay ───────────────────────────────
    DarkOverlay {
        visible: root.visible
        onClicked: root.close()
    }

    // ── Card ─────────────────────────────────────────────
    Rectangle {
        id: card

        width: root.cardW
        height: root.cardH
        anchors.centerIn: parent
        color: Theme.Tokens.color.bg
        radius: Theme.Tokens.radius.md
        border.width: 1
        border.color: Theme.Tokens.color.border
        opacity: root.visible ? 1 : 0
        scale: root.visible ? 1 : 0.97

        MouseArea {
            anchors.fill: parent
        }

        Column {
            spacing: Theme.Tokens.space.sm

            anchors {
                fill: parent
                margins: root.pad
            }

            // Search field
            TextField {
                id: searchInput

                width: parent.width
                height: root.searchH
                placeholderText: "Only Binary..."
                placeholderTextColor: Theme.Tokens.color.textMuted
                color: Theme.Tokens.color.textPrimary
                font.pixelSize: Theme.Tokens.text.lg
                font.letterSpacing: 0.3
                leftPadding: 34
                rightPadding: root.pad
                topPadding: 10
                bottomPadding: 10
                onTextChanged: AppLauncherState.query = text
                Keys.onEscapePressed: root.close()
                Keys.onDownPressed: appList.incrementCurrentIndex()
                Keys.onUpPressed: appList.decrementCurrentIndex()
                Keys.onReturnPressed: appList.launchCurrent()

                background: Rectangle {
                    color: Theme.Tokens.color.bgElevated
                    radius: Theme.Tokens.radius.lg
                    border.width: 1
                    border.color: searchInput.activeFocus ? Theme.Tokens.color.accent : Theme.Tokens.color.border

                    Text {
                        text: " 󰍉 "
                        font.family: Theme.Tokens.text.iconFont
                        font.pixelSize: Theme.Tokens.text.xl
                        color: Theme.Tokens.color.accent

                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: 10
                        }
                    }
                }
            }

            // App list
            ListView {
                id: appList

                function launchCurrent() {
                    if (currentItem) {
                        const entry = currentItem.entry;
                        root.close();
                        AppLauncherState.launch(entry);
                    }
                }

                width: parent.width
                height: root.itemHeight * root.itemCount
                clip: true
                model: root.visible ? AppLauncherState.filteredApps : null
                currentIndex: 0
                keyNavigationWraps: true
                highlightRangeMode: ListView.ApplyRange
                preferredHighlightBegin: 0
                preferredHighlightEnd: height
                highlightMoveDuration: 100
                onModelChanged: {
                    currentIndex = 0;
                    positionViewAtBeginning();
                }

                highlight: Rectangle {
                    radius: Theme.Tokens.radius.lg
                    color: Theme.Tokens.color.bgElevated

                    Behavior on y {
                        NumberAnimation {
                            duration: Theme.Tokens.motion.fast
                            easing.type: Theme.Tokens.motion.ease
                        }
                    }
                }

                delegate: Item {
                    id: delegateRoot

                    readonly property bool isCurrent: appList.currentIndex === index
                    property var entry: modelData

                    width: appList.width
                    height: root.itemHeight

                    Row {
                        spacing: Theme.Tokens.space.md
                        scale: delegateRoot.isCurrent ? 1.1 : 1
                        transformOrigin: Item.Left

                        anchors {
                            verticalCenter: parent.verticalCenter
                            left: parent.left
                            leftMargin: root.pad
                        }

                        IconImage {
                            width: 23
                            height: 23
                            anchors.verticalCenter: parent.verticalCenter
                            source: Quickshell.iconPath(modelData.icon)
                        }

                        Text {
                            text: modelData.name
                            color: delegateRoot.isCurrent ? Theme.Tokens.color.textPrimary : Theme.Tokens.color.textMuted
                            font.pixelSize: Theme.Tokens.text.lg
                            font.letterSpacing: 0.2
                            height: root.itemHeight
                            verticalAlignment: Text.AlignVCenter

                            Behavior on color {
                                ColorAnimation { duration: Theme.Tokens.motion.fast }
                            }
                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: Theme.Tokens.motion.fast
                                easing.type: Theme.Tokens.motion.ease
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: appList.currentIndex = index
                        onClicked: {
                            const app = modelData;
                            root.close();
                            AppLauncherState.launch(app);
                        }
                    }
                }
            }
        }

        // Empty-state quote — visible when no results
        Column {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 10
            width: parent.width - (root.pad * 4)
            spacing: 10
            visible: appList.count === 0

            Text {
                text: "\"We all make choices, but in the end... our choices make us\""
                color: Theme.Tokens.color.textMuted
                font.pixelSize: Theme.Tokens.text.md
                font.italic: true
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
                wrapMode: Text.WordWrap
            }

            Text {
                text: "Andrew Ryan"
                color: Theme.Tokens.color.textMuted
                font.pixelSize: Theme.Tokens.text.sm
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }

            Text {
                text: "BioShock"
                color: Theme.Tokens.color.textMuted
                font.pixelSize: Theme.Tokens.text.sm
                font.italic: true
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
            }
        }

        Behavior on opacity { NumberAnimation { duration: Theme.Tokens.motion.fast; easing.type: Theme.Tokens.motion.ease } }
        Behavior on scale   { NumberAnimation { duration: Theme.Tokens.motion.fast; easing.type: Theme.Tokens.motion.ease } }
    }
}
