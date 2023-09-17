{ config, pkgs, ... }:
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

  ## For Japanese IME support
  ## https://nixos.wiki/wiki/Fcitx5
  i18n.inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
          fcitx5-mozc
          fcitx5-with-addons
      ];
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

  # Excludes Elisa, a music player that I don't use
  # https://nixos.wiki/wiki/KDE
  environment.plasma5.excludePackages = with pkgs.libsForQt5; [
    elisa
  ];

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Exclude xterm
  services.xserver.excludePackages = [ pkgs.xterm ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

  ## Needed for your printer
  ## https://nixos.wiki/wiki/Printing
  services.printing.drivers = [ pkgs.brlaser ];

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
    ncu = "sudo nix-channel --update";
    nrs = "sudo nixos-rebuild switch";
    nsp = "nix-shell -p \"$@\"";
    nixUp = "ncu && nrs";
    # git
    gca = "git commit -av";
    gp = "git pull -v;git push -v";
  };

  programs.bash.interactiveShellInit = "set -o vi";

  users.users.alex = {
    isNormalUser = true;
    description = "Alex";
    extraGroups = [ "networkmanager" "wheel" "docker" "scanner" "lp"];
    packages = with pkgs; [
      ## GUI
      firefox
      thunderbird
      nextcloud-client
      discord
      moonlight-qt
      signal-desktop
      onlyoffice-bin
      xournalpp ## for pdf editing
      ## umbc
      google-chrome
      webex
      openconnect
      networkmanager-openconnect
      ## gnome-specific stuff
      #gnomeExtensions.appindicator
      #pkgs.gnome3.gnome-tweaks
      ## This is a good rdp client, but it doesn't get used super often.  Might be better to keep it in a nix-shell
      #gnome-connections
      ## kde-specific stuff
      yakuake
      mpv
      kolourpaint
      ## fixes clipboard for neovim
      wl-clipboard
      ## This doesn't seem to work, I just installed the Firefox addon manually
      #plasma-browser-integration
      obsidian
      ## ansible
      ansible
      ansible-lint
      # for credentials
      bitwarden-cli
      ## photo/picture tools
      gimp
      simple-scan
    ];
  };

  environment.variables = {
      ## Geary for whatever reason didn't default to Adwaita dark unless this was here.
      ## Since I'm Currently testing out KDE, I'm going to comment this out unless I need it later.
      ## GTK_THEME = "Adwaita:dark";
  };


  fonts.packages = with pkgs; [
    ## Default
    dejavu_fonts
    ## Good Terminal font
    terminus_font
    ## For better Japanese support
    ## https://functor.tokyo/blog/2018-10-01-japanese-on-nixos
    ipafont
    ## MS fonts for OnlyOffice
    corefonts
  ];

  fonts.fontconfig.defaultFonts = {
   monospace = [
     "DejaVu Sans Mono"
     "IPAGothic"
   ];
   sansSerif = [
     "DejaVu Sans"
     "IPAPGothic"
   ];
   serif = [
     "DejaVu Serif"
     "IPAPMincho"
   ];
 };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
     ranger
     neovim
     htop
     git
     neofetch
     screen
     tmux
     ripgrep
     zip
     unzip
     nfs-utils
  ];

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    configure = {
      customRC = ''
        set nu
        set nospell
        set smartcase
        set mouse=a
        set noshowmode
	"this needs the `wl-clipboard` package on wayland
        set clipboard+=unnamedplus
	let g:indent_guides_enable_on_vim_startup = 1
	let g:lightline = { 'colorscheme': 'wombat', }
      '';
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [ 
	vim-gitgutter
	vim-smoothie
	lightline-vim
	];
    };
  };
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

  #networking.firewall.allowedTCPPorts = [ 22 ];
  #services.openssh.enable = true;
  networking.firewall.enable = true;

  system.stateVersion = "unstable"; 

  # Scanner support
  # https://nixos.wiki/wiki/Scanners
  hardware.sane.enable = true;

  # Going to try and stay away from flatpaks for now, but this is here just incase I want to flip it
  services.flatpak.enable = false;

  ## Docker
  virtualisation.docker.enable = true;

  services.rpcbind.enable = true; # needed for NFS
  systemd.mounts = [{
    type = "nfs";
    mountConfig = {
      Options = "rw,noatime,_netdev";
    };
    what = "rokkenjima:/opt/alex";
    where = "/home/alex";
  }
  ];
  systemd.automounts = [{
    wantedBy = [ "multi-user.target" ];
    automountConfig = {
      TimeoutIdleSec = "0";
    };
    where = "/home/alex";
  }
  ];


}
