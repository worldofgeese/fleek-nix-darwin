{
  pkgs,
  ...
}: {
  programs.zsh.profileExtra = ''
    [ -r ~/.nix-profile/etc/profile.d/nix.sh ] && source  ~/.nix-profile/etc/profile.d/nix.sh
    export XCURSOR_PATH=$XCURSOR_PATH:/usr/share/icons:~/.local/share/icons:~/.icons:~/.nix-profile/share/icons
  '';
  programs.zsh.initContent = ''
    if [ -z "''${HOMEBREW_GITHUB_API_TOKEN:-}" ]; then
      token=""

      if command -v secretspec &>/dev/null; then
        token="$(cd ${./.} && secretspec get HOMEBREW_GITHUB_API_TOKEN 2>/dev/null || true)"
      fi

      if [ -z "$token" ] && command -v gh &>/dev/null && gh auth status &>/dev/null 2>&1; then
        token="$(gh auth token)"
      fi

      if [ -n "$token" ]; then
        export HOMEBREW_GITHUB_API_TOKEN="$token"
      fi
    fi
  '';
  programs.zsh.enable = true;
}
