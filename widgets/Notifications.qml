pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Widgets
import QtQuick
import ".."
import "../components"
import "../animations"

PopupButton {
  id: button

  readonly property int notifCount: NotificationData.notifications.length

  accentColor: Theme.red
  popupColor: Theme.withOpacity(Theme.bg, 0.9)

  text: `${notifCount > 0 ? '󱅫' : '󰂚'} ${notifCount}`

  popupHeight: 1030
  popupWidth: Theme.notificationWidth + Theme.notificationInnerMargin * 2
  horAlign: 2

  Item {
    id: window

    function groupNotifications(n) {
      const groups = {};

      n.forEach(v => {
        const name = v.appName;

        if (groups[name]) {
          groups[name].push(v);
        } else {
          groups[name] = [v];
        }
      });

      return Object.entries(groups);
    }

    property var notificationStack: NotificationData.notifications.filter(v => v && v.id !== undefined && !NotificationData.excusedNotifications[v.id])
    property var openedNotifications: ({})

    width: button.popupWidth
    height: button.popupHeight

    Column {
      spacing: 4
      width: button.popupWidth
      height: button.popupHeight

      anchors {
        top: parent.top
        bottom: parent.bottom
        left: parent.left
        right: parent.right

        topMargin: 10
        bottomMargin: 10
        leftMargin: 10
        rightMargin: 10
      }

      Item {
        height: 30
        width: parent.width

        Label {
          anchors.verticalCenter: parent.verticalCenter
          text: 'Notifications'
          anchors.left: parent.left
        }

        Button {
          id: closeAllButton

          onClicked: NotificationData.notifications = []
          anchors.verticalCenter: parent.verticalCenter
          text: 'Clear All'
          anchors.right: parent.right
        }
      }

      Flickable {
        width: button.popupWidth
        height: 1100
        contentHeight: window.notificationStack.reduce((total, notif) => total + (notif ? (NotificationData.notificationHeights[notif.id] ?? Theme.notificationHeight) : 0) + 4, 0)
        clip: true

        Repeater {
          id: groupsRepeater
          model: window.groupNotifications(NotificationData.notifications.filter(v => v && v.id !== undefined))

          Item {
            id: group
            required property var modelData

            Repeater {
              id: repeater

              model: window.openedNotifications[group.modelData[0]] ? group.modelData[1] : [group.modelData[1][0]]

              Rectangle {
                id: root

                required property var modelData
                property bool loading: true
                property var closedId: null

                function startCloseAnimation() {
                  if (!modelData)
                    return;
                  root.width = 0;
                  closedId = modelData.id;
                  NotificationData.excusedNotifications[modelData.id] = true;
                  window.notificationStack = NotificationData.notifications.filter(v => v && v.id !== undefined && !NotificationData.excusedNotifications[v.id]);
                  closeAnim.running = true;
                }

                readonly property int newIndex: modelData ? window.notificationStack.findIndex(v => v.id === modelData.id) : -1
                property int index: 0

                onNewIndexChanged: {
                  if (newIndex !== -1) {
                    index = newIndex;
                  }
                }

                readonly property var before: window.notificationStack.slice(0, index)
                readonly property int topMargin: index > -1 ? before.reduce((total, notif) => total + (notif ? (NotificationData.notificationHeights[notif.id] ?? Theme.notificationHeight) : 0) + 4, 0) : -height

                anchors {
                  top: parent.top
                  topMargin: topMargin + Theme.notificationInnerMargin
                  left: parent.left
                }

                Behavior on anchors.topMargin {
                  NumberAnim {}
                }

                Behavior on width {
                  NumberAnim {}
                }

                clip: true

                visible: !!modelData && (loading || shown)
                property bool shown: true

                Component.onCompleted: {
                  loading = false;
                  if (!modelData || NotificationData.excusedNotifications[modelData.id]) {
                    shown = false;
                  } else {
                    root.width = Theme.notificationWidth;
                    shown = true;
                  }
                }

                MouseArea {
                  anchors.fill: parent
                  onClicked: () => {
                    root.startCloseAnimation();
                  }
                }

                Timer {
                  id: closeAnim
                  interval: Theme.animDuration
                  onTriggered: () => {
                    root.shown = false;
                    if (root.closedId != null) {
                      NotificationData.notifications = NotificationData.notifications.filter(v => v && v.id !== root.closedId);
                      delete NotificationData.excusedNotifications[root.closedId];
                      delete NotificationData.notificationHeights[root.closedId];
                    }
                  }
                  running: false
                }

                width: Theme.notificationWidth
                height: Theme.notificationHeight + body.implicitHeight - Theme.fontSize
                onHeightChanged: {
                  if (!modelData)
                    return;
                  NotificationData.notificationHeights[modelData.id] = height;
                  window.notificationStack = NotificationData.notifications.filter(v => v && v.id !== undefined && !NotificationData.excusedNotifications[v.id]);
                }
                radius: Theme.rounding
                color: Theme.withOpacity(Theme.bg, 0.3)
                border.color: Theme.border
                border.width: 1

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

                    function getIcon(name) {
                      return Quickshell.iconPath(name);
                    }

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
                        anchors.fill: parent
                        source: root.modelData ? icon.getIcon(root.modelData.appIcon) : ''
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

            Label {
              text: window.openedNotifications[group.modelData[0]] ? 'collapse' : `expand (+${group.modelData[1].length - 1})`
              visible: group.modelData[1].length > 1

              ClickArea {
                onClicked: {
                  const name = group.modelData[0];
                  const next = Object.assign({}, window.openedNotifications);
                  next[name] = !next[name];
                  window.openedNotifications = next;
                }
              }
            }

            Label {
              text: `close`
              visible: group.modelData[1].length > 1
              x: 300

              ClickArea {
                onClicked: {
                  NotificationData.notifications = NotificationData.notifications.filter(v => v.appName !== group.modelData[0]);
                }
              }
            }
          }
        }
      }
    }
  }
}
