{
  pkgs,
  misc,
  ...
}: {
  home.shellAliases = {
    "apply-M-02877" = "nix flake update --flake ~/.config/home-manager && nix run nix-darwin -- switch --flake ~/.config/home-manager && mas upgrade && brew upgrade";
    # bat --plain for unformatted cat
    catp = "bat -P";

    # replace cat with bat
    cat = "bat";
  };
}
