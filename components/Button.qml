import QtQuick
import ".."
import "../animations"

Rectangle {
  id: root

  property string text: "button"
  property color accentColor: Theme.surface0
  property bool hovered: false
  property color hoverColor: accentColor
  property bool active: true

  signal clicked

  radius: Theme.rounding
  color: hovered ? Theme.withOpacity(hoverColor, 0.4) : Theme.withOpacity(accentColor, 0.3)
  width: label.implicitWidth + 30
  height: 35

  Behavior on color {
    ColorAnim {}
  }

  Label {
    id: label
    anchors.centerIn: parent
    text: root.text
  }

  MouseArea {
    visible: root.active
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true
    onEntered: root.hovered = true
    onExited: root.hovered = false
    onClicked: root.clicked()
  }
}
