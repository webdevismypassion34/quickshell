import QtQuick.Dialogs
import "."

Button {
  id: dirSelect

  property string value: ''

  signal accepted(string path)

  border.width: 1
  text: value

  onClicked: folderDialog.open()

  FolderDialog {
    id: folderDialog
    title: 'Choose a folder'
    currentFolder: dirSelect.value ? `file://${dirSelect.value}` : ''

    onAccepted: dirSelect.accepted(selectedFolder.toString().replace('file://', ''))
  }
}
