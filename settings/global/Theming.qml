import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import "../.."
import "../../components"
import "../../theme"

Column {
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
        const selectedScheme = schemeSelect.displayText.replace(' ', '');

        // qmllint disable eval
        if (/^[a-zA-Z]+$/.test(selectedScheme) && Theme.selectedTheme.name !== selectedScheme)
          Theme.selectedTheme = eval(selectedScheme);
        // qmllint enable eval

        Theme.accent = Theme.selectedTheme[accentSelect.displayText.toLowerCase()];

        Theme.changeGlobalTheme();
      }
    }
  }

  Column {
    spacing: 4

    Row {
      id: colorSchemes

      spacing: 5

      property var colorSchemes: []

      Process {
        id: colorSchemeProc

        running: true
        command: ['ls', 'theme']
        workingDirectory: Settings.configDir

        stdout: StdioCollector {
          onStreamFinished: colorSchemes.colorSchemes = this.text.split('\n').filter(v => v.includes('.qml')).map(v => v.split('.')[0])
        }
      }

      Label {
        anchors.verticalCenter: parent.verticalCenter
        text: 'Color Scheme:'
      }

      Select {
        id: schemeSelect

        width: 200
        options: colorSchemes.colorSchemes.map(v => v.replace(/[a-z][A-Z]/, v => v[0] + ' ' + v[1]))
        currentIndex: colorSchemes.colorSchemes.findIndex(v => v === Theme.selectedTheme.name)
      }
    }

    Row {
      id: accents

      spacing: 5

      Label {
        anchors.verticalCenter: parent.verticalCenter
        text: 'Accent Color:'
      }

      Select {
        id: accentSelect

        width: 200
        options: ['Red', 'Orange', 'Yellow', 'Green', 'Teal', 'Blue', 'Purple',]
        currentIndex: options.findIndex(v => v.toLowerCase() === Settings.persistent.currentAccent)
      }
    }

    Row {
      id: radius

      spacing: 5

      Label {
        anchors.verticalCenter: parent.verticalCenter
        text: 'Border Radius:'
      }

      NumberInput {
        placeholder: '#'
        width: 50
      }
    }
  }
}
