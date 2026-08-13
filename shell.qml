//@ pragma IgnoreSystemSettings

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "features"

Scope {
  IpcHandler {
    target: "notifications"

    function shown(): string {
      return JSON.stringify(NotificationData.shownNotifications);
    }

    function get(): string {
      return JSON.stringify(NotificationData.notifications);
    }
  }

  IpcHandler {
    target: 'launcher'

    function toggle(): void {
      Popups.toggle(launcher);
    }
  }

  IpcHandler {
    target: 'capture'
    
    function open(): void {
      capture.open()
    }
  }

  Notifications {}
  Bar {
    id: bar
  }
  Launcher {
    id: launcher
  }
  ScreenCapture {
    id: capture
  }

  HyprlandFocusGrab {
    active: Popups.openPopup !== null
    windows: Popups.openPopup ? [bar, Popups.openPopup.popupWindow] : [bar]
    onCleared: Popups.close()
  }
}
