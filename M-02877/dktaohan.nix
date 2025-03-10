{
  pkgs,
  misc,
  ...
}: {
  home.username = "dktaohan";
  home.homeDirectory = "/Users/dktaohan";
  programs.git = {
    enable = true;
    aliases = {
      pushall = "!git remote | xargs -L1 git push --all";
      graph = "log --decorate --oneline --graph";
      add-nowhitespace = "!git diff -U0 -w --no-color | git apply --cached --ignore-whitespace --unidiff-zero -";
    };
    userName = "Tao Hansen";
    userEmail = "tao.hansen@lego.com";
    extraConfig = {
      feature.manyFiles = true;
      init.defaultBranch = "main";
      gpg.format = "ssh";
    };

    signing = {
      signByDefault = true;
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAbIQYGvgicAePeJgXJY2wTFMjna8zHSIfqppFB0edOV";
    };

    lfs.enable = true;
    ignores = [".direnv" "result"];
  };
}
