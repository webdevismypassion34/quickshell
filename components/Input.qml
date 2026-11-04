import ".."
import "../animations"
import QtQuick

Rectangle {
  id: root

  property alias text: input.text
  property string placeholder: ""
  property color accentColor: Theme.surface0
  property alias input: input

  signal accepted

  radius: Theme.rounding
  color: Theme.withOpacity(accentColor, 0.3)
  border.color: input.activeFocus ? Theme.accent : Theme.border
  border.width: 1
  width: 200
  height: 35

  MouseArea {
    anchors.fill: parent
    onPressed: input.forceActiveFocus()
  }

  Label {
    visible: input.text.length === 0
    text: root.placeholder
    color: Theme.subtext0

    anchors {
      left: parent.left
      verticalCenter: parent.verticalCenter
      leftMargin: 10
    }
  }

  TextInput {
    id: input

    color: Theme.fg
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Theme.fontType
    selectionColor: Theme.blue
    selectedTextColor: Theme.fg
    clip: true
    onAccepted: root.accepted()
    onActiveFocusChanged: {
      if (!activeFocus) {
        deselect()
      }
    }

    anchors {
      left: parent.left
      right: parent.right
      verticalCenter: parent.verticalCenter
      leftMargin: 10
      rightMargin: 10
    }
  }

  Behavior on border.color {
    ColorAnim {}
  }
}
