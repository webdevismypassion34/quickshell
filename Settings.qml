// this file is for all the NON-VISUAL properties - data, layout, feature configs, etc..

pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  FileView {
    id: persistentFile
    path: `${root.configDir}/persistent.json`
    blockLoading: true
  }

  readonly property string configDir: `${Quickshell.env("XDG_CONFIG_HOME")}/quickshell`
  readonly property var persistent: new Proxy(JSON.parse(persistentFile.text()), {
    set(target, prop, value) {
      target[prop] = value;
      persistentFile.setText(JSON.stringify(target, null, 2));
      return true;
    }
  })

  readonly property string wallpaperDir: `${Quickshell.env("HOME")}/wallpaper`

  property bool censorWifiNames: false

  property string statusBarSide: 'top'

  /*

  archNodes<{
    type: 'button' | 'sep'
    label?: string
    action?: string
    requires?: ('activewindow')[]
  }[]>: the nodes for the Arch button (see ./widgets/Arch.qml)

  type - 'button' for a regular button and 'sep' for a seperator
  [optional] label - the label to display, replaces select keywords with variables (only applies to button), see options:
    * %A - the class of the current window
  [optional] action - the action to do when clicking the node (only applies to button), see options:
    * run:x - run x in shell
    * dispatch:x - dispatch x to hyprland
  [optional] requires - what variables need to be valid to display that node, see options:
    * activewindow - the currently active window+. should only exist on a workspace with 1+ window(s) and otherwise be null

  */

  readonly property var archNodes: [
    {
      type: 'button',
      label: 'about this distro',
      action: 'run:kitty --hold fastfetch'
    },
    {
      type: 'button',
      label: 'system settings',
      action: 'run:qs ipc call settings open'
    },
    {
      type: 'sep'
    },
    {
      type: 'button',
      label: 'close %A',
      action: 'dispatch:killactive',
      requires: ['activewindow']
    },
    {
      type: 'button',
      label: 'force quit %A',
      action: 'dispatch:forcekillactive',
      requires: ['activewindow']
    },
    {
      type: 'sep',
      requires: ['activewindow']
    },
    {
      type: 'button',
      label: 'lock',
      action: 'run:hyprlock'
    },
    {
      type: 'button',
      label: 'reboot',
      action: 'run:reboot'
    },
    {
      type: 'button',
      label: 'logout',
      action: 'run:uwsm stop'
    },
    {
      type: 'button',
      label: 'shutdown',
      action: 'run:shutdown'
    },
  ]

  /*

  player<string>: the dbus name of the player to show information for via the player widget (see ./widgets/Player.qml)

  Formatted as org.mpris.MediaPlayer2.*, this can be obtained via `busctl --user list | grep org.mpris.MediaPlayer2`

  */

  readonly property string player: 'org.mpris.MediaPlayer2.spotify'

  /*

  vpnLocation<string>: the city to connect to by default

  */

  property string vpnLocation: 'New York'
}
