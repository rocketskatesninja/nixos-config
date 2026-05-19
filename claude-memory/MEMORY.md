# NixOS Laptop Setup

## Hardware
- **Laptop:** Lenovo IdeaPad 82VG
- **CPU:** AMD Ryzen 3 7320U (4c/8t)
- **RAM:** 5.5 GB
- **GPU:** AMD Radeon (integrated, amdgpu)
- **Storage:** 238.5 GB SK Hynix NVMe SSD, LUKS encrypted, ext4
- **WiFi:** Realtek rtw89_8852be (power save disabled via modprobe)
- **Bluetooth:** enabled (hci0)
- **Webcam:** broken — usb5-port1 fails to enumerate (hardware issue)

## System
- **OS:** NixOS 25.11
- **Config:** /etc/nixos/configuration.nix (user-owned by nope)
- **WMs:** Hyprland (only, KDE and Sway removed)
- **Shell:** zsh with Oh My Zsh (agnoster theme), autosuggestions, syntax highlighting, autocomplete
- **Terminal:** foot (size 14, transparent, catppuccin mocha colors)
- **Bar:** waybar (catppuccin mocha theme, nerd fonts, hyprland workspaces)
- **Launcher:** wofi (centered, dark theme, app icons)
- **File manager:** thunar (needs xfconf for settings)
- **Notifications:** mako (bottom-right)
- **Lock:** swaylock with nixos1.jpg wallpaper, catppuccin mocha indicator (config in ~/.swaylock/config)
- **Login:** SDDM with catppuccin-mocha-mauve theme, auto-login enabled (KDE sddm package for Qt6)
- **VPN:** Twingate (rocketskatesninja.twingate.com, auto-starts at boot)
- **OpenVPN:** installed, .ovpn files go in ~/keys/vpn/, toggle via waybar widget
- **Tor:** transparent proxy toggle via iptables scripts in ~/.local/bin/
- **Cursor:** Adwaita (symlinked in ~/.icons/default/)

## Network Hosts
- serv: 192.168.0.80 (SSH as nope, has sudo)
- boxer: 192.168.0.100 (SSH as nope, has sudo, Ubuntu 26.04 LTS, Intel N100, 16GB RAM, runs VMs via libvirt)
- cowboy: 192.168.0.69 (SSH as nope, has sudo, SMB share at //cowboy/desktop)
- hermes: 192.168.0.101 (VM on boxer, SSH as nope, has sudo, Ubuntu 26.04 LTS, 23GB disk, hardened SSH, Claude Code installed)
- punch: 5.78.138.47 Hetzner server (SSH as nope, has sudo)

## Key Directories
- ~/keys/ - SSH/security keys
- ~/images/wallpaper/ - wallpapers (nixos1.jpg, lock screen image)
- ~/images/screenshots/ - screenshots from waybar widget
- ~/documents/Obsidian Vault/ - Obsidian vault (Google Drive sync)
- ~/keys/vpn/ - OpenVPN .ovpn files (for HTB etc.)
- ~/.local/bin/ - tor-on/off/status, vpn-on/off/status, twingate-status, net-reset scripts
- Lowercase home dirs (desktop, downloads, documents, images, music, public, templates, videos)

## Packages Installed
See [packages.md](packages.md) for full list

## User Preferences
- 12-hour time format everywhere
- Dark mode (catppuccin mocha theme)
- Natural scroll DISABLED on touchpad and mouse
- 4 Hyprland workspaces: 1=foot+foot+thunar, 2=firefox, 3=thunderbird, 4=free
- Master layout in Hyprland
- Ctrl+Tab/Ctrl+Shift+Tab to switch workspaces
- Alt+Tab to cycle windows
- BIOS password + LUKS + login = 3 passwords, no bootloader password needed
- Passwordless sudo for nope (blanket NOPASSWD ALL)
- No `killall` — use `pkill` instead

## Known Issues
- Firefox uses ~1.8GB RAM regardless of settings (fission can't be disabled in newer builds)
- File dialogs need portal config: hyprland-portals.conf with gtk for FileChooser
- foot terminal: set TERM=xterm when SSH to rescue/minimal systems
- Wallpaper paths hardcoded to /nix/store - may break on rebuild
- Waybar custom modules need full paths in exec (waybar's /bin/sh doesn't have ~/.local/bin in PATH)
- Waybar custom module tooltips require return-type=json with printf/script outputting JSON
- Waybar on-click handlers block refresh — use `& disown` or `&` suffix to run async for mid-transition state updates
- Use state files (/tmp/) + pkill -RTMIN+N waybar signal pattern for immediate widget refresh
- swaylock config must be at ~/.swaylock/config (not ~/.config/swaylock/config)
- swaylock colors need explicit alpha suffix (e.g. ff for opaque, 00 for transparent)
- Ubuntu LVM installer only allocates ~50% of disk — use `lvextend -l +100%FREE` + `resize2fs` to expand
- When hardening SSH: always verify key works BEFORE disabling password auth
- GitHub: rocketskatesninja, nixos-config repo at github.com/rocketskatesninja/nixos-config
