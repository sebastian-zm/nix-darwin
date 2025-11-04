{ pkgs, self, nvim-plugins, us-altgr-intl, ... }: {

  imports = [ ./modules/mysql.nix ];

  environment.variables = {
    EDITOR = "nvim";
  };
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    caskArgs = {
      appdir = "/Applications";
    };
    casks = [ "obs" "protonvpn" ];
  };
  environment.systemPackages = with pkgs; [
    podman
    docker-compose
    codex
    gemini-cli
    jq
    bat
    btop
    dust
    uv
    nodejs_24
    pandoc

    # uni
    mysql84
    jupyter
    python313Packages.numpy
    python313Packages.pandas
    python313Packages.openpyxl
    node-red
    maven
    zulu21

    # hack
    imagemagick
    hexedit
    apktool
    nmap
    ghidra-bin
    volatility3
    jadx

    # editors
    (
      pkgs.vscode-with-extensions.override {
        vscode = pkgs.vscode;

        vscodeExtensions = with pkgs.vscode-extensions; [
          redhat.java
          ms-python.python
          ms-toolsai.jupyter
        ];
      }
    )
    (
      let
        mkNvimPlugin = { name, src }: {
          plugin = pkgs.vimUtils.buildVimPlugin {
            inherit name src;
          };
          optional = false;
          type = "lua";
        };
        plugins = with nvim-plugins; map mkNvimPlugin [
          { name = "mini.nvim"; src = "${mini-nvim}"; }
          { name = "guess-indent.nvim"; src = "${guess-indent-nvim}"; }
          { name = "netrw.nvim"; src = "${netrw-nvim}"; }
        ];
      in pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped (
        pkgs.neovimUtils.makeNeovimConfig {
          withPython3 = false;
          withNodeJs = false;
          withRuby = false;
          withPerl = false;
          waylandSupport = false;
          viAlias = true;
          vimAlias = true;
          inherit plugins;
          customLuaRC = ''
            require("mini.ai").setup()
            require("mini.basics").setup()
            require("mini.comment").setup()
            require("mini.cursorword").setup()
            require("mini.diff").setup()
            require("mini.icons").setup()
            require("mini.git").setup()
            require("mini.pairs").setup()
            require("mini.surround").setup()
            require("mini.statusline").setup()
            require("mini.tabline").setup()
            require("mini.trailspace").setup()
            require("netrw").setup({})
          '';
          customRC = ''
    	    set mouse=nvi
    	    set expandtab
            let g:netrw_liststyle = 3
            let g:netrw_winsize = 30
          '';
        }
      )
    )
  ];

  security.pam.services.sudo_local.touchIdAuth = true;

  nixpkgs.config = {
    allowUnfree = true;
  };

  system.primaryUser = "sebastian";

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "x86_64-darwin";
}
