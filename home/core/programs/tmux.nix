{
  config,
  myLib,
  pkgs,
  ...
}:

let
  palette = myLib.palette;
in
{
  home.packages = with pkgs; [
    scripts.tmux-sessionizer
    scripts.tmux-sshr
  ];

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    escapeTime = 0;
    terminal = "tmux-256color";
    disableConfirmationPrompt = true;
    prefix = "C-s";
    plugins =
      let
        inherit (pkgs) tmuxPlugins;
      in
      [
        {
          plugin = tmuxPlugins.fpp;
          extraConfig = # tmux
            ''
              set -g @plugin 'tmux-plugins/tmux-fpp'
            '';
        }
        {
          plugin = tmuxPlugins.fzf-tmux-url;
          extraConfig = # tmux
            ''
              set -g @plugin 'wfxr/tmux-fzf-url'

              set -g @fzf-url-history-limit '2000'
              set -g @fzf-url-fzf-options '-w 60% -h 50% --multi -0 --no-preview --border=sharp --tac --color=border:${palette.bg1}'
            '';
        }
        {
          plugin = tmuxPlugins.yank;
          extraConfig = # tmux
            ''
              set -g @plugin 'tmux-plugins/tmux-yank'
            '';
        }
        {
          # prefix + shift + p -> start/stop loggin current pane
          # prefix + alt + c -> clear pane history
          # prefix + alt + shift + p -> save complete history
          # prefix + alt + p -> save screen history
          plugin = tmuxPlugins.logging;
          extraConfig = # tmux
            ''
              set -g @plugin 'tmux-plugins/tmux-logging'

              set -g @logging-path "/home/${config.me.user}/.local/state/tmux-logging"
            '';
        }
      ];
    historyLimit = 50000;
    mouse = true;
    extraConfig = # tmux
      ''
        set -ga terminal-overrides ",alacritty:RGB" # support for undercurl

        set -g focus-events on
        set -g detach-on-destroy off

        set -g set-titles on
        set -g set-titles-string "#W"
        set -g window-status-current-format '#W'
        set -g window-status-format '#W'
        set -g window-status-separator ' '
        set -g status-left '#S: '
        set -g status-left-length 120
        set -g status-right '''

        set -g display-time 2000
        set -g status-interval 1

        set -g status on
        set -g status-style fg=${palette.bg2},bg=${palette.bg0}
        set -g mode-style 'bg=${palette.bg0_dark},fg=${palette.red},reverse'
        set -g message-style 'fg=${palette.red}'
        set -g popup-border-style fg=${palette.bg1}

        set -g window-status-current-style fg=${palette.red}
        set -g window-status-style fg=${palette.bg2}

        set -g pane-active-border-style fg=${palette.red}
        set -g pane-border-style fg=${palette.bg2}

        setw -g mode-keys vi

        bind R source-file ~/.config/tmux/tmux.conf \; \
          display "Reloaded tmux.conf"
        bind N neww -c "#{pane_current_path}"

        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        bind B break-pane -d
        bind J join-pane -h -s :+1
        bind K join-pane -h -s :-1
        bind L select-pane -t :.+ # cycle between panes

        bind i set status

        bind h switch-client -l

        unbind '"'

        unbind t

        bind k run-shell "tmux popup -E ${pkgs.scripts.tmux-sessionizer}/bin/tmux-sessionizer || true"

        # bind H run-shell "${pkgs.scripts.tmux-sessionizer}/bin/tmux-sessionizer ${config.me.flakeDir}"

        bind -n 'C-\' run-shell -b "${pkgs.scripts.tmux-toggle-term}/bin/tmux-toggle-term"

        # navigate prompts
        bind -n M-p copy-mode \; \
          send-keys -X start-of-line \; \
          send-keys -X search-backward " "

        bind -n M-n copy-mode \; \
          send-keys -X search-forward " "

        bind / copy-mode \; send-keys /
        bind ? copy-mode \; send-keys ?

        bind , swap-window -t -1
        bind . swap-window -t +1

        bind + select-window -t :=1
        bind [ select-window -t :=2
        bind \{ select-window -t :=3
        bind ( select-window -t :=4
        bind & select-window -t :=5

        bind r command-prompt -I'#W' { rename-window -- '%%' }

        # copying
        bind j copy-mode
        bind -T copy-mode-vi 'v'    send -X begin-selection
        bind -T copy-mode-vi 'C-v'  send -X rectangle-toggle
        bind -T copy-mode-vi 's'    send -X select-line

        # don't cancel mouse selection on release
        bind -T copy-mode-vi MouseDragEnd1Pane \
          select-pane \; \
          send -X copy-pipe-no-clear "${pkgs.xsel}/bin/xsel -i"

        bind -T copy-mode-vi DoubleClick1Pane \
          select-pane \; \
          send -X select-word \; \
          send -X copy-pipe-no-clear "${pkgs.xsel}/bin/xsel -i"

        bind -T copy-mode-vi TripleClick1Pane \
          select-pane \; \
          send -X select-line \; \
          send -X copy-pipe-no-clear "${pkgs.xsel}/bin/xsel -i"

        bind -T copy-mode-vi 'y' \
          send -X copy-pipe-and-cancel "${pkgs.xsel}/bin/xsel -i --clipboard"
      '';
  };
}
