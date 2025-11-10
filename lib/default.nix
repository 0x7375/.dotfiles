{ lib }:

{
  filesIn =
    let
      inherit (lib)
        fileset
        hasInfix
        hasSuffix
        filter
        ;
      ignoreFilter = path: !hasInfix "/_" (toString path);
      nixFilter = file: hasSuffix ".nix" file.name;
    in
    dir: filter ignoreFilter (fileset.toList (fileset.fileFilter nixFilter dir));

  syncthingDirConfig =
    {
      path,
      devices,
      type ? "sendreceive",
      extraConfig ? { },
    }:
    {
      path = "~/" + path;
      inherit type;
      inherit devices;
      versioning =
        if type != "sendonly" then
          {
            type = "simple";
            params = {
              keep = "5";
              cleanoutDays = "14";
            };
          }
        else
          null;
    }
    // extraConfig;

  notifyOnServiceFailure = service: {
    ${service} = {
      unitConfig.OnFailure = "service-failure-notify@%N.service";
    };
  };
}
