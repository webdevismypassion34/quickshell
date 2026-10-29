pragma Singleton

import Quickshell
import QtQuick

// https://lospec.com/palette-list/gruvbox-light

Singleton {
  readonly property string name: 'GruvboxLight'

  readonly property color purple: "#8f3f71"
  readonly property color red: "#9d0006"
  readonly property color orange: "#af3a03"
  readonly property color yellow: "#b57614"
  readonly property color green: "#79740e"
  readonly property color blue: "#076678"
  readonly property color teal: "#427b58"

  readonly property color text: "#282828"
  readonly property color subtext1: "#3c3836"
  readonly property color subtext0: "#504945"
  readonly property color overlay2: "#665c54"
  readonly property color overlay1: "#7c6f64"
  readonly property color overlay0: "#928374"
  readonly property color surface2: "#a89984"
  readonly property color surface1: "#bdae93"
  readonly property color surface0: "#d5c4a1"
  readonly property color crust: "#ebdbb2"
  readonly property color mantle: "#f2ecd3"
  readonly property color base: "#fbf1c7"
}
