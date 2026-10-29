pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import ".."
import "../components"
import "../animations"

// qmllint disable uncreatable-type
PanelWindow {
  id: popupWindow
  WlrLayershell.namespace: "quickshell-launcher"
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
  visible: popupOpen || closeTimer.running
  color: Theme.transparent

  function search(q) {
    const fuzzy = Utils.fuzzySearch(q, DesktopEntries.applications.values, "name");

    /*
    if (query.startsWith('=')) {
      await execAsync(['qalc', '-t', query.slice(1).trim()])
        .then(out => {
          if (out == '>') return;
          result.unshift([
            '',
            `${query.slice(1).trim()} = ${out}`,
            null,
            '',
            `wl-copy "${out}"`,
            false,
          ]);
        })
        .catch(() => {});
    }
    */

    return [...fuzzy].slice(0, 10);
  }

  readonly property var desktopEntries: search(searchInput.text)
  readonly property bool popupOpen: Popups.openPopup === popupWindow

  property int selected: 0

  onPopupOpenChanged: {
    if (!popupOpen)
      closeTimer.restart();
    else
      searchInput.input.forceActiveFocus();
  }

  Timer {
    id: closeTimer
    interval: Theme.animDuration
    onTriggered: {
      searchInput.text = '';
      popupWindow.selected = 0;
    }
  }

  anchors {
    top: true
    bottom: true
    left: true
    right: true
  }

  ClickArea {
    onClicked: popupWindow.togglePopup()
  }

  function togglePopup() {
    Popups.openPopup = (Popups.openPopup === popupWindow) ? null : popupWindow;
  }

  ClippingRectangle {
    id: content
    anchors.verticalCenter: parent.verticalCenter
    anchors.horizontalCenter: parent.horizontalCenter
    height: 407
    width: popupWindow.popupOpen ? 350 : 0
    opacity: popupWindow.popupOpen ? 1 : 0
    clip: true
    color: Theme.transparent
    radius: Theme.rounding

    Behavior on width {
      NumberAnim {}
    }

    Behavior on opacity {
      NumberAnim {}
    }

    Rectangle {
      anchors.fill: parent
      color: Theme.withOpacity(Theme.bg, 0.9)
      radius: Theme.rounding
      border {
        width: 1
        color: Theme.border
      }

      Input {
        id: searchInput
        placeholder: 'search...'
        border.width: 0
        width: parent.width
        radius: Theme.rounding

        onTextChanged: {
          popupWindow.selected = 0;
        }

        onAccepted: {
          const selected = Math.max(Utils.mod(popupWindow.selected, Math.round(content.height / 37)) - 1, 0);
          popupWindow.desktopEntries[selected].execute();
          popupWindow.togglePopup();
        }

        Keys.onPressed: event => {
          if (event.key === Qt.Key_Down) {
            popupWindow.selected += 1;
            event.accepted = true;
          } else if (event.key === Qt.Key_Up) {
            popupWindow.selected -= 1;
            event.accepted = true;
          } else if (event.key === Qt.Key_Escape) {
            popupWindow.togglePopup();
            event.accepted = true;
          }
        }
      }
    }

    MouseArea {
      anchors.fill: parent
      onClicked: searchInput.input.forceActiveFocus()
    }

    Flickable {
      id: scroll

      width: content.width
      y: searchInput.height + 2
      contentHeight: col.height + 2

      Item {
        id: col
        width: content.width
        anchors.horizontalCenter: parent.horizontalCenter

        Repeater {
          model: popupWindow.desktopEntries

          Rectangle {
            id: entry

            required property DesktopEntry modelData
            required property int index

            width: content.width
            height: 35
            color: Theme.withOpacity(Theme.surface0, 0.3)
            radius: Theme.rounding
            clip: true
            y: entry.index * 37

            Behavior on y {
              NumberAnim {}
            }

            anchors.horizontalCenter: parent.horizontalCenter

            Row {
              anchors.verticalCenter: parent.verticalCenter

              anchors {
                left: parent.left
                leftMargin: 8
              }

              spacing: 8

              ClippingRectangle {
                width: 30
                height: 30
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.transparent

                Image {
                  anchors.fill: parent
                  source: Quickshell.iconPath(entry.modelData.icon)
                  smooth: true
                  mipmap: true
                }
              }

              Label {
                text: entry.modelData.name
                anchors.verticalCenter: parent.verticalCenter
              }
            }
          }
        }
      }
    }

    Rectangle {
      id: selectedBorder

      readonly property int wrappedY: Utils.mod(selectedY, content.height)

      width: content.width
      height: 37
      color: Theme.transparent
      border.width: 1
      border.color: Theme.accent
      y: wrappedY
      radius: Theme.rounding

      property int selectedY: popupWindow.selected * 37

      Behavior on selectedY {
        NumberAnim {
          easing.type: Easing.OutCubic
        }
      }
    }

    Rectangle {
      width: content.width
      height: 37
      color: Theme.transparent
      border.width: 1
      border.color: Theme.accent
      y: selectedBorder.wrappedY - content.height
      radius: Theme.rounding
    }
  }
}
