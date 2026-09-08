pragma Singleton

import Quickshell
import QtQuick

// https://lospec.com/palette-list/gruvbox-dark

Singleton {
  readonly property string name: 'Gruvbox'

  readonly property color purple: "#b16286"
  readonly property color red: "#fb4934"
  readonly property color orange: "#fe8019"
  readonly property color yellow: "#fabd2f"
  readonly property color green: "#b8bb26"
  readonly property color blue: "#458588"
  readonly property color teal: "#689d6a"

  readonly property color text: "#ebdbb2"
  readonly property color subtext1: "#d5c4a1"
  readonly property color subtext0: "#bdae93"
  readonly property color overlay2: "#a89984"
  readonly property color overlay1: "#928374"
  readonly property color overlay0: "#7c6f64"
  readonly property color surface2: "#665c54"
  readonly property color surface1: "#504945"
  readonly property color surface0: "#3c3836"
  readonly property color base: "#32302f"
  readonly property color mantle: "#282828"
  readonly property color crust: "#1d2021"
}
