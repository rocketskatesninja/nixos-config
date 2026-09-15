# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  # Recompile glmatrix with Catppuccin Mocha mauve (#cba6f7) instead of green
  nixpkgs.overlays = [
    (final: prev: {
      xscreensaver = prev.xscreensaver.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          sed -i 's/r = b = 0, g = 1;/r = 0.537f, g = 0.706f, b = 0.980f;/' hacks/glx/glmatrix.c
          sed -i 's/g = 0xFF;/r = 137; g = 180; b = 250;/' hacks/glx/glmatrix.c
        '';
      });
      unimatrix = prev.unimatrix.overrideAttrs (old: {
        postPatch = (old.postPatch or "") + ''
          sed -i 's/\\;/\\\\;/g' unimatrix.py
        '';
      });
    })
  ];
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.systemd.enable = true;
  boot.initrd.luks.devices."luks-f7c388a2-4a30-4933-90d4-bb703b0c8fa2".device = "/dev/disk/by-uuid/f7c388a2-4a30-4933-90d4-bb703b0c8fa2";
  boot.resumeDevice = "/dev/disk/by-uuid/097b8142-c1ec-4e0d-90e1-e530e7a63af3";
  networking.hostName = "zorro"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Network aliases
  networking.extraHosts = ''
    192.168.0.80 serv evetrade.local osint.local greps.local leads.local
    192.168.0.100 boxer
    192.168.0.69 cowboy
    192.168.0.101 hermes secy.test chat.secy.test
    192.168.0.222 hydra
    5.78.138.47 punch
    192.168.0.239 metasploitable
  '';

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # Disable rtw89 WiFi power saving to prevent disconnects
  boot.extraModprobeConfig = "options rtw89_core disable_ps_mode=Y";

  # Prevent AMD GPU TTM buffer eviction crash on suspend (5.5GB RAM too tight)
  boot.kernelParams = [ "amdgpu.runpm=0" ];

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

  # Display manager - auto login
  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.displayManager.sddm.theme = "catppuccin-mocha-mauve";
  services.displayManager.sddm.package = pkgs.kdePackages.sddm;
  services.displayManager.autoLogin = {
    enable = true;
    user = "nope";
  };

  # Cursor theme
  environment.variables = {
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
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
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nope = {
    isNormalUser = true;
    description = "Nope";
    extraGroups = [ "networkmanager" "wheel" "wireshark" "libvirtd" ];
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
      customPkgs = [ pkgs.zsh-autocomplete ];
    };
  };
  users.defaultUserShell = pkgs.zsh;

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
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  wget
  fzf
  zoxide
  (pkgs.writeShellScriptBin "glmatrix" ''
    exec ${pkgs.xscreensaver}/libexec/xscreensaver/glmatrix "$@"
  '')
  hyprlock
  swayidle
  waybar
  wofi
  mako
  grim
  slurp
  wl-clipboard
  foot
  networkmanagerapplet
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
  adwaita-qt
  gnome-themes-extra
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
  wireshark
  tor
  obsidian
  slack
  unimatrix
  recon-ng
  aircrack-ng
  seclists
  dnsrecon
  enum4linux
  smbmap
  smtp-user-enum
  wf-recorder
  xscreensaver
  rclone
  pipx
  tmux
  btop
  virt-manager
  xfce.thunar
  xfce.xfconf
  cifs-utils
  samba
  autotiling
  swaybg
  nixos-artwork.wallpapers.catppuccin-mocha
  catppuccin-sddm
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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

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
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=24h
  '';

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

  # Twingate (installed but not auto-started, toggle via waybar widget)
  services.twingate.enable = true;
  systemd.services.twingate.wantedBy = pkgs.lib.mkForce [];
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

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
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

  system.stateVersion = "25.11"; # Did you read the comment?

}
