{ self, ... }:

{
  flake.nixos.wm = {
    xdg.mimeApps.defaultApplications = self.lib.mimeMapEntries [
      "image/png"
      "image/apng"
      "image/vnd.microsoft.icon"
      "image/jpeg"
      "image/webp"
      "image/svg+xml"
    ] "pqiv";
  };

  flake.shared.wm =
    {
      pkgs,
      lib,
      ...
    }:
    {
      packages = [ pkgs.pqiv ];

      me.wm.floating = [
        {
          type = "class";
          name = "Pqiv";
        }
      ];

      hj.xdg.config.files."pqivrc".text = lib.concatLines [
        (lib.generators.toINI
          {
            mkKeyValue =
              key: value:
              let
                value' = if lib.isBool value then (if value then "1" else "0") else toString value;
              in
              "${key} = ${value'}";
          }
          {
            options = {
              hide-info-box = true;
              browse = 1;
            };
            keybindings = {
              "<Control>j" = "{ goto_file_relative(-1) }";
              "<Control>k" = "{ goto_file_relative(1) }";
              "<Shift>j" = "{ set_scale_level_relative(0.9) }";
              "<Shift>k" = "{ set_scale_level_relative(1.1) }";
              h = "{ shift_x(25) }";
              j = "{ shift_y(-25) }";
              k = "{ shift_y(25) }";
              l = "{ shift_x(-25) }";
              r = "{ rotate_right() }";
              "<Shift>r" = "{ rotate_left() }";
            };
          }
        )
        ""
      ];
    };
}
