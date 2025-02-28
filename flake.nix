{
  inputs = {
    # Nixpkgs
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.0.tar.gz";

    # Home manager
    home-manager.url = "https://github.com/nix-community/home-manager/archive/master.tar.gz";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Fleek
    fleek.url = "https://flakehub.com/f/ublue-os/fleek/*.tar.gz";

    # Overlays
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs"; # ...
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    fleek,
    darwin,
    ...
  } @ inputs: {
    packages.aarch64-darwin.fleek = fleek.packages.aarch64-darwin.default;
    packages.x86_64-linux.fleek = fleek.packages.x86_64-linux.default;

    # Available through 'home-manager --flake .#your-username@your-hostname'

    darwinConfigurations."M-02877" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./M-02877/darwin.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
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
          # self-manage fleek
          {
            home.packages = [
              fleek.packages.aarch64-darwin.default
            ];
          }
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
          # self-manage fleek
          {
            home.username = "user";
            home.homeDirectory = "/home/user/";
            home.packages = [
              fleek.packages.x86_64-linux.default
            ];
          }
          {
            nixpkgs.overlays = [];
          }
        ];
      };
      
    };
  };
}
