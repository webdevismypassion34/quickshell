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

  Item {
    width: parent.width
    height: 35

    Label {
      text: "Status Bar"
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  Column {
    spacing: 4

    Row {
      spacing: 5

      Label {
        text: 'Side:'
        anchors.verticalCenter: parent.verticalCenter
      }

      Select {
        id: sideSelect

        width: 100

        options: ['top', 'left', 'bottom', 'right']

        onCurrentTextChanged: {
          Settings.statusBarSide = currentText
        }
      }
    }
  }
}
