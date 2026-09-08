pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import "."
import ".."
import "../animations"

ComboBox {
  id: select

  required property var options

  model: options

  contentItem: Label {
    text: select.displayText
    leftPadding: 8
    topPadding: 8
    bottomPadding: 8
    rightPadding: 8
  }

  background: Rectangle {
    radius: Theme.rounding
    color: (select.hovered || select.popup.visible) ? Theme.surface0 : Theme.withOpacity(Theme.surface0, 0.6)
    border.color: Theme.border
    border.width: 1

    HoverHandler {
      cursorShape: Qt.PointingHandCursor
    }

    Behavior on color {
      ColorAnim {}
    }
  }

  popup: Popup {
    y: select.height + 4
    width: select.width
    padding: 4

    enter: Transition {
      NumberAnim {
        property: "height"
        from: 0
        to: select.popup.contentHeight + 8
      }
    }

    exit: Transition {
      NumberAnim {
        property: "height"
        from: select.popup.contentHeight + 8
        to: 0
      }
    }

    contentItem: ListView {
      implicitHeight: Math.min(contentHeight, 240)
      model: select.popup.visible ? select.delegateModel : null
      clip: true
    }

    background: Rectangle {
      radius: Theme.rounding
      color: Theme.surface0
      border.color: Theme.border
      border.width: 1
    }
  }

  delegate: ItemDelegate {
    id: del

    required property string modelData
    required property int index

    width: select.width - 8
    highlighted: select.highlightedIndex === index

    contentItem: Label {
      text: del.modelData
      color: Theme.fg
      verticalAlignment: Text.AlignVCenter
      leftPadding: 8
    }

    background: Rectangle {
      radius: 5
      color: del.highlighted ? Theme.surface1 : Theme.surface0

      Behavior on color {
        ColorAnim {}
      }

      HoverHandler {
        cursorShape: Qt.PointingHandCursor
      }
    }
  }
}
