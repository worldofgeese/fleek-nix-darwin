{
  pkgs,
  misc,
  ...
}: {
  # DO NOT EDIT: This file is managed by fleek. Manual changes will be overwritten.
  home.shellAliases = {
    "apply-M-02877" = "nix flake update --flake ~/.local/share/fleek/ && nix run nix-darwin -- switch --flake ~/.local/share/fleek && mas upgrade && brew upgrade";
    # bat --plain for unformatted cat
    catp = "bat -P";

    # replace cat with bat
    cat = "bat";
  };
}
