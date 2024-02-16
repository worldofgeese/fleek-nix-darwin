{ pkgs, misc, ... }: {
  # DO NOT EDIT: This file is managed by fleek. Manual changes will be overwritten.
   home.shellAliases = {
    "apply-M-02877" = "nix run --impure home-manager/master -- -b bak switch --flake .#dktaohan@M-02877";
    
    "fleeks" = "cd ~/fleekgen";
    
    "latest-fleek-version" = "nix run https://getfleek.dev/latest.tar.gz -- version";
    
    "update-fleek" = "nix run https://getfleek.dev/latest.tar.gz -- update";
    
    # bat --plain for unformatted cat
    catp = "bat -P";
    
    # replace cat with bat
    cat = "bat";
    };
}
