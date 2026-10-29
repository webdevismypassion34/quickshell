pragma ComponentBehavior: Bound

import QtQuick
import Quickshell.Bluetooth
import ".."
import "../components"
import "../animations"

PopupButton {
  id: root

  readonly property var connectedDevice: Bluetooth.devices.values.filter(v => v.connected)[0]
  accentColor: Theme.purple
  text: connectedDevice?.connected ? `󰂯 ${connectedDevice.name}` : '󰂲 None'

  function getIcon(name) {
    if (name === 'audio-headset') {
      return '󰋋';
    } else if (name === 'none') {
      return '󰂲';
    } else {
      return '';
    }
  }

  popupWidth: 300
  popupHeight: 250

  Label {
    text: 'Bluetooth'
    anchors {
      top: parent.top
      left: parent.left
      topMargin: 10
      leftMargin: 10
      rightMargin: 10
    }
  }

  Toggle {
    onToggled: checked => Bluetooth.defaultAdapter.enabled = checked
    accentColor: root.accentColor
    checked: Bluetooth.defaultAdapter?.enabled ?? false

    anchors {
      top: parent.top
      right: parent.right
      topMargin: 10
      leftMargin: 10
      rightMargin: 10
    }
  }

  Rectangle {
    id: conn
    color: hovered ? Theme.withOpacity(Theme.red, 0.5) : Theme.withOpacity(Theme.purple, 0.5)
    height: 45
    radius: Theme.rounding

    property bool hovered: false

    anchors {
      top: parent.top
      left: parent.left
      right: parent.right
      topMargin: 40
      leftMargin: 10
      rightMargin: 10
    }

    Behavior on color {
      ColorAnim {}
    }

    MouseArea {
      anchors.fill: parent
      cursorShape: Qt.PointingHandCursor
      hoverEnabled: true
      onEntered: conn.hovered = true
      onExited: conn.hovered = false
    }

    Label {
      text: root.getIcon(root.connectedDevice?.icon ?? 'none')
      font.pixelSize: Theme.fontSize * 2

      anchors {
        top: parent.top
        left: parent.left
        leftMargin: 13
        verticalCenter: parent.verticalCenter
      }
    }

    Label {
      text: '󱘹'
      font.pixelSize: Theme.fontSize * 2
      opacity: conn.hovered ? 1 : 0

      anchors {
        top: parent.top
        right: parent.right
        rightMargin: 15
        verticalCenter: parent.verticalCenter
      }

      Behavior on opacity {
        NumberAnim {}
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: () => {
          root.connectedDevice.disconnect();
        }
      }
    }

    Label {
      text: root.connectedDevice?.name ?? 'None'

      anchors {
        top: parent.top
        left: parent.left
        bottom: parent.bottom
        leftMargin: 30 + Theme.fontSize
        bottomMargin: 15
      }
    }

    Label {
      readonly property int battery: Math.round(root.connectedDevice?.battery * 100) ?? 0
      font.pixelSize: Theme.fontSize * 0.75

      text: root.connectedDevice?.batteryAvailable ? `${battery}% battery` : 'battery unavailable'

      anchors {
        top: parent.top
        left: parent.left
        bottom: parent.bottom
        topMargin: 15
        leftMargin: 30 + Theme.fontSize
      }
    }
  }

  Label {
    text: `Other Devices (${Bluetooth.devices?.values?.filter(v => !v.connected).length ?? -1})`
    anchors {
      top: parent.top
      left: parent.left
      topMargin: 100
      leftMargin: 10
      rightMargin: 10
    }
  }

  Flickable {
    width: root.popupWidth
    height: root.popupHeight - y
    y: 130
    contentHeight: col.height + 20
    clip: true

    Column {
      id: col
      spacing: 4

      Repeater {
        model: Bluetooth.devices.values.filter(v => !v.connected)

        Rectangle {
          id: device

          required property var modelData
          property bool hovered: false

          color: hovered ? Theme.withOpacity(Theme.green, 0.5) : Theme.withOpacity(Theme.purple, 0.5)
          height: 45
          width: root.popupWidth - 20
          x: 10
          radius: Theme.rounding

          Behavior on color {
            ColorAnim {}
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: true
            onEntered: device.hovered = true
            onExited: device.hovered = false
          }

          Label {
            text: root.getIcon(device.modelData?.icon ?? 'none')
            font.pixelSize: Theme.fontSize * 2

            anchors {
              top: parent.top
              left: parent.left
              leftMargin: 13
              verticalCenter: parent.verticalCenter
            }
          }

          Label {
            text: '󱇬'
            font.pixelSize: Theme.fontSize * 2
            opacity: device.hovered ? 1 : 0

            anchors {
              top: parent.top
              right: parent.right
              rightMargin: 15
              verticalCenter: parent.verticalCenter
            }

            Behavior on opacity {
              NumberAnim {}
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor
              onClicked: () => {
                device.modelData.connect();
              }
            }
          }

          Label {
            text: device.modelData?.name ?? 'None'

            anchors {
              top: parent.top
              left: parent.left
              bottom: parent.bottom
              leftMargin: 30 + Theme.fontSize
              bottomMargin: 15
            }
          }

          Label {
            font.pixelSize: Theme.fontSize * 0.75

            text: device.modelData.icon

            anchors {
              top: parent.top
              left: parent.left
              bottom: parent.bottom
              topMargin: 15
              leftMargin: 30 + Theme.fontSize
            }
          }
        }
      }
    }
  }
}
