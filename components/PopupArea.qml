import QtQuick
import QtQuick.Window
import Quickshell
import ".."
import "../animations"

Item {
  id: root

  // external - meant to be changed outside this file
  property color popupColor: Theme.surface0
  property int popupWidth: 200
  property int popupHeight: 200
  property bool ver: false // animate that dimension
  property bool hor: true // animate that dimension
  property int verAlign: 0 // which way to align (0: left, 1: center, 2: right)
  property int horAlign: 1 // which way to align (0: left, 1: center, 2: right)
  property bool drawBorder: true

  // internal - should never be changed from outside this file, but can be viewed
  property int topMargin: 10
  property bool hovered: false
  readonly property bool popupOpen: Popups.openPopup === root

  default property alias popupContent: contentRect.data
  property alias popupWindow: popupWindow

  function togglePopup() {
    Popups.openPopup = (Popups.openPopup === root) ? null : root;
  }

  onPopupOpenChanged: {
    if (!popupOpen)
      closeTimer.restart();
  }

  anchors.fill: parent

  MouseArea {
    anchors.fill: parent
    cursorShape: Qt.PointingHandCursor
    hoverEnabled: true
    onEntered: root.hovered = true
    onExited: root.hovered = false
    onClicked: root.togglePopup()
  }

  PopupWindow {
    id: popupWindow

    visible: root.popupOpen || closeTimer.running
    color: Theme.transparent
    anchor.item: root.parent
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.adjustment: PopupAdjustment.SlideX
    anchor.margins.left: Theme.outsideMargin
    anchor.margins.right: Theme.outsideMargin
    implicitWidth: root.popupWidth
    implicitHeight: root.popupHeight

    Timer {
      id: closeTimer
      interval: Theme.animDuration
    }

    Item {
      // qmllint disable Quick.anchor-combinations
      anchors {
        top: root.verAlign === 0 ? parent.top : undefined
        topMargin: root.topMargin
        horizontalCenter: root.horAlign === 1 ? parent.horizontalCenter : undefined
        verticalCenter: root.verAlign === 1 ? parent.verticalCenter : undefined
        right: root.horAlign === 2 ? parent.right : undefined
        bottom: root.verAlign === 2 ? parent.bottom : undefined
      }
      // qmllint enable Quick.anchor-combinations

      opacity: (root.popupOpen || closeTimer.running) ? 1 : 0

      height: root.ver ? (root.popupOpen ? (root.popupHeight - root.topMargin) : 0) : root.popupHeight - root.topMargin
      width: root.hor ? (root.popupOpen ? root.popupWidth : 0) : root.popupWidth

      clip: true

      Behavior on height {
        NumberAnim {}
      }

      Behavior on width {
        NumberAnim {}
      }

      Behavior on scale {
        NumberAnim {}
      }

      Rectangle {
        id: contentRect
        anchors.horizontalCenter: parent.horizontalCenter
        width: root.popupWidth
        height: root.popupHeight - root.topMargin
        radius: Theme.rounding
        border.color: Theme.border
        border.width: +root.drawBorder
        color: root.popupColor === Theme.transparent ? root.popupColor : Theme.withOpacity(root.popupColor, 0.9)
      }
    }
  }
}
