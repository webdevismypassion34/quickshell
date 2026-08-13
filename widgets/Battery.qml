import QtQuick
import QtQuick.Shapes
import Quickshell.Services.UPower
import ".."
import "../components"

PopupButton {
  id: root

  function getIcon(percent) {
    if (UPower.onBattery)
      return ['󰂎', '󰁺', '󰁻', '󰁼', '󰁽', '󰁾', '󰁿', '󰂀', '󰂁', '󰂂', '󰁹'][Math.round(percent / 10)] ?? '?';
    else
      return ['󰢟', '󰢜', '󰂆', '󰂇', '󰂈', '󰢝', '󰂉', '󰢞', '󰂊', '󰂋', '󰂅'][Math.round(percent / 10)] ?? '?';
  }

  readonly property int battery: Math.round(UPower.displayDevice.percentage * 100)

  text: `${getIcon(battery)} ${battery}%`
  accentColor: Theme.green

  Label {
    text: 'Battery'
    anchors {
      top: parent.top
      left: parent.left
      topMargin: 10
      leftMargin: 10
      rightMargin: 10
    }
  }

  Item {
    id: gauge

    property color trackColor: Theme.withOpacity(Theme.green, 0.3)
    property color arcColor: Theme.withOpacity(Theme.green, 0.8)
    property real lineWidth: 15

    x: 10
    y: 40

    width: 100
    height: width

    // background track (full circle)
    Shape {
      anchors.fill: parent
      antialiasing: true
      preferredRendererType: Shape.CurveRenderer
      ShapePath {
        strokeWidth: gauge.lineWidth
        strokeColor: gauge.trackColor
        fillColor: "transparent"
        capStyle: ShapePath.RoundCap

        PathAngleArc {
          centerX: gauge.width / 2
          centerY: gauge.height / 2
          radiusX: gauge.width / 2 - gauge.lineWidth / 2
          radiusY: radiusX
          startAngle: -90
          sweepAngle: 360
        }
      }
    }

    // progress arc
    Shape {
      anchors.fill: parent
      antialiasing: true
      preferredRendererType: Shape.CurveRenderer
      ShapePath {
        strokeWidth: gauge.lineWidth
        strokeColor: gauge.arcColor
        fillColor: "transparent"
        capStyle: ShapePath.FlatCap

        PathAngleArc {
          centerX: gauge.width / 2
          centerY: gauge.height / 2
          radiusX: gauge.width / 2 - gauge.lineWidth / 2
          radiusY: radiusX
          startAngle: -90
          sweepAngle: 360 * (root.battery / 100)

          Behavior on sweepAngle {
            NumberAnimation {
              duration: 200
            }
          }
        }
      }
    }

    Label {
      anchors.centerIn: parent
      text: root.battery + '%'
      font.pixelSize: 21
    }
  }
}
