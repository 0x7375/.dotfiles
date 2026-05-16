{ self, ... }:

{
  flake.modules.nixos.desktop = {
    xdg = {
      mimeApps.defaultApplications = self.lib.mapMimeEntries [
        "image/png"
        "image/apng"
        "image/vnd.microsoft.icon"
        "image/jpeg"
        "image/webp"
        "image/svg+xml"
      ] "pqiv";

      desktopEntries."pqiv-browse" = {
        name = "pqiv (browse)";
        exec = "pqiv --browse %f";
        mimeType = [
          "image/png"
          "image/apng"
          "image/vnd.microsoft.icon"
          "image/jpeg"
          "image/webp"
          "image/svg+xml"
        ];
      };
    };
  };

  flake.modules.generic.desktop =
    { pkgs, ... }:
    {
      packages = [ pkgs.pqiv ];

      me.desktop.floating = [
        {
          type = "appid";
          name = "Pqiv";
        }
      ];

      hj.xdg.config.files.pqivrc.text = # ini
        ''
          [options]
          hide-info-box=1

          [keybindings]
          <Control>j { goto_file_relative(1) }
          <Control>k { goto_file_relative(-1) }
          <Shift>j { set_scale_level_relative(0.9) }
          <Shift>k { set_scale_level_relative(1.1) }
          <Shift>r { rotate_left() }
          h { shift_x(25) }
          j { shift_y(-25) }
          k { shift_y(25) }
          l { shift_x(-25) }
          r { rotate_right() }
          <Shift>d { command(trash $1) }

          @MONTAGE {
            <l>  { montage_mode_shift_x(1) }
            <h>  { montage_mode_shift_x(-1) }
            <k>  { montage_mode_shift_y(-1) }
            <j>  { montage_mode_shift_y(1) }
            m  { montage_mode_return_proceed() }
          }
        '';
    };
}
