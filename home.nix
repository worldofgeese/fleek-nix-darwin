{
  config,
  pkgs,
  misc,
  ...
}: {
  nixpkgs = {
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  # packages are just installed (no configuration applied)
  # programs are installed and configuration applied to dotfiles
  home.packages = [
    # user selected packages
    #pkgs.jetbrains.writerside
    pkgs.mono
    pkgs.gimp
    pkgs.alejandra
    pkgs.headsetcontrol
    pkgs.texlive.combined.scheme-small
    pkgs.odo
    # pkgs.aws-sam-cli
    pkgs.saml2aws
    pkgs.exercism
    # pkgs.bun
    # pkgs.eksctl
    pkgs.kubernetes-helm
    pkgs.fluxcd
    pkgs.topgrade
    pkgs.docker-compose
    pkgs.podman-compose
    pkgs.devcontainer
    pkgs.devpod
    pkgs.kubectl
    pkgs.helm-dashboard
    pkgs.vale ## prose linter
    pkgs.podman-desktop
    pkgs.zed-editor
    pkgs.warp-terminal
    pkgs.git
    pkgs.htop
    pkgs.github-cli
    pkgs.glab
    pkgs.fzf
    pkgs.ripgrep
    pkgs.lazygit
    pkgs.jq
    pkgs.yq-go
    pkgs.neovim
    pkgs.neofetch
    pkgs.btop
    pkgs.cheat
    pkgs.just
    pkgs.nerd-fonts.fira-code
    pkgs.zotero
    pkgs.glab
  ];
  fonts.fontconfig.enable = true;
  home.stateVersion = "22.11"; # To figure this out (in-case it changes) you can comment out the line and see what version it expected.
  programs.home-manager.enable = true;
}
