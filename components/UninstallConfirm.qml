import QtQuick
import QtQuick.Controls
import qs.Commons
import qs.Ui

// Confirmation for removing any engine the plugin installed, speech or OCR.
// An engine with several device builds (Kokoro ONNX) offers one button per
// installed device; the sizes come from the same installInfo headers the
// install confirmation uses.
Rectangle {
  id: root
  // The provider or OCR engine object from `speak --info`, or null to hide.
  property var target: null
  // The provider in use, so removing it can say speech will stop.
  property string activeName: ""
  property string inUseWarning: "This is the voice in use. Pick another provider afterwards or the shortcuts will stop speaking."
  property color foreground: Color.popups.text
  property string fontFamily: Style.font.family
  signal cancelled()
  // `uninstallTarget` is what `speak-setup uninstall` takes.
  signal confirmed(string uninstallTarget)

  readonly property string name: target ? String(target.title || target.name || "") : ""
  // Only an engine with a separate build per device (an installInfo entry
  // per device) is removed per device; Kokoro PyTorch runs either way from
  // one build and is removed whole.
  readonly property var devices: target ? (target.installedDevices || []).filter(function(d) {
    return !!((target.installInfo || {})[d]) }) : []
  function sizeFor(device) {
    var info = (target && target.installInfo) || {}
    return ((info[device] || info["default"] || {}).size) || ""
  }
  function targetFor(device) {
    return device ? target.name + "_" + device : target.name
  }
  readonly property bool removesCurrentVoice: !!target && target.name === activeName
    && (devices.length === 0 || devices.indexOf(String(target.device || "")) >= 0)

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
      text: "Uninstall " + root.name + "?"
      color: root.foreground; font.family: root.fontFamily; font.pixelSize: Style.font.body
    }
    Text {
      width: parent.width; wrapMode: Text.WordWrap; textFormat: Text.PlainText
      text: root.devices.length > 1 ? "Choose which engine to remove. The other keeps working."
          : "Removes its engine and downloaded files" + (root.sizeFor(root.devices[0] || "") ? ", freeing " + root.sizeFor(root.devices[0] || "") : "") + ". You can install it again later."
      color: Color.muted; font.family: root.fontFamily; font.pixelSize: Style.font.caption
    }
    Text {
      visible: root.removesCurrentVoice
      width: parent.width; wrapMode: Text.WordWrap
      text: "󰀪  " + root.inUseWarning
      color: Color.urgent; font.family: root.fontFamily; font.pixelSize: Style.font.caption
    }
    Flow {
      width: parent.width; spacing: 8
      Button { text: "Cancel"; bordered: true; focusable: true; onClicked: root.cancelled() }
      Repeater {
        model: root.devices.length > 1 ? root.devices : [root.devices.length === 1 ? root.devices[0] : ""]
        delegate: Button {
          required property string modelData
          text: modelData && root.devices.length > 1
                ? "Remove " + modelData.toUpperCase() + " engine" + (root.sizeFor(modelData) ? " (" + root.sizeFor(modelData) + ")" : "")
                : "Uninstall"
          bordered: true; focusable: true; foreground: Color.urgent
          onClicked: root.confirmed(root.targetFor(modelData))
        }
      }
    }
  }
}
