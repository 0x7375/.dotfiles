{
  outputs =
    { self, ... }@args:
    let
      import-tree =
        path:
        let
          inherit (inputs.nixpkgs.lib) fileset hasInfix;
          nixFiles = fileset.toList (fileset.fileFilter (f: f.hasExt "nix") path);
        in
        builtins.filter (p: !(hasInfix "/_" (toString p))) nixFiles;

      inputs = (import ./.tack) {
        overrides = args.tackOverrides or { };
      };
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs self; } {
      imports = [
        inputs.flake-parts.flakeModules.modules
      ]
      ++ (import-tree ./modules);

      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    };
}
