{
  lib,
  pkgs,
  ...
}:

{
  services.arbtt = {
    enable = true;
    logFile = "%h/.local/state/arbtt/capture.log";
  };

  hj.xdg.state.files."arbtt/.stignore".text = ''
    capture.log.lck
  '';

  environment.shellAliases.arbtt = ''
    ${lib.getExe' pkgs.haskellPackages.arbtt "arbtt-stats"} --logfile=$HOME/.local/state/arbtt/capture.log \
      --categorizefile=$HOME/.config/arbtt/categorize.cfg
  '';

  hj.xdg.config.files."arbtt/categorize.cfg".text = ''
    aliases (
      "Navigator" -> "Firefox",
    )

    {
       tag Title:$current.title,
       tag Program:$current.program,
    }
  '';
}
