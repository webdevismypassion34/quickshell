import QtQuick

MouseArea {
  property bool hovered: false

  anchors.fill: parent
  cursorShape: Qt.PointingHandCursor
  hoverEnabled: true

  onEntered: hovered = true
  onExited: hovered = false
}
