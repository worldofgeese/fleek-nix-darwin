{
  pkgs,
  ...
}: {
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
      syntax-theme = "Dracula";
      dark = true;
    };
  };
  programs.git.enable = true;
  programs.git.ignores = [".direnv" "result"];
  programs.git.settings = {
    user.name = "Tao Hansen";
    user.email = "tao.hansen@lego.com";
    feature.manyFiles = true;
    init.defaultBranch = "main";
    gpg.format = "ssh";
    aliases = {
      pushall = "!git remote | xargs -L1 git push --all";
      graph = "log --decorate --oneline --graph";
      add-nowhitespace = "!git diff -U0 -w --no-color | git apply --cached --ignore-whitespace --unidiff-zero -";
    };

    signing = {
      signByDefault = true;
      key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAbIQYGvgicAePeJgXJY2wTFMjna8zHSIfqppFB0edOV";
    };

    lfs.enable = true;
  };
}
