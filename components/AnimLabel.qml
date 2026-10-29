import QtQuick
import ".."
import "."
import "../animations"

Item {
  id: root

  clip: true

  required property var text

  property var labels: []
  property var currentLabel

  implicitWidth: currentLabel ? currentLabel.width : 0
  implicitHeight: currentLabel ? currentLabel.height : 0

  Behavior on implicitWidth {
    NumberAnim {}
  }

  Behavior on implicitHeight {
    NumberAnim {}
  }

  function show() {
    if (root.currentLabel)
      root.currentLabel.retire();

    root.currentLabel = labelComponent.createObject(root, {
      text: root.text
    });
  }

  Component.onCompleted: show()
  onTextChanged: show()

  Component {
    id: labelComponent

    Label {
      id: label

      opacity: 0

      Component.onCompleted: {
        fadeIn.start();
      }

      function retire() {
        fadeOut.start();
      }

      NumberAnim {
        id: fadeOut
        target: label
        property: "opacity"
        to: 0
        onFinished: label.destroy()
      }

      NumberAnim {
        id: fadeIn
        target: label
        property: "opacity"
        to: 1
      }
    }
  }
}
