import QtQuick

Image {
  id: root

  property string artUrl: ''
  property int retriesLeft: 3

  smooth: true
  mipmap: true
  asynchronous: true

  onArtUrlChanged: {
    root.retriesLeft = 3
    root.source = root.artUrl
  }

  onStatusChanged: {
    if (status !== Image.Error || !root.retriesLeft)
      return

    root.retriesLeft--
    retryTimer.restart()
  }

  // retryig so i dont have to restart qs when the art wants to load
  Timer {
    id: retryTimer
    interval: 1500
    onTriggered: {
      root.source = ''
      root.source = root.artUrl
    }
  }
}
