pragma ComponentBehavior: Bound

import Quickshell
import QtQuick

import "widgets"
import "."

Scope {
  property alias windows: variants.instances

  Variants {
    id: variants
    model: Quickshell.screens

    // qmllint disable uncreatable-type
    PanelWindow {
      id: bar

      required property var modelData
      screen: modelData
      color: Theme.transparent

      anchors {
        top: Settings.statusBarSide !== 'bottom'
        left: Settings.statusBarSide !== 'right'
        right: Settings.statusBarSide !== 'left'
        bottom: Settings.statusBarSide !== 'top'
      }

      // qmllint disable unqualified
      margins {
        top: Settings.statusBarSide !== 'bottom' && Theme.outsideMargin
        left: Settings.statusBarSide !== 'right' && Theme.outsideMargin
        right: Settings.statusBarSide !== 'left' && Theme.outsideMargin
        bottom: Settings.statusBarSide !== 'top' && Theme.outsideMargin
      }
      // qmllint enable unqualified

      Rectangle {
        anchors.fill: parent
        color: Theme.withOpacity(Theme.bg, 0.7)
        border.color: Theme.border
        border.width: 1
        radius: Theme.rounding
      }

      implicitHeight: Theme.barHeight

      // left
      Row {
        anchors {
          left: parent.left
          verticalCenter: parent.verticalCenter
          leftMargin: 8
        }
        spacing: 8

        Row {
          spacing: 4

          Arch {}
          Workspaces {
            screen: bar.modelData.name
          }
        }

        Player {}
      }

      Row {
        anchors.centerIn: parent
        spacing: 8

        Clock {}
      }

      Row {
        anchors {
          right: parent.right
          verticalCenter: parent.verticalCenter
          rightMargin: 8
        }
        spacing: 8

        Wifi {}
        Bluetooth {}
        Battery {}
        Volume {}
        Notifications {}
      }
    }
  }
}
