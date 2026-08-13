import QtQuick
import ".."
import "../animations"

Item {
  id: root

  property int value: 0 // any number

  implicitWidth: 8.1
  implicitHeight: Theme.fontSize
  clip: true

  property int scrollHeight: value * Theme.fontSize
  readonly property int digitAt: root.scrollHeight / Theme.fontSize

  Behavior on scrollHeight {
    NumberAnim {}
  }

  Label {
    id: digit1
    text: (Math.floor(root.digitAt / 2) * 2 + 1) % 10
    y: ((root.scrollHeight) % (Theme.fontSize * 2)) - Theme.fontSize
  }

  Label {
    id: digit2
    text: (Math.floor((root.digitAt - 1) / 2) * 2 + 2) % 10
    y: ((root.scrollHeight + Theme.fontSize) % (Theme.fontSize * 2)) - Theme.fontSize
  }
}
