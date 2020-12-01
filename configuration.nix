{ config, pkgs, ... }:
let
  cursor = {
    name = "Vanilla-DMZ";
    package = pkgs.vanilla-dmz;
    size = 128;
  };
  dpi = 100;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;

  # links /libexec from derivations to /run/current-system/sw
  environment.pathsToLink = [ "/libexec" "/share/nix-direnv" ];

  # nix options for derivations to persist garbage collection
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';

  # Use the systemd-boot EFI boot loader.
  boot = {

    kernelParams = [ "quiet" ];

    consoleLogLevel = 0;

    plymouth = {
      enable = true;
    };

    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
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
      localuser = null;
      locate = pkgs.mlocate;
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

        # HighDPI and cursor
        sessionCommands = ''
          ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
          Xft.dpi: ${toString dpi}
          Xcursor.theme: ${cursor.name}
          # Xcursor.size: ${toString cursor.size}
          EOF
          ${pkgs.xorg.xsetroot}/bin/xsetroot -xcf ${cursor.package}/share/icons/${cursor.name}/cursors/left_ptr ${toString cursor.size}

        '';
      };
      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          rofi
          i3lock-fancy-rapid
          yad

          (i3blocks.overrideDerivation (old: {
            src = fetchFromGitHub {
              owner = "FlexW";
              repo = "i3blocks";
              rev = "ca50d9d30edb60f3ce19271872104a9f2d5ac35e";
              sha256 = "1vgw2dji4zpf81l0gzy5crkzrnfsmskk5pss4gjby3svlipqgdc8";
            };
          }))
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

  systemd.user = {
    services = {

      "dunst" = {
        enable = true;
        description = "Desktop notifications";
        wantedBy = [ "default.target" ];
        serviceConfig.Restart = "always";
        serviceConfig.RestartSec = 2;
        serviceConfig.ExecStart = "${pkgs.dunst}/bin/dunst";
      };

      "nextcloud" = {
        enable = true;
        description = "Nextcloud client";
        wantedBy = [ "default.target" ];
        serviceConfig.Restart = "always";
        serviceConfig.RestartSec = 2;
        serviceConfig.ExecStart = "${pkgs.nextcloud-client}/bin/nextcloud";
      };

    };
  };

  # Define my user account.
  users = {
    mutableUsers = true;

    users.felix = {
      isNormalUser = true;
      extraGroups = [ "wheel" "mlocate" ];
    };
  };

  programs.adb.enable = true;

  nixpkgs.config = {
    android_sdk.accept_license = true;

    zathura.useMupdf = true;
  };


  # System packages
  environment.systemPackages = with pkgs; [
    man-pages
    unzip
    calc
    wget git youtube-dl
    perl532Packages.FileMimeInfo
    zsh fish direnv nix-direnv exa bat
    gettext
    nano emacs
    firefox qutebrowser
    alacritty
    mu offlineimap
    zathura

    pavucontrol
    arandr

    dunst libnotify

    htop

    scrot feh viewnior imagemagick

    hunspell hunspellDicts.de_DE hunspellDicts.en_GB-large

    # Python
    python3

    # C/C++
    gcc clang clang-tools cmake ninja gnumake

    # Web dev
    hugo
    nodejs
    nodePackages.npm
    nodePackages.prettier
    nodePackages.typescript
    nodePackages.typescript-language-server

    mpg123 mpg321 vlc cmus spotify playerctl

    exiftool

    nextcloud-client
    skype signal-desktop

    texlive.combined.scheme-full

    gimp inkscape

    vanilla-dmz
  ];

  # Don't edit.
  system.stateVersion = "20.09";

}
