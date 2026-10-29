pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import ".."

Scope {
  id: root

  property bool active: false

  function open() {
    root.active = true;
    Settings.censorWifiNames = true
  }

  function close() {
    root.active = false;
    Settings.censorWifiNames = false
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: win

      required property var modelData
      screen: modelData
      visible: root.active

      WlrLayershell.namespace: "quickshell-screenshot"
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
      exclusionMode: ExclusionMode.Ignore

      color: Theme.transparent

      anchors {
        top: true
        bottom: true
        left: true
        right: true
      }

      onVisibleChanged: {
        if (visible) {
          selectArea.forceActiveFocus();
          selectionRect.visible = true;
          border.width = 0;
          border.height = 0;
        }
      }

      MouseArea {
        id: selectArea

        anchors.fill: parent
        cursorShape: Qt.CrossCursor
        focus: true

        Keys.onPressed: event => {
          if (event.key === Qt.Key_Escape) {
            root.close();
          }
        }

        property real startX
        property real startY

        onPressed: mouse => {
          border.visible = true;
          startX = mouse.x;
          startY = mouse.y;
          border.width = 0;
          border.height = 0;
        }

        onPositionChanged: mouse => {
          border.x = Math.min(startX, mouse.x);
          border.y = Math.min(startY, mouse.y);
          border.width = Math.abs(mouse.x - startX);
          border.height = Math.abs(mouse.y - startY);
        }

        onReleased: {
          border.visible = false;
          selectionRect.visible = false;
          const {
            x,
            y,
            width,
            height
          } = border;
          const globalX = Math.round(win.screen.x + x);
          const globalY = Math.round(win.screen.y + y);
          const dimensions = `${globalX},${globalY} ${Math.round(width)}x${Math.round(height)}`;
          Quickshell.execDetached(['sh', '-c', `grim -g "${dimensions}" - | tee ~/screenshots/screenshot-$(date +%Y%m%d-%H%M%S).png | swappy -f -`]);
          root.close();
        }

        Item {
          id: selectionRect
          visible: false
          anchors.fill: parent

          Rectangle {
            x: 0
            y: 0
            width: border.x
            height: parent.height
            color: Theme.withOpacity(Theme.accent, 0.2)
          }

          Rectangle {
            x: border.x + border.width
            y: 0
            width: parent.width - (border.x + border.width)
            height: parent.height
            color: Theme.withOpacity(Theme.accent, 0.2)
          }

          Rectangle {
            x: border.x
            y: 0
            width: border.width
            height: border.y
            color: Theme.withOpacity(Theme.accent, 0.2)
          }

          Rectangle {
            x: border.x
            y: border.y + border.height
            width: border.width
            height: parent.height - (border.y + border.height)
            color: Theme.withOpacity(Theme.accent, 0.2)
          }

          Rectangle {
            id: border
            border.color: Theme.accent
            border.width: 2
            color: Theme.transparent
          }
        }
      }
    }
  }
}
