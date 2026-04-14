{
  pkgs,
  lib,
  ...
}: {
  # ── Terminal tools ──────────────────────────────────────────────

  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
    };
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "rg --files --hidden --glob '!.git'";
    defaultOptions = [
      "--height 40%"
      "--border"
      "--layout=reverse"
      "--info=inline"
    ];
    fileWidgetCommand = "rg --files --hidden --glob '!.git'";
    fileWidgetOptions = ["--preview 'bat --color=always --style=numbers --line-range=:500 {}'"];
    changeDirWidgetOptions = ["--preview 'eza --tree --color=always {} | head -200'"];
    tmux.enableShellIntegration = true;
  };

  programs.zoxide.enable = true;
  programs.dircolors.enable = true;

  # ── Shell history ───────────────────────────────────────────────

  programs.atuin = {
    enable = true;
    settings = {
      auto_sync = false;
      search_mode = "fuzzy";
      filter_mode = "global";
      style = "compact";
      show_help = false;
      show_tabs = false;
      enter_accept = true;
    };
  };

  # ── Environment ─────────────────────────────────────────────────

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    silent = true;
  };

  # ── Prompt ──────────────────────────────────────────────────────

  programs.starship = {
    enable = true;
    enableNushellIntegration = true;
    settings = let
      lang = fg: symbol: {
        inherit symbol;
        style = "bg:color_blue fg:${fg}";
        format = "[ $symbol($version) ](bg:color_blue fg:${fg})";
      };
    in {
      "$schema" = "https://starship.rs/config-schema.json";

      format = lib.concatStrings [
        "[](color_orange)"
        "$os"
        "$username"
        "[](bg:color_yellow fg:color_orange)"
        "$directory"
        "[](fg:color_yellow bg:color_aqua)"
        "$git_branch"
        "$git_status"
        "$git_state"
        "[](fg:color_aqua bg:color_blue)"
        "$nodejs"
        "$rust"
        "$python"
        "$golang"
        "$bun"
        "$dotnet"
        "$package"
        "[](fg:color_blue bg:color_purple)"
        "$nix_shell"
        "$direnv"
        "$docker_context"
        "$kubernetes"
        "$aws"
        "[](fg:color_purple bg:color_bg3)"
        "$time"
        "[ ](fg:color_bg3)"
        "$line_break"
        "$cmd_duration"
        "$character"
      ];

      palette = "fleek";

      palettes.fleek = {
        color_fg0 = "#e2e4e8";
        color_bg1 = "#2e3440";
        color_bg3 = "#4c566a";
        color_blue = "#5e81ac";
        color_aqua = "#8fbcbb";
        color_green = "#a3be8c";
        color_orange = "#d08770";
        color_purple = "#b48ead";
        color_red = "#bf616a";
        color_yellow = "#ebcb8b";
      };

      os = {
        disabled = false;
        style = "bg:color_orange fg:color_fg0";
        symbols = {
          Macos = "🍎";
          Linux = "🐧";
          Ubuntu = "🟠";
          Debian = "🔴";
          Fedora = "🔵";
          Windows = "🪟";
          Alpine = "🏔️";
          Arch = "🔷";
          NixOS = "❄️";
        };
      };

      username = {
        show_always = true;
        style_user = "bg:color_orange fg:color_fg0";
        style_root = "bg:color_orange fg:color_fg0";
        format = "[ $user ]($style)";
      };

      directory = {
        style = "bg:color_yellow fg:color_bg1";
        format = "[ $path ]($style)";
        truncation_length = 4;
        truncation_symbol = "…/";
        truncate_to_repo = true;
        substitutions = {
          Documents = "📄";
          Downloads = "📥";
          Music = "🎵";
          Pictures = "📸";
          Developer = "💻";
        };
      };

      git_branch = {
        symbol = "🌿";
        style = "bg:color_aqua fg:color_bg1";
        format = "[ $symbol $branch ](bg:color_aqua fg:color_bg1)";
      };

      git_status = {
        style = "bg:color_aqua fg:color_bg1";
        format = "[($all_status$ahead_behind )](bg:color_aqua fg:color_bg1)";
        ahead = "⬆\${count}";
        behind = "⬇\${count}";
        diverged = "⬆\${ahead_count}⬇\${behind_count}";
        conflicted = "⚔\${count}";
        untracked = "❓\${count}";
        stashed = "📦\${count}";
        modified = "✏\${count}";
        staged = "✅\${count}";
        renamed = "📝\${count}";
        deleted = "🗑\${count}";
      };

      git_state = {
        style = "bg:color_aqua fg:color_bg1";
        format = "[$state( $progress_current/$progress_total) ](bg:color_aqua fg:color_bg1)";
      };

      nodejs = lang "color_fg0" "🟢";
      rust = lang "color_fg0" "🦀";
      python = lang "color_fg0" "🐍";
      golang = lang "color_fg0" "🐹";
      bun = lang "color_fg0" "🧅";
      dotnet = lang "color_fg0" "🟣";

      package = {
        style = "bg:color_blue fg:color_fg0";
        format = "[ 📦$version ](bg:color_blue fg:color_fg0)";
      };

      nix_shell = {
        style = "bg:color_purple fg:color_fg0";
        format = "[ ❄️ $state( \\($name\\)) ](bg:color_purple fg:color_fg0)";
        impure_msg = "impure";
        pure_msg = "pure";
      };

      direnv = {
        disabled = false;
        style = "bg:color_purple fg:color_fg0";
        format = "[ 📂direnv ](bg:color_purple fg:color_fg0)";
      };

      docker_context = {
        symbol = "🐳";
        style = "bg:color_purple fg:color_fg0";
        format = "[ $symbol$context ](bg:color_purple fg:color_fg0)";
      };

      kubernetes = {
        disabled = false;
        symbol = "☸️";
        style = "bg:color_purple fg:color_fg0";
        format = "[ $symbol$context(/$namespace) ](bg:color_purple fg:color_fg0)";
      };

      aws = {
        symbol = "☁️";
        style = "bg:color_purple fg:color_fg0";
        format = "[ $symbol$profile(/$region) ](bg:color_purple fg:color_fg0)";
      };

      time = {
        disabled = false;
        time_format = "%H:%M";
        style = "bg:color_bg3 fg:color_fg0";
        format = "[ 🕐$time ](bg:color_bg3 fg:color_fg0)";
      };

      line_break.disabled = false;

      cmd_duration = {
        min_time = 2000;
        format = "⏱️ [$duration]($style) ";
        style = "bold yellow";
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold blue)";
        vimcmd_replace_symbol = "[❮](bold purple)";
        vimcmd_visual_symbol = "[❮](bold yellow)";
      };
    };
  };

  # ── Cloud & infrastructure ──────────────────────────────────────

  programs.awscli.enable = true;
  programs.k9s.enable = true;

  # ── Editors ─────────────────────────────────────────────────────

  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;
    withRuby = false;
    withPython3 = false;
  };

  # ── Git tools ───────────────────────────────────────────────────

  programs.lazygit.enable = true;

  # ── File managers ───────────────────────────────────────────────

  programs.lf.enable = true;

  # ── System monitoring ───────────────────────────────────────────

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "Default";
      theme_background = false;
      vim_keys = true;
    };
  };

  # ── Terminal multiplexer ────────────────────────────────────────

  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    mouse = true;
    historyLimit = 50000;
    escapeTime = 0;
    baseIndex = 1;
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    extraConfig = ''
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -g renumber-windows on
    '';
  };

  # ── Shells ──────────────────────────────────────────────────────

  programs.nushell.enable = true;
  programs.wezterm.enable = true;

  # ── Upgrade management ──────────────────────────────────────────

  programs.topgrade = {
    enable = true;
    settings = {
      misc = {
        assume_yes = true;
        disable = [
          "nix"
          "home_manager"
          "brew_formula"
          "brew_cask"
          "bun"
          "bob"
        ];
        cleanup = true;
        set_title = true;
      };
      commands = {
        "Nix-Darwin" = "nix flake update --flake ~/.local/share/fleek && sudo -H darwin-rebuild switch --flake ~/.local/share/fleek";
      };
    };
  };

  # ── SSH ─────────────────────────────────────────────────────────

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        controlMaster = "auto";
        controlPersist = "yes";
      };
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/my_ssh_key";
        addKeysToAgent = "yes";
        controlMaster = "auto";
        controlPersist = "yes";
      };
    };
  };
}
