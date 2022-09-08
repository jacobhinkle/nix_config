{
  enable = true;
  aggressiveResize = true;
  clock24 = true;
  escapeTime = 0;
  historyLimit = 10000;
  keyMode = "vi";
  shortcut = "a";
  terminal = "kitty";
  extraConfig = ''
    unbind [
    bind Escape copy-mode

    bind f set-option status

    bind c new-window -c "#{pane_current_path}"

    # Set status bar
    set -g status-position bottom
    set -g status-style fg=white
    set -g status-left '#h'
    set -g status-left-style 'fg=blue'
    # TODO: highlighted for nested local session as well
    wg_is_keys_off="#[fg=red,bright]#([ $(tmux show-option -qv key-table) = 'off' ] && echo 'PASSTHRU')#[default]"
    set -g status-right "#[fg=yellow,bright]#S $wg_is_keys_off #[fg=green,dim]%H:%M"
    set-window-option -g window-status-current-style fg=red
    # align center the window list
    set -g status-justify centre

  '';
}
