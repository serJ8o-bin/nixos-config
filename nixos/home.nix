{ config, pkgs, ... }:

let

  wallpaperSource = ./wallpapers; 
  

  stateFile = "/home/serj/.config/wallpaper/.state";

  selectWallpaper = pkgs.writeShellScriptBin "select-wallpaper" ''
    #!${pkgs.bash}/bin/bash
    WALLPAPER_DIR="${wallpaperSource}"
    STATE_FILE="${stateFile}" 
    mkdir -p "$(dirname "$STATE_FILE")"
    MONITOR=$(printf 'HDMI-A-1\nDP-1' | ${pkgs.wofi}/bin/wofi --dmenu --prompt "Monitor" --insensitive)
    [ -z "$MONITOR" ] && exit 0
    mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) | sort)
    if [ ''${#WALLPAPERS[@]} -eq 0 ]; then
        ${pkgs.libnotify}/bin/notify-send "Wallpaper" "No wallpapers found in $WALLPAPER_DIR"
        exit 1
    fi
    CHOICES=()
    for wp in "''${WALLPAPERS[@]}"; do
        CHOICES+=("$(basename "$wp")")
    done
    SELECTED_NAME=$(printf '%s\n' "''${CHOICES[@]}" | ${pkgs.wofi}/bin/wofi --dmenu --prompt "Wallpaper" --insensitive)
    [ -z "$SELECTED_NAME" ] && exit 0
    
    SELECTED_PATH="$WALLPAPER_DIR/$SELECTED_NAME"
    MODE=$(printf 'fill\nfit\nstretch\ncenter\ntile' | ${pkgs.wofi}/bin/wofi --dmenu --prompt "Mode" --insensitive)
    [ -z "$MODE" ] && MODE="fill"
    if [ -f "$STATE_FILE" ]; then
        grep -v "^''${MONITOR}=" "$STATE_FILE" > "''${STATE_FILE}.tmp" 2>/dev/null || true
        mv "''${STATE_FILE}.tmp" "$STATE_FILE" 2>/dev/null || true
    fi
    
    echo "''${MONITOR}=''${SELECTED_PATH} ''${MODE}" >> "$STATE_FILE"
    pkill -f "swaybg -o ''${MONITOR}" 2>/dev/null || true
    ${pkgs.swaybg}/bin/swaybg -o "$MONITOR" -i "$SELECTED_PATH" -m "$MODE" &
    
    ${pkgs.libnotify}/bin/notify-send "Wallpaper" "''${MONITOR}: $SELECTED_NAME ($MODE)"
  '';

  applyWallpaper = pkgs.writeShellScriptBin "apply-wallpaper" ''
    #!${pkgs.bash}/bin/bash
    
    STATE_FILE="${stateFile}"
    [ ! -f "$STATE_FILE" ] && exit 0
    
    while IFS= read -r line; do
        MONITOR="''${line%%=*}"
        REST="''${line#*=}"
        WP_PATH="''${REST% *}"
        MODE="''${REST##* }"
        
        if [ -n "$WP_PATH" ] && [ -f "$WP_PATH" ]; then
            ${pkgs.swaybg}/bin/swaybg -o "$MONITOR" -i "$WP_PATH" -m "$MODE" &
        fi
    done < "$STATE_FILE"
  '';
  
in {
  home.username = "serj";
  home.homeDirectory = "/home/serj";
  home.stateVersion = "25.05";

  qt = {
    enable = true;
    platformTheme.name = "qt5ct";
    style.name = "adwaita-dark";
  };

  home.packages = with pkgs; [
    foot
    wofi
    waybar
    mako
    libnotify
    flameshot
    wl-clipboard
    brightnessctl
    pavucontrol
    playerctl

    libsForQt5.qt5ct
    kdePackages.qt6ct
    adwaita-qt
    adwaita-qt6
    graphite-gtk-theme
    adw-gtk3
    gruvbox-dark-gtk
    andromeda-gtk-theme
    
    swaybg
    discord
    steam
    vscodium
    lxqt.lxqt-policykit
    firefox
    selectWallpaper
    applyWallpaper
    nwg-look
    gsettings-desktop-schemas

    qbittorrent
    vlc
    
    kdePackages.qtwayland
    kdePackages.qt6ct
    libsForQt5.qtwayland
  ];
  
  #fish 
  programs.fish = {
    enable = true;
    interactiveShellInit = "set fish_greeting"; # Убирает текст при входе
    shellAliases = {
      update = "sudo nixos-rebuild switch --flake /etc/nixos#nixos";
      c = "clear";
      ls = "ls --color=auto";
    };
  };
  #foot fish
  programs.foot.settings.main.shell = "${pkgs.fish}/bin/fish";

  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    systemd.enable = true;

    extraSessionCommands = ''
      export QT_QPA_PLATFORMTHEME=qt5ct
      export QT_QPA_PLATFORM=wayland
      export SDL_VIDEODRIVER=wayland
      export _JAVA_AWT_WM_NONREPARENTING=1
      export XDG_CURRENT_DESKTOP=sway
      export XDG_SESSION_TYPE=wayland
    '';

    config = {
      modifier = "Mod4";
      terminal = "foot";
      menu = "wofi --show drun --allow-images --insensitive";

      output = {
        "HDMI-A-1" = {
          mode = "1920x1080@100Hz";
          position = "0,0";
        };
        "DP-1" = {
          mode = "1920x1080";
          position = "1920,-480";
          transform = "270";
        };
      };

      input = {
        "*" = {
          xkb_layout = "us,ru";
          xkb_variant = ",";
          xkb_options = "grp:lalt_lshift_toggle";
        };
      };

      workspaceOutputAssign = [
        { workspace = "10"; output = "DP-1"; }
      ];

      keybindings = let
        mod = config.wayland.windowManager.sway.config.modifier;
      in {
        "${mod}+Return" = "exec foot";
        "${mod}+Shift+q" = "kill";
        "${mod}+d" = "exec wofi --show drun --allow-images --insensitive";
        "${mod}+Shift+c" = "reload";
        "${mod}+Shift+e" = "exec swaynag -t warning -m 'Exit sway?' -B 'Yes' 'swaymsg exit'";

        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";
        "${mod}+Left" = "focus left";
        "${mod}+Down" = "focus down";
        "${mod}+Up" = "focus up";
        "${mod}+Right" = "focus right";

        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";
        "${mod}+Shift+Left" = "move left";
        "${mod}+Shift+Down" = "move down";
        "${mod}+Shift+Up" = "move up";
        "${mod}+Shift+Right" = "move right";

        "${mod}+1" = "workspace number 1";
        "${mod}+2" = "workspace number 2";
        "${mod}+3" = "workspace number 3";
        "${mod}+4" = "workspace number 4";
        "${mod}+5" = "workspace number 5";
        "${mod}+6" = "workspace number 6";
        "${mod}+7" = "workspace number 7";
        "${mod}+8" = "workspace number 8";
        "${mod}+9" = "workspace number 9";
        "${mod}+0" = "workspace number 10";

        "${mod}+Shift+1" = "move container to workspace number 1";
        "${mod}+Shift+2" = "move container to workspace number 2";
        "${mod}+Shift+3" = "move container to workspace number 3";
        "${mod}+Shift+4" = "move container to workspace number 4";
        "${mod}+Shift+5" = "move container to workspace number 5";
        "${mod}+Shift+6" = "move container to workspace number 6";
        "${mod}+Shift+7" = "move container to workspace number 7";
        "${mod}+Shift+8" = "move container to workspace number 8";
        "${mod}+Shift+9" = "move container to workspace number 9";
        "${mod}+Shift+0" = "move container to workspace number 10";

        "${mod}+b" = "splith";
        "${mod}+v" = "splitv";
        "${mod}+e" = "layout toggle split";
        "${mod}+f" = "fullscreen";
        "${mod}+Shift+space" = "floating toggle";
        "${mod}+space" = "focus mode_toggle";
        "${mod}+a" = "focus parent";

        "${mod}+Shift+minus" = "move scratchpad";
        "${mod}+minus" = "scratchpad show";

        "${mod}+r" = "mode resize";

        "XF86AudioMute" = "exec --no-startup-id wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioLowerVolume" = "exec --no-startup-id wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioRaiseVolume" = "exec --no-startup-id wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioMicMute" = "exec --no-startup-id wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
        "XF86MonBrightnessUp" = "exec brightnessctl set 5%+";

        "${mod}+Shift+s" = "exec flameshot gui";
        "${mod}+Shift+p" = "exec flameshot screen";

        "${mod}+z" = "exec pavucontrol";
        "${mod}+w" = "exec select-wallpaper";
      };

      modes = {
        resize = {
          "h" = "resize shrink width 10px";
          "j" = "resize grow height 10px";
          "k" = "resize shrink height 10px";
          "l" = "resize grow width 10px";
          "Left" = "resize shrink width 10px";
          "Down" = "resize grow height 10px";
          "Up" = "resize shrink height 10px";
          "Right" = "resize grow width 10px";
          "Return" = "mode default";
          "Escape" = "mode default";
        };
      };

      floating.modifier = config.wayland.windowManager.sway.config.modifier;

      bars = [];
    };

    extraConfig = ''

      # fuck this titlebar
      default_border pixel 2
      default_floating_border pixel 2

      # Polkit agent floating rules
      for_window [app_id="^lxqt-policykit-agent$"] floating enable
      for_window [title="(?i)polkit"] floating enable
      for_window [title="(?i)authentication"] floating enable
      for_window [title="(?i)password"] floating enable
      
      # Generic dialog rules
      for_window [title="(?i)(save|сохранить|open|открыть|choose|выберите|look in)"] floating enable
      for_window [window_type="dialog"] floating enable
      for_window [window_type="menu"] floating enable
      for_window [window_role="pop-up"] floating enable
      for_window [window_role="bubble"] floating enable



      client.focused          #ffffff #000000 #ffffff #ffffff #ffffff
      client.focused_inactive #444444 #000000 #444444 #444444 #444444
      client.unfocused        #333333 #000000 #333333 #333333 #333333
      client.urgent           #ff0000 #000000 #ff0000 #ff0000 #ff0000

      exec dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway QT_QPA_PLATFORMTHEME=qt5ct
      exec systemctl --user import-environment PATH DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP QT_QPA_PLATFORMTHEME

      exec_always swaymsg workspace 10 && swaymsg move workspace to output DP-1 && swaymsg workspace 1

      exec_always "pkill waybar; waybar"
      exec_always "pkill mako; mako"
      exec_always "pkill swaybg; apply-wallpaper"

      exec_always lxqt-policykit-agent
    '';
  };

  programs.waybar = {
    enable = true;
    systemd.enable = false;

    settings = [{
      output = "HDMI-A-1";
      layer = "top";
      position = "top";
      height = 24;
      spacing = 0;
      margin = "0";

      modules-left = [ "sway/workspaces" ];
      modules-center = [ "sway/window" ];
      modules-right = [ "cpu" "custom/media" "clock" "tray" ];

      "sway/window" = {
        format = "{}";
        max-length = 50;
        separate-outputs = true;
      };

      cpu = {
        format = "CPU {usage}%";
        interval = 2;
        tooltip = false;
      };

      "custom/media" = {
        format = "{icon} {}";
        return-type = "json";
        format-icons = {
          Playing = "▶";
          Paused = "⏸";
          Stopped = ".";
        };
        exec = "playerctl metadata --format '{\"text\": \"{{artist}} - {{title}}\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}' -F";
        on-click = "playerctl play-pause";
        on-scroll-up = "playerctl next";
        on-scroll-down = "playerctl previous";
        hide-empty-text = true;
      };

      clock = {
        format = "{:%d.%m %H:%M}";
        interval = 60;
      };

      tray = {
        spacing = 10;
        icon-size = 16;
      };
    }];

    style = ''
      * {
        border: none;
        border-radius: 0;
        font-family: "JetBrains Mono", monospace;
        font-size: 13px;
        min-height: 0;
        padding: 0;
        margin: 0;
      }

      window#waybar {
        background-color: #000000;
        color: #ffffff;
      }

      #workspaces {
        margin-left: 4px;
      }

      #workspaces button {
        padding: 0 6px;
        color: #666666;
        background: transparent;
        border: none;
        border-radius: 0;
        min-width: 14px;
      }

      #workspaces button.focused {
        color: #ffffff;
        background: #2a2a2a;
      }

      #workspaces button:hover {
        background: #3a3a3a;
        color: #ffffff;
      }

      #window {
        color: #ffffff;
        padding: 0 20px;
      }

      #cpu {
        color: #ffffff;
        padding: 0 12px;
        margin-right: 4px;
      }

      #custom-media {
        color: #ffffff;
        padding: 0 12px;
        background: #111111;
        margin-right: 4px;
      }

      #custom-media.playing {
        color: #ffffff;
      }

      #custom-media.paused {
        color: #666666;
      }

      #clock {
        color: #ffffff;
        padding: 0 16px;
        margin-right: 8px;
      }

      #tray {
        margin-right: 8px;
        padding: 0 8px;
      }
    '';
  };

  services.mako = {
    enable = true;
    backgroundColor = "#000000ff";
    textColor = "#ffffff";
    borderColor = "#ffffff";
    borderSize = 2;
    padding = "10";
    output = "HDMI-A-1";
    defaultTimeout = 5000;
  };

  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "JetBrains Mono:size=11";
      };
      colors-dark = {
        background = "000000";
        foreground = "ffffff";
      };
    };
  };



  programs.home-manager.enable = true;
}
