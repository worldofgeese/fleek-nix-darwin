{
  pkgs,
  ...
}: {
  home.shellAliases = {
    "apply-M-02877" = "nix flake update --flake ~/.local/share/fleek && sudo -H darwin-rebuild switch --flake ~/.local/share/fleek";
    # bat --plain for unformatted cat
    catp = "bat -P";

    # replace cat with bat
    cat = "bat";
  };
}
