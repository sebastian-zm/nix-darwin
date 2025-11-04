{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = { url = "github:nix-darwin/nix-darwin/master"; inputs.nixpkgs.follows = "nixpkgs"; };

    mini-nvim = { url = "github:echasnovski/mini.nvim"; flake = false; };
    guess-indent-nvim = { url = "github:NMAC427/guess-indent.nvim"; flake = false; };
    netrw-nvim = { url = "github:prichrd/netrw.nvim"; flake = false; };
  };

  outputs = inputs@{ nix-darwin, ... }:
  let
    configuration = import ./configuration.nix;
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Sebastians-MacBook-Pro
    darwinConfigurations."Sebastians-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
      specialArgs = {
        nvim-plugins = { inherit (inputs) auto-dark-mode-nvim mini-nvim netrw-nvim guess-indent-nvim; };
	inherit (inputs) self;
      };
    };
  };
}
