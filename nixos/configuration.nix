{ config, pkgs,lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # <home-manager/nixos>  
  ];
  
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

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

  # Polkit
  security.polkit.enable = true;
  services.gnome.gnome-keyring.enable = true;

  # user
  users.users.serj = {
    isNormalUser = true;
    description = "serj";
    extraGroups = [ "networkmanager" "wheel" "video" ];
  };

  # Fonts
  fonts.packages = with pkgs; [
    jetbrains-mono
  ];

  # packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    fastfetch
    xfce.thunar
    xfce.thunar-archive-plugin
    file-roller
   
    telegram-desktop
    discord
    btop
    wlogout
  ];

  # Home Manager

  nixpkgs.config.allowUnfree = true;
  system.stateVersion = "25.11";

  environment.etc."ly/config.ini".source = lib.mkForce ./ly-config.ini;
}

