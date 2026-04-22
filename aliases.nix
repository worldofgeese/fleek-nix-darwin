{
  pkgs,
  ...
}: {
  home.shellAliases = {
    "apply-M-02877" = "nix flake update --flake ~/.local/share/fleek && sudo -H darwin-rebuild switch --flake ~/.local/share/fleek";

    # Generic apply — picks `darwinConfigurations.<your-hostname>` automatically.
    # Prefer this over `apply-M-02877` in new hosts.
    fleek-apply = "nix flake update --flake ~/.local/share/fleek && sudo -H darwin-rebuild switch --flake ~/.local/share/fleek";

    # bat --plain for unformatted cat
    catp = "bat -P";

    # replace cat with bat
    cat = "bat";

    # modern CLI replacements
    du = "dust";
    df = "duf";
    ps = "procs";
    find = "fd";
  };
}
