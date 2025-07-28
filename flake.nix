{
  inputs = {
    # Nixpkgs
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.0.tar.gz";

    # Home manager
    home-manager.url = "https://github.com/nix-community/home-manager/archive/master.tar.gz";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.2-1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Overlays
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    darwin,
    lix-module,
    ...
  } @ inputs: {
    # Available through 'home-manager --flake .#your-username@your-hostname'

    darwinConfigurations."M-02877" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./M-02877/darwin.nix
        home-manager.darwinModules.home-manager
        lix-module.nixosModules.default
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
          {
            nixpkgs.overlays = [];
          }
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
          {
            nixpkgs.overlays = [];
          }
        ];
      };
    };
  };
}
