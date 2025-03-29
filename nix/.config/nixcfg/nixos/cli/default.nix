{
  options,
  config,
  pkgs,
  myLib,
  ...
}:

{
  imports = [
    ./default
  ] ++ (myLib.filesIn ./bundles);

  i18n.supportedLocales = options.i18n.supportedLocales.default ++ [ "fr_FR.UTF-8/UTF-8" ];

  system.activationScripts = {
    symlinkRootConfig = {
      text = # bash
        ''
          if [ ! -L /root/.config ] && [ -e /home/${config.me.user}/.config ]; then
            ln -s /home/${config.me.user}/.config /root/.config
          fi
        '';
    };
    copyBashrcToRoot = {
      text = # bash
        ''
          if [ -e /home/${config.me.user}/.bashrc ]; then
            cp -f /home/${config.me.user}/.bashrc /root/.bashrc
          fi
        '';
    };
  };

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  console = {
    packages = with pkgs; [ terminus_font ];
    font = "${pkgs.terminus_font}/share/consolefonts/ter-132b.psf.gz";
    useXkbConfig = true;
    colors =
      let
        hex = myLib.hex;
      in
      [
        "000000"
        hex.red
        hex.green
        hex.yellow
        hex.blue
        hex.magenta
        hex.cyan
        "ffffff"
        hex.bg3
        hex.red
        hex.green
        hex.magenta
        hex.blue
        hex.magenta
        hex.cyan
        "ffffff"
      ];
  };

  time.timeZone = "Europe/Paris";
}
