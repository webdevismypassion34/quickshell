//@ pragma IgnoreSystemSettings
//@ pragma IconTheme Papirus-Dark

import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import "features"
import "settings"

Scope {
  // ipc handlers
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
      capture.open();
    }
  }

  IpcHandler {
    target: 'settings'

    function open(): void {
      settings.open();
    }
  }

  // contents
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
    windows: Popups.openPopup ? [...bar.windows, Popups.openPopup.popupWindow ?? Popups.openPopup] : [...bar.windows]
    onCleared: Popups.close()
  }

  App {
    id: settings
  }

  OSD {
    id: osd
  }
}
