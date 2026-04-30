{ config, pkgs, ... }:



{
  home.username = "serj";
  home.homeDirectory = "/home/serj";
  home.stateVersion = "25.05";

  # Сессионные переменные
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    _JAVA_AWT_WM_NONREPARENTING = "1";
    XDG_CURRENT_DESKTOP = "sway";
    XDG_SESSION_TYPE = "wayland";
  };

  # Пакеты пользователя
  home.packages = with pkgs; [
    foot
    wofi
    waybar
    mako
    libnotify
    grim
    slurp
    wl-clipboard
    brightnessctl
    pavucontrol
    playerctl
    cava
    libsForQt5.qt5ct
    kdePackages.qt6ct
    adwaita-qt
    adwaita-qt6
    swaybg
    discord
    steam
    vscodium
    lxqt.lxqt-policykit
    firefox
  ];

  # Sway
  wayland.windowManager.sway = {
    enable = true;
    xwayland = true;
    systemd.enable = true;

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
        "Print" = "exec grim ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png";
        "${mod}+Shift+s" = "exec grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png";
        "${mod}+z" = "exec pavucontrol";
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

      bars = []; # Waybar отдельно
    };

    extraConfig = ''
      default_border pixel 1
      default_floating_border pixel 1

      client.focused          #ffffff #000000 #ffffff #ffffff #ffffff
      client.focused_inactive #444444 #000000 #444444 #444444 #444444
      client.unfocused        #333333 #000000 #333333 #333333 #333333
      client.urgent           #ff0000 #000000 #ff0000 #ff0000 #ff0000

      exec_always swaymsg workspace 10 && swaymsg move workspace to output DP-1 && swaymsg workspace 1

      exec_always pkill swaybg; swaybg -o HDMI-A-1 -i /etc/nixos/wallpapers/sp.jpg -m fill
      exec_always pkill swaybg; swaybg -o DP-1 -i /etc/nixos/wallpapers/wp.png -m fit
   
      exec_always lxqt-policykit-agent
      exec_always dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
      exec_always dbus-update-activation-environment --systemd --all

      exec_always pkill waybar; waybar
  
    '';
  };

  # Waybar
  programs.waybar = {
    enable = true;
    systemd.enable = false; # запускаем через sway

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
        font-family: "JetBrains Mono", monospace;
        font-size: 13px;
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

      #custom-cava {
        color: #ffffff;
        padding: 0 8px;
        margin-right: 8px;
        font-family: monospace;
        letter-spacing: -2px;
      }

      #custom-cava.empty {
        padding: 0;
        margin: 0;
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

  # Mako
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

  # Foot терминал
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

  # Git
  programs.git = {
    enable = true;
    signing.format = "openpgp";
    userName = "serj";
    userEmail = "your@email.com";
  };

  programs.home-manager.enable = true;
}


#pidoras
#cherez raz