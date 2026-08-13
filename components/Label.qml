import QtQuick
import ".."

Text {
  color: Theme.fg
  font.family: Theme.fontFamily
  font.pixelSize: Theme.fontSize
  font.weight: Theme.fontType
  renderType: Text.NativeRendering

  height: Theme.fontSize * 1.2
  verticalAlignment: Text.AlignVCenter
}
