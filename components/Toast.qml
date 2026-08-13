import QtQuick
import ".."
import "../animations"

Rectangle {
  id: root

  // external - meant to be changed outside this file
  default property alias toastContent: contentItem.data
  property int duration: 5000
  property bool persistent: false
  property color accentColor: Theme.accent

  // internal - should never be changed from outside this file, but can be viewed
  property bool shown: false

  signal dismissed

  function close() {
    if (!shown)
      return;
    shown = false;
    bar.stop();
    closeTimer.restart();
  }

  Component.onCompleted: {
    shown = true;
    if (!persistent)
      bar.restart();
  }

  radius: Theme.rounding
  color: Theme.withOpacity(Theme.bg, 0.3)
  border.color: Theme.border
  border.width: 1

  implicitWidth: contentItem.width + Theme.notificationInnerMargin * 2
  implicitHeight: contentItem.height + Theme.notificationInnerMargin * 2 + (persistent ? 0 : barTrack.height + 4)

  opacity: shown ? 1 : 0
  scale: shown ? 1 : 0.9

  Behavior on opacity {
    NumberAnim {}
  }

  Behavior on scale {
    NumberAnim {}
  }

  Timer {
    id: closeTimer
    interval: Theme.animDuration
    onTriggered: root.dismissed()
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    onClicked: root.close()
  }

  Item {
    id: contentItem
    anchors {
      left: parent.left
      top: parent.top
      margins: Theme.notificationInnerMargin
    }
    width: childrenRect.width
    height: childrenRect.height
  }

  Item {
    id: barTrack
    visible: !root.persistent
    height: root.persistent ? 0 : 3

    anchors {
      left: parent.left
      right: parent.right
      bottom: parent.bottom
      leftMargin: Theme.notificationInnerMargin
      rightMargin: Theme.notificationInnerMargin
      bottomMargin: 4
    }

    Rectangle {
      id: bar

      property real progress: 1

      function restart() {
        progress = 1;
        anim.restart();
      }
      function stop() {
        anim.stop();
      }

      color: root.accentColor
      radius: height / 2
      height: parent.height
      width: barTrack.width * progress

      anchors.left: parent.left

      NumberAnimation {
        id: anim
        target: bar
        property: "progress"
        from: 1
        to: 0
        duration: root.duration
        onFinished: root.close()
      }
    }
  }
}
