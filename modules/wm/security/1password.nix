{
  lib,
  config,
  ...
}:

lib.mkIf config.me.wm.enable {
  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = ''
        librewolf
        zen
      '';
      mode = "0755";
    };
  };

  nixpkgs.overlays = [
    (final: prev: {
      _1password-cli = final.auto._1password-cli;
      _1password-gui = final.auto._1password-gui;
      _1password = final.auto._1password-gui;
    })
  ];

  unfree-packages = [
    "1password"
    "1password-cli"
  ];

  programs = {
    _1password.enable = true;
    _1password-gui = {
      enable = true;
      polkitPolicyOwners = [ config.me.user ];
    };
  };

  systemd.tmpfiles.rules =
    let
      content =
        builtins.replaceStrings [ "\n" ] [ "\\n" ]
          # json
          ''
            {
              "version": 1,
              "sshAgent.sshAuthorizatonModel": "application",
              "ui.routes.lastUsedRoute": "{\\\"type\\\":\\\"ItemDetail\\\",\\\"content\\\":{\\\"itemListRoute\\\":{\\\"unlockedRoute\\\":{\\\"collectionUuid\\\":\\\"everything\\\"},\\\"itemListType\\\":{\\\"type\\\":\\\"AllItems\\\"},\\\"category\\\":null,\\\"sortBehavior\\\":null},\\\"itemId\\\":\\\"DC\\\"}}",
              "security.authenticatedUnlock.enabled": true,
              "browsers.extension.enabled": true,
              "keybinds.lock": "",
              "keybinds.autoFill": "CommandOrControl+Shift+[l]L",
              "keybinds.quickAccess": "",
              "sidebar.showCategories": true,
              "sidebar.showTags": false,
              "privacy.checkHibp": true,
              "authTags": {
                "browsers.extension.enabled": "",
                "keybinds.autoFill": "",
                "keybinds.lock": "",
                "keybinds.quickAccess": "",
                "privacy.checkHibp": "",
                "security.authenticatedUnlock.enabled": "",
                "sidebar.showCategories": "",
                "sidebar.showTags": "",
                "sshAgent.sshAuthorizatonModel": "",
                "ui.routes.lastUsedRoute": ""
              }
            }
          '';
    in
    [
      "d ${config.me.home}/.config 0755 ${config.me.user} users - -"
      "d ${config.me.home}/.config/1Password 0700 ${config.me.user} users - -"
      "d ${config.me.home}/.config/1Password/settings 0700 ${config.me.user} users - -"
      "f ${config.me.home}/.config/1Password/settings/settings.json 0600 ${config.me.user} users - ${content}"
    ];
}
