{
  flake.modules.nixos.core =
    {
      config,
      pkgs,
      ...
    }:
    {
      # systemd.timers.auto-input = {
      #   wantedBy = [ "timers.target" ];
      #   timerConfig = {
      #     OnCalendar = "daily";
      #     Persistent = true;
      #   };
      # };

      systemd.services.auto-input = {
        script = ''
          # pushd "${config.me.flakeDir}"
          # git stash
          #
          # nix flake update auto-update zen-browser --flake .
          # git add flake.lock
          # if ! git diff --cached --quiet; then
          #   last_msg=$(git log -1 --pretty=%s)
          #   if [[ "$last_msg" == "chore: flake.lock update" ]]; then
          #     git -c commit.gpgsign=false commit --amend --no-edit
          #   else
          #     git -c commit.gpgsign=false commit -m "chore: flake.lock update"
          #   fi
          # fi
          #
          # git stash pop
          # popd

          [[ -d "$HOME/repos/nixpkgs" ]] && git -C "$HOME/repos/nixpkgs" pull
          [[ -d "$HOME/repos/home-manager" ]] && git -C "$HOME/repos/home-manager" pull
          [[ -d "$HOME/repos/nix-darwin" ]] && git -C "$HOME/repos/nix-darwin" pull
        '';
        serviceConfig = {
          Type = "oneshot";
          User = config.me.user;
        };
        path = with pkgs; [
          nix
          git
          openssh
        ];
      };
    };
}
