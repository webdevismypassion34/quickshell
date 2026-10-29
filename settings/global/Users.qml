pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import "../.."
import "../../components"
import "../../theme"
import "../../animations"

Column {
  id: root

  Component.onCompleted: {}

  Item {
    width: parent.width
    height: 35

    Label {
      text: "Users"
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  Column {
    spacing: 4
  }
}
