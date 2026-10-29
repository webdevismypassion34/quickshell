pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
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

  readonly property var monitors: Hyprland.monitors
  property int totalWidth: 0
  property int totalHeight: 0

  property int selected: 0

  Component.onCompleted: {
    const boundRight = monitors.values.reduce((max, monitor) => Math.max(max, monitor.x + monitor.width), 0);
    const boundLeft = monitors.values.reduce((min, monitor) => Math.min(min, monitor.x), 0);

    const boundBottom = monitors.values.reduce((max, monitor) => Math.max(max, monitor.y + monitor.height), 0);
    const boundTop = monitors.values.reduce((min, monitor) => Math.min(min, monitor.y), 0);

    totalWidth = boundRight - boundLeft;
    totalHeight = boundBottom - boundTop;
  }

  Item {
    width: parent.width
    height: 35

    Label {
      text: "Monitors"
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  Item {
    id: monitorDisplay

    readonly property int smaller: 10
    readonly property real fitScale: Math.min((root.width - 5) / (root.totalWidth / smaller), 2000 / (root.totalHeight / smaller), 1)
    width: root.totalWidth / smaller * fitScale
    height: root.totalHeight / smaller * fitScale

    Repeater {
      model: root.monitors

      Rectangle {
        required property var modelData

        x: modelData.x / monitorDisplay.smaller * monitorDisplay.fitScale
        y: modelData.y / monitorDisplay.smaller * monitorDisplay.fitScale
        width: modelData.width / monitorDisplay.smaller * monitorDisplay.fitScale
        height: modelData.height / monitorDisplay.smaller * monitorDisplay.fitScale

        color: Theme.surface0 // @TODO make it show monitor content (blurred?)
        radius: Theme.rounding
        border.width: 1
        border.color: root.selected === modelData.id ? Theme.accent : Theme.border

        Label {
          anchors.centerIn: parent
          horizontalAlignment: Text.AlignHCenter
          text: `${parent.modelData.name}\n${parent.modelData.width} x ${parent.modelData.height}\n${Math.round(parent.modelData.lastIpcObject.refreshRate)}hz`
        }

        ClickArea {
          onClicked: root.selected = parent.modelData.id
        }

        Behavior on border.color {
          ColorAnim {}
        }
      }
    }
  }

  Spacer {
    height: 12
  }

  Column {
    id: details

    spacing: 4

    readonly property var m: root.monitors.values[root.selected]

    Row {
      Label {
        text: 'Selected: '
      }
      AnimLabel {
        text: `${details.m.name}`
      }
    }

    Row {
      Label {
        text: 'Description: '
      }
      AnimLabel {
        text: `${details.m.lastIpcObject.description}`
      }
    }

    Row {
      Label {
        text: 'Scale: '
      }
      AnimLabel {
        text: `${details.m.scale}`
      }
    }

    Row {
      Label {
        text: 'VRR: '
      }
      AnimLabel {
        text: `${details.m.lastIpcObject.vrr}`
      }
    }

    Row {
      Label {
        text: 'Tearing: '
      }
      AnimLabel {
        text: `${details.m.lastIpcObject.activelyTearing}`
      }
    }
  }
}
