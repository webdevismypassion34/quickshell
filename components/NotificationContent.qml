import Quickshell.Widgets
import QtQuick
import ".."

Row {
  id: root

  required property var modelData

  readonly property alias bodyHeight: body.implicitHeight

  spacing: Theme.notificationInnerMargin

  anchors {
    left: parent.left
    top: parent.top
    right: parent.right
    bottom: parent.bottom
    leftMargin: Theme.notificationInnerMargin
    topMargin: Theme.notificationInnerMargin
    rightMargin: Theme.notificationInnerMargin
    bottomMargin: Theme.notificationInnerMargin
  }

  Item {
    id: icon

    readonly property int iconSize: 40

    implicitHeight: iconSize
    implicitWidth: icon.iconSize

    ClippingRectangle {
      implicitHeight: icon.iconSize
      implicitWidth: icon.iconSize
      radius: Theme.rounding
      color: Theme.transparent
      anchors.left: parent.left

      IconImage {
        anchors.fill: parent
        source: root.modelData ? NotificationData.getIcon(root.modelData.appIcon, root.modelData.appName) : ''
      }
    }
  }

  Column {
    spacing: 4

    Label {
      text: root.modelData?.summary ?? ''
    }

    Label {
      id: body
      text: root.modelData?.body ?? ''
      color: Theme.subtext0
      wrapMode: Text.WrapAnywhere
      width: Theme.notificationWidth - (Theme.notificationInnerMargin * 3) - icon.iconSize
      height: implicitHeight
      verticalAlignment: Text.AlignTop
    }
  }
}
