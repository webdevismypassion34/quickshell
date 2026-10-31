pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import ".."
import "../components"
import "../animations"

// qmllint disable uncreatable-type
PanelWindow {
  id: panelWindow
  WlrLayershell.namespace: "quickshell-launcher"
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
  visible: osdActive || closeAnimationTimer.running
  color: Theme.transparent
  implicitWidth: 200
  implicitHeight: 60
  exclusionMode: ExclusionMode.Ignore

  property var audio: Pipewire.defaultAudioSink.audio
  property real volume: audio.volume
  property bool muted: audio.muted
  property real startingVolume: 0

  property var osdActive: false

  Connections {
    target: panelWindow.audio

    function onVolumeChanged() {
      closeTimer.restart();
      panelWindow.osdActive = true;
    }

    function onMutedChanged() {
      closeTimer.restart();
      panelWindow.osdActive = true;
    }
  }

  anchors {
    top: true
  }

  // qmllint disable missing-property
  margins.top: Theme.barHeight + Theme.outsideMargin * 2
  // qmllint enable missing-property

  Timer {
    id: closeAnimationTimer
    interval: Theme.animDuration
    running: false
    repeat: false
    onTriggered: {
      panelWindow.startingVolume = Pipewire.defaultAudioSink.audio.volume;
    }
  }

  Timer {
    id: closeTimer
    interval: 3000
    running: false
    repeat: false
    onTriggered: {
      closeAnimationTimer.start();
      panelWindow.osdActive = false;
    }
  }

  ClippingRectangle {
    id: content
    anchors.horizontalCenter: parent.horizontalCenter
    height: panelWindow.height
    width: panelWindow.osdActive ? panelWindow.width : 0
    opacity: panelWindow.osdActive ? 1 : 0
    clip: true
    color: Theme.bg
    radius: Theme.rounding

    border {
      color: Theme.border
      width: 1
    }

    Behavior on width {
      NumberAnim {}
    }

    Behavior on height {
      NumberAnim {}
    }

    Behavior on opacity {
      NumberAnim {}
    }

    Column {
      id: col
      width: content.width - 20
      height: content.height - 20
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      spacing: 5

      Label {
        text: 'Volume'
        anchors.horizontalCenter: parent.horizontalCenter
      }

      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 5
        width: col.width

        Row {
          id: amount

          Label {
            width: Theme.fontSize * 1.4
            text: panelWindow.muted ? ' ' : ['', '', '', ''][Math.ceil(panelWindow.volume * 3)] + ' '
            color: panelWindow.muted ? Theme.surface2 : Theme.fg
          }

          Odometer {
            value: Math.floor(panelWindow.volume * 100).toString().padStart(2, '0')[0]
            color: panelWindow.muted ? Theme.surface2 : Theme.fg
          }

          Odometer {
            value: Math.floor(panelWindow.volume * 100).toString().padStart(2, '0')[1]
            color: panelWindow.muted ? Theme.surface2 : Theme.fg
          }

          Label {
            text: '%'
            color: panelWindow.muted ? Theme.surface2 : Theme.fg
          }
        }

        Rectangle {
          id: total
          width: col.width - amount.width - 10
          color: Theme.darkbg
          height: 10
          anchors.verticalCenter: parent.verticalCenter
          radius: Theme.rounding

          Rectangle {
            width: total.width * (panelWindow.startingVolume + volumeChanged)
            color: panelWindow.muted ? Theme.surface2 : Theme.fg
            height: 10
            anchors.verticalCenter: parent.verticalCenter
            radius: Theme.rounding

            property real volumeChanged: panelWindow.volume - panelWindow.startingVolume

            Behavior on volumeChanged {
              NumberAnim {
                easing.type: Easing.OutCubic
              }
            }
          }
        }
      }
    }
  }
}
