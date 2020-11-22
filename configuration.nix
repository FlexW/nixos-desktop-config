{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw

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
  i18n = {
    defaultLocale = "de_DE.UTF-8";
  };
  console = {
    useXkbConfig = true;
    font = "Lat2-Terminus16";
  };

  services = {

    # Configure x server.
    xserver = {
      enable = true;

      # Configure keymap.
      layout = "de";
      xkbOptions = "eurosign:e, ctrl:nocaps";
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
    unzip
    wget git
    zsh
    nano emacs
    firefox qutebrowser
    alacritty
    mu offlineimap

    # Development
    python3
    gcc clang
  ];

  # Don't edit.
  system.stateVersion = "20.09";

}
