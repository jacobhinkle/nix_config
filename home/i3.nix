pkgs: rec {
  menu = "${pkgs.dmenu}/bin/dmenu_run";
  modifier = "Mod1";
  terminal = "kitty";
  keybindings = let
    browser = "qutebrowser";
    scrot2clip =
      pkgs.writeShellScript "scrot2clip"
      "${pkgs.scrot}/bin/scrot -s - | ${pkgs.xclip}/bin/xclip -selection primary -i -t image/png";
  in {
    "${modifier}+Return" = "exec ${terminal} tmux new";
    "${modifier}+Shift+Return" = "exec ${terminal}";
    "${modifier}+Shift+q" = "kill";
    "${modifier}+d" = "exec ${menu}";
    "${modifier}+apostrophe" = "exec ${browser}";

    "${modifier}+j" = "focus left";
    "${modifier}+k" = "focus down";
    "${modifier}+l" = "focus up";
    "${modifier}+semicolon" = "focus right";

    "${modifier}+Shift+j" = "move left";
    "${modifier}+Shift+k" = "move down";
    "${modifier}+Shift+l" = "move up";
    "${modifier}+Shift+semicolon" = "move right";

    "${modifier}+h" = "split h";
    "${modifier}+v" = "split v";
    "${modifier}+f" = "fullscreen toggle";

    "${modifier}+s" = "layout stacking";
    "${modifier}+w" = "layout tabbed";
    "${modifier}+e" = "layout toggle split";

    "${modifier}+Shift+space" = "floating toggle";
    "${modifier}+space" = "focus mode_toggle";

    "${modifier}+a" = "focus parent";
    "${modifier}+z" = "focus child";

    "${modifier}+Shift+s" = "exec ${scrot2clip}";

    "${modifier}+Shift+minus" = "move scratchpad";
    "${modifier}+minus" = "scratchpad show";

    "${modifier}+1" = "workspace number 1";
    "${modifier}+2" = "workspace number 2";
    "${modifier}+3" = "workspace number 3";
    "${modifier}+4" = "workspace number 4";
    "${modifier}+5" = "workspace number 5";
    "${modifier}+6" = "workspace number 6";
    "${modifier}+7" = "workspace number 7";
    "${modifier}+8" = "workspace number 8";
    "${modifier}+9" = "workspace number 9";
    "${modifier}+0" = "workspace number 10";

    "${modifier}+Shift+1" = "move container to workspace number 1";
    "${modifier}+Shift+2" = "move container to workspace number 2";
    "${modifier}+Shift+3" = "move container to workspace number 3";
    "${modifier}+Shift+4" = "move container to workspace number 4";
    "${modifier}+Shift+5" = "move container to workspace number 5";
    "${modifier}+Shift+6" = "move container to workspace number 6";
    "${modifier}+Shift+7" = "move container to workspace number 7";
    "${modifier}+Shift+8" = "move container to workspace number 8";
    "${modifier}+Shift+9" = "move container to workspace number 9";
    "${modifier}+Shift+0" = "move container to workspace number 10";

    "${modifier}+Shift+c" = "reload";
    "${modifier}+Shift+r" = "restart";
    "${modifier}+Shift+e" = "exec i3-nagbar -t warning -m 'Do you want to exit i3?' -b 'Yes' 'i3-msg exit'";

    "${modifier}+r" = "mode resize";
  };
}
