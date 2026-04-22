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

    sharedOverlays = [
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

    # Helper to create a darwin system configuration.
    # Team members: add your entry to darwinConfigurations below.
    mkDarwin = {
      hostname,
      username,
      system ? "aarch64-darwin",
    }:
      darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {inherit username;};
        modules = [
          ./${hostname}/darwin.nix
          home-manager.darwinModules.home-manager
          ({pkgs, ...}: {
            nixpkgs.config = {
              allowUnfree = true;
              allowUnfreePredicate = _: true;
            };
            nixpkgs.overlays = sharedOverlays;
            # Lix from nixpkgs (recommended path per https://lix.systems/add-to-config/).
            # `.latest` tracks the most recent Lix release in the pinned nixpkgs;
            # `nix flake update nixpkgs` moves to a newer Lix when nixpkgs ships one.
            nix.package = pkgs.lixPackageSets.latest.lix;
            # We manage everything via flakes — disable the legacy channels machinery
            # so NIX_PATH stops pointing at nonexistent /nix/var/nix/profiles/.../channels.
            nix.channel.enable = false;
            nix.settings = {
              experimental-features = ["nix-command" "flakes" "auto-allocate-uids"];
              # ARM-only fleet: drop Rosetta auto-detect's x86_64-darwin.
              extra-platforms = [];
              warn-dirty = false;
              auto-optimise-store = true;
              # Temporary: nixpkgs-unstable's lib uses `or` as an identifier, which
              # Lix 2.95 flags as deprecated. Remove once nixpkgs upstream renames it.
              extra-deprecated-features = ["or-as-identifier"];
            };
            users.users.${username}.home = "/Users/${username}";
            system.primaryUser = username;
          })
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "hm-backup";
            home-manager.users.${username}.imports = [
              ./home.nix
              ./path.nix
              ./shell.nix
              ./user.nix
              ./aliases.nix
              ./programs.nix
              ./${hostname}/${username}.nix
              ./${hostname}/custom.nix
            ];
          }
        ];
      };
  in {
    # --- macOS (nix-darwin) configurations ---
    # Add your machine here: mkDarwin { hostname = "YOUR-HOSTNAME"; username = "your-user"; };
    darwinConfigurations."M-02877" = mkDarwin {hostname = "M-02877"; username = "dktaohan";};

    # --- Linux / WSL (home-manager standalone) configurations ---
    homeConfigurations = {
      "dktaohan@M-02877" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "aarch64-darwin";
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
          ./M-02877/dktaohan.nix
          ./M-02877/custom.nix
        ];
      };

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
