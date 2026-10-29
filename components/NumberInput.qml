import QtQuick
import ".."
import "../animations"

Rectangle {
  id: root

  property alias text: input.text
  property string placeholder: ""
  property color accentColor: Theme.surface0
  property alias input: input
  property real min: -Infinity
  property real max: Infinity
  readonly property int valueDigits: Math.max(isFinite(max) ? Math.abs(Math.trunc(max)).toString().length : 0, isFinite(min) ? Math.abs(Math.trunc(min)).toString().length : 0, 1)
  readonly property bool showsSign: min < 0

  signal accepted

  radius: Theme.rounding
  color: Theme.withOpacity(accentColor, 0.3)
  border.color: input.activeFocus ? Theme.accent : Theme.border
  border.width: 1
  width: (isFinite(min) || isFinite(max)) ? metrics.width + 40 : 200
  height: 35

  TextMetrics {
    id: metrics
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Theme.fontType
    text: '0'.repeat(root.valueDigits) + (root.showsSign ? '-' : '')
  }

  function clamp(value) {
    return Math.min(root.max, Math.max(root.min, value));
  }

  function step(delta) {
    input.text = String(root.clamp((parseInt(input.text, 10) || 0) + delta));
  }

  Behavior on border.color {
    ColorAnim {}
  }

  MouseArea {
    anchors.fill: parent
    onPressed: input.forceActiveFocus()
  }

  Label {
    visible: input.text.length === 0
    text: root.placeholder
    color: Theme.subtext0

    anchors {
      left: parent.left
      verticalCenter: parent.verticalCenter
      leftMargin: 10
    }
  }

  TextInput {
    id: input

    validator: RegularExpressionValidator {
      regularExpression: /-?[0-9]*/
    }

    anchors {
      left: parent.left
      right: spinner.left
      verticalCenter: parent.verticalCenter
      leftMargin: 10
      rightMargin: 6
    }

    color: Theme.fg
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontSize
    font.weight: Theme.fontType
    selectionColor: Theme.blue
    selectedTextColor: Theme.fg
    clip: true

    onAccepted: {
      if (text.length)
        text = String(root.clamp(parseInt(text, 10) || 0));
      root.accepted();
    }
    onActiveFocusChanged: {
      if (activeFocus)
        return;
      deselect();
      if (text.length)
        text = String(root.clamp(parseInt(text, 10) || 0));
    }
  }

  Column {
    id: spinner

    anchors {
      top: parent.top
      bottom: parent.bottom
      right: parent.right
      rightMargin: 6
    }
    width: 14

    Label {
      width: parent.width
      height: parent.height / 2
      text: '▲'
      font.pixelSize: 8
      color: increase.hovered ? Theme.fg : Theme.subtext0
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter

      ClickArea {
        id: increase
        onClicked: root.step(1)
      }
    }

    Label {
      width: parent.width
      height: parent.height / 2
      text: '▼'
      font.pixelSize: 8
      color: decrease.hovered ? Theme.fg : Theme.subtext0
      horizontalAlignment: Text.AlignHCenter
      verticalAlignment: Text.AlignVCenter

      ClickArea {
        id: decrease
        onClicked: root.step(-1)
      }
    }
  }
}
