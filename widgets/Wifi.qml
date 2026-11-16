pragma ComponentBehavior: Bound

import Quickshell.Networking
import Quickshell.Io
import QtQuick
import ".."
import "../components"
import "../animations"

PopupButton {
  id: root

  readonly property var computeWifiName: ssid => (Settings.censorWifiNames && ssid && ssid.length > 2) ? `${ssid[0]}${'*'.repeat(ssid.length - 2)}${ssid[ssid.length - 1]}` : ssid

  function getIcon(connectedWifi) {
    if (connectedWifi)
      return ['󰤯', '󰤟', '󰤥', '󰤨'][Math.round(connectedWifi.signalStrength * 4 - 1)] ?? '?'
    else
      return '󰤮'
  }

  readonly property var wifi: Networking?.devices?.values.filter(n => n.name === 'wlp2s0' || n.name === 'wlan0')[0]
  readonly property var connectedWifi: wifi?.networks?.values.filter(v => v.connected)[0]
  readonly property var otherNetworks: wifi?.networks?.values.filter(v => !v.connected)
  readonly property var wired: Networking?.devices?.values.filter(n => n.type === DeviceType.Wired)[0]

  property int page: 0
  property bool vpnEnabled: false
  property bool vpnLoading: false
  property string vpnLabel: 'Disconnected'
  property string vpnLocation: Settings.persistent.vpnLocation

  property bool pingLoading: false
  property string pingResult: ''

  property bool speedLoading: false
  property string speedResult: ''

  function runPing() {
    root.pingLoading = true
    root.pingResult = ''

    Utils.exec(['ping', '-c', '3', '-W', '1', '1.1.1.1'], text => {
      const match = text.match(/= [\d.]+\/([\d.]+)\//)
      root.pingResult = match ? `${(+match[1]).toFixed(1)}ms` : 'failed'
      root.pingLoading = false
    })
  }

  function runSpeedTest() {
    root.speedLoading = true
    root.speedResult = ''

    Utils.exec(['speedtest-cli', '--json'], text => {
      try {
        const data = JSON.parse(text)
        // it goes off the edge gotta make it thinner @TODO do that 
        root.speedResult = `󰇚 ${(data.download / 1_000_000).toFixed(1)} 󰕒 ${(data.upload / 1_000_000).toFixed(1)} Mbps`
      } catch (err) {
        root.speedResult = 'failed'
      }
      root.speedLoading = false
    })
  }

  FileView {
    id: proton
    path: `${Settings.cache}/Proton/VPN/serverlist.json`

    readonly property var freeCountries: {
      let data

      try {
        data = JSON.parse(text())
      } catch (err) {
        return
      }

      const servers = data.LogicalServers.filter(s => s.Tier === 0)
      let groupedServers = {}

      servers.forEach(server => {
        if (groupedServers[server.City]) {
          groupedServers[server.City].locations++
        } else {
          groupedServers[server.City] = {
            country: server.ExitCountry,
            locations: 1
          }
        }
      })

      const countryData = Object.entries(groupedServers).sort(function (x, y) {
        return x[1].country.localeCompare(y[1].country) || x[0].localeCompare(y[0])
      })

      return countryData
    }
  }

  // qmllint disable signal-handler-parameters
  Process {
    id: proc
    onStarted: () => {
      root.vpnLabel = root.vpnEnabled ? 'Connecting...' : 'Disconnecting...'
      root.vpnLoading = true
    }
    onExited: () => {
      root.vpnLabel = root.vpnEnabled ? 'Connected' : 'Disconnected'
      root.vpnLoading = false
    }
  }
  // qmllint enable signal-handler-parameters

  Binding {
    target: root.wifi ?? null
    property: "scannerEnabled"
    value: root.popupWindow.visible
    when: root.wifi !== null && root.wifi !== undefined
  }

  accentColor: Theme.blue
  text: wired?.connected ? `󰈀 wired connection` : `${getIcon(connectedWifi)} ${connectedWifi ? computeWifiName(connectedWifi.name) : 'cannot find network'}`

  popupWidth: 300
  popupHeight: 300

  Label {
    id: wifiLabel

    color: root.page === 0 ? Theme.fg : Theme.subtext0
    text: 'Wi-Fi'

    Behavior on color {
      ColorAnim {}
    }

    anchors {
      top: parent.top
      left: parent.left
      topMargin: 10
      leftMargin: 10
      rightMargin: 10
    }

    ClickArea {
      onClicked: () => {
        root.page = 0
      }
    }
  }

  Label {
    id: vpnLabel

    color: root.page === 1 ? Theme.fg : Theme.subtext0
    text: 'VPN'

    Behavior on color {
      ColorAnim {}
    }

    anchors {
      top: parent.top
      left: parent.left
      topMargin: 10
      leftMargin: wifiLabel.width + 20
      rightMargin: 10
    }

    ClickArea {
      onClicked: () => {
        root.page = 1
      }
    }
  }

  Label {
    color: root.page === 2 ? Theme.fg : Theme.subtext0
    text: 'Network'

    Behavior on color {
      ColorAnim {}
    }

    anchors {
      top: parent.top
      left: parent.left
      topMargin: 10
      leftMargin: wifiLabel.width + vpnLabel.width + 30
      rightMargin: 10
    }

    ClickArea {
      onClicked: () => {
        root.page = 2
      }
    }
  }

  Toggle {
    id: enabledToggle
    property bool shown: true

    opacity: (shown && !toggleHideTimer.running) ? 1 : 0
    visible: shown || toggleHideTimer.running

    Behavior on opacity {
      NumberAnim {}
    }

    Timer {
      id: toggleHideTimer
      interval: Theme.animDuration
      running: false
      repeat: false
      onTriggered: {
        enabledToggle.shown = false
      }
    }

    onToggled: checked => root.page === 0 ? (Networking.wifiEnabled = checked) : (root.vpnEnabled = checked)

    accentColor: root.accentColor
    checked: root.page === 0 ? Networking.wifiEnabled : root.vpnEnabled

    Connections {
      target: root

      function onPageChanged() {
        enabledToggle.checked = root.page === 0 ? Networking.wifiEnabled : root.vpnEnabled
        if (page === 2) {
          toggleHideTimer.restart()
        } else {
          toggleHideTimer.stop()
          enabledToggle.shown = true
        }
      }

      // @TODO handle spam
      function onVpnEnabledChanged() {
        if (root.vpnEnabled) {
          root.vpnEnabled = true
          proc.exec({
            command: ['python3', 'scripts/protonvpn_connect.py', root.vpnLocation],
            workingDirectory: Settings.configDir
          })
        } else {
          root.vpnEnabled = false
          proc.exec(['protonvpn', 'disconnect'])
        }
      }
    }

    anchors {
      top: parent.top
      right: parent.right
      topMargin: 10
      leftMargin: 10
      rightMargin: 10
    }
  }

  Item {
    id: viewContainer
    anchors.fill: parent
    clip: true

    Item {
      id: wifiPage
      width: parent.width
      height: parent.height

      x: -root.page * root.popupWidth

      Behavior on x {
        NumberAnim {}
      }

      Rectangle {
        id: conn
        color: hovered ? Theme.withOpacity(Theme.red, 0.5) : Theme.withOpacity(Theme.blue, 0.5)
        width: root.popupWidth - 20
        height: 45
        radius: Theme.rounding

        property bool hovered: false

        anchors {
          top: parent.top
          left: parent.left
          right: parent.right
          topMargin: 40
          leftMargin: 10
          rightMargin: 10
        }

        Behavior on color {
          ColorAnim {}
        }

        ClickArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          hoverEnabled: true
          onEntered: conn.hovered = true
          onExited: conn.hovered = false
        }

        Label {
          text: root.connectedWifi ? '󱚽' : '󱛅'
          font.pixelSize: Theme.fontSize * 2

          anchors {
            top: parent.top
            left: parent.left
            leftMargin: 10
            verticalCenter: parent.verticalCenter
          }
        }

        Label {
          text: '󱘹' // used to be '󱎘', might change back if I wanna
          font.pixelSize: Theme.fontSize * 2
          opacity: conn.hovered ? 1 : 0

          anchors {
            top: parent.top
            right: parent.right
            rightMargin: 15
            verticalCenter: parent.verticalCenter
          }

          Behavior on opacity {
            NumberAnim {}
          }

          MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: () => {
              root.connectedWifi ? root.connectedWifi.disconnect() : 0
            }
          }
        }

        Label {
          text: root.connectedWifi?.name ? root.computeWifiName(root.connectedWifi?.name) : 'None'

          anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
            leftMargin: 30 + Theme.fontSize
            bottomMargin: 15
          }
        }

        Label {
          readonly property int signalStrength: Math.round(root.connectedWifi?.signalStrength * 100 ?? 0)
          font.pixelSize: Theme.fontSize * 0.75

          text: `${signalStrength}% strength`

          anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
            topMargin: 15
            leftMargin: 30 + Theme.fontSize
          }
        }
      }

      Label {
        text: `Other Networks (${root.otherNetworks?.length ?? -1})`
        anchors {
          top: parent.top
          left: parent.left
          topMargin: 100
          leftMargin: 10
          rightMargin: 10
        }
      }

      Flickable {
        width: root.popupWidth
        height: root.popupHeight - y
        y: 130
        contentHeight: col.height + 20
        clip: true

        Column {
          id: col
          spacing: 4

          Repeater {
            model: root.otherNetworks?.sort((a, b) => b.signalStrength - a.signalStrength) ?? []

            Rectangle {
              id: nw

              required property var modelData
              property bool hovered: false

              color: hovered ? Theme.withOpacity(Theme.green, 0.5) : Theme.withOpacity(Theme.blue, 0.5)
              height: 45
              width: root.popupWidth - 20
              x: 10
              radius: Theme.rounding

              Behavior on color {
                ColorAnim {}
              }

              MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: nw.hovered = true
                onExited: nw.hovered = false
              }

              Label {
                text: nw.modelData.known ? '󱛀' : '󱚿'
                font.pixelSize: Theme.fontSize * 2

                anchors {
                  top: parent.top
                  left: parent.left
                  leftMargin: 10
                  verticalCenter: parent.verticalCenter
                }
              }

              Label {
                text: '󱇬' // used to be '󰸞', might change back if I wanna
                font.pixelSize: Theme.fontSize * 2
                opacity: nw.hovered ? 1 : 0

                anchors {
                  top: parent.top
                  right: parent.right
                  rightMargin: 15
                  verticalCenter: parent.verticalCenter
                }

                Behavior on opacity {
                  NumberAnim {}
                }

                MouseArea {
                  anchors.fill: parent
                  cursorShape: Qt.PointingHandCursor
                  onClicked: () => {
                    nw.modelData.connect()
                  }
                }
              }

              Label {
                text: nw.modelData?.name ? root.computeWifiName(nw.modelData?.name) : 'None'

                anchors {
                  top: parent.top
                  left: parent.left
                  bottom: parent.bottom
                  leftMargin: 30 + Theme.fontSize
                  bottomMargin: 15
                }
              }

              Label {
                readonly property int signalStrength: Math.round(nw.modelData?.signalStrength * 100) ?? 0
                font.pixelSize: Theme.fontSize * 0.75

                text: `${signalStrength}% strength`

                anchors {
                  top: parent.top
                  left: parent.left
                  bottom: parent.bottom
                  topMargin: 15
                  leftMargin: 30 + Theme.fontSize
                }
              }
            }
          }
        }
      }
    }

    Item {
      id: vpnPage
      width: parent.width
      height: parent.height

      x: -(root.page - 1) * root.popupWidth

      Behavior on x {
        NumberAnim {}
      }

      Rectangle {
        color: Theme.withOpacity(Theme.blue, 0.5)
        width: root.popupWidth - 20
        height: 45
        radius: Theme.rounding

        anchors {
          top: parent.top
          right: parent.right
          left: parent.left
          topMargin: 40
          rightMargin: 10
          leftMargin: 10
        }

        Label {
          text: '󰒄'
          font.pixelSize: Theme.fontSize * 2

          anchors {
            top: parent.top
            left: parent.left
            leftMargin: 10
            verticalCenter: parent.verticalCenter
          }
        }

        Label {
          text: 'VPN (Proton)'

          anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
            leftMargin: 30 + Theme.fontSize
            bottomMargin: 15
          }
        }

        Label {
          font.pixelSize: Theme.fontSize * 0.75

          text: root.vpnLabel

          anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
            topMargin: 15
            leftMargin: 30 + Theme.fontSize
          }
        }
      }

      Label {
        text: `Locations (selected: ${root.vpnLocation})`
        anchors {
          top: parent.top
          left: parent.left
          topMargin: 100
          leftMargin: 10
          rightMargin: 10
        }
      }

      Flickable {
        width: root.popupWidth
        height: root.popupHeight - y
        y: 130
        contentHeight: countries.height + 20
        clip: true

        Column {
          id: countries
          spacing: 4

          Repeater {
            model: proton.freeCountries

            Rectangle {
              id: country

              required property var modelData

              color: countryArea.hovered ? Theme.withOpacity(Theme.blue, 0.7) : Theme.withOpacity(Theme.blue, 0.5)
              height: 45
              width: root.popupWidth - 20
              x: 10
              radius: Theme.rounding

              Behavior on color {
                ColorAnim {}
              }

              ClickArea {
                id: countryArea
                onClicked: {
                  root.vpnLocation = country.modelData[0]
                  Settings.persistent.vpnLocation = country.modelData[0]
                }
              }

              Label {
                readonly property var countryIcon: code => code.replace(/./g, char => String.fromCodePoint(127397 + char.charCodeAt(0)))

                text: countryIcon(country.modelData[1].country)
                font.pixelSize: Theme.fontSize * 1.9

                anchors {
                  top: parent.top
                  left: parent.left
                  leftMargin: 9
                  topMargin: Theme.fontSize / 1.05
                }
              }

              Label {
                text: '󰸞'
                font.pixelSize: Theme.fontSize * 2
                visible: root.vpnLocation === country.modelData[0]

                anchors {
                  top: parent.top
                  right: parent.right
                  rightMargin: 10
                  verticalCenter: parent.verticalCenter
                }
              }

              Label {
                readonly property string city: country.modelData[0]
                readonly property var info: country.modelData[1]
                text: `${city}, ${info.country}`

                anchors {
                  top: parent.top
                  left: parent.left
                  bottom: parent.bottom
                  leftMargin: 30 + Theme.fontSize
                  bottomMargin: 15
                }
              }

              Label {
                readonly property int locations: country.modelData[1].locations
                font.pixelSize: Theme.fontSize * 0.75

                text: `${locations} location${locations > 1 ? 's' : ''}`

                anchors {
                  top: parent.top
                  left: parent.left
                  bottom: parent.bottom
                  topMargin: 15
                  leftMargin: 30 + Theme.fontSize
                }
              }
            }
          }
        }
      }
    }

    Item {
      id: networkPage
      width: parent.width
      height: parent.height

      x: -(root.page - 2) * root.popupWidth

      Behavior on x {
        NumberAnim {}
      }

      Rectangle {
        color: Theme.withOpacity(Theme.blue, 0.5)
        width: root.popupWidth - 20
        height: 45
        radius: Theme.rounding

        anchors {
          top: parent.top
          left: parent.left
          right: parent.right
          topMargin: 40
          leftMargin: 10
          rightMargin: 10
        }

        Label {
          text: '󰈀'
          font.pixelSize: Theme.fontSize * 2

          anchors {
            top: parent.top
            left: parent.left
            leftMargin: 10
            verticalCenter: parent.verticalCenter
          }
        }

        Label {
          text: root.wired ? (root.wired?.connected ? root.wired.address || 'unknown address' : 'disconnected') : 'no ethernet'

          anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
            leftMargin: 30 + Theme.fontSize
            bottomMargin: 15
          }
        }

        Label {
          font.pixelSize: Theme.fontSize * 0.75
          text: root.wired?.connected ? `Speed: ${Math.round(root.wired.linkSpeed ?? 0)} Mb/s` : ''

          anchors {
            top: parent.top
            left: parent.left
            bottom: parent.bottom
            topMargin: 15
            leftMargin: 30 + Theme.fontSize
          }
        }
      }

      Column {
        spacing: 10

        anchors {
          top: parent.top
          left: parent.left
          right: parent.right
          topMargin: 100
          leftMargin: 10
          rightMargin: 10
        }

        Row {
          spacing: 10

          Button {
            accentColor: Theme.blue
            text: root.pingLoading ? 'Pinging...' : '󰔛 Ping 1.1.1.1'
            active: !root.pingLoading
            anchors.verticalCenter: parent.verticalCenter
            onClicked: root.runPing()
          }

          Label {
            text: root.pingResult
            anchors.verticalCenter: parent.verticalCenter
          }
        }

        Row {
          spacing: 10

          Button {
            accentColor: Theme.blue
            text: root.speedLoading ? 'Testing...' : '󰓅 Test Speed'
            active: !root.speedLoading
            anchors.verticalCenter: parent.verticalCenter
            onClicked: root.runSpeedTest()
          }

          Label {
            text: root.speedResult
            anchors.verticalCenter: parent.verticalCenter
          }
        }
      }
    }
  }
}
