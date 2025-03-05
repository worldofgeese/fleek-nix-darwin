# Nix Home Manager Configuration

Nix Home Manager configuration with additional `nix-darwin` support for macOS users.

## What is this?

This repository contains a declarative specification of tools, settings, and files for your system. Using Nix, you can create reproducible and pure environments. The main benefit is defining your system *portably*, allowing you to take the same configuration to any machine you use.

`nix-darwin` extends Nix for macOS specific configuration: you can manage your Homebrew packages, Mac App Store applications, and even enable fingerprint authentication for administrative terminal actions.

## Getting started

1. Install Lix (a Nix fork with niceties):
   ```bash
   curl -sSf -L https://install.lix.systems/lix | sh -s -- install
   ```

2. Clone this repo to `~/.config/home-manager` (hint: you can use `nix-shell -p gitMinimal gh` for an ad-hoc shell with Git and `gh` installed)

3. Modify this opinionated configuration by following the guides for macOS and WSL/Linux below.

3. Update your packages:
`nix flake update --flake ~/.config/home-manager`

4. Create your first Home Manager generation:
`nix run home-manager/master -- init --switch`

For help with any errors or bugs, refer to [Troubleshooting](#troubleshooting) or open an issue!

### Configuring `nix-darwin` for macOS users

Create or edit the file `darwin.nix` in the  `~/.config/home-manager` under your machine name folder. My machine name folder is M-02877 but it won't be yours. You can copy many of my settings, packages, and applications in my own `darwin.nix` file as you like. The important thing is you minimally include the following in your `darwin.nix` file:

```nix
{pkgs, ...}: {
  # if you use zsh (the default on new macOS installations),
  # you'll need to enable this so nix-darwin creates a zshrc sourcing needed environment changes
  programs.zsh.enable = true;
}
```

2. Configure nix-darwin to support Home Manager. Open `~/.config/home-manager/flake.nix`. Modify or add the `darwinConfigurations` block:

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

> [!IMPORTANT]  
> Replace instances of your-username and your-hostname with your actual values. Find your hostname by running the hostname command.

3. Apply your configuration:
`nix run nix-darwin -- switch --flake ~/.config/home-manager`

4. Open a new terminal to test your changes.

> [!WARNING]
> Homebrew users: ensure "/opt/homebrew/bin" is added to `~/.config/home-manager/path.nix`
> Look to my `darwin.nix` file for reference on installing brew packages. Be warned that my configuration assumes all Homebrew packages are managed by `nix-darwin`. Any unmanaged packages will be uninstalled unless you change `onActivation.cleanup = "zap";` to `onActivation.cleanup = "none"`.

## Configuring for WSL/Linux users

For WSL or Linux, make sure to customize the configuration for your username and system:

1. Open `~/.config/home-manager/flake.nix`
2. Find the `homeConfigurations` section
3. Add or modify an entry for your username:

```nix
"your-username" = home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  extraSpecialArgs = {inherit inputs;};
  modules = [
    ./home.nix
    ./path.nix
    ./shell.nix
    ./user.nix
    ./aliases.nix
    ./programs.nix
    {
      home = {
        username = "your-username";
        homeDirectory = "/home/your-username";
      };
    }
    {
      home.packages = [];
    }
    {
      nixpkgs.overlays = [];
    }
  ];
};
```

4. Update packages and apply your configuration:
```sh
nix flake update ~/.config/home-manager
nix run home-manager/master -- switch --flake ~/.config/home-manager#your-username
```

## Reference

- [home-manager](https://nix-community.github.io/home-manager/)
- [home-manager options](https://nix-community.github.io/home-manager/options.html)
- [nix-darwin options](https://daiderd.com/nix-darwin/manual/index.html)

## Usage

### macOS

```bash
# To update your packages
$ nix flake update --flake ~/.config/home-manager
# To update your machine with any changes
$ nix run nix-darwin -- switch --flake ~/.config/home-manager
```

### Windows Subsystem for Linux/Linux

```bash
# To update your packages
$ nix flake update --flake ~/.config/home-manager
# To update your machine with any changes
$ nix run home-manager/master -- switch
```

## Quality-of-life improvements

To improve your experience with Nix, run this command to:

- Set up a GitHub personal access token (avoids rate limiting)
- Configure experimental features
- Turn off dirty Git tree warnings
- Enable auto-optimization

```sh
echo -n "Enter your GitHub key (get one at https://github.com/settings/tokens): " && \
read github_key && \
printf "%s\n" "experimental-features = nix-command flakes auto-allocate-uids" \
"access-tokens = github.com=$github_key" \
"fallback = true" \
"warn-dirty = false" \
"auto-optimise-store = true" > nix.conf
```

## Uninstall

Since Nix is largely self-contained, uninstalling and reverting to your old configuration is easy! (Thank you, Aram, for these instructions.)

If on macOS, first uninstall nix-darwin:

```sh
`nix --extra-experimental-features "nix-command flakes" run nix-darwin#darwin-uninstaller`.
```

On WSL/Linux, uninstall Home Manager:

```sh
home-manager uninstall
```

- Uninstall Nix itself
  ```sh
  /nix/lix-installer uninstall
  ```

  If you're on macOS and you receive the error:
  ```console
  The volume "Nix Store" on disk3s7 couldn't be unmounted because it is in use by process $x`
  ```

  Run `sudo diskutil unmountDisk force /nix && sudo diskutil apfs deleteVolume "Nix Store"`

- Restore `.bashrc.bak` to `.bashrc`.
- Restore `.profile.bak` to `.profile.`

## Troubleshooting

### Git-related issues

- *Missing files error*: If you version your configuration with Git, commit all files before running Nix commands to prevent errors like:
  ```console
  error: getting status of '/nix/store/2pjy2jwi803dkhn7l77zyqcqja1gq38i-source/flake.nix': No such file or directory
  ```

- *Index error*: If you encounter:
  ```console
  error: ... while fetching the input 'git+file:///Users/username/.config/home-manager'
  error: getting working directory status: invalid data in index - calculated checksum does not match expected
  ```

  Run: 
  ```sh
  cd ~/.config/home-manager
  git config --local index.skipHash false
  git reset --mixed
  ```

### Nix and Home Manager issues

- *Hash mismatch error*: When you see:
`error: NAR hash mismatch in input 'https://github.com/nix-community/home-manager/archive/master.tar.gz?narHash=sha256-...'`
  
  Update your flake:
  `nix flake update --flake ~/.config/home-manager`

- *Activation package error*:
  `error: flake 'git+file:///home/user/.config/home-manager' does not provide attribute 'packages.x86_64-linux.homeConfigurations."user".activationPackage'...`
  
  This typically happens when using the default configuration without replacing the username and hostname. Edit your `~/.config/home-manager/flake.nix` to include your username in the `homeConfigurations` section.
  
- *Starship error*: If you see
  `bash: /home/USERNAME/.nix-profile/bin/starship: No such file or directory`
  
  Refer to [this bug report](https://github.com/nix-community/home-manager/issues/4807#issuecomment-1988625268) for solutions.

- *Systemd permission error*:
  `Creating home file links in /home/user ln: failed to create symbolic link '/home/user/.config/systemd/user/tray.target': Permission denied`

  Fix permissions with:
  ```sh
  sudo mkdir -p $HOME/.config/systemd/user
  sudo chown -R $USER:$USER $HOME/.config/systemd/user
  ```

