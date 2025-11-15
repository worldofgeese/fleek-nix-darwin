{
  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Overlays
    darwin.url = "github:nix-darwin/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    darwin,
    ...
  } @ inputs: {
    # Available through 'home-manager --flake .#your-username@your-hostname'

    darwinConfigurations."M-02877" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./M-02877/darwin.nix
        home-manager.darwinModules.home-manager
        ({pkgs, ...}: {
          nixpkgs.overlays = [
            (final: prev: {
              inherit
                (prev.lixPackageSets.latest)
                nixpkgs-review
                nix-eval-jobs
                nix-fast-build
                colmena
                ;
            })
          ];
          nix.package = pkgs.lixPackageSets.latest.lix;
        })
        {
          home-manager.users.dktaohan.imports = [
            ./home.nix
            ./path.nix
            ./shell.nix
            ./user.nix
            ./aliases.nix
            ./programs.nix
            ./M-02877/dktaohan.nix
            ./M-02877/custom.nix
          ];
        }
      ];
    };

    homeConfigurations = {
      "dktaohan@M-02877" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = {inherit inputs;}; # Pass flake inputs to our config
        modules = [
          ./home.nix
          ./path.nix
          ./shell.nix
          ./user.nix
          ./aliases.nix
          ./programs.nix
          # Host Specific configs
          ./M-02877/dktaohan.nix
          ./M-02877/custom.nix
        ];
      };

      # Adding configuration that matches the default home-manager expectation
      "user" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs;};
        modules = [
          ./home.nix
          ./path.nix
          ./shell.nix
          ./user.nix
          ./aliases.nix
          ./programs.nix
          {
            home.username = "user";
            home.homeDirectory = "/home/user/";
          }
        ];
      };
    };
  };
}
