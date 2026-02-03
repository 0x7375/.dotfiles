{ config, ... }:

{
  sops.templates."profile.mobileconfig" = {
    owner = config.me.user;
    content = import ./_profile.mobileconfig.nix { inherit (config.sops.placeholder) nextdns_id; };
  };

  activation = ''
    flag_file=/var/db/profile_activated
    [[ ! -e $flag_file ]] && sudo -u ${config.me.user} open ${
      config.sops.templates."profile.mobileconfig".path
    } && touch $flag_file
  '';
}
