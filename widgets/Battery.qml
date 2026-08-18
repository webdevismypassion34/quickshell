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

  function formatChangeRate(rate, state) {
    const sign = state === UPowerDeviceState.Charging ? '+' : state === UPowerDeviceState.Discharging ? '-' : '';
    return `${sign}${rate.toFixed(1)} W`;
  }

  function formatDuration(seconds) {
    if (!seconds)
      return 'calculating...';
    const h = Math.floor(seconds / 3600);
    const m = Math.round((seconds % 3600) / 60);
    return h > 0 ? `${h}h ${m}m` : `${m}m`;
  }

  readonly property UPowerDevice device: UPower.displayDevice
  readonly property int battery: Math.round(device.percentage * 100)

  text: `${getIcon(battery)} ${battery}%`
  accentColor: Theme.green
  popupWidth: 330

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

  Row {
    x: 10
    y: 40

    spacing: 10

    Item {
      id: gauge

      property color trackColor: Theme.withOpacity(Theme.green, 0.3)
      property color arcColor: Theme.withOpacity(Theme.green, 0.8)
      property real lineWidth: 10

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
    
    Column {
      Label {
        text: `Status: ${UPowerDeviceState.toString(root.device.state)}`
      }

      Label {
        text: `Change Rate: ${root.formatChangeRate(root.device.changeRate, root.device.state)}`
      }

      Label {
        text: {
          const empty = root.device.timeToEmpty;
          const full = root.device.timeToFull;
          if (!empty && !full)
            return 'Time remaining: calculating...';
          return empty > 0 ? `Time to empty: ${root.formatDuration(empty)}` : `Time to full: ${root.formatDuration(full)}`;
        }
      }
    }
  }
}
