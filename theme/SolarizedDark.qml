pragma Singleton

import Quickshell
import QtQuick

// https://ethanschoonover.com/solarized/

Singleton {
  readonly property string name: 'SolarizedDark'

  readonly property color purple: "#6c71c4"
  readonly property color red: "#dc322f"
  readonly property color orange: "#cb4b16"
  readonly property color yellow: "#b58900"
  readonly property color green: "#859900"
  readonly property color blue: "#268bd2"
  readonly property color teal: "#2aa198"

  readonly property color text: "#93a1a1"
  readonly property color subtext1: "#839496"
  readonly property color subtext0: "#657b83"
  readonly property color overlay2: "#586e75"
  readonly property color overlay1: "#4a5c63"
  readonly property color overlay0: "#3c4d53"
  readonly property color surface2: "#2d3c42"
  readonly property color surface1: "#0f3039"
  readonly property color surface0: "#073642"
  readonly property color base: "#002b36"
  readonly property color mantle: "#00242e"
  readonly property color crust: "#001e26"
}
