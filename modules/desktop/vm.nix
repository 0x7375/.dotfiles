{
  flake.modules.nixos.desktop =
    {
      config,
      lib,
      ...
    }:
    {
      persist.directories = [ "/var/lib/libvirt" ];

      virtualisation.libvirtd = {
        enable = true;
        shutdownTimeout = 1;
        qemu.swtpm.enable = true;
      };
      programs.virt-manager.enable = true;
      virtualisation.spiceUSBRedirection.enable = true;

      virtualisation.vmVariant = {
        me.boot = {
          encryption.enable = lib.mkForce false;
          debug.enable = lib.mkForce true;
        };

        virtualisation = {
          memorySize = 8192;
          cores = 8;
        };
      };

      users.users.${config.me.user}.extraGroups = [ "libvirtd" ];

      programs.dconf.profiles = {
        user.databases = [
          {
            settings = {
              "org/virt-manager/virt-manager/connections" = {
                autoconnect = [ "qemu:///system" ];
                uris = [ "qemu:///system" ];
              };
            };
          }
        ];
      };
    };
}
