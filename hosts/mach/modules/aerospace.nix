{ pkgs, lib, ... }:

let
  inherit (lib) getExe;
in
{
  services.aerospace = {
    enable = true;
    settings = {
      config-version = 2;
      after-startup-command = [ ];
      accordion-padding = 50;
      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;

      default-root-container-layout = "accordion";
      default-root-container-orientation = "auto";

      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
      automatically-unhide-macos-hidden-apps = true;

      persistent-workspaces = map toString (lib.range 1 9);

      key-mapping.preset = "qwerty";

      gaps = {
        inner.horizontal = 0;
        inner.vertical = 0;
        outer.left = 0;
        outer.bottom = 0;
        outer.top = 0;
        outer.right = 0;
      };

      mode.main.binding = {
        "alt-shift-esc" = [
          "reload-config"
          "mode main"
        ];
        "alt-enter" = [
          "layout floating tiling"
          "mode main"
        ];
        "alt-a" = "layout tiles accordion horizontal";
        "alt-q" = "close --quit-if-last-window";
        "alt-f" = "fullscreen";

        "alt-t" = "exec-and-forget open -na Alacritty --args -e ${getExe pkgs.my.tmux-sessionizer} ~/";
        "alt-s" = "exec-and-forget open -na Alacritty --args -e ${getExe pkgs.my.tmux-sshr}";
        "alt-e" = "exec-and-forget open -na Alacritty --args -e ${getExe pkgs.lf}";
        # "alt-e" = "exec-and-forget osascript -e 'tell application \"Finder\" to make new Finder window to home'";
        "alt-shift-e" = "exec-and-forget open -na Alacritty --args -e sudo ${getExe pkgs.lf}";

        "alt-m" = "exec-and-forget ${pkgs.writeShellScript "open-note" ''
          cd ~/notes
          note=$(ls *.md | sed 's/\.md$//' | ${lib.getExe pkgs.choose-gui})
          [ -n "$note" ] && open -na Alacritty --args -e nvim "$HOME/notes/$note.md"
        ''}";

        "alt-shift-t" = "exec-and-forget open -na Alacritty";
        "alt-shift-s" = "exec-and-forget ${getExe pkgs.my.swap-theme}";
        "alt-w" = "exec-and-forget open -na Zen";

        "alt-h" = "focus left";
        "alt-j" = "focus down";
        "alt-k" = "focus up";
        "alt-l" = "focus right";

        "alt-shift-h" = "move left";
        "alt-shift-j" = "move down";
        "alt-shift-k" = "move up";
        "alt-shift-l" = "move right";

        "alt-minus" = "resize smart -50";
        "alt-equal" = "resize smart +50";

        "alt-1" = "workspace 1";
        "alt-2" = "workspace 2";
        "alt-3" = "workspace 3";
        "alt-4" = "workspace 4";
        "alt-5" = "workspace 5";
        "alt-6" = "workspace 6";
        "alt-7" = "workspace 7";
        "alt-8" = "workspace 8";
        "alt-9" = "workspace 9";

        "alt-shift-1" = "move-node-to-workspace 1";
        "alt-shift-2" = "move-node-to-workspace 2";
        "alt-shift-3" = "move-node-to-workspace 3";
        "alt-shift-4" = "move-node-to-workspace 4";
        "alt-shift-5" = "move-node-to-workspace 5";
        "alt-shift-6" = "move-node-to-workspace 6";
        "alt-shift-7" = "move-node-to-workspace 7";
        "alt-shift-8" = "move-node-to-workspace 8";
        "alt-shift-9" = "move-node-to-workspace 9";

        "alt-tab" = "workspace-back-and-forth";
        "alt-shift-tab" = "move-workspace-to-monitor --wrap-around next";
      };

      on-window-detected = [
        {
          "if" = {
            app-id = "com.1password.1password";
          };
          run = "layout floating";
        }
        {
          "if" = {
            app-id = "app.zen-browser.zen";
          };
          run = "move-node-to-workspace 3";
        }
        {
          "if" = {
            app-id = "com.hnc.Discord";
          };
          run = "move-node-to-workspace 4";
        }
        {
          "if" = {
            app-id = "com.github.th-ch.youtube-music";
          };
          run = "move-node-to-workspace 4";
        }
      ];
    };
  };

  # TODO: try with squared corners
  # services.jankyborders = {
  #     enable = true;
  #     active_color = "0xffe1e3e4"; # ARGB format
  #     inactive_color = "0xff494d64";
  #     width = 5.0;
  #   };
}
