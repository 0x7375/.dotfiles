{
  secrets,
  myLib,
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware.nix
    ../../nixos
    ./options.nix
  ];

  networking.hostName = config.me.hostname;

  boot.supportedFilesystems = [ "ntfs" ];

  services.xserver.displayManager.setupCommands = ''
    ${pkgs.xorg.xset}/bin/xset s off -dpms
  '';

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  services.hardware.openrgb.enable = true;

  services.xserver.videoDrivers = [ "nvidia" ];

  age.secrets.syncthing-yugen-cert = {
    file = "${secrets}/syncthing-yugen-cert.age";
    owner = config.me.user;
  };

  age.secrets.syncthing-yugen-key = {
    file = "${secrets}/syncthing-yugen-key.age";
    owner = config.me.user;
  };

  services.syncthing = {
    key = "${config.age.secrets.syncthing-yugen-key.path}";
    cert = "${config.age.secrets.syncthing-yugen-cert.path}";
  };

  services.autorandr.profiles =
    let
      f-acer = "00ffffffffffff0004728404263610731f1b0103803c22782a14d5a55852a2260c5054b30c00d1c081c081009500b30081808140714f866f80a0703840403020350056502100001a023a801871382d40582c450056502100001e000000fd0030781eb41e000a202020202020000000fc0041636572205846323730480a200104020329f14b0102030411121305141f10230907078301000067030c001000b83c681a000001013078008c0ad08a20e02d10103e9600565021000018011d007251d01e206e28550056502100001e8c0ad090204031200c4055005650210000180000000000000000000000000000000000000000000000000000000000000000d4";
      f-benq = "00ffffffffffff0009d1827f010101011d20010380361e782e9055a75553a028135054a56b80d1c081c081008180a9c0b30081bc0101023a801871382d40582c4500202f2100001e000000ff00454242374e3030393538534c30000000fd0018f01eff3c000a202020202020000000fc005a4f57494520584c204c43440a01a302033cf14e9005040302011112133f061f2040e200cf230907078301000067030c001000004467d85dc40178c0006d1a0000020130f0e600000000009cc700085200a04074903700202f2100001c5a8780a070384d4030203500202f2100001a0cdf80a07038404030403500202f2100001a000000000000000000000000007a";
    in
    {
      home = {
        fingerprint = {
          HDMI-0 = f-acer;
          HDMI-1 = f-benq;
        };
        config = {
          HDMI-0 = {
            enable = true;
            position = "0x0";
            mode = "1920x1080";
            rate = "120";
          };
          HDMI-1 = {
            enable = true;
            primary = true;
            position = "1920x0";
            mode = "1920x1080";
            rate = "240";
          };
        };
      };
      "home: right monitor" = {
        fingerprint = {
          HDMI-1 = f-benq;
        };
        config = {
          HDMI-1 = {
            primary = true;
            enable = true;
            mode = "1920x1080";
            rate = "240";
          };
        };
      };
      "home: left monitor" = {
        fingerprint = {
          HDMI-0 = f-acer;
        };
        config = {
          HDMI-0 = {
            primary = true;
            enable = true;
            mode = "1920x1080";
            rate = "120";
          };
        };
      };
    };

  # do not change   
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
