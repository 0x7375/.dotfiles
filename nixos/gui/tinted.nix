{ config, ... }:

{
  tinted.enable = true;

  hj.xdg.state.files."tinted/theme" = {
    text = "dark";
    type = "copy";
    clobber = false;
    permissions = "0644";
  };

  vars.TINTED_FILE = "$HOME/.local/state/tinted/theme";
}
