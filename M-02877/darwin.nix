{pkgs, ...}: {
  nix.enable = false;
  nixpkgs.hostPlatform = {
    config = "aarch64-apple-darwin";
    system = "aarch64-darwin";
  };
  nixpkgs.config.allowUnfree = true;
  users.users."dktaohan".home = "/Users/dktaohan"; # Set to $USER. This is required to avoid an error when using nix-darwin with Home Manager
  # https://github.com/nix-community/home-manager/issues/4026
  # if you use zsh (the default on new macOS installations),
  # you'll need to enable this so nix-darwin creates a zshrc sourcing needed environment changes
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    interactiveShellInit = ''
      autoload -Uz compinit && compinit
      eval "$(gh copilot alias -- zsh)"
      eval "$(saml2aws --completion-script-zsh)"
      eval "$(eksctl completion zsh)"
    '';
  };

  # Enables TouchID for sudo operations
  security.pam.services.sudo_local.touchIdAuth = true;
  system = {
    primaryUser = "dktaohan";
    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 5;
    defaults = {
      CustomUserPreferences = {
        # Avoid creating .DS_Store files on network or USB volumes
        "com.apple.desktopservices" = {
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
      };
      # Where to save screenshots
      screencapture.location = "~/Downloads";
      # Show hidden files in Finder
      finder = {
        AppleShowAllFiles = true;
      };
    };
  };
  # Settings that don't have an option in nix-darwin
  #  system.activationScripts.postActivation.text = ''
  #    echo "Allow apps from anywhere"
  #    SPCTL=$(spctl --status)
  #    if ! [ "$SPCTL" = "assessments disabled" ]; then
  #        sudo spctl --master-disable
  #    fi
  #  '';
  #  # User-level settings
  #  system.activationScripts.postUserActivation.text = ''
  #    echo "Show the ~/Library folder"
  #    chflags nohidden ~/Library
  #
  #    echo "Reduce Menu Bar padding"
  #    defaults write -globalDomain NSStatusItemSelectionPadding -int 6
  #    defaults write -globalDomain NSStatusItemSpacing -int 12
  #
  #    echo "Disable the Power Chime sound when plugging in a MacBook"
  #    defaults write com.apple.PowerChime ChimeOnNoHardware -bool true ;killall PowerChime
  #  '';
  homebrew = {
    # install apps from the Mac App Store
    masApps = {
      "Microsoft Outlook" = 985367838;
      "Microsoft To Do" = 1274495053;
      "Flow" = 1423210932;
    };
    enable = true;
    global.autoUpdate = true;
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    # remove all Homebrew packages and casks not managed by nix-darwin
    onActivation.cleanup = "zap";
    # updates homebrew packages on activation,
    # can make darwin-rebuild much slower (otherwise i'd forget to do it ever though)
    brews = [
      "podman"
      "aws-nuke"
      "azure-cli"
    ];
    casks = [
      "jordanbaird-ice"
      "battery"
      "alt-tab"
      "loop"
      "neardrop"
      "raycast"
      "logseq"
      "notunes"
      "fork"
      "keycastr"
      "devpod"
      "dotnet-sdk"
      "adobe-acrobat-reader"
      "jetbrains-toolbox"
      "background-music"
      "secretive"
      "aerospace"
      "cursor"
      "chatgpt"
      "visual-studio-code"
      "visual-studio-code@insiders"
      "monokle"
    ];

    taps = [
      "grishka/grishka"
      "mrkai77/cask"
      "nikitabobko/tap"
    ];
  };
}
