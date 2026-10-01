import QtQuick
import qs.Commons

// Rows split into titled groups whose headers collapse them. The rows keep
// their own delegate; collapsing only hides what the delegate says it may
// (the speech and OCR lists keep the entry in use visible).
Column {
  id: root
  // [{ key, title, note, rows }]; a group with no rows is not shown.
  property var groups: []
  property Component rowDelegate
  // Comma-separated keys of collapsed groups.
  property string collapsedGroups: ""
  // Announced after the group title, e.g. "providers".
  property string itemNoun: "items"
  property color foreground: Color.popups.text
  property color dim: Color.muted
  property string fontFamily: Style.font.family
  signal toggled(string key)

  function isCollapsed(key) { return collapsedGroups.split(",").indexOf(key) >= 0 }

  width: parent ? parent.width : implicitWidth
  spacing: Style.space(4)

  Repeater {
    model: root.groups
    delegate: Column {
      id: group
      required property var modelData
      width: root.width; spacing: Style.space(4)
      visible: modelData.rows.length > 0
      Item {
        width: parent.width; height: groupToggle.implicitHeight + Style.space(4)
        InlineAction {
          id: groupToggle; anchors.left: parent.left; anchors.bottom: parent.bottom
          text: (root.isCollapsed(group.modelData.key) ? "󰅂 " : "󰅀 ") + group.modelData.title + " · " + group.modelData.rows.length
          color: root.foreground; font.family: root.fontFamily; font.pixelSize: Style.font.caption; font.bold: true
          Accessible.name: group.modelData.title + " " + root.itemNoun + ", " + (root.isCollapsed(group.modelData.key) ? "collapsed" : "expanded")
          onTriggered: root.toggled(group.modelData.key)
        }
        Text {
          anchors.right: parent.right; anchors.baseline: groupToggle.baseline
          text: group.modelData.note || ""; color: root.dim; font.family: root.fontFamily; font.pixelSize: Style.font.caption
        }
      }
      Repeater { model: group.modelData.rows; delegate: root.rowDelegate }
    }
  }
}
