{
  description = "A simple example of an OCaml project";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    opam-nix = {
      url = "github:tweag/opam-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    opam-repository = {
      url = "github:ocaml/opam-repository";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, flake-utils, opam-nix, opam-repository }:
    # coupling: dune-project package we want to export
    let package = "hello-world";
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        on = opam-nix.lib.${system};
        opamRepos = [ "${opam-repository}" ];
        lib = pkgs.lib;
      in
      let
        devPackagesQuery = {
          # You can add "development" ocaml packages here. They will get added
          # to the devShell automatically.
          ocaml-lsp-server = "*";
          utop = "*";
          ocamlformat = "*";
          earlybird = "*";
          merlin = "*";
          odoc = "*";
        };
        query = devPackagesQuery // {
          # You can force versions of certain packages here
          ocaml-base-compiler = "4.14.0";
        };
        # Using the opam repository as an input means we will always use a
        # specific version of the repository. This is nice in case the repository
        # changes and breaks our build.
        scope = on.buildDuneProject { repos = opamRepos; } package ./. query;
        overlay = final: prev: {
          # You can add overrides here
          ${package} = prev.${package}.overrideAttrs (_: {
            # Prevent the ocaml dependencies from leaking into dependent environments
            doNixSupport = false;
            checkPhase = "make test";
            doCheck = true;
          });
        };
        scope' = scope.overrideScope' overlay;
        # The main package containing the executable
        main = scope'.${package};
        # Packages from devPackagesQuery
        devPackages = builtins.attrValues
          (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) scope');
      in
      {
        legacyPackages = scope';

        packages.default = main;

        formatter = pkgs.nixpkgs-fmt;

        checks.default = main;

        devShells.default = pkgs.mkShell {
          inputsFrom = [ main ];
          buildInputs = devPackages ++ [
            # You can add packages from nixpkgs here
          ];
        };
      });
}
