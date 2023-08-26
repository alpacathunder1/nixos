{ config, pkgs, ... }:
# I needed to pull Obsidian from unstable, so I found this:
# This is from:
# https://web.archive.org/web/20230217171255/https://microeducate.tech/how-to-add-nixos-unstable-channel-declaratively-in-configuration-nix/
let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz;
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      ## This is for hardware accelerated video decoding:
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  nixpkgs.config = {
     packageOverrides = pkgs: {
       ## This is for hardware accelerated video decoding:
       ## https://nixos.wiki/wiki/Accelerated_Video_Playback
       vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
       ## This is for the unstable repo, more comments later
       unstable = import unstableTarball {
         config = config.nixpkgs.config;
       };
     };
   };


  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "Desktop"; # Define your hostname.
  networking.wireless.enable = false;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # GNOME
  services.xserver.displayManager.gdm.enable = false;
  services.xserver.desktopManager.gnome.enable = false;

  # KDE
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;
  services.xserver.displayManager.defaultSession = "plasmawayland";

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.bash.shellAliases = {
    # Read/Only nvim alias
    view = "nvim -R \"$@\"";
    nrs = "sudo nixos-rebuild switch";
  };

  users.users.alex = {
    isNormalUser = true;
    description = "Alex";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      ## GUI
      firefox
      thunderbird
      nextcloud-client
      discord
      moonlight-qt
      neofetch
      signal-desktop
      onlyoffice-bin
      ## gnome-specific stuff
      #gnomeExtensions.appindicator
      #pkgs.gnome3.gnome-tweaks
      ## kde-specific stuff
      yakuake
      mpv
      ## This doesn't seem to work, I just installed the Firefox addon manually
      #plasma-browser-integration
      ## unstable
      unstable.obsidian
    ];
  };

  environment.variables = {
      ## Geary for whatever reason didn't default to Adwaita dark unless this was here.
      ## 
      ## Since I'm Currently testing out KDE, I'm going to comment this out unless I need it later.
      ## GTK_THEME = "Adwaita:dark";
  };


  fonts.fonts = with pkgs; [
    ## MS fonts for OnlyOffice
    corefonts
    ## Good Terminal font
    terminus_font
  ];


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
     ranger
     neovim
     htop
     git
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  services.openssh.enable = false;
  networking.firewall.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  # Going to try and stay away from flatpaks for now, but this is here just incase I want to flip it
  services.flatpak.enable = false;

}
