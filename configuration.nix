{ pkgs, self, nvim-plugins, us-altgr-intl, ... }: {
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    podman
    docker-compose
    codex
    jq
    uv
    imagemagick
    hexedit
    apktool
    nmap
    ghidra
    ghidra-extensions.wasm
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
          # { name = "auto-dark-mode.nvim"; src = "${auto-dark-mode-nvim}"; }
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
            -- require("auto-dark-mode").setup({})
            require("netrw").setup({})
          '';
          customRC = ''
    	set mouse=nvi
            let g:netrw_liststyle = 3
            let g:netrw_winsize = 30
          '';
        }
      )
    )
  ];

  security.pam.services.sudo_local.touchIdAuth = true;

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
