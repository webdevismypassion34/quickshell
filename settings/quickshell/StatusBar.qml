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

    SettingsRow {
      label: 'Side:'

      Select {
        id: sideSelect

        width: 100

        options: ['top', 'left', 'bottom', 'right']
        currentIndex: options.indexOf(Settings.statusBarSide)

        onCurrentTextChanged: {
          Settings.statusBarSide = currentText
          Settings.persistent.statusBarSide = currentText
        }
      }
    }
  }

  SettingsRow {
    label: 'Bar Height:'

    Slider {
      width: 100
      min: 20
      max: 60
      value: Theme.barHeight
      anchors.verticalCenter: parent.verticalCenter

      onMoved: {
        Theme.barHeight = value
      }
    }
  }
}
