# Installed Packages

## Core
- claude-code, git, firefox, thunderbird, telegram-desktop, obsidian

## Security/Pentesting
- nmap, nmapAutomator (custom derivation from GitHub), netdiscover
- metasploit, burpsuite, sqlmap, thc-hydra, john
- sherlock, theharvester, pentestgpt
- wireshark, proxychains-ng, tor (service with transparent proxy)

## Networking
- twingate (rocketskatesninja.twingate.com), openvpn, rclone, networkmanagerapplet
- iptables (for Tor transparent proxy)

## Desktop/WM
- hyprland (KDE and Sway removed)
- waybar, wofi, mako, swaylock, swayidle, swaybg
- foot, grim, slurp, wl-clipboard, autotiling
- thunar, xfconf, blueman
- pavucontrol (audio control)
- brightnessctl, playerctl (media/hardware keys)
- virt-manager, libvirtd (VM management)
- samba, cifs-utils, gvfs (SMB file sharing)

## Fonts/Theming
- font-awesome, nerd-fonts.jetbrains-mono, glib (gsettings)
- adwaita-icon-theme, adwaita-qt, gnome-themes-extra
- nixos-artwork.wallpapers.catppuccin-mocha, catppuccin-sddm
- sddm uses kdePackages.sddm (Qt6) with catppuccin-mocha-mauve theme

## System
- btop, zsh-autocomplete, iptables, libnotify
- gnome-keyring (WiFi password storage)

## Custom Derivations
- nmapAutomator: fetched from github.com/21y4d/nmapAutomator
  - rev: c5e15de8429c78aa5923010145dfac0996aba9e1
  - Just a bash script installed to $out/bin/nmapAutomator

## Network Failsafe
- **net-reset** script (~/.local/bin/net-reset) — flushes iptables, stops Twingate, restarts NetworkManager
- **Super+N** keybinding — runs net-reset as panic button
- **NixOS rollback** — hold Space at boot to pick previous generation

## Hyprland Keybindings
- Super+Return = foot terminal
- Super+D = wofi launcher
- Super+Shift+Q = kill window
- Super+Shift+E = exit (with wofi confirmation)
- Super+L = lock screen
- Super+F = fullscreen
- Super+N = network reset
- Print = full screenshot
- Super+Print = region screenshot
- Super+1-4 = workspaces
- Ctrl+Tab/Shift+Tab = cycle workspaces
- Alt+Tab = cycle windows
- Super+R = resize mode
- XF86 keys = volume, mic mute, brightness, media controls

## Custom Waybar Widgets
All use return-type=json with full paths to scripts in exec.
- **VPN toggle** — connects/disconnects OpenVPN using .ovpn from ~/keys/vpn/ (vpn-on, vpn-off, vpn-status)
- **Tor toggle** — routes all traffic through Tor transparent proxy (tor-on, tor-off, tor-status)
- **Twingate toggle** — single click connect/disconnect, auto-opens auth URL when needed (twingate-status, twingate-toggle)
  - Uses state file /tmp/twingate-transitioning + RTMIN+1 signal for immediate "..." display
  - Auth expires every ~4 days, re-auth via browser
- **Screenshot** — full screen (left click) or region (right click), saves to ~/images/screenshots/
- All show "..." during connecting/activating state

## NOPASSWD Sudo Rules
- Blanket ALL NOPASSWD for user nope
