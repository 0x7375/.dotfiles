{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) getExe getExe';
in
{
  nixpkgs.overlays = [
    (final: prev: {
      tmux = prev.tmux.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          ./tmux_bigger_input_buffer.patch
        ];
      });
    })
  ];

  packages = with pkgs; [
    scripts.tmux-sessionizer
    scripts.tmux-sshr
    wl-clipboard
  ];

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    escapeTime = 0;
    terminal = "tmux-256color";
    plugins = with pkgs.tmuxPlugins; [
      fzf-tmux-url
      yank
    ];
    historyLimit = 50000;
    extraConfig = # tmux
      let
        clip =
          if config.me.gui.displayServer == "wayland" then
            "${getExe' pkgs.wl-clipboard "wl-copy"}"
          else
            "${getExe pkgs.xsel} -i";
      in
      ''
        set -g @plugin 'wfxr/tmux-fzf-url'
        set -g @fzf-url-history-limit '2000'
        set -g @fzf-url-fzf-options '-w 60% -h 50% --multi -0 --no-preview --border=sharp --tac'

        set -g @plugin 'tmux-plugins/tmux-yank'

        set -ga terminal-overrides ",${config.me.gui.terminal}:RGB" # support for undercurl

        unbind C-b
        set -g prefix C-s
        bind -n -N "Send the prefix key through to the application" \
          C-s send-prefix

        set -g mouse on
        set -g focus-events on
        set -g detach-on-destroy off

        set -g set-titles on
        set -g set-titles-string '#S'
        set -g window-status-current-format '#W*'
        set -g window-status-format '#W'
        set -g window-status-separator ' '
        set -g status-justify centre
        # set -g status-left '#S: '
        set -g status-left '''
        set -g status-left-length 120
        set -g status-right '''

        set -g display-time 2000
        set -g status-interval 1

        set -g status on
        set -g status-style bg=default
        set -g message-style fg=terminal

        set -g popup-border-style fg=black

        set -g window-status-current-style fg=default
        set -g window-status-style fg=brightblack

        set -g pane-active-border-style fg=default
        set -g pane-border-style fg=brightblack

        set -g mode-style 'fg=default,reverse'

        setw -g mode-keys vi

        bind R source-file /etc/tmux.conf \; \
          display "Reloaded tmux.conf"
        bind N neww -c "#{pane_current_path}"

        bind-key -N "Kill the current window" & kill-window
        bind-key -N "Kill the current pane" x kill-pane

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

        bind k run-shell "tmux popup -E ${getExe pkgs.scripts.tmux-sessionizer} || true"
        bind M new-window "man -k . | ${getExe pkgs.fzf} --reverse --padding 1 | ${getExe pkgs.gawk} '{print $1}' | xargs man"

        # navigate prompts
        bind -n M-p copy-mode \; \
          send-keys -X start-of-line \; \
          send-keys -X search-backward " "

        bind -n M-n copy-mode \; \
          send-keys -X search-forward " "

        bind / copy-mode \; send-keys /
        bind ? copy-mode \; send-keys ?

        bind , swap-window -t -1\; select-window -t -1
        bind . swap-window -t +1\; select-window -t +1

        bind + select-window -t :=1
        bind [ select-window -t :=2
        bind \{ select-window -t :=3
        bind ( select-window -t :=4

        bind r command-prompt -I'#W' { rename-window -- '%%' }

        # copying
        bind j copy-mode
        bind -T copy-mode-vi 'v'    send -X begin-selection
        bind -T copy-mode-vi 'C-v'  send -X rectangle-toggle
        bind -T copy-mode-vi 's'    send -X select-line

        # don't cancel mouse selection on release
        bind -T copy-mode-vi MouseDragEnd1Pane \
          select-pane \; \
          send -X copy-pipe-no-clear "${clip}"

        bind -T copy-mode-vi DoubleClick1Pane \
          select-pane \; \
          send -X select-word \; \
          send -X copy-pipe-no-clear "${clip}"

        bind -T copy-mode-vi TripleClick1Pane \
          select-pane \; \
          send -X select-line \; \
          send -X copy-pipe-no-clear "${clip}"

        bind -T copy-mode-vi 'y' \
          send -X copy-pipe-and-cancel "${clip}"
      '';
  };
}
