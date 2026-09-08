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

    readonly property int footerHeight: 24

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

    function footerKey(name) {
      return `footer:${name}`;
    }

    property var openedNotifications: ({})

    readonly property var groupedNotifications: window.groupNotifications(NotificationData.notifications.filter(v => v && v.id !== undefined))

    readonly property var notificationStack: {
      const entries = [];

      window.groupedNotifications.forEach(([name, notifs]) => {
        const expanded = !!window.openedNotifications[name];
        const visible = expanded ? notifs : [notifs[0]];

        visible.forEach(n => {
          if (n && !NotificationData.excusedNotifications[n.id]) {
            entries.push({
              key: n.id,
              height: NotificationData.notificationHeights[n.id] ?? Theme.notificationHeight
            });
          }
        });

        if (notifs.length > 1) {
          entries.push({
            key: window.footerKey(name),
            height: window.footerHeight
          });
        }
      });

      return entries;
    }

    readonly property var stackOffsets: {
      const offsets = {};
      let total = 0;

      window.notificationStack.forEach(entry => {
        offsets[entry.key] = total;
        total += entry.height + 4;
      });

      offsets.total = total;
      return offsets;
    }

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
        contentHeight: window.stackOffsets.total ?? 0
        clip: true

        Repeater {
          id: groupsRepeater
          model: window.groupedNotifications

          Item {
            id: group
            required property var modelData

            width: Theme.notificationWidth

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
                  NotificationData.excusedNotifications = Object.assign({}, NotificationData.excusedNotifications, {
                    [modelData.id]: true
                  });
                  closeAnim.running = true;
                }

                readonly property int topMargin: modelData ? (window.stackOffsets[modelData.id] ?? -height) : -height

                anchors {
                  top: group.top
                  topMargin: topMargin + Theme.notificationInnerMargin
                  left: group.left
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
                    shown = true;
                    root.width = Theme.notificationWidth;
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

                      const nextExcused = Object.assign({}, NotificationData.excusedNotifications);
                      delete nextExcused[root.closedId];
                      NotificationData.excusedNotifications = nextExcused;

                      const nextHeights = Object.assign({}, NotificationData.notificationHeights);
                      delete nextHeights[root.closedId];
                      NotificationData.notificationHeights = nextHeights;
                    }
                  }
                  running: false
                }

                width: 0
                height: Theme.notificationHeight + body.implicitHeight - Theme.fontSize
                onHeightChanged: {
                  if (!modelData)
                    return;
                  NotificationData.notificationHeights = Object.assign({}, NotificationData.notificationHeights, {
                    [modelData.id]: height
                  });
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

            Item {
              id: footer

              visible: group.modelData[1].length > 1
              height: window.footerHeight

              anchors {
                top: group.top
                topMargin: (window.stackOffsets[window.footerKey(group.modelData[0])] ?? 0) + Theme.notificationInnerMargin
                left: group.left
                right: group.right
              }

              Behavior on anchors.topMargin {
                NumberAnim {}
              }

              Label {
                text: window.openedNotifications[group.modelData[0]] ? 'collapse' : `expand (+${group.modelData[1].length - 1})`
                anchors.left: parent.left

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
                anchors.right: parent.right

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
}
