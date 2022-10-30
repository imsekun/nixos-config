{
  description = "Sekun's system(s) lmao lol pee";

  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    emojiedpkg.url = "github:sekunho/emojied";
    oshismashpkg.url = "github:sekunho/oshismash";
    sekunpkg.url = "github:sekunho/sekun.dev";
    deploy-rs.url = "github:serokell/deploy-rs";
    agenix.url = "github:ryantm/agenix";
  };

  outputs = {
    self,
    nixpkgs-stable,
    nixpkgs-unstable,
    emojiedpkg,
    oshismashpkg,
    sekunpkg,
    deploy-rs,
    agenix
  }:
    let
      system = "x86_64-linux";

      # https://github.com/hlissner/dotfiles/blob/master/flake.nix
      mkPkgs = pkgs: extraOverlays: import pkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = extraOverlays;
      };

      pkgs = mkPkgs nixpkgs-stable [];
      pkgs' = mkPkgs nixpkgs-unstable [];
      emojied = emojiedpkg.packages.${system}.emojied;
      oshismash = oshismashpkg.packages.${system}.oshismash;
      blog = sekunpkg.packages.${system}.blog;
      agenixPackage = agenix.defaultPackage.${system};
    in {
      nixosConfigurations = {
        # TODO: Add usual config for Linode/DO/Hetzner/etc.

        # Personal computer
        # `nixos-rebuild switch --flake .#ichi` or
        # `nixos-rebuild switch --flake .#`
        ichi = nixpkgs-stable.lib.nixosSystem {
          inherit system;

          modules = [
            ./hosts/ichi/configuration.nix
            agenix.nixosModules.age
          ];

          specialArgs = {
            inherit pkgs;
            inherit pkgs';
            inherit agenixPackage;
          };
        };

        mew = nixpkgs-stable.lib.nixosSystem {
          inherit system;

          modules = [
            emojiedpkg.nixosModule
            oshismashpkg.nixosModule
            ./hosts/mew/configuration.nix
            agenix.nixosModules.age
          ];

          specialArgs = {
            inherit pkgs;
            inherit pkgs';
            inherit emojied;
            inherit oshismash;
            inherit blog;
            inherit agenixPackage;
          };
        };
      };
    };
}
