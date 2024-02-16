{pkgs, ...}: {
  # if you use zsh (the default on new macOS installations),
  # you'll need to enable this so nix-darwin creates a zshrc sourcing needed environment changes
  programs.zsh.enable = true;
  users.users."dktaohan".home = "/Users/dktaohan"; # Set to $USER. This is required to avoid an error when using nix-darwin with Home Manager
  # https://github.com/nix-community/home-manager/issues/4026
  # allow packages with non-free licenses, like VS Code, to be installed
  nixpkgs.config.allowUnfree = true;
  nix = {
    useDaemon = true;
    package = pkgs.nixFlakes;
  };
  # installs a version of nix, that dosen't need "experimental-features = nix-command flakes" in /etc/nix/nix.conf
  security.pam.enableSudoTouchIdAuth = true;
  system.defaults.finder.AppleShowAllFiles = true;
  # Enables TouchID for sudo operations
  homebrew = {
    # install apps from the Mac App Store
    masApps = {
      "Microsoft Outlook" = 985367838;
      "Bitwarden" = 1352778147;
    };
    enable = true;
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    # remove all Homebrew packages and casks not managed by nix-darwin
    onActivation.cleanup = "zap";
    # updates homebrew packages on activation,
    # can make darwin-rebuild much slower (otherwise i'd forget to do it ever though)
    brews = [
      "bitwarden-cli"
    ];
    casks = [
      "bartender"
      "battery"
      "alt-tab"
      "amethyst"
      "raycast"
      "warp"
      "logseq"
      "notunes"
      "fork"
    ];
  };
}
