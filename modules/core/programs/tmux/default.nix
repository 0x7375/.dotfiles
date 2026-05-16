{
  flake.modules.generic.core =
    {
      config,
      options,
      lib,
      pkgs,
      ...
    }:
    let
      inherit (lib) getExe;
      plugins = with pkgs.tmuxPlugins; [
        fzf-tmux-url
      ];
    in
    {
      nixpkgs.overlays = [
        (_: prev: {
          tmux = (prev.crossPkgs or prev).tmux.overrideAttrs (old: {
            patches = (old.patches or [ ]) ++ [
              ./tmux_bigger_input_buffer.patch
            ];
          });
        })
      ];

      packages = with pkgs; [
        my.tmux-sessionizer
        my.tmux-sshr
        less
        fzf
        coreutils
      ];

      programs.tmux = {
        enable = true;
        extraConfig =
          # tmux
          ''
            set -g @plugin 'wfxr/tmux-fzf-url'
            set -g @fzf-url-history-limit '2000'
            set -g @fzf-url-fzf-options '-w 60% -h 50% --multi -0 --no-preview --border=sharp --tac'

            set -g default-terminal "tmux-256color"
            ${lib.optionalString (options ? me.desktop) ''
              set -ga terminal-overrides ",${config.me.desktop.terminal.name}:RGB"
            ''}

            unbind C-b
            set -g prefix C-s
            bind -N "Send the prefix key through to the application" \
              C-s send-prefix

            set -g mouse on
            set -g focus-events on
            set -g detach-on-destroy off
            set -g set-clipboard on

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

            set  -s escape-time 0
            set -g display-time 2000
            set -g base-index 1
            set -g history-limit 50000
            set -g status-interval 1

            set -g status on
            set -g status-style bg=default
            set -g message-style fg=terminal

            set -g popup-border-style fg=black

            set -g window-status-current-style fg=red
            set -g window-status-style fg=brightblack

            set -g pane-active-border-style fg=default
            set -g pane-border-style fg=brightblack

            set -g mode-style 'fg=red,reverse'

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

            bind C-h select-pane -L
            bind C-j select-pane -D
            bind C-k select-pane -U
            bind C-l select-pane -R

            bind i set status

            bind h switch-client -l

            unbind '"'

            unbind t

            bind k run-shell "tmux popup -E ${getExe pkgs.my.tmux-sessionizer} || true"
            bind M new-window "man -k . | ${getExe pkgs.fzf} --reverse --padding 1 | ${getExe pkgs.gawk} '{print $1}' ${lib.optionalString pkgs.stdenv.isDarwin "| tr -d '()0-9' "}| xargs man"

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

            bind -T copy-mode-vi MouseDragEnd1Pane \
              select-pane \; \
              send -X copy-selection-no-clear

            bind -T copy-mode-vi DoubleClick1Pane \
              select-pane \; \
              send -X select-word \; \
              send -X copy-selection-no-clear

            bind -T copy-mode-vi TripleClick1Pane \
              select-pane \; \
              send -X select-line \; \
              send -X copy-selection-no-clear

            bind -T copy-mode-vi 'y' \
              send -X copy-selection-and-cancel

            bind -T copy-mode-vi 'Y' \
              send -X copy-selection-and-cancel \; \
              paste-buffer

            ${lib.concatMapStringsSep "\n" (x: "run-shell ${x.rtp}") plugins}
          '';
      };
    };
}
