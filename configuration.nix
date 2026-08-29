# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
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
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Network aliases
  networking.extraHosts = ''
    192.168.0.80 serv evetrade.local
    192.168.0.100 boxer
    192.168.0.69 cowboy
    192.168.0.101 hermes secy.test chat.secy.test
    192.168.0.222 hydra
    5.78.138.47 punch
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
      plugins = [ "git" ];
      theme = "agnoster";
      customPkgs = [ pkgs.zsh-autocomplete ];
    };
  };
  users.defaultUserShell = pkgs.zsh;

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    font-awesome
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  wget
  swaylock
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
  netdiscover
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
  cmatrix
  rclone
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

  # Lid close behavior
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend-then-hibernate";
    HandleLidSwitchDocked = "ignore";
  };

  # Hibernate after 30 min of suspend to prevent overnight battery drain
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=30min
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

  system.stateVersion = "25.11"; # Did you read the comment?

}
