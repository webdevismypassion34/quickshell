// so I can access 'notifications' from nested elements
pragma ComponentBehavior: Bound

import Quickshell.Services.Notifications
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import ".."
import "../components"
import "../animations"
import QtQuick

// qmllint disable uncreatable-type
PanelWindow {
  // qmllint enable uncreatable-type
  id: window

  readonly property int toastDuration: 5000

  implicitWidth: Theme.notificationWidth
  implicitHeight: 1000
  WlrLayershell.layer: WlrLayer.Overlay

  anchors {
    top: true
    right: true
  }

  // qmllint disable unqualified
  margins {
    top: 50 + Theme.outsideMargin * 2
    right: Theme.outsideMargin
  }
  // qmllint enable unqualified

  exclusionMode: ExclusionMode.Ignore
  color: Theme.transparent

  mask: Region {
    item: maskArea
  }

  property var notificationStack: notifications.trackedNotifications.values.filter(v => v && NotificationData.shownNotifications[v.id])

  Item {
    id: list
    anchors.fill: parent

    Item {
      id: maskArea
      anchors.top: parent.top
      anchors.left: parent.left
      width: Theme.notificationWidth
      height: window.notificationStack.reduce((total, notif) => total + (notif ? (NotificationData.notificationHeights[notif.id] ?? Theme.notificationHeight) : 0) + 4, 0)

      Behavior on height {
        NumberAnim {}
      }
    }

    Repeater {
      model: notifications.trackedNotifications

      Rectangle {
        id: root

        required property Notification modelData
        property bool loading: true

        function startCloseAnimation() {
          if (!modelData)
            return;
          timeout.running = false;
          root.anchors.leftMargin = Theme.notificationWidth;
          delete NotificationData.shownNotifications[modelData.id];
          window.notificationStack = notifications.trackedNotifications.values.filter(v => v && NotificationData.shownNotifications[v.id]);
          closeAnim.running = true;
        }

        Component.onDestruction: {
          if (modelData) {
            delete NotificationData.shownNotifications[modelData.id];
            delete NotificationData.notificationHeights[modelData.id];
            window.notificationStack = notifications.trackedNotifications.values.filter(v => v && NotificationData.shownNotifications[v.id]);
          }
        }

        readonly property int index: modelData ? window.notificationStack.findIndex(v => v.id === modelData.id) : -1
        readonly property var before: window.notificationStack.slice(0, index)
        readonly property int topMargin: index > -1 ? before.reduce((total, notif) => total + (notif ? (NotificationData.notificationHeights[notif.id] ?? Theme.notificationHeight) : 0) + 4, 0) : -height

        anchors {
          top: parent.top
          topMargin: topMargin
        }

        Behavior on anchors.topMargin {
          NumberAnim {}
        }

        visible: !!modelData && (loading || shown)
        property bool shown: true

        Component.onCompleted: {
          loading = false;
          if (!modelData || NotificationData.toastedNotifications[modelData.id]) {
            shown = false;
            return;
          }
          NotificationData.shownNotifications[modelData.id] = true;
          root.anchors.leftMargin = 0;
          window.notificationStack = notifications.trackedNotifications.values.filter(v => v && NotificationData.shownNotifications[v.id]);
          shown = true;
        }

        MouseArea {
          anchors.fill: parent
          onClicked: () => {
            root.startCloseAnimation();
          }
        }

        Timer {
          id: timeout
          interval: window.toastDuration - Theme.animDuration
          onTriggered: () => {
            root.startCloseAnimation();
          }
          running: true
        }

        Timer {
          id: closeAnim
          interval: Theme.animDuration
          onTriggered: () => {
            root.shown = false;
            if (root.modelData)
              NotificationData.toastedNotifications[root.modelData.id] = true;
          }
          running: false
        }

        Behavior on anchors.leftMargin {
          NumberAnim {}
        }

        width: Theme.notificationWidth
        height: Theme.notificationHeight + body.implicitHeight - Theme.fontSize
        onHeightChanged: {
          if (!modelData)
            return;
          NotificationData.notificationHeights[modelData.id] = height;
          window.notificationStack = notifications.trackedNotifications.values.filter(v => v && NotificationData.shownNotifications[v.id]);
        }
        radius: Theme.rounding
        color: Theme.withOpacity(Theme.bg, 0.3)
        border.color: Theme.border
        border.width: 1

        anchors {
          /* comment out below line to disable all close/open animations */
          left: parent.left
          leftMargin: Theme.notificationWidth
        }

        Row {
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

              anchors {
                left: parent.left
              }

              IconImage {
                readonly property var appIcon: () => {
                  if (root.modelData.appName === 'NetworkManager Applet')
                    return Quickshell.iconPath('network-workgroup');

                  return Quickshell.iconPath(root.modelData.appIcon);
                }

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
      }
    }
  }

  NotificationServer {
    id: notifications
    keepOnReload: false
    onNotification: notification => {
      notification.tracked = true;
      NotificationData.notifications = [...NotificationData.notifications,
        {
          id: notification.id,
          appIcon: notification.appIcon,
          summary: notification.summary,
          body: notification.body,
          appName: notification.appName
        }
      ];
    }
  }
}
