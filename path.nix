{
  pkgs,
  ...
}: {
  home.sessionPath = [
    "$HOME/bin"
    "$HOME/.local/bin"
    "/opt/homebrew/bin"
    "$HOME/.dotnet/tools"
  ];
}
