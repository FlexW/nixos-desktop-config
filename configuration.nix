{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;

  environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  location = {
    latitude= 48.78232;
    longitude= 9.17702;
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
    defaultLocale = "en_GB.UTF-8";
  };
  console = {
    useXkbConfig = true;
    font = "Lat2-Terminus16";
  };

  services = {

    locate = {
      enable = true;
      interval = "hourly";
    };

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
          rofi
          i3status
          i3lock
          i3blocks
          yad
        ];
      };

      videoDrivers = [ "nvidia" ];
    };

    redshift = {
      enable = true;
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
  fonts = {
    enableDefaultFonts = true;

    fonts = with pkgs; [
      noto-fonts
      noto-fonts-extra
      noto-fonts-emoji
      source-code-pro
      ubuntu_font_family
      font-awesome
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Ubuntu" ];
        sansSerif = [ "Ubuntu" ];
        monospace = [ "Ubuntu Mono" ];
      };
    };
  };

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

  programs.adb.enable = true;
  # required :-( for adb
  nixpkgs.config.android_sdk.accept_license = true;


  # System packages
  environment.systemPackages = with pkgs; [
    man-pages
    unzip
    wget git youtube-dl
    perl532Packages.FileMimeInfo
    zsh
    gettext
    nano emacs
    firefox qutebrowser
    alacritty
    mu offlineimap
    zathura

    htop

    scrot feh viewnior

    hunspell hunspellDicts.de_DE hunspellDicts.en_GB-large

    # Development
    python3 python-language-server
    gcc clang clang-tools

    mpg123 cmus spotify playerctl

    nextcloud-client
    skype signal-desktop

    texlive.combined.scheme-full
  ];

  # Don't edit.
  system.stateVersion = "20.09";

}
