import QtQuick
import QtQuick.Controls
import qs.Commons
import qs.Ui

// Confirmation for installing any local engine, speech or OCR. What the
// install downloads comes from the engine's own `# installsize:` and
// `# installnote:` headers (per device with a `-cpu`/`-gpu` suffix), as
// reported by `speak --info` under installInfo, so a new engine describes
// itself instead of the panel carrying its numbers.
Rectangle {
  id: root
  // The provider or OCR engine object from `speak --info`, or null to hide.
  property var target: null
  // Set when the install is for switching the target to this device; empty
  // installs (or repairs) for the device it is configured with.
  property string device: ""
  property color foreground: Color.popups.text
  property string fontFamily: Style.font.family
  signal accepted()
  signal cancelled()

  readonly property bool switching: device !== ""
  readonly property string effectiveDevice: switching ? device : String((target && target.device) || "")
  readonly property var details: {
    var info = (target && target.installInfo) || {}
    return info[effectiveDevice] || info["default"] || {}
  }
  readonly property string name: target ? String(target.title || target.name || "") : ""
  readonly property bool repairing: !switching && !!target && target.status === "failing"

  visible: target !== null
  width: parent ? parent.width : implicitWidth
  height: content.implicitHeight + 16
  radius: 6
  color: Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.08)
  border.width: 1
  border.color: Color.popups.border

  Column {
    id: content
    anchors.fill: parent; anchors.margins: 8; spacing: 6
    Text {
      width: parent.width; wrapMode: Text.WordWrap; textFormat: Text.PlainText
      text: root.switching ? "Run " + root.name + " on the " + root.device.toUpperCase() + "?"
          : (root.repairing ? "Repair " : "Install ") + root.name
            + (root.effectiveDevice ? " for the " + root.effectiveDevice.toUpperCase() : "") + "?"
      color: root.foreground; font.family: root.fontFamily; font.pixelSize: Style.font.body
    }
    Text {
      visible: !!(root.details.size || root.details.note)
      width: parent.width; wrapMode: Text.WordWrap; textFormat: Text.PlainText
      text: "󰀪  " + (root.details.size ? "Downloads " + root.details.size + (root.details.note ? ". " : "") : "")
            + (root.details.note || "")
      color: Color.accent; font.family: root.fontFamily; font.pixelSize: Style.font.caption
    }
    Text {
      width: parent.width; wrapMode: Text.WordWrap
      text: "Tested before it replaces anything; rolled back if it fails."
      color: Color.muted
      font.family: root.fontFamily; font.pixelSize: Style.font.caption
    }
    Row {
      spacing: 8
      Button { text: "Cancel"; bordered: true; focusable: true; onClicked: root.cancelled() }
      Button {
        text: root.switching ? "Download and switch" : (root.repairing ? "Repair" : "Download and install")
        bordered: true; focusable: true; foreground: Color.accent
        onClicked: root.accepted()
      }
    }
  }
}
