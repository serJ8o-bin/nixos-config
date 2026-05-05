{ config, pkgs,lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # <home-manager/nixos>  
  ];
  
  # Bootloader

  # fuck systemd virus exploit
  #boot.loader.systemd-boot.enable = true;

  
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader = {
    efi.canTouchEfiVariables = true;
    
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true; 
      splashImage = ./wallpapers/grubwp.jpeg;
      gfxmodeEfi = "1920x1080";
    };
  };


  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  time.timeZone = "Europe/Warsaw";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  # XWayland 
  programs.xwayland.enable = true;

  # Sway
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  # DM — ly
  services.displayManager.ly.enable = true;

  # PipeWire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  #Noise supp 

  


  # Polkit
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # user
  users.users.serj = {
  isNormalUser = true;
  description = "serj";
  extraGroups = [ "networkmanager" "wheel" "video" "audio" "input" ];
  initialPassword = "1111";
};

  # Fonts
  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];
# Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    gamescopeSession.enable = true;
  };

  # 32bit libs
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  # packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    fastfetch

    nemo
   
    telegram-desktop
    cowsay
    btop
    wlogout

    rnnoise-plugin
    easyeffects
  ];

  # Home Manager

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";

  #alias
  environment.shellAliases = {
  ff = "fastfetch";
  nix-switch = "sudo nixos-rebuild switch";
  gparted = "sudo -E gparted";
  };

  #files
  services.gvfs.enable = true;
  services.udisks2.enable = true;


  # ly config
  services.displayManager.ly.enable = true;

  environment.etc."ly/config.ini".text = ''
  allow_empty_password = true
  animation = doom
  animation_frame_delay = 4
  animation_timeout_sec = 0
  asterisk = *
  auth_fails = 10
  bigclock = en
  bigclock_12hr = false
  bigclock_seconds = false
  blank_box = true
  border_fg = 0x00FFFFFF
  box_title = null
  clear_password = false
  clock = null
  cmatrix_fg = 0x00FFFFFF
  cmatrix_head_col = 0x01FFFFFF
  cmatrix_min_codepoint = 0x21
  cmatrix_max_codepoint = 0x7B
  colormix_col1 = 0x00222222
  colormix_col2 = 0x00808080
  colormix_col3 = 0x20CCCCCC
  default_input = login
  doom_fire_height = 6
  doom_fire_spread = 2
  doom_top_color = 0x00222222
  doom_middle_color = 0x00888888
  doom_bottom_color = 0x00FFFFFF
  edge_margin = 0
  error_bg = 0x00000000
  error_fg = 0x01FF0000
  fg = 0x00FFFFFF
  bg = 0x00000000
  full_color = true
  hide_borders = false
  hide_key_hints = false
  hide_keyboard_locks = false
  hide_version_string = false
  input_len = 34
  lang = en
  margin_box_h = 2
  margin_box_v = 1
  numlock = false
  restart_key = F2
  save = true
  service_name = ly
  session_log = .local/state/ly-session.log
  shell = true
  show_password_key = F7
  show_tty = false
  shutdown_key = F1
  text_in_center = false
  vi_mode = false
  vi_default_mode = normal
  xinitrc = ~/.xinitrc

  brightness_down_cmd = ${pkgs.brightnessctl}/bin/brightnessctl -q -n s 10%-
  brightness_up_cmd = ${pkgs.brightnessctl}/bin/brightnessctl -q -n s +10%
  brightness_down_key = F5
  brightness_up_key = F6
  path = /run/current-system/sw/bin
  restart_cmd = /run/current-system/systemd/bin/systemctl reboot
  shutdown_cmd = /run/current-system/systemd/bin/systemctl poweroff
  tty = 1
  '';

  # fish
  programs.fish.enable = true;
  users.users.serj.shell = pkgs.fish;

  services.dbus.enable = true;
  xdg.portal = {
  enable = true;
  wlr.enable = true;
  extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
};

}

