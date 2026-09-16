pragma Singleton

import QtQuick

/*!
    EventBus — Mediator pattern for inter-module communication.

    Modules never import each other directly. Instead they emit or
    connect to signals here. Adding a new listener never touches the emitter.

    Signal naming convention:
      - Past tense  → event already happened  (themeChanged)
      - Imperative  → request to do something (themeChangeRequested)
*/
QtObject {
    id: root

    // ── Calendar ──────────────────────────────────────────
    // Clock emits calendarToggleRequested; CalendarWindow listens and acts.
    // CalendarWindow emits calendarVisibilityChanged; Clock listens to update its color.
    signal calendarToggleRequested()
    signal calendarVisibilityChanged(bool visible)

    // ── Monitors ──────────────────────────────────────────
    signal monitorConnected(string monitorName)
    signal monitorDisconnected(string monitorName)
}
