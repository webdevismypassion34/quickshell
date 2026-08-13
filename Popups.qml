pragma Singleton
import Quickshell

Singleton {
  property var openPopup: null

  function toggle(popup) {
    popup.togglePopup();
  }

  function close() {
    if (openPopup)
      openPopup.togglePopup();
  }
}
