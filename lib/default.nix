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

  notifyOnServiceFailure = service: {
    ${service} = {
      unitConfig.OnFailure = "service-failure-notify@%N.service";
    };
  };
}
