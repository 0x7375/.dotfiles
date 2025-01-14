{
  me = {
    secrets.enable = true;
    hostname = "ryusei";
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH9wtfhfEPZ6GVA4FWRUk5KXtTttn6Q4qjxO1apMc7RK ryusei";
    syncthing-client.enable = true;
    gui = {
      enable = true;
      bundles.virtualBox.enable = true;
      bundles.gaming.enable = true;
    };
    devPkgs.enable = true;
    minecraft.enable = false;
  };
}
