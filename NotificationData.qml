pragma Singleton
import Quickshell

Singleton {
  property var notifications: []
  property var shownNotifications: ({})
  property var notificationHeights: ({})
  property var excusedNotifications: ({})
  property var toastedNotifications: ({})

  function getIcon(icon, app) {
    // manually for apps with no icon
    if (icon === 'NetworkManager Applet')
      return Quickshell.iconPath('network-workgroup');

    // default
    return Quickshell.iconPath(icon);
  }
}
