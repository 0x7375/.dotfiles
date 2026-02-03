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

  mkLaunchdAgent =
    {
      name,
      command,
      background ? true,
      extraConfig ? { },
    }:
    {
      inherit command;
      serviceConfig = {
        Label = name;
        KeepAlive = background;
        RunAtLoad = true;
        ProcessType = if background then "Background" else null;
        StandardOutPath = "/tmp/${name}.out";
        StandardErrorPath = "/tmp/${name}.out";
      }
      // extraConfig;
    };

  notifyOnServiceFailure = service: {
    ${service} = {
      unitConfig.OnFailure = "service-failure-notify@%N.service";
    };
  };
}
