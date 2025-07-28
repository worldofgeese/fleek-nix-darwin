{
  pkgs,
  misc,
  ...
}: {
  programs.eza.extraOptions = [
    "--group-directories-first"
    "--header"
  ];

  programs.bat.config = {
    theme = "TwoDark";
  };
  # zsh
  programs.zsh.profileExtra = ''
    [ -r ~/.nix-profile/etc/profile.d/nix.sh ] && source  ~/.nix-profile/etc/profile.d/nix.sh
    export XCURSOR_PATH=$XCURSOR_PATH:/usr/share/icons:~/.local/share/icons:~/.icons:~/.nix-profile/share/icons
  '';
  programs.zsh.enable = true;
}
