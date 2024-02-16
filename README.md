# Fleek Configuration

Nix Home Manager configs created by [fleek](https://github.com/ublue-os/fleek) with a generous heaping of nix-darwin added by @worldofgeese.

## What is all this?

Fleek is a "[porcelain](https://stackoverflow.com/a/20448189)" over the tool, Home Manager. TL;DR: Fleek is a tool for generating a declarative specification of the tools, settings, and files you want on your system. Home Manager, in turn, depends on Nix to do its work. Nix is a tool for creating reproducible and pure outputs. The benefits of Nix *for you* is to define your system *portably*, meaning you can take it with you to whichever system you go.

`nix-darwin` extends Nix for macOS specific configuration: you can manage your Homebrew packages, Mac App Store applications, even down to enabling your fingerprint to authenticate administrative terminal actions.

## Getting started

First, make sure Nix and Fleek are installed on your system. Documentation is [available at the Fleek website](https://getfleek.dev/docs/installation). Stop after initializing your first Fleek configuration with `nix run "https://getfleek.dev/latest.tar.gz" -- init`.

You'll now generate a `high` bling Fleek configuration then "eject" from Fleek to set up nix-darwin. This is required to [work around a Fleek limitation](https://github.com/ublue-os/fleek/issues/254).

Run `fleek generate --level high`, then move into the directory created by Fleek at `~/.config/fleek`. Create the file, `darwin.nix` in the generated path at `~/.config/fleek` under your machine name folder Fleek created. My machine name folder is M-02877 but it won't be yours. You can copy many of my settings, packages, and applications in my own `darwin.nix` file as you like. The important thing is you minimally include the following:

```nix
{pkgs, ...}: {
  # if you use zsh (the default on new macOS installations),
  # you'll need to enable this so nix-darwin creates a zshrc sourcing needed environment changes
  programs.zsh.enable = true;
}
```

Now we will configure `nix-darwin` to support Fleek/Home Manager. Open `~/.config/fleek/flake.nix`. Above the `homeConfigurations` block, insert the following:

```nix
    darwinConfigurations."your-hostname" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./your-hostname/darwin.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.your-username.imports = [
            ./home.nix
            ./path.nix
            ./shell.nix
            ./user.nix
            ./aliases.nix
            ./programs.nix
            ./your-hostname/dktaohan.nix
            ./your-hostname/custom.nix
          ];
        }
      ];
    };
```

Replace any instances of `your-username` and `your-hostname`. This step both enables `nix-darwin` and allows it to manage our generated Fleek/Home Manager configuration.

For a taste of what's possible with `nix-darwin` have a look at this repository's `darwin.nix` inside the `M-02877` directory.

> [!WARNING]
> Homebrew users: ensure "/opt/homebrew/bin" is added to `~/.config/fleek/path.nix`
> Look to my `darwin.nix` file for reference on installing brew packages. Be warned that my configuration assumes all Homebrew packages are managed by `nix-darwin`. Any unmanaged packages will be uninstalled unless you change `onActivation.cleanup = "zap";` to `onActivation.cleanup = "none"`.

You are at last ready to turn the power on: run `nix run nix-darwin -- switch --flake ~/.config/fleek`.

## Reference

- [home-manager](https://nix-community.github.io/home-manager/)
- [home-manager options](https://nix-community.github.io/home-manager/options.html)
- [nix-darwin options](https://daiderd.com/nix-darwin/manual/index.html)

## Usage

```zsh
# To update your packages
$ nix flake update ~/.config/fleek
# To apply the configuration
$ nix run nix-darwin -- switch --flake ~/.config/fleek
```

## Troubleshooting

If you version your configuration with Git, be sure to commit all files otherwise it is likely to run into an error like the below due to [a Nix issue](https://discourse.nixos.org/t/nix-flakes-nix-store-source-no-such-file-or-directory/17836/12):

```console
error: getting status of '/nix/store/2pjy2jwi803dkhn7l77zyqcqja1gq38i-source/flake.nix': No such file or directory
```
