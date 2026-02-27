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
  } @ inputs: let
    decapodOverlay = final: prev: {
      decapod = final.rustPlatform.buildRustPackage {
        pname = "decapod";
        version = "0.42.1";

        src = final.fetchCrate {
          pname = "decapod";
          version = "0.42.1";
          hash = "sha256-v78OI6wniJP7XNsh2xCTRk0e3efocTjBwrr3WxzLpew=";
        };

        cargoHash = "sha256-YkjnlzkGJQfQkIWR5fR6qJ0YYlTwEWkUtpl7uqZ3KGw=";

        doCheck = false;

        nativeBuildInputs = [
          final.pkg-config
        ];

        nativeCheckInputs = [
          final.git
        ];

        buildInputs = [
          final.sqlite
        ];

        meta = {
          description = "Decapod CLI";
          homepage = "https://crates.io/crates/decapod";
          mainProgram = "decapod";
        };
      };
    };
  in {
    # Available through 'home-manager --flake .#your-username@your-hostname'

    darwinConfigurations."M-02877" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./M-02877/darwin.nix
        home-manager.darwinModules.home-manager
        ({pkgs, ...}: {
          nixpkgs.config = {
            allowUnfree = true;
            allowUnfreePredicate = _: true;
          };
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
            decapodOverlay
          ];
          nix.package = pkgs.lixPackageSets.latest.lix;
        })
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
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
          config = {
            allowUnfree = true;
            allowUnfreePredicate = _: true;
          };
          overlays = [decapodOverlay];
        }; # Home-manager requires 'pkgs' instance
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
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config = {
            allowUnfree = true;
            allowUnfreePredicate = _: true;
          };
          overlays = [decapodOverlay];
        };
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

    packages.aarch64-darwin = let
      pkgs = import nixpkgs {
        system = "aarch64-darwin";
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
        };
        overlays = [decapodOverlay];
      };
    in {
      decapod = pkgs.decapod;
      default = pkgs.decapod;
    };

    packages.x86_64-linux = let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
        };
        overlays = [decapodOverlay];
      };
    in {
      decapod = pkgs.decapod;
      default = pkgs.decapod;
    };
  };
}
