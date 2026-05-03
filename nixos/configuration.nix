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
    extraGroups = [ "networkmanager" "wheel" "video" ];
  };

  # Fonts
  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  # packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    fastfetch

    nemo
   
    telegram-desktop
    cowsay
    discord
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
  };


  services.gvfs.enable = true;
  services.udisks2.enable = true;


  # ly config
  environment.etc."ly/config.ini".source = lib.mkForce ./ly-config.ini;


  # fish
  programs.fish.enable = true;
  users.users.serj.shell = pkgs.fish;

}

