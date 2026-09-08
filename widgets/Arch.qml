pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import QtQuick
import ".."
import "../components"

PopupButton {
  id: root

  readonly property var checkButton: v => !(v.requires?.includes('activewindow')) || !!activeWindow

  text: ''
  color: Theme.transparent
  accentColor: Theme.bg
  textColor: Theme.arch
  ver: true
  hor: false
  verAlign: 0
  popupHeight: Settings.archNodes.filter(v => v.type === 'button' && checkButton(v)).length * nodeHeight + Settings.archNodes.filter(v => v.type === 'sep').length + 13

  readonly property int nodeWidth: popupWidth - 2
  readonly property int nodeHeight: 40
  readonly property int nodeSpacing: 0

  property var activeWindow: null

  Connections {
    target: Hyprland

    function onRawEvent(event) {
      if (event.name === 'activewindow')
        root.activeWindow = event.parse(0)[0].split(',')[0] ?? null;
    }
  }

  Column {
    spacing: root.nodeSpacing
    width: root.nodeWidth 
    height: root.popupHeight - 2
    anchors.horizontalCenter: parent.horizontalCenter
    y: 2

    Repeater {
      model: Settings.archNodes

      Item {
        id: node
        required property var modelData

        readonly property bool blockElement: !root.checkButton(modelData)

        width: root.nodeWidth
        height: blockElement ? 0 : (node.modelData.type === 'sep' ? 1 : root.nodeHeight)

        anchors.horizontalCenter: parent.horizontalCenter

        Rectangle {
          visible: node.modelData.type === 'sep'

          width: root.nodeWidth
          height: 1
          color: Theme.border
        }

        Button {
          visible: node.modelData.type === 'button' && root.activeWindow !== undefined
          width: root.nodeWidth
          height: root.nodeHeight
          text: node.modelData?.label?.replace('%A', root.activeWindow) ?? 'err'
          accentColor: Theme.bg
          hoverColor: Theme.surface1

          onClicked: {
            const [action, props] = node.modelData.action.split(':');
            if (action === 'run') {
              Quickshell.execDetached({
                command: ['sh', '-c', props]
              });
            } else if (action === 'dispatch') {
              Hyprland.dispatch(props);
            }
            Popups.close();
          }
        }
      }
    }
  }
}
