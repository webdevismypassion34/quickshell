import Quickshell.Services.Pipewire
import QtQuick
import ".."
import "../components"
import "../animations"

PopupButton {
  id: root
  readonly property PwNode sink: Pipewire.defaultAudioSink
  readonly property int volume: Math.round(sink?.audio?.volume * 100 ?? 0)

  function getIcon(vol) {
    return vol === 0 ? '' : '';
  }

  PwObjectTracker {
    objects: [root.sink]
  }

  text: volume !== undefined ? `${getIcon(volume)} ${volume}%` : '?'
  accentColor: Theme.yellow

  Label {
    text: 'volume'
  }
}
