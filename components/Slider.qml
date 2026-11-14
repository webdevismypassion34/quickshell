import QtQuick
import ".."

Row {
  id: root

  height: Theme.fontSize * 2

  spacing: 10

  property real value: min
  property real min: 0
  property real max: 100
  property real step: 1
  signal moved

  TextMetrics {
    id: tm

    font {
      family: Theme.fontFamily
      pixelSize: Theme.fontSize
    }

    text: root.max
  }

  Label {
    text: root.value
    anchors.verticalCenter: parent.verticalCenter
    width: tm.advanceWidth
  }

  Item {
    id: slider

    anchors.verticalCenter: parent.verticalCenter

    height: 12
    width: 100

    Rectangle {
      color: Theme.surface1
      width: slider.width
      height: slider.height / 1.5
      anchors.verticalCenter: parent.verticalCenter
      radius: Theme.rounding
    }

    Rectangle {
      id: filled
      color: Theme.surface2
      width: slider.width * (root.value - root.min) / (root.max - root.min)
      height: slider.height / 1.5
      radius: Theme.rounding
      anchors.verticalCenter: parent.verticalCenter
    }

    Rectangle {
      width: slider.height
      height: width
      radius: Theme.rounding
      color: Theme.overlay0
      x: filled.width - width / 2
    }

    MouseArea {
      anchors.fill: parent
      preventStealing: true

      function update(x) {
        const r = Math.max(0, Math.min(1, x / slider.width))
        let v = root.min + r * (root.max - root.min)
        if (root.step > 0)
          v = root.min + Math.round((v - root.min) / root.step) * root.step
        let oldValue = root.value
        root.value = Math.min(root.max, v)
        if (oldValue !== root.value)
          root.moved()
      }

      onPressed: e => update(e.x)
      onPositionChanged: e => {
        if (pressed)
          update(e.x)
      }
    }
  }
}
