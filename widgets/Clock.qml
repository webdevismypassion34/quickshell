import Quickshell
import QtQuick
import ".."
import "../components"

Row {
  id: root
  spacing: 0

  function pad(n) {
    return String(n).padStart(2, "0");
  }

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  readonly property string hours: pad(clock.hours)
  readonly property string mm: pad(clock.minutes)
  readonly property string month: clock.date.toLocaleDateString(Qt.locale('pl_PL'), "MMM")
  readonly property string day: pad(clock.date.getDate())

  readonly property var digits: [hours[0], hours[1]]

  // text: `${hours}:${mm} ${month} ${day}`

  height: Theme.fontSize
  width: Theme.fontSize

  Row {
    Odometer {
      value: root.hours[0]
    }
    Odometer {
      value: root.hours[1]
    }
    Label {
      y: -1
      text: ':'
    }
    Odometer {
      value: root.mm[0]
    }
    Odometer {
      value: root.mm[1]
    }
  }

  Label {
    text: ` ${root.month} ${root.day}`
  }
}
