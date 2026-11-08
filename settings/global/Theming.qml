import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import "../.."
import "../../components"
import "../../theme"

Column {
  id: root

  readonly property var simpleFields: [
    { key: 'rounding', label: 'Rounding:', min: 0, max: 99 },
    { key: 'power', label: 'Power:', min: 1, max: 5 },
    { key: 'outsideMargin', label: 'Margin:', min: 0, max: 99 },
  ]

  Item {
    width: parent.width
    height: applyBtn.height

    Label {
      text: "Theming"
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
        const selectedScheme = schemeSelect.displayText.replace(' ', '')

        // qmllint disable eval
        if (/^[a-zA-Z]+$/.test(selectedScheme) && Theme.selectedTheme.name !== selectedScheme)
          Theme.selectedTheme = eval(selectedScheme)
        // qmllint enable eval

        Theme.accent = Theme.selectedTheme[accentSelect.displayText.toLowerCase()]

        Theme.changeGlobalTheme()
      }
    }
  }

  Column {
    spacing: 4

    SettingsRow {
      id: schemeRow

      label: 'Color Scheme:'

      property var colorSchemes: []

      Process {
        id: colorSchemeProc

        running: true
        command: ['ls', 'theme']
        workingDirectory: Settings.configDir

        stdout: StdioCollector {
          onStreamFinished: schemeRow.colorSchemes = this.text.split('\n').filter(v => v.includes('.qml')).map(v => v.split('.')[0])
        }
      }

      Select {
        id: schemeSelect

        width: 200
        options: schemeRow.colorSchemes.map(v => v.replace(/[a-z][A-Z]/, v => v[0] + ' ' + v[1]))
        currentIndex: schemeRow.colorSchemes.findIndex(v => v === Theme.selectedTheme.name)
      }
    }

    SettingsRow {
      label: 'Accent Color:'

      Select {
        id: accentSelect

        width: 200
        options: ['Red', 'Orange', 'Yellow', 'Green', 'Teal', 'Blue', 'Purple',]
        currentIndex: options.findIndex(v => v.toLowerCase() === Settings.persistent.currentAccent)
      }
    }

    Repeater {
      model: root.simpleFields

      SettingsField {
        required property var modelData

        target: Theme
        field: modelData
      }
    }
  }
}
