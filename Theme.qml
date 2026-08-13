// this file is for all the VISUAL properties - colors, sizes, font, animation, etc..

pragma Singleton

import Quickshell
import QtQuick
import "theme"

Singleton {
  readonly property var selectedTheme: CatppuccinMocha

  // colors
  readonly property color darkbg: selectedTheme.mantle
  readonly property color bg: selectedTheme.base
  readonly property color fg: selectedTheme.text
  readonly property color border: selectedTheme.crust
  readonly property color surface0: selectedTheme.surface0
  readonly property color surface1: selectedTheme.surface1
  readonly property color surface2: selectedTheme.surface2
  readonly property color overlay0: selectedTheme.overlay0
  readonly property color overlay1: selectedTheme.overlay1
  readonly property color overlay2: selectedTheme.overlay2
  readonly property color subtext0: selectedTheme.subtext0
  readonly property color subtext1: selectedTheme.subtext1
  readonly property color purple: selectedTheme.purple
  readonly property color red: selectedTheme.red
  readonly property color orange: selectedTheme.orange
  readonly property color yellow: selectedTheme.yellow
  readonly property color green: selectedTheme.green
  readonly property color blue: selectedTheme.blue

  readonly property color accent: purple

  // colors - do not change these
  readonly property color transparent: '#00000000'
  readonly property color arch: "#1793d1"

  // pixel measurements (excluding font)
  readonly property int barHeight: 50
  readonly property int outsideMargin: 4
  readonly property int rounding: 5
  readonly property int notificationWidth: 350
  readonly property int notificationHeight: 60
  readonly property int notificationInnerMargin: 10

  // font
  readonly property string fontFamily: "JetBrainsMono Nerd Font Propo"
  readonly property int fontType: Font.Bold
  readonly property int fontSize: 14

  // animations
  readonly property int animDuration: 300
  readonly property int easingType: Easing.InOutCubic

  // functions
  function withOpacity(color, alpha) {
    return Qt.rgba(color.r, color.g, color.b, alpha);
  }
}
