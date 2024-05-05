# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
  ];

  # Bootloader.
  boot.kernelParams = [ "nvidia.NVreg_PreserveVideoMemoryAllocations=1" ];
  boot.supportedFilesystems = [ "ntfs" ];
  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi"; # ← use the same mount point here.
    };
    grub = {
      enable = true;
      efiSupport = true;
      #efiInstallAsRemovable = true; # in case canTouchEfiVariables doesn't work for your system
      device = "nodev";
      useOSProber = true;
    };
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHibernation=yes
    AllowHybridSleep=yes
    AllowSuspendThenHibernate=no
  '';

  time.hardwareClockInLocalTime = true;
  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # enable tailscale
  services.tailscale.enable = true;
  services.tailscale.useRoutingFeatures = "both";

  # networking.nameservers = [
  #   "1.1.1.1#one.one.one.one"
  #   "1.0.0.1#one.one.one.one"
  # ];

  # services.resolved = {
  #   enable = true;
  #   dnssec = "true";
  #   domains = [ "~." ];
  #   fallbackDns = [
  #     "1.1.1.1#one.one.one.one"
  #     "1.0.0.1#one.one.one.one"
  #   ];
  #   dnsovertls = "true";
  # };

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
  };
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.production;
  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    WLR_NO_HARDWARE_CURSORS = "1";
    NIXOS_OZONE_WL = "1";
    # Not officially in the specification
    XDG_BIN_HOME = "$HOME/.local/bin";
    PATH = [ "${XDG_BIN_HOME}" ];
  };
  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.whale = {
    isNormalUser = true;
    description = "whale";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      firefox
      neovim
      atlauncher
      prismlauncher
      glfw-wayland-minecraft

      #  thunderbird
    ];
  };

  programs.zsh.enable = true;
  users.users.whale.shell = pkgs.zsh;

  xdg.portal.enable = true;

  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [

    # Add any missing dynamic libraries for unpackaged programs

    # here, NOT in environment.systemPackages
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  programs.gamemode.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    rsync
    neovim
    lazygit
    mangohud
    super-slicer-latest
    ripgrep
    gcc
    termius
    alacritty
    obsidian
    lmstudio
    gnumake
    ollama
    wootility
    fastfetch
    fuse3
    hugo
    dart-sass
    starship
    cmake
    fd
    zsh
    nodejs_21
    discord
    neovim
    wget
    neofetch
    wofi
    mpv
    pyprland
    hyprlock
    keymapp
    wally-cli
    rofi-wayland-unwrapped
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-wlr
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    waybar
    watershot
    wl-clipboard
    hyprpicker
    git
    vscode-fhs
    kitty
    appimage-run
    warp-terminal
    tailscale
    jdk21
    pkgs.gnome3.gnome-tweaks
    gnome.gnome-themes-extra
    gnome.gnome-terminal
    gtk-engine-murrine
    ocs-url
    swww
    lz4
    testdisk-qt
    yubikey-personalization-gui
    yubikey-manager-qt
    yubikey-manager
    yubioath-flutter
    testdisk
  ];
  services.udev.packages = [ pkgs.yubikey-personalization ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", DRIVER=="pcieport", ATTR{power/wakeup}="disabled"
  '';

  security.pam.services = {
    login.u2fAuth = true;
    sudo.u2fAuth = true;
  };

  services.pcscd.enable = true;
  services.yubikey-agent.enable = true;
  security.pam.yubico = {
    enable = true;
    debug = true;
    mode = "challenge-response";
    control = "required";
    id = [ "23666615" ];
  };

  services.gvfs.enable = true;
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  # List services that you want to enable:
  nixpkgs.config = {

    packageOverrides = pkgs: {
      warp-beta =
        import
          (fetchTarball "https://github.com/imadnyc/nixpkgs/archive/refs/heads/warp-terminal-initial-linux.zip")
          { config = config.nixpkgs.config; };
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
  system.stateVersion = "23.11"; # Did you read the comment?
}
