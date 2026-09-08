pragma Singleton

import Quickshell
import QtQuick

// https://github.com/rose-pine/palette (main/dark variant)
// accent -> role mapping follows the project's own official kitty port:
// https://github.com/rose-pine/kitty/blob/main/dist/rose-pine.conf

Singleton {
  readonly property string name: 'RosePine'

  readonly property color purple: "#c4a7e7"
  readonly property color red: "#eb6f92"
  // no distinct orange in the palette (only 6 accent hues total) - gold is
  // the warmest of them, reused here for both yellow and orange
  readonly property color orange: "#f6c177"
  readonly property color yellow: "#f6c177"
  readonly property color green: "#31748f"
  readonly property color blue: "#9ccfd8"
  readonly property color teal: "#ebbcba"

  readonly property color text: "#e0def4"
  readonly property color subtext1: "#908caa"
  readonly property color subtext0: "#6e6a86"
  readonly property color overlay2: "#524f67"
  readonly property color overlay1: "#403d52"
  readonly property color overlay0: "#26233a"
  readonly property color surface2: "#21202e"
  readonly property color surface1: "#1f1d2e"
  readonly property color surface0: "#191724"
  readonly property color base: "#191724"
  readonly property color mantle: "#191724"
  readonly property color crust: "#191724"
}