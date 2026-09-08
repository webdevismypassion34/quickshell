pragma Singleton

import Quickshell
import QtQuick

// https://github.com/folke/tokyonight.nvim/blob/main/lua/tokyonight/colors/storm.lua
// (Night variant: storm's palette with the darker background overrides)

Singleton {
  readonly property string name: 'TokyoNight'

  readonly property color purple: "#bb9af7"
  readonly property color red: "#f7768e"
  readonly property color orange: "#ff9e64"
  readonly property color yellow: "#e0af68"
  readonly property color green: "#9ece6a"
  readonly property color blue: "#7aa2f7"
  readonly property color teal: "#1abc9c"

  readonly property color text: "#c0caf5"
  readonly property color subtext1: "#a9b1d6"
  readonly property color subtext0: "#737aa2"
  readonly property color overlay2: "#565f89"
  readonly property color overlay1: "#545c7e"
  readonly property color overlay0: "#414868"
  readonly property color surface2: "#3b4261"
  readonly property color surface1: "#292e42"
  readonly property color surface0: "#1a1b26"
  readonly property color base: "#16161e"
  readonly property color mantle: "#0c0e14"
  readonly property color crust: "#0c0e14"
}