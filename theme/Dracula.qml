pragma Singleton

import Quickshell
import QtQuick

// https://draculatheme.com/spec

Singleton {
  readonly property string name: 'Dracula'

  readonly property color purple: "#bd93f9"
  readonly property color red: "#ff5555"
  readonly property color orange: "#ffb86c"
  readonly property color yellow: "#f1fa8c"
  readonly property color green: "#50fa7b"
  readonly property color blue: "#8be9fd"
  readonly property color teal: "#8be9fd"

  // the official spec only defines 4 neutral tones (background, selection,
  // comment, foreground) - deliberately minimal by design - so most slots
  // below repeat one of those 4, not a mistake.
  readonly property color text: "#f8f8f2"
  readonly property color subtext1: "#f8f8f2"
  readonly property color subtext0: "#6272a4"
  readonly property color overlay2: "#6272a4"
  readonly property color overlay1: "#44475a"
  readonly property color overlay0: "#44475a"
  readonly property color surface2: "#44475a"
  readonly property color surface1: "#282a36"
  readonly property color surface0: "#282a36"
  readonly property color base: "#282a36"
  readonly property color mantle: "#282a36"
  readonly property color crust: "#282a36"
}