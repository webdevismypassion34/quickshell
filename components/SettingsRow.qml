import QtQuick
import ".."

Row {
  required property string label
  property int labelWidth: 120

  spacing: 5

  Label {
    width: parent.labelWidth
    anchors.verticalCenter: parent.verticalCenter
    text: parent.label
  }
}
