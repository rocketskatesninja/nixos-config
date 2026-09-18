import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Services.UI
import qs.Widgets

NIconButton {
  id: root

  property ShellScreen screen
  property string widgetId: ""
  property string section: ""
  property int sectionWidgetIndex: -1
  property int sectionWidgetsCount: 0

  property var pluginApi: null
  property var cfg: pluginApi?.pluginSettings || ({})
  property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})
  readonly property int refreshInterval: cfg.refreshInterval ?? defaults.refreshInterval ?? 5000

  property string statusText: "Off"
  property string statusTooltip: "VPN"

  baseSize: Style.getCapsuleHeightForScreen(screen?.name)
  customRadius: Style.radiusL
  colorBg: statusText === "On" ? Color.mPrimary : Style.capsuleColor
  colorFg: statusText === "On" ? Color.mOnPrimary : (statusText === "Connecting" ? Color.mWarning : Color.mOnSurfaceVariant)
  border.color: Style.capsuleBorderColor
  border.width: Style.capsuleBorderWidth

  icon: "brand-openvpn"
  tooltipText: root.statusTooltip
  tooltipDirection: BarService.getTooltipDirection(screen?.name)

  onClicked: {
    Quickshell.execDetached(["sh", "-c", "/home/nope/.local/bin/vpn-toggle"])
    statusProc.running = true
  }

  Process {
    id: statusProc
    command: ["/home/nope/.local/bin/vpn-status"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var parsed = JSON.parse(String(text || "").trim())
          root.statusText = parsed.text || "?"
          root.statusTooltip = parsed.tooltip || "VPN"
        } catch (e) {
          root.statusText = "?"
        }
      }
    }
  }

  Timer {
    interval: root.refreshInterval
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: statusProc.running = true
  }
}
