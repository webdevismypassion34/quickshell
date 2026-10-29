pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import ".."
import "../components"
import "../animations"

import "global"
import "hyprland"
import "quickshell"

Loader {
  id: root

  active: false

  readonly property var sections: {
    'Global': {
      icon: '',
      items: ['Users', 'Theming', 'Wallpaper', 'Defaults',]
    },
    'Hyprland': {
      icon: '',
      items: ['Autostart', 'Keybindings', 'Monitors', 'Windowrules', 'Input', 'Environment',]
    },
    'Quickshell': {
      icon: '󰧨',
      items: ['Status Bar', 'App Launcher', 'Notifications',]
    }
  }
  property var selectedPage: Object.values(sections)[0].items[0]
  property var selectedSection: Object.entries(sections)[0][0]

  function open() {
    root.active = true;
  }

  sourceComponent: FloatingWindow {
    id: window

    implicitWidth: 800
    implicitHeight: 500
    visible: true
    color: Theme.bg

    onVisibleChanged: {
      if (!visible)
        root.active = false;
    }

    MouseArea {
      anchors.fill: parent
      onClicked: forceActiveFocus()
    }

    Row {
      height: parent.height
      spacing: 8

      anchors {
        left: parent.left
        top: parent.top
        bottom: parent.bottom

        leftMargin: 8
        topMargin: 8
        bottomMargin: 8
      }

      Column {
        id: pageList

        width: 150

        Repeater {
          model: Object.entries(root.sections)

          Column {
            id: section

            required property var modelData

            Item {
              height: Theme.fontSize + 8
              width: pageList.width

              Rectangle {
                height: 1
                width: parent.width
                color: Theme.fg
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                  color: Theme.bg
                  width: sectionLabel.width + 8
                  height: Theme.fontSize
                  anchors.horizontalCenter: parent.horizontalCenter
                  anchors.verticalCenter: parent.verticalCenter

                  Label {
                    id: sectionLabel

                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: `${section.modelData[1].icon} ${section.modelData[0]}`
                  }
                }
              }
            }

            Repeater {
              model: section.modelData[1].items

              Label {
                id: page

                required property var modelData

                text: modelData
                color: root.selectedPage === modelData ? Theme.accent : Theme.fg

                ClickArea {
                  onClicked: {
                    root.selectedPage = page.modelData;
                    root.selectedSection = section.modelData[0];
                  }
                }

                Behavior on color {
                  ColorAnim {}
                }
              }
            }
          }
        }
      }

      Rectangle {
        width: 1

        color: Theme.border
        height: parent.height
      }

      Loader {
        width: window.width - pageList.width - 25
        height: parent.height
        source: `${root.selectedSection.toLowerCase()}/${root.selectedPage.replace(' ', '')}.qml`
      }
    }
  }
}
