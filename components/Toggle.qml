import QtQuick
import ".."
import "../animations"

Rectangle {
  id: root

  property bool checked: false
  property color accentColor: Theme.green
  signal toggled(bool checked)

  width: 34
  height: 20
  radius: height / 2
  color: checked ? Theme.withOpacity(accentColor, 0.5) : Theme.withOpacity(Theme.bg, 0.5)

  Behavior on color {
    ColorAnim {}
  }

  Rectangle {
    width: parent.height - 6
    height: width
    radius: width / 2
    color: Theme.fg
    anchors.verticalCenter: parent.verticalCenter
    x: root.checked ? parent.width - width - 3 : 3

    Behavior on x {
      NumberAnim {}
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: {
      root.checked = !root.checked;
      root.toggled(root.checked);
    }
  }
}
