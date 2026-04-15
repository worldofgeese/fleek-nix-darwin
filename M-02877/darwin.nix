{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  nix.enable = false;
  nixpkgs.config.allowUnfree = true;

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
      eval "$(saml2aws --completion-script-zsh)"
      eval "$(eksctl completion zsh)"
    '';
  };

  # Enables TouchID for sudo operations (including inside tmux)
  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.reattach = true;
  security.sudo.extraConfig = ''
    Defaults env_keep += "HOMEBREW_GITHUB_API_TOKEN"
  '';
  system = {
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
  system.activationScripts.preActivation.text = ''
    if [ -z "''${HOMEBREW_GITHUB_API_TOKEN:-}" ]; then
      if token="$(sudo --user=${lib.escapeShellArg config.homebrew.user} --set-home sh -lc 'cd ${../.} && ${pkgs.secretspec}/bin/secretspec get HOMEBREW_GITHUB_API_TOKEN' 2>/dev/null)"; then
        export HOMEBREW_GITHUB_API_TOKEN="$token"
      elif token="$(sudo --user=${lib.escapeShellArg config.homebrew.user} --set-home ${pkgs.github-cli}/bin/gh auth token 2>/dev/null)"; then
        export HOMEBREW_GITHUB_API_TOKEN="$token"
      fi
    fi
  '';
  homebrew = {
    # install apps from the Mac App Store
    masApps = {
      "Microsoft To Do" = 1274495053;
      "Flow" = 1423210932;
    };
    enable = true;
    global.autoUpdate = true;
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    # remove all Homebrew packages and casks not managed by nix-darwin
    onActivation.cleanup = "zap";
    brews = [
      "podman"
      "aws-nuke"
      "azure-cli"
      "pulumi"
      "container"
      "jira-cli"
      "lego/tap/bob-cli"
      "lego/tap/mdc"
      # "swival/tap/swival" # FIXME: placeholder checksum in tap formula - re-enable once tap maintainers fix
    ];
    casks = [
      "jordanbaird-ice"
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
      "codex-app"
    ];

    taps = [
      "grishka/grishka"
      "mrkai77/cask"
      "nikitabobko/tap"
      "pulumi/tap"
      "ankitpokhrel/jira-cli"
      "swival/tap"
      {
        name = "lego/tap";
        clone_target = "git@github.com:LEGO/homebrew-tap.git";
      }
    ];
  };
}
