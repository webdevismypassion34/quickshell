import QtQuick
import Quickshell.Widgets
import Quickshell.Services.Mpris
import "../components"
import ".."

Row {
  id: root
  spacing: 8

  readonly property var player: Mpris.players.values.filter(v => v.dbusName === Settings.player)[0]
  readonly property bool isPlaying: (root.player?.playbackState === MprisPlaybackState.Playing) ?? false

  FrameAnimation {
    running: root.isPlaying
    onTriggered: root.player.positionChanged()
  }

  ClippingRectangle {
    radius: Theme.rounding
    width: 35
    height: 35
    clip: true
    color: Theme.bg

    Image {
      anchors.fill: parent
      source: root.player?.trackArtUrl ?? ""
      smooth: true
      mipmap: true
    }

    ClickArea {
      onClicked: root.player ? root.player.togglePlaying() : ''
    }
  }

  Item {
    implicitWidth: col.implicitWidth
    implicitHeight: col.implicitHeight
    anchors.verticalCenter: parent.verticalCenter

    PopupArea {
      popupWidth: 216
      popupHeight: 316
      popupColor: Theme.bg

      Column {
        anchors.horizontalCenter: parent.horizontalCenter

        anchors {
          top: parent.top
          bottom: parent.bottom
          topMargin: 8
          bottomMargin: 8
        }

        ClippingRectangle {
          radius: Theme.rounding
          width: 200
          height: 200
          color: Theme.bg

          Image {
            anchors.fill: parent
            source: root.player?.trackArtUrl ?? ""
            smooth: true
            mipmap: true
          }
        }

        Spacer {
          height: 8
        }

        Item {
          id: length

          readonly property real positionTotal: (root.player?.position ?? 0) / (root.player?.length ?? 0)

          anchors.horizontalCenter: parent.horizontalCenter
          width: 180
          height: 6

          Rectangle {
            anchors.fill: parent
            color: Theme.surface1
            radius: Theme.rounding

            ClickArea {
              onClicked: mouse => {
                root.player.position = (mouse.x / length.width) * root.player?.length ?? 0;
              }
            }
          }

          Rectangle {
            height: parent.height
            width: parent.width * parent.positionTotal
            color: Theme.overlay0
            radius: Theme.rounding
          }

          Rectangle {
            x: parent.width * parent.positionTotal - width / 2
            y: -width / 4
            width: 12
            height: width
            color: Theme.surface2
            radius: Theme.rounding
          }
        }

        Spacer {
          height: 4
        }

        Item {
          id: elapsedLabel
          readonly property var formatTime: seconds => `${Math.floor(seconds / 60)}:${(Math.floor(seconds) % 60).toString().padStart(2, '0')}`

          anchors.horizontalCenter: parent.horizontalCenter
          width: 180
          height: elapsed.height

          Label {
            id: elapsed
            anchors.left: parent.left
            text: elapsedLabel.formatTime(root.player?.position ?? 0)
          }

          Label {
            anchors.right: parent.right
            text: elapsedLabel.formatTime(root.player?.length ?? 0)
          }
        }

        Column {
          spacing: 0
          anchors.horizontalCenter: parent.horizontalCenter

          Label {
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.fg
            text: root.player?.trackTitle || 'unknown title'
          }

          Label {
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.subtext1
            text: root.player?.trackArtist || 'unknown artist'
          }
        }

        Spacer {
          height: 6
        }

        Row {
          readonly property real fontMulti: 1.5
          spacing: 16
          anchors.horizontalCenter: parent.horizontalCenter

          Label {
            font.pixelSize: Theme.fontSize * parent.fontMulti
            text: '󰒮'

            ClickArea {
              onClicked: root.player?.previous()
            }
          }

          Label {
            font.pixelSize: Theme.fontSize * parent.fontMulti * 1.2
            text: root.isPlaying ? '󰏤' : '󰐊'

            ClickArea {
              onClicked: root.player?.togglePlaying()
            }
          }

          Label {
            font.pixelSize: Theme.fontSize * parent.fontMulti
            text: '󰒭'

            ClickArea {
              onClicked: root.player?.next()
            }
          }
        }
      }
    }

    Column {
      id: col
      spacing: 0

      Label {
        color: Theme.fg
        text: root.player?.trackTitle || 'unknown title'
      }

      Label {
        color: Theme.subtext1
        text: root.player?.trackArtist || 'unknown artist'
      }
    }
  }
}
