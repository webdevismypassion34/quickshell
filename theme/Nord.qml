pragma Singleton

import Quickshell
import QtQuick

// https://www.nordtheme.com/docs/colors-and-palettes

Singleton {
  readonly property string name: 'Nord'

  readonly property color purple: "#b48ead"
  readonly property color red: "#bf616a"
  readonly property color orange: "#d08770"
  readonly property color yellow: "#ebcb8b"
  readonly property color green: "#a3be8c"
  readonly property color blue: "#88c0d0"
  readonly property color teal: "#8fbcbb"

  // Nord only has 7 neutral tones (nord0-nord6, split into a 4-tone dark
  // "Polar Night" group and a 3-tone light "Snow Storm" group with no
  // in-between shades), so some slots below intentionally repeat a tone -
  // that's the real palette, not a mistake.
  readonly property color text: "#eceff4"
  readonly property color subtext1: "#e5e9f0"
  readonly property color subtext0: "#d8dee9"
  readonly property color overlay2: "#4c566a"
  readonly property color overlay1: "#4c566a"
  readonly property color overlay0: "#434c5e"
  readonly property color surface2: "#434c5e"
  readonly property color surface1: "#3b4252"
  readonly property color surface0: "#3b4252"
  readonly property color base: "#2e3440"
  readonly property color mantle: "#2e3440"
  readonly property color crust: "#2e3440"
}