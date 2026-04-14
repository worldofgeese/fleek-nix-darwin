{
  config,
  pkgs,
  lib,
  ...
}: {
  home.packages = [
    pkgs.alejandra
    pkgs.nh
    pkgs.headsetcontrol
    pkgs.texlive.combined.scheme-small
    pkgs.odo
    pkgs.saml2aws
    pkgs.exercism
    pkgs.bun
    pkgs.kubernetes-helm
    pkgs.fluxcd
    pkgs.docker-compose
    pkgs.podman-compose
    pkgs.devpod
    pkgs.kubectl
    pkgs.helm-dashboard
    pkgs.vale
    pkgs.podman-desktop
    pkgs.zed-editor
    pkgs.htop
    pkgs.github-cli
    pkgs.secretspec
    pkgs.glab
    pkgs.ripgrep
    pkgs.jq
    pkgs.yq-go
    pkgs.cheat
    pkgs.just
    pkgs.nerd-fonts.fira-code
    pkgs.pnpm
    pkgs.nodejs
    pkgs.claude-code-bin
    pkgs.uv
    pkgs.decapod
    pkgs.rustup
  ];

  home.sessionVariables = {
    EDITOR = "zed";
  };

  fonts.fontconfig.enable = true;
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
