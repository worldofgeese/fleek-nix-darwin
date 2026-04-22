# Fleek - Nix Home Manager & nix-darwin Configuration

Declarative system configuration for macOS (via nix-darwin) and Linux/WSL (via Home Manager). Clone, configure, and get a fully reproducible development environment in minutes.

## What you get

- **Shell**: zsh with autocompletions, syntax highlighting, and Starship prompt
- **Terminal tools**: eza, bat, fzf, ripgrep, zoxide, atuin (history), tmux, neovim
- **Development**: Node.js, Rust (via rustup), Python (via uv), Bun, .NET, Go tooling
- **Cloud & infra**: kubectl, k9s, Helm, Flux, AWS CLI, Azure CLI, Pulumi
- **Git**: Signing with SSH keys, LFS, lazygit
- **macOS extras**: Homebrew management, Touch ID for sudo (even in tmux), system defaults
- **Upgrades**: Run `topgrade --yes` to update everything in one go

## Quick start (macOS)

### 1. Install Lix

```bash
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

### 2. Clone this repo

Use an ad-hoc nix shell if you don't have Git yet:

```bash
nix-shell -p gitMinimal gh
```

Clone to the standard location:

```bash
git clone <repo-url> ~/.local/share/fleek
cd ~/.local/share/fleek
```

### 3. Create your host configuration

Find your hostname and username:

```bash
echo "Hostname: $(hostname)  Username: $(whoami)"
```

Create your host folder and config files:

```bash
HOSTNAME=$(hostname)
USERNAME=$(whoami)

mkdir -p "$HOSTNAME"

# Create your personal config (git, SSH signing, etc.)
cat > "$HOSTNAME/$USERNAME.nix" << EOF
{
  pkgs,
  ...
}: {
  programs.git.enable = true;
  programs.git.ignores = [".direnv" "result"];
  programs.git.settings = {
    user.name = "Your Name";
    user.email = "your.email@lego.com";
    feature.manyFiles = true;
    init.defaultBranch = "main";
    lfs.enable = true;
  };
}
EOF

# Create a host-level darwin config
cat > "$HOSTNAME/darwin.nix" << 'EOF'
{
  config,
  lib,
  pkgs,
  username,
  ...
}: {
  # nix-darwin manages the Nix daemon + /etc/nix/nix.conf.
  # Leave `nix.enable` at its default (true) so `lix-module.darwinModules.default`
  # can pin Lix to the version from flake.nix.
  nixpkgs.config.allowUnfree = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
  };

  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.reattach = true;

  system.stateVersion = 5;

  homebrew = {
    enable = true;
    global.autoUpdate = true;
    onActivation.autoUpdate = true;
    onActivation.upgrade = true;
    onActivation.cleanup = "zap";
    brews = [];
    casks = [];
    taps = [];
  };
}
EOF

# Create an empty custom overrides file
cat > "$HOSTNAME/custom.nix" << 'EOF'
{
  pkgs,
  ...
}: {
}
EOF
```

### 4. Register your machine in `flake.nix`

Open `flake.nix` and add your entry to the `darwinConfigurations` section:

```nix
darwinConfigurations."YOUR-HOSTNAME" = mkDarwin { hostname = "YOUR-HOSTNAME"; username = "your-username"; };
```

### 5. Apply your configuration

```bash
nix flake update --flake ~/.local/share/fleek && sudo -H nix run nix-darwin -- switch --flake ~/.local/share/fleek
```

Open a new terminal to see your changes.

## Upgrading

To upgrade everything (Nix packages, Homebrew, and all other package managers):

```bash
topgrade --yes
```

To only update the Nix configuration:

```bash
nix flake update --flake ~/.local/share/fleek && sudo -H darwin-rebuild switch --flake ~/.local/share/fleek
```

There is also a shell alias for the above:

```bash
fleek-apply     # hostname-agnostic; picks darwinConfigurations.$(hostname)
apply-M-02877   # example of a host-specific alias
```

### Upgrading Lix itself

Lix comes from nixpkgs via `pkgs.lixPackageSets.latest.lix` (the path [recommended by upstream](https://lix.systems/add-to-config/) for stable releases). To move to a newer Lix, bump nixpkgs:

```bash
nix flake update nixpkgs --flake ~/.local/share/fleek
fleek-apply
```

`nix --version` after the rebuild reflects whatever Lix release the new nixpkgs ships. **Don't** run `nix upgrade-nix` — it doesn't know about Lix's release channel.

If you need a specific Lix version that's newer than what `nixos-unstable` has, switch `.latest` to `.git` (follows Lix main — requires compile) or `.lix_2_93` / `.lix_2_95` (pinned channels) in `flake.nix`. See https://lix.systems/add-to-config/.

## Quick start (WSL / Linux)

### 1. Install Lix

```bash
curl -sSf -L https://install.lix.systems/lix | sh -s -- install
```

### 2. Clone and configure

```bash
git clone <repo-url> ~/.local/share/fleek
cd ~/.local/share/fleek
```

### 3. Add your homeConfiguration

Open `flake.nix` and add an entry under `homeConfigurations`:

```nix
"your-username" = home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  extraSpecialArgs = { inherit inputs; };
  modules = [
    ./home.nix
    ./path.nix
    ./shell.nix
    ./user.nix
    ./aliases.nix
    ./programs.nix
    {
      home.username = "your-username";
      home.homeDirectory = "/home/your-username";
    }
  ];
};
```

### 4. Apply

```bash
nix flake update --flake ~/.local/share/fleek
nix run home-manager/master -- switch --flake ~/.local/share/fleek#your-username
```

## File structure

```
flake.nix                 # Flake inputs, mkDarwin helper, all system/user entries
├── home.nix              # Shared packages, session variables, fonts
├── shell.nix             # Zsh initialization (profile, homebrew token)
├── programs.nix          # All program enables + configuration (starship, fzf, tmux, etc.)
├── aliases.nix           # Shell aliases
├── path.nix              # Session PATH entries
├── user.nix              # Shared user-level overrides (empty by default)
└── <hostname>/           # Per-machine configuration
    ├── darwin.nix        # macOS system settings, Homebrew packages, PAM/Touch ID
    ├── <username>.nix    # Personal config: git identity, SSH signing keys
    └── custom.nix        # Host-specific overrides (empty by default)
```

## Quality-of-life improvements

The flake's `mkDarwin` already declares these system-wide via `nix.settings`:

- `experimental-features = nix-command flakes auto-allocate-uids`
- `warn-dirty = false`
- `auto-optimise-store = true`
- `extra-platforms = []` (drops Rosetta's x86_64-darwin auto-detect; ARM-only fleet)

No user-level `~/.config/nix/nix.conf` is needed for the above.

Optionally add a GitHub token (keeps `nix flake update` from hitting API rate limits — stays user-level since it's per-user auth):

```bash
mkdir -p ~/.config/nix
echo "access-tokens = github.com=$(gh auth token)" >> ~/.config/nix/nix.conf
```

## Reference

- [Home Manager manual](https://nix-community.github.io/home-manager/)
- [Home Manager options](https://nix-community.github.io/home-manager/options.html)
- [nix-darwin manual](https://nix-darwin.github.io/nix-darwin/manual/index.html)

## Uninstall

### macOS

```bash
# Uninstall nix-darwin
nix --extra-experimental-features "nix-command flakes" run nix-darwin#darwin-uninstaller

# Uninstall Lix/Nix
/nix/lix-installer uninstall
```

If you receive a "volume in use" error:

```bash
sudo diskutil unmountDisk force /nix && sudo diskutil apfs deleteVolume "Nix Store"
```

### WSL / Linux

```bash
home-manager uninstall
/nix/lix-installer uninstall
```

Restore `.bashrc.bak` to `.bashrc` and `.profile.bak` to `.profile` if needed.

## Troubleshooting

### Missing files error

If you version your configuration with Git, commit all files before running Nix commands:

```
error: getting status of '/nix/store/.../flake.nix': No such file or directory
```

### Git index error

```bash
cd ~/.local/share/fleek
git config --local index.skipHash false
git reset --mixed
```

### Hash mismatch

```bash
nix flake update --flake ~/.local/share/fleek
```

### Homebrew warning

Ensure `/opt/homebrew/bin` is in `path.nix`. Note that `onActivation.cleanup = "zap"` will remove any Homebrew packages not declared in your `darwin.nix` -- change to `"none"` if you want to manage some packages manually.

### `Unexpected files in /etc, aborting activation`

On first apply after the Lix installer, nix-darwin refuses to overwrite the installer's `/etc/nix/nix.conf`. Move it aside and re-run:

```bash
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
sudo -H darwin-rebuild switch --flake ~/.local/share/fleek
```

If `.before-nix-darwin` already exists from a prior attempt, use `.before-nix-darwin-2`, etc.

### `experimental Lix feature 'nix-command' is disabled`

Seen when bootstrapping via `sudo nix run nix-darwin ...` after the installer's `/etc/nix/nix.conf` has been moved aside (root's nix has no experimental-features set yet). Pass the flag inline for that one invocation:

```bash
sudo -H nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake ~/.local/share/fleek
```

Or just use `darwin-rebuild` directly if it's already on PATH:

```bash
sudo -H darwin-rebuild switch --flake ~/.local/share/fleek
```

After the first successful rebuild, nix-darwin writes its own `/etc/nix/nix.conf` with the needed features, and this goes away.
