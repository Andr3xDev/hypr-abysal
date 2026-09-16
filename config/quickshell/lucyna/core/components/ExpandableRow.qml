import QtQuick
import "../theme" as Theme

/*!
    ExpandableRow — collapsible bar-widget shell.

    Collapses to 0 width when not expanded, animating to its first child's
    implicitWidth when expanded. Sibling widgets in the bar's RowLayout
    shift to make room — expected trade-off, not a bug, given rightSection's
    right-anchor (see bug/root-cause-rightsection... in Engram: expanding a
    widget shifts only its LEFT neighbors, right-anchor point stays fixed).
    Compose the actual row content (a RowLayout, typically) as a plain
    child — no special property needed, it becomes `children[0]`.

    Usage:
        ExpandableRow {
            expanded: someCondition

            RowLayout {
                anchors.centerIn: parent
                opacity: expanded ? 1 : 0
                // ...
            }
        }
*/
Item {
    id: root

    property bool expanded: false

    implicitWidth: expanded && children.length > 0 ? children[0].implicitWidth : 0
    implicitHeight: parent.height
    clip: true

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Theme.Tokens.motion.standard
            easing.type: Theme.Tokens.motion.ease
        }
    }
}
