pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Hyprland
import ".."
import "../components"
import "../animations"

Item {
  id: container

  implicitWidth: row.implicitWidth
  implicitHeight: row.implicitHeight

  readonly property var workspaces: Hyprland.workspaces.values.filter(v => isFinite(v.name))

  Rectangle {
    id: active

    width: 45
    height: 35
    radius: Theme.rounding
    color: Theme.withOpacity(Theme.overlay1, 0.1)
    x: (row.buttonWidth + row.spacing) * container.workspaces.findIndex(v => v.focused)

    Behavior on x {
      NumberAnim {}
    }

    MouseArea {
      id: drag

      anchors.fill: parent
      drag.target: parent
      drag.axis: Drag.XAxis
      drag.minimumX: 0
      drag.maximumX: (row.buttonWidth + row.spacing) * (container.workspaces.length - 1)
      drag.smoothed: true
    }

    Connections {
      target: drag.drag

      function onActiveChanged() {
        if (!drag.drag.active) {
          const closest = Math.round(active.x / (row.buttonWidth + row.spacing));
          Hyprland.workspaces.values[closest].activate();
          active.x = (row.buttonWidth + row.spacing) * closest
        }
      }
    }
  }

  Row {
    id: row
    spacing: 4

    readonly property int buttonWidth: 45
    readonly property int buttonHeight: 35

    Repeater {
      model: container.workspaces

      Button {
        id: root

        required property var modelData

        color: Theme.transparent
        width: row.buttonWidth
        height: row.buttonHeight
        radius: Theme.rounding

        onClicked: modelData.activate()
        text: modelData.name

        active: !modelData.focused
      }
    }
  }
}
