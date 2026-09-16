import QtQuick
import QtQuick.Controls
import "../theme" as Theme

/*!
    QsComboBox — Themed drop-down selector.

    Drop-in replacement for ComboBox with shell visual style.

    Properties:
      model           any     — list model (array, ListModel, etc.)
      currentIndex    int     — selected index
      maxPopupHeight  int     — max height of the dropdown list (default 200)

    Signal:
      activated(int index)   — user selected an item (mirrors ComboBox.activated)
*/
ComboBox {
    id: root

    property int maxPopupHeight: 200

    implicitHeight: 32

    background: Rectangle {
        color:        Theme.Tokens.color.bgElevated
        radius:       Theme.Tokens.radius.lg
        border.width: 1
        border.color: root.activeFocus
                          ? Theme.Tokens.color.accent
                          : Theme.Tokens.color.border
    }

    contentItem: Text {
        leftPadding:       8
        text:              root.displayText
        color:             Theme.Tokens.color.textPrimary
        font.pixelSize:    Theme.Tokens.text.md
        verticalAlignment: Text.AlignVCenter
        elide:             Text.ElideRight
    }

    delegate: ItemDelegate {
        width:       root.width
        highlighted: root.highlightedIndex === index

        contentItem: Text {
            leftPadding:       8
            text:              modelData
            color:             highlighted
                                   ? Theme.Tokens.color.accent
                                   : Theme.Tokens.color.textPrimary
            font.pixelSize:    Theme.Tokens.text.md
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            color:  highlighted
                        ? Theme.Tokens.color.accentSurface
                        : Theme.Tokens.color.bgElevated
            radius: Theme.Tokens.radius.md
        }
    }

    popup: Popup {
        y:       root.height + 2
        width:   root.width
        padding: 0

        background: Rectangle {
            color:        Theme.Tokens.color.bgElevated
            radius:       Theme.Tokens.radius.lg
            border.width: 1
            border.color: Theme.Tokens.color.border
        }

        contentItem: Rectangle {
            color:  "transparent"
            radius: Theme.Tokens.radius.lg
            clip:   true

            implicitHeight: Math.min(_list.contentHeight + Theme.Tokens.space.sm * 2,
                                     root.maxPopupHeight)

            ListView {
                id: _list
                anchors {
                    fill:         parent
                    topMargin:    Theme.Tokens.space.xs
                    bottomMargin: Theme.Tokens.space.xs
                    leftMargin:   Theme.Tokens.space.xs
                    rightMargin:  Theme.Tokens.space.xs
                }
                clip:         true
                model:        root.delegateModel
                currentIndex: root.highlightedIndex
                ScrollIndicator.vertical: ScrollIndicator { }
            }
        }
    }
}
