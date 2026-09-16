import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../theme" as Theme
import "../services" as Services

/*!
    SlidePanel — base sliding layer-shell panel.

    A lightweight, always-present Item that owns a LazyLoader around the
    actual PanelWindow: closed panels hold zero mapped window, zero render
    loop. show()/hide() create/destroy the window, sequencing the exit
    animation before teardown so the slide is never cut off. Content is
    declared as a plain child, reparented into the mounted window on each
    open. anchor picks the sliding edge; touchesEdge/offsetBlock pick the
    surface's own styling. Register through PanelService (core/services),
    the single entry point every caller uses to open/close/toggle a panel
    by name.

    Usage:
        SlidePanel {
            name: "launcher"
            anchor: "bottom"
            scrim: true
            focusable: true

            RowLayout {
                // panel content
            }
        }
*/
Item {
    id: root

    required property string name
    required property string anchor // "top" | "bottom" | "left" | "right"

    // trigger is caller-facing documentation only; this file never reads or branches on it.
    property string trigger: "manual" // "manual" | "automatic"

    property bool scrim: false
    property bool focusable: false
    property bool autoHide: false
    property int autoHideTimeout: 3000
    property bool exclusive: true

    property bool touchesEdge: false
    property bool offsetBlock: false

    property Component enterAnimation: Component {
        NumberAnimation {
            duration: Theme.Tokens.motion.slow
            easing.type: Theme.Tokens.motion.ease
        }
    }
    property Component exitAnimation: Component {
        NumberAnimation {
            duration: Theme.Tokens.motion.slow
            easing.type: Theme.Tokens.motion.easeIn
        }
    }

    property bool open: false
    readonly property bool active: panelLoader.active

    default property alias content: contentHolder.data
    Item { id: contentHolder; visible: false }

    signal opened()
    signal closed()

    function show() {
        panelLoader.active = true
    }

    function hide() {
        if (panelLoader.item)
            panelLoader.item.playExitThenDestroy()
        else
            root.open = false
    }

    function toggle() {
        if (panelLoader.active)
            root.hide()
        else
            root.show()
    }

    function notifyInteraction() {
        autoHideTimer.restart()
    }

    Component.onCompleted: Services.PanelService.register(root.name, root)
    Component.onDestruction: Services.PanelService.unregister(root.name)

    Timer {
        id: autoHideTimer
        interval: root.autoHideTimeout
        running: root.open && root.autoHide
        onTriggered: root.hide()
    }

    LazyLoader {
        id: panelLoader
        active: false
        component: panelWindowComponent

        property bool _wasMounted: false
        onItemChanged: {
            if (item) {
                _wasMounted = true
            } else if (_wasMounted) {
                _wasMounted = false
                root.closed()
            }
        }
    }

    Component {
        id: panelWindowComponent

        PanelWindow {
            id: window

            readonly property bool _horizontalEdge: root.anchor === "top" || root.anchor === "bottom"
            property Animation _enterAnimation
            property Animation _exitAnimation
            property var _contentItems: []

            anchors { top: true; bottom: true; left: true; right: true }
            color: "transparent" // layer-shell root — must not paint, surface Rectangle below paints

            WlrLayershell.keyboardFocus: root.focusable && root.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            mask: Region {
                item: surface

                Region {
                    intersection: Intersection.Combine
                    x: 0
                    y: 0
                    width: root.scrim && root.open ? window.width : 0
                    height: root.scrim && root.open ? window.height : 0
                }
            }

            function playExitThenDestroy() {
                root.open = false
                if (window._enterAnimation.running)
                    window._enterAnimation.stop()
                window._exitAnimation.start()
            }

            Rectangle {
                id: scrim
                anchors.fill: parent
                z: 0
                color: Theme.Tokens.color.scrimBlack
                visible: root.scrim && root.open
            }

            Loader {
                id: offsetBlockLoader
                active: root.offsetBlock
                z: 1
                anchors.fill: surface
                anchors.topMargin: Theme.Tokens.space.xs
                anchors.leftMargin: Theme.Tokens.space.xs

                sourceComponent: Rectangle {
                    color: Theme.Tokens.color.accentSurface
                    radius: surface.radius
                }
            }

            RectangularShadow {
                anchors.fill: surface
                z: 2
                visible: !root.touchesEdge
                radius: surface.radius
                blur: Theme.Tokens.shadow.blur
                spread: Theme.Tokens.shadow.spread
                offset: Qt.vector2d(0, Theme.Tokens.shadow.offsetY)
                color: Theme.Tokens.color.shadowBlack
            }

            Rectangle {
                id: surface
                z: 3
                focus: root.focusable && root.open

                // Not a `Behavior`: QQuickBehavior::setAnimation refuses any
                // re-assignment after the first one, so a single Behavior can never
                // be swapped from the enter animation to the exit animation (Qt
                // silently ignores the swap, the exit `finished` never fires, the
                // panel never destroys). `slideOffset` carries no binding of its
                // own — enter/exit animate it imperatively instead, so nothing
                // competes with either run.
                property real slideOffset: 0

                anchors {
                    left: window._horizontalEdge || root.anchor === "left"
                    right: window._horizontalEdge || root.anchor === "right"
                    top: !window._horizontalEdge || root.anchor === "top"
                    bottom: !window._horizontalEdge || root.anchor === "bottom"
                    topMargin: root.anchor === "top" ? slideOffset : 0
                    bottomMargin: root.anchor === "bottom" ? slideOffset : 0
                    leftMargin: root.anchor === "left" ? slideOffset : 0
                    rightMargin: root.anchor === "right" ? slideOffset : 0
                }

                implicitWidth: children.length > 0 ? children[0].implicitWidth : 0
                implicitHeight: children.length > 0 ? children[0].implicitHeight : 0

                radius: root.touchesEdge ? Theme.Tokens.radius.none : Theme.Tokens.radius.lg
                color: Theme.Tokens.color.bgElevated
                border.width: root.touchesEdge ? 0 : Theme.Tokens.border.sm
                border.color: Theme.Tokens.color.borderMuted

                Keys.onEscapePressed: root.hide()

                function reparentContentIntoSurface() {
                    window._contentItems = contentHolder.children.slice()
                    for (const child of window._contentItems)
                        child.parent = surface
                }

                function computeOffscreenSlideOffset() {
                    return window._horizontalEdge ? -surface.implicitHeight : -surface.implicitWidth
                }

                function createAnimations(offscreen) {
                    window._enterAnimation = root.enterAnimation.createObject(surface, {
                        target: surface,
                        property: "slideOffset",
                        to: 0
                    })
                    window._exitAnimation = root.exitAnimation.createObject(surface, {
                        target: surface,
                        property: "slideOffset",
                        to: offscreen
                    })
                }

                function wireAnimationFinishedHandlers() {
                    window._enterAnimation.finished.connect(function () {
                        root.opened()
                    })
                    window._exitAnimation.finished.connect(function () {
                        if (!root.open) {
                            for (const child of window._contentItems)
                                child.parent = contentHolder
                            panelLoader.active = false
                        }
                    })
                }

                function startEnterAnimation() {
                    root.open = true
                    if (window._exitAnimation.running)
                        window._exitAnimation.stop()
                    window._enterAnimation.start()
                }

                Component.onCompleted: {
                    reparentContentIntoSurface()
                    const offscreen = computeOffscreenSlideOffset()
                    surface.slideOffset = offscreen
                    createAnimations(offscreen)
                    wireAnimationFinishedHandlers()
                    startEnterAnimation()
                }
            }
        }
    }
}
