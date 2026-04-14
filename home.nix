{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = [
    # Nix tools
    pkgs.alejandra
    pkgs.nh

    # Hardware
    pkgs.headsetcontrol

    # Documents
    pkgs.texlive.combined.scheme-small
    pkgs.vale

    # Languages & runtimes
    pkgs.nodejs
    pkgs.pnpm
    pkgs.bun
    pkgs.uv
    pkgs.rustup

    # Cloud & infra
    pkgs.saml2aws
    pkgs.kubectl
    pkgs.kubernetes-helm
    pkgs.helm-dashboard
    pkgs.fluxcd
    pkgs.docker-compose
    pkgs.podman-compose
    pkgs.podman-desktop
    pkgs.devpod
    pkgs.odo

    # Dev tools
    pkgs.secretspec
    pkgs.glab
    pkgs.ripgrep
    pkgs.jq
    pkgs.yq-go
    pkgs.cheat
    pkgs.just
    pkgs.zed-editor
    pkgs.exercism
    pkgs.decapod
    pkgs.claude-code-bin

    # Modern CLI replacements
    pkgs.fd
    pkgs.dust
    pkgs.duf
    pkgs.procs
    pkgs.sd
    pkgs.tokei
    pkgs.bandwhich
    pkgs.grex
    pkgs.hyperfine

    # Linting
    pkgs.shellcheck

    # Fonts
    pkgs.nerd-fonts.fira-code
  ];

  home.sessionVariables = {
    EDITOR = "zed";
  };

  xdg.enable = true;
  fonts.fontconfig.enable = true;
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
