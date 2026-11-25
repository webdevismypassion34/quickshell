pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import "../.."
import "../../components"
import "../../theme"
import "../../animations"

Column {
  id: root

  // bro wtf does this even do dont ask me
  readonly property var keyboardMethods: fcitxProfile.text().split(/\n(?=\[)/).filter(s => s.startsWith('[Groups/0/Items/')).map(s => s.match(/Name=(.+)/)?.[1]).filter(Boolean)

  FileView {
    id: fcitxProfile
    path: `${Settings.home}/fcitx5/profile`
    blockLoading: true
  }

  function applyKeyboardMethod(method) {
    Settings.keyboardMethod = method
    Settings.persistent.keyboardMethod = method
    Utils.exec(['fcitx5-remote', '-s', method])
    fcitxProfile.setText(fcitxProfile.text().replace(/DefaultIM=\S*/, `DefaultIM=${method}`))
  }

  Item {
    width: parent.width
    height: applyBtn.height

    Label {
      text: "Input"
      anchors.verticalCenter: parent.verticalCenter
    }

    Button {
      id: applyBtn

      text: 'Apply'

      anchors {
        verticalCenter: parent.verticalCenter
        right: parent.right
        rightMargin: 8
      }

      onClicked: {
        Settings.accelProfile = accelSelect.currentText
        Settings.persistent.accelProfile = Settings.accelProfile

        Settings.sensitivity = sensitivitySlider.value
        Settings.persistent.sensitivity = Settings.sensitivity

        Settings.naturalScroll = naturalScrollToggle.checked
        Settings.persistent.naturalScroll = Settings.naturalScroll

        Settings.tapToClick = tapToClickToggle.checked
        Settings.persistent.tapToClick = Settings.tapToClick

        Theme.applyTemplate('hyprland.lua')

        root.applyKeyboardMethod(layoutSelect.currentText)
      }
    }
  }

  Column {
    spacing: 4

    SettingsRow {
      label: 'Accel Profile:'

      Select {
        id: accelSelect

        width: 120
        options: ['flat', 'adaptive']
        currentIndex: options.indexOf(Settings.accelProfile)
      }
    }

    SettingsRow {
      label: 'Keyboard Layout:'

      Select {
        id: layoutSelect

        width: 120
        options: root.keyboardMethods
        currentIndex: options.indexOf(Settings.keyboardMethod)
      }
    }

    SettingsRow {
      label: 'Natural Scroll:'

      Toggle {
        id: naturalScrollToggle

        anchors.verticalCenter: parent.verticalCenter
        checked: Settings.naturalScroll
      }
    }

    SettingsRow {
      label: 'Sensitivity:'

      Slider {
        id: sensitivitySlider

        width: 100
        min: -1
        max: 1
        step: 0.1
        value: Settings.sensitivity
        anchors.verticalCenter: parent.verticalCenter
      }
    }

    SettingsRow {
      label: 'Tap to Click:'

      Toggle {
        id: tapToClickToggle

        anchors.verticalCenter: parent.verticalCenter
        checked: Settings.tapToClick
      }
    }
  }
}
