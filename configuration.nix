{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Configure networking.
  networking = {
    hostName = "nixos";
    useDHCP = false;
    interfaces.enp3s0.useDHCP = true;
  };


  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "de";
  };

  services = {

    # Configure x server.
    xserver = {
      enable = true;

      # Configure keymap.
      layout = "de";
      xkbOptions = "eurosign:e";

      desktopManager = {
        xterm.enable = false;
      };

      displayManager = {
        defaultSession = "none+i3";
      };

      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          dmenu
          i3status
          i3lock
        ];
      };
    };

    # Enable OpenSSH
    openssh.enable = true;

    emacs = {
      # Start emacs on startup.
      enable = true;
      defaultEditor = true;
    };
  };

  # Add fonts
  fonts.fonts = with pkgs; [
    source-code-pro
  ];

  programs = {

    # Let Gtk apps save data.
    dconf.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Define a my user account.
  users.users.felix = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  # System packages
  environment.systemPackages = with pkgs; [
    wget git
    zsh
    nano emacs
    firefox qutebrowser
    alacritty
    mu offlineimap
  ];

  # Don't edit.
  system.stateVersion = "20.09";

}
