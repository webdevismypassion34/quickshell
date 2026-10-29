pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls
import Qt.labs.folderlistmodel
import "../.."
import "../../components"
import "../../theme"
import "../../animations"

Column {
  id: root

  property string selected: ''
  property var wallpapers: []

  Component.onCompleted: {
    Utils.exec(['awww', 'query', '--json'], stdout => {
      root.selected = JSON.parse(stdout)[''][0].displaying.image;
    });
  }

  FolderListModel {
    id: wallpaperModel

    folder: 'file://' + Settings.wallpaperDir
    showDirs: false
    sortField: FolderListModel.Name

    onStatusChanged: if (status === FolderListModel.Ready)
      root.wallpapers = Array.from({
        length: count
      }, (_, i) => get(i, 'fileName'))
  }

  Item {
    width: parent.width
    height: 35

    Label {
      text: "Wallpaper"
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  Column {
    spacing: 4

    Row {
      id: backend

      spacing: 5

      property var colorSchemes: []

      Label {
        anchors.verticalCenter: parent.verticalCenter
        text: 'Wallpaper Backend:'
      }

      Select {
        id: schemeSelect

        width: 120
        options: ['awww', 'hyprpaper'] // @TODO add more options, wire up hyprpaper
        currentIndex: 0
      }
    }

    Row {
      spacing: 5

      Column {
        id: wallpaperBig

        ClippingRectangle {
          id: wallpaper

          readonly property int ratioScale: 20

          color: Theme.bg
          width: 16 * ratioScale
          height: 9 * ratioScale
          radius: Theme.rounding

          border {
            width: 1
            color: Theme.border
          }

          Image {
            anchors.fill: parent
            source: root.selected
            smooth: true
            mipmap: true
            asynchronous: true
            sourceSize: Qt.size(wallpaper.width, wallpaper.height)
          }
        }

        Label {
          text: root.selected.split('/').pop()
          anchors.horizontalCenter: parent.horizontalCenter
        }
      }

      Flickable {
        width: root.width - wallpaperBig.width - 5
        height: 180

        clip: true
        contentWidth: cols.width
        contentHeight: height
        flickableDirection: Flickable.HorizontalFlick

        Row {
          id: cols

          spacing: 2

          Repeater {
            model: root.wallpapers.filter(item => item && (item.includes('.png') || item.includes('.jp'))).reduce((cols, item, i) => {
              if (i % 3 === 0)
                cols.push([item]);
              else
                cols[cols.length - 1].push(item);
              return cols;
            }, [])

            Column {
              id: col

              required property var modelData

              spacing: 2

              Repeater {
                model: col.modelData

                ClippingRectangle {
                  id: wallpaperSmall

                  required property string modelData
                  readonly property real ratioScale: (180 - 2 * 2) / 3 / 9

                  color: Theme.bg
                  width: 16 * ratioScale
                  height: 9 * ratioScale
                  radius: Theme.rounding

                  border {
                    width: 1
                    color: wallpaperSelect.hovered ? Theme.accent : Theme.border

                    Behavior on color {
                      ColorAnim {}
                    }
                  }

                  Image {
                    anchors.fill: parent
                    source: Settings.wallpaperDir + '/' + wallpaperSmall.modelData
                    smooth: true
                    mipmap: true
                    asynchronous: true
                    sourceSize: Qt.size(wallpaperSmall.width, wallpaperSmall.height)
                  }

                  ClickArea {
                    id: wallpaperSelect
                    onClicked: () => {
                      Utils.exec(['awww', 'img', Settings.wallpaperDir + '/' + wallpaperSmall.modelData]);
                      root.selected = Settings.wallpaperDir + '/' + wallpaperSmall.modelData;
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
