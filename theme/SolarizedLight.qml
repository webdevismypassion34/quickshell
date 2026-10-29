pragma Singleton

import Quickshell
import QtQuick

// https://ethanschoonover.com/solarized/

Singleton {
  readonly property string name: 'SolarizedLight'

  readonly property color purple: "#6c71c4"
  readonly property color red: "#dc322f"
  readonly property color orange: "#cb4b16"
  readonly property color yellow: "#b58900"
  readonly property color green: "#859900"
  readonly property color blue: "#268bd2"
  readonly property color teal: "#2aa198"

  readonly property color text: "#586e75"
  readonly property color subtext1: "#657b83"
  readonly property color subtext0: "#839496"
  readonly property color overlay2: "#93a1a1"
  readonly property color overlay1: "#a8b2ac"
  readonly property color overlay0: "#bcc4b7"
  readonly property color surface2: "#d0d5c2"
  readonly property color surface1: "#dfe2cd"
  readonly property color surface0: "#e9e6d4"
  readonly property color crust: "#eee8d5"
  readonly property color mantle: "#f5f0dc"
  readonly property color base: "#fdf6e3"
}
