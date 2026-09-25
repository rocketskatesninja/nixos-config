# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.systemd.enable = true;
  boot.initrd.luks.devices."luks-7f326384-f754-4432-8916-40942868737f".device = "/dev/disk/by-uuid/7f326384-f754-4432-8916-40942868737f";
  boot.resumeDevice = "/dev/disk/by-uuid/8b24fd2a-c7b0-43a2-bad5-7022d392d12d";
  networking.hostName = "zorro"; # Define your hostname.

  # Network aliases
  networking.extraHosts = ''
    192.168.0.80 serv evetrade.local osint.local greps.local leads.local routepilot.local
    192.168.0.100 boxer
    192.168.0.69 cowboy
    192.168.0.101 hermes secy.test chat.secy.test
    192.168.0.222 hydra
    5.78.138.47 punch
    192.168.0.239 metasploitable
  '';

  # Enable networking
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = false;
  security.polkit.enable = true;
  programs.dconf.enable = true;
  services.gnome.gnome-keyring.enable = true;
  # Auto-login has no password prompt for PAM to unlock the keyring with, so
  # it otherwise falls back to asking separately. sddm-autologin (not sddm)
  # is the actual PAM service the autologin flow authenticates through, and
  # the sddm module defines it with useDefaultRules = false + fully custom
  # rules — enableGnomeKeyring only injects into the *default* rule set, so
  # it has no effect here. Adding the same pam_gnome_keyring rules the
  # generic option would (see nixos/modules/security/pam.nix) directly
  # instead, keyed as new rule names that merge into sddm's custom rules.
  security.pam.services.sddm-autologin.rules = {
    auth.gnome_keyring = {
      control = "optional";
      modulePath = "${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so";
      order = 10400; # after nologin(10100)/sddm-autologin-user(10200)/permit(10300)
    };
    session.gnome_keyring = {
      control = "optional";
      modulePath = "${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so";
      settings.auto_start = true;
      order = 10150; # early in session, alongside the included sddm session stack
    };
  };

  # Disable rtw89 WiFi power saving to prevent disconnects
  boot.extraModprobeConfig = "options rtw89_core disable_ps_mode=Y";

  # Prevent AMD GPU TTM buffer eviction crash on suspend (5.5GB RAM too tight)
  boot.kernelParams = [ "amdgpu.runpm=0" "serial8250.nr_uarts=0" ];

  # SSD TRIM support
  services.fstrim.enable = true;

  # Better memory management with zram (helps with only 5.5GB RAM)
  zramSwap.enable = true;

  # AMD GPU - enable Vulkan and firmware
  hardware.graphics.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Power profiles — required by noctalia-shell's power widget
  services.power-profiles-daemon.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Display manager - auto login, stock SDDM theme
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.autoLogin = {
    enable = true;
    user = "nope";
  };

  environment.variables = {
    # AMD VA-API hardware video decoding for Firefox
    LIBVA_DRIVER_NAME = "radeonsi";
    MOZ_DISABLE_RDD_SANDBOX = "1";
  };

  # Hyprland window manager
  programs.hyprland.enable = true;

  # Fix slow file dialogs
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-hyprland ];
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents (local only)
  services.printing.enable = true;
  services.printing.listenAddresses = [ "localhost:631" ];
  services.printing.browsing = false;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.nope = {
    isNormalUser = true;
    description = "Nope";
    extraGroups = [ "networkmanager" "wheel" "wireshark" "libvirtd" ];
    linger = true;
    packages = with pkgs; [
    ];
  };

  # Install firefox.
  programs.firefox = {
    enable = true;
    preferencesStatus = "locked";
    preferences = {
      "dom.ipc.processCount" = 2;
      "dom.ipc.processPrelaunch.fission.number" = 0;
      "fission.autostart" = false;
      # AMD GPU hardware video decoding via VA-API
      "media.ffmpeg.vaapi.enabled" = true;
      "media.hardware-video-decoding.force-enabled" = true;
    };
  };

  # Zsh with Oh My Zsh
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "history-substring-search" ];
      theme = "agnoster";
    };
    # zsh-autocomplete doesn't ship its plugin file under share/zsh/plugins/<name>
    # the way ohMyZsh.customPkgs expects (it uses share/zsh-autocomplete/ instead),
    # so customPkgs silently linked in nothing. Source it directly; mkAfter
    # guarantees it loads after oh-my-zsh.sh so it wins the arrow-key bindings.
    interactiveShellInit = lib.mkAfter ''
      source ${pkgs.zsh-autocomplete}/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
    '';
  };
  users.defaultUserShell = pkgs.zsh;

  # Wireshark: grants the 'wireshark' group (nope is already a member, see
  # extraGroups above) capture rights via a setcap dumpcap wrapper, instead
  # of running the whole GUI as root. package must match the GUI package
  # below so the capability grant lands on the dumpcap binary actually
  # invoked at capture time, not some other build's copy.
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  # Theme Qt apps (Wireshark is Qt6) with a custom Nord palette instead of
  # whatever style each toolkit defaults to. Installs both qt5ct and qt6ct
  # so it covers Qt5 and Qt6 apps alike; the actual Nord colors live in
  # qt/colors/Nord.conf, referenced from qt/qt5ct.conf and qt/qt6ct.conf,
  # symlinked into ~/.config/qt5ct and ~/.config/qt6ct.
  qt = {
    enable = true;
    platformTheme = "qt5ct";
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    font-awesome
    noto-fonts-cjk-sans
  ];

  fonts.fontconfig.defaultFonts.monospace = [
    "JetBrainsMono Nerd Font"
    "Noto Sans Mono CJK JP"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  terminaltexteffects
  figlet
  yazi
  kitty
  xdg-user-dirs
  # dconf itself comes from programs.dconf.enable, not listed here
  gsettings-desktop-schemas
  wget
  fzf
  zoxide
  quickshell
  noctalia-shell
  swayidle
  grim
  slurp
  wl-clipboard
  glib
  libnotify
  iptables
  pavucontrol
  brightnessctl
  playerctl
  dnsutils
  whois
  wirelesstools
  adwaita-icon-theme
  gh
  claude-code
  git
  thunderbird
  telegram-desktop
  twingate
  openvpn
  proxychains-ng
  nmap
  netcat-gnu
  masscan
  hashcat
  netdiscover
  gobuster
  ffuf
  nikto
  nuclei
  amass
  subfinder
  exploitdb
  python3Packages.impacket
  netexec
  ghidra
  binwalk
  pentestgpt
  sherlock
  theharvester
  discord
  metasploit
  burpsuite
  sqlmap
  thc-hydra
  john
  tor
  obsidian
  slack
  recon-ng
  aircrack-ng
  seclists
  dnsrecon
  enum4linux
  smbmap
  smtp-user-enum
  wf-recorder
  rclone
  # pipx removed — broken tests in nixpkgs 26.05, re-add when fixed
  tmux
  btop
  fastfetch
  # headless (no ffplay/SDL2/X11 deps) — cliamp shells out to this for stream
  # formats it has no native decoder for
  ffmpeg-headless
  nordic
  virt-manager
  xfce.thunar
  xfce.xfconf
  cifs-utils
  samba
  autotiling
  (pkgs.buildGoModule rec {
    pname = "cliamp";
    version = "2.2.0";
    src = pkgs.fetchFromGitHub {
      owner = "bjarneo";
      repo = "cliamp";
      rev = "v${version}";
      hash = "sha256-PC+1uOt/LBGkW+ASNyGrS0e/rB8mcr+ILlcnf3F8esU=";
    };
    vendorHash = "sha256-d/ENFm9b1DkIir1lz50VVX1pvuQpwPUVlA5XOC7Jj5o=";
    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.alsa-lib pkgs.libvorbis pkgs.libogg pkgs.flac pkgs.lame pkgs.mpg123 ];
  })
  (pkgs.stdenv.mkDerivation {
    pname = "nmapAutomator";
    version = "unstable-2024-01-01";
    src = pkgs.fetchFromGitHub {
      owner = "21y4d";
      repo = "nmapAutomator";
      rev = "c5e15de8429c78aa5923010145dfac0996aba9e1";
      sha256 = "1y7kx60h0an5nxaivq5npigil1cmb8rmxdifs1m8wmf6bf26y00z";
    };
    installPhase = ''
      mkdir -p $out/bin
      cp nmapAutomator.sh $out/bin/nmapAutomator
      chmod +x $out/bin/nmapAutomator
      sed -i 's|/usr/share/nmap/scripts/vulners.nse|${pkgs.nmap}/share/nmap/scripts/vulners.nse|g' $out/bin/nmapAutomator
    '';
  })
  ];

  # Hibernate at critical battery regardless of AC state
  services.upower = {
    enable = true;
    percentageLow = 20;
    percentageCritical = 10;
    percentageAction = 5;
    criticalPowerAction = "Hibernate";
  };

  # Lid close behavior
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  # Hibernate after 24h of suspend (battery lasts days in suspend, no rush)
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "24h";
  };

  # Public file sharing — SMB + HTTP for /home/nope/public
  services.samba = {
    enable = true;
    settings = {
      global = {
        workgroup = "WORKGROUP";
        "server string" = "zorro";
        security = "user";
        "map to guest" = "bad user";
      };
      public = {
        path = "/home/nope/public";
        browseable = "yes";
        "read only" = "yes";
        "guest ok" = "yes";
      };
    };
  };
  services.samba-wsdd.enable = true;

  services.httpd = {
    enable = true;
    adminAddr = "nope@zorro";
    virtualHosts."zorro" = {
      documentRoot = "/home/nope/public";
      extraConfig = ''
        <Directory "/home/nope/public">
          Options Indexes FollowSymLinks
          AllowOverride None
          Require all granted
        </Directory>
      '';
    };
  };

  networking.firewall.extraCommands = ''
    iptables -A nixos-fw -s 192.168.0.0/24 -p tcp --dport 80 -j nixos-fw-accept
    iptables -A nixos-fw -s 192.168.0.0/24 -p tcp --dport 139 -j nixos-fw-accept
    iptables -A nixos-fw -s 192.168.0.0/24 -p tcp --dport 445 -j nixos-fw-accept
    iptables -A nixos-fw -s 192.168.0.0/24 -p udp --dport 137 -j nixos-fw-accept
    iptables -A nixos-fw -s 192.168.0.0/24 -p udp --dport 138 -j nixos-fw-accept
  '';

  # Wordlist symlinks so tools that expect /usr/share/wordlists/ work on NixOS
  system.activationScripts.wordlistSymlinks = ''
    mkdir -p /usr/share/wordlists/dirb
    SECLISTS=$(echo /nix/store/*seclists*/share/wordlists/seclists)
    MSF_WORDLISTS=$(echo /nix/store/*metasploit*/share/msf/data/wordlists)
    ln -sfn "$SECLISTS" /usr/share/wordlists/seclists
    ln -sfn "$SECLISTS/Discovery/Web-Content/common.txt" /usr/share/wordlists/dirb/common.txt
    rm -rf /usr/share/wordlists/metasploit
    ln -sfn "$MSF_WORDLISTS" /usr/share/wordlists/metasploit
  '';

  # Allow Apache (wwwrun) to traverse into /home/nope to serve /home/nope/public
  system.activationScripts.homeTraversable = ''
    chmod 711 /home/nope
  '';

  # GVFS for Thunar network browsing (SMB, etc.)
  services.gvfs.enable = true;

  # Flatpak (for Obsidian and other pre-built apps)
  services.flatpak.enable = true;

  # Virtualization
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # Twingate (installed but not auto-started, toggle via bar widget)
  services.twingate.enable = true;
  systemd.services.twingate.wantedBy = pkgs.lib.mkForce [];

  # Passwordless sudo — needed for the vpn/tor/twingate toggle scripts and
  # general convenience; this is the sole sudo policy for the user.
  security.sudo.extraRules = [{
    users = [ "nope" ];
    commands = [
      { command = "ALL"; options = [ "NOPASSWD" ]; }
    ];
  }];

  # PostgreSQL for Metasploit
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
  };

  # Tor service with transparent proxy
  services.tor = {
    enable = true;
    client.enable = true;
    settings = {
      TransPort = [ 9040 ];
      DNSPort = [ 5353 ];
      VirtualAddrNetworkIPv4 = "10.192.0.0/10";
      AutomapHostsOnResolve = true;
    };
  };

  # Automatic security updates
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
  };

  # Cap journal size so it doesn't grow unboundedly
  services.journald.extraConfig = ''
    SystemMaxUse=200M
  '';

  # Weekly GC — keep last 3 generations, delete the rest
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 3d";
  };

  # Hard-link identical files in the nix store to save space (SSD-friendly)
  nix.optimise.automatic = true;

  # Limit parallel nix builds to prevent RAM exhaustion during nixos-rebuild
  nix.settings.max-jobs = 2;
  nix.settings.cores = 2;

  # Distribute hardware interrupts across all cores
  services.irqbalance.enable = true;

  # zstd gives better compression ratio than lzo-rle — fits more in zram
  zramSwap.algorithm = "zstd";

  boot.kernel.sysctl = {
    # Use zram aggressively before evicting file cache (ideal with zram swap)
    "vm.swappiness" = 100;
    # TCP BBR congestion control — better throughput on WiFi/VPN
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data were taken. Left at this machine's original
  # install version — do not change.
  system.stateVersion = "26.05";

}
