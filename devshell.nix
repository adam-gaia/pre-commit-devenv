{
  inputs,
  pkgs,
  ...
}: let
  inherit (pkgs) lib;
  # Treefmt doesn't easily expose the programs with out its flake-parts module (as far as I can tell)
  # This snipit, modified from their default.nix, lets us grab the programs after building with our treefmt config
  treefmt-module-builder = nixpkgs: configuration: let
    mod = inputs.treefmt-nix.lib.evalModule nixpkgs configuration;
  in
    mod.config.build;
  treefmt-module = treefmt-module-builder pkgs (import ./treefmt.nix);
  treefmt-bin = treefmt-module.wrapper;
  treefmt-programs = lib.attrValues treefmt-module.programs;
in
  inputs.devenv.lib.mkShell {
    inherit inputs pkgs;
    modules = [
      {
        packages = with pkgs;
          [
            just
            mdbook
            rustc # For rustdoc, required by mdbook
            unionfs-fuse
          ]
          # Include treefmt and formatters
          ++ treefmt-programs
          ++ [treefmt-bin];

        enterShell = ''
          export PRJ_ROOT="$(git rev-parse --show-toplevel)"
        '';

        pre-commit.hooks = {
          treefmt = {
            enable = true;
            package = treefmt-bin;
          };
        };
      }
    ];
  }
