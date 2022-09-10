{
  description = "A collection of templates";

  nixConfig = {
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = {
    self,
    devshell,
    flake-utils,
    nixpkgs,
    ...
  } @ inputs:
    with (flake-utils.lib);
      eachDefaultSystem
      (system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            devshell.overlay
          ];
        };

        linters = with pkgs; [
          alejandra # https://github.com/kamadorueda/alejandra
          gofumpt # https://github.com/mvdan/gofumpt
          nodePackages.prettier # https://prettier.io/
          treefmt # https://github.com/numtide/treefmt
        ];

        # devshell command categories
        pkgWithCategory = category: package: {inherit package category;};
        formatter = pkgWithCategory "formatters";
        util = pkgWithCategory "utils";
      in {
        # nix develop
        devShells.default = pkgs.devshell.mkShell {
          packages = with pkgs;
            [
              just # https://github.com/casey/just
            ]
            ++ linters;

          commands = with pkgs; [
            (formatter alejandra)
            (formatter gofumpt)
            (formatter nodePackages.prettier)

            (util jq)
            (util just)
          ];
        };

        # nix flake check
        checks = {
          format =
            pkgs.runCommandNoCC "treefmt" {
              nativeBuildInputs = linters;
            } ''
              # keep timestamps so that treefmt is able to detect mtime changes
              cp --no-preserve=mode --preserve=timestamps -r ${self} source
              cd source
              HOME=$TMPDIR treefmt --fail-on-change
              touch $out
            '';
        };
      }) //
      {
        # nix flake new --template github:41north/templates#<template> ./new-dir
        templates = {

          # nix flake new --template github:41north/templates#go ./new-project
          go = {
            path = ./go;
            description = "This template is prepared for creating a new go-lib / go-app kind of project.";
          };
        };
      };
}
