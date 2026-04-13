# This overlay, when applied to nixpkgs, adds the final neovim derivation to nixpkgs.
{inputs}: final: prev:
with final.pkgs.lib; let
  pkgs = final;

  # Use this to create a plugin from a flake input
  mkNvimPlugin = src: pname:
    pkgs.vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate;
    };

  # Make sure we use the pinned nixpkgs instance for wrapNeovimUnstable,
  # otherwise it could have an incompatible signature when applying this overlay.
  pkgs-locked = inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  locked-vim-plugins = pkgs-locked.vimPlugins;

  # This is the helper function that builds the Neovim derivation.
  mkNeovim = pkgs.callPackage ./mkNeovim.nix {
      inherit (pkgs-locked) wrapNeovimUnstable neovimUtils;
    };

  # A plugin can either be a package or an attrset, such as
  # { plugin = <plugin>; # the package, e.g. pkgs.vimPlugins.nvim-cmp
  #   config = <config>; # String; a config that will be loaded with the plugin
  #   # Boolean; Whether to automatically load the plugin as a 'start' plugin,
  #   # or as an 'opt' plugin, that can be loaded with `:packadd!`
  #   optional = <true|false>; # Default: false
  #   ...
  # }
  all-plugins = with pkgs.vimPlugins; [
    alpha-nvim
    amp-nvim
    copilot-lua
    opencode-nvim # https://github.com/nickjvandyke/opencode.nvim
    # plugins from nixpkgs go in here.
    # https://search.nixos.org/packages?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=vimPlugins
    nvim-treesitter.withAllGrammars
    # blink.cmp (autocompletion)
    blink-cmp # https://github.com/saghen/blink.cmp
    friendly-snippets # optional snippets collection used by blink.cmp
    # ^ blink.cmp
    # git integration plugins
    diffview-nvim # https://github.com/sindrets/diffview.nvim/
    neogit # https://github.com/TimUntersberger/neogit/
    gitsigns-nvim # https://github.com/lewis6991/gitsigns.nvim/
    vim-fugitive # https://github.com/tpope/vim-fugitive/
    lazygit-nvim # https://github.com/kdheepak/lazygit.nvim
    # ^ git integration plugins
    # telescope and extensions
    telescope-nvim # https://github.com/nvim-telescope/telescope.nvim/
    telescope-fzy-native-nvim # https://github.com/nvim-telescope/telescope-fzy-native.nvim
    # telescope-smart-history-nvim # https://github.com/nvim-telescope/telescope-smart-history.nvim
    # ^ telescope and extensions
    # UI
    rose-pine # https://github.com/rose-pine/neovim
    # nvim-tree-lua # File explorer | https://github.com/nvim-tree/nvim-tree.lua
    lualine-nvim # Status line | https://github.com/nvim-lualine/lualine.nvim/
    nvim-navic # Add LSP location to lualine | https://github.com/SmiteshP/nvim-navic
    statuscol-nvim # Status column | https://github.com/luukvbaal/statuscol.nvim/
    nvim-treesitter-context # nvim-treesitter-context
    # ^ UI
    # language support
    nvim-lspconfig # https://github.com/neovim/nvim-lspconfig
    render-markdown-nvim # https://github.com/MeanderingProgrammer/render-markdown.nvim
    locked-vim-plugins.quarto-nvim # https://github.com/quarto-dev/quarto-nvim
    locked-vim-plugins.otter-nvim # https://github.com/jmbuhr/otter.nvim
    (mkNvimPlugin inputs.markdown-plus-nvim "markdown-plus.nvim") # https://github.com/YousefHadder/markdown-plus.nvim
    (mkNvimPlugin inputs.fm-nvim "fm-nvim") # https://github.com/is0n/fm-nvim
    # ^ language support
    # jupyter notebook support
    locked-vim-plugins.molten-nvim # https://github.com/benlubas/molten-nvim
    locked-vim-plugins.image-nvim # https://github.com/3rd/image.nvim
    locked-vim-plugins.jupytext-nvim # https://github.com/GCBallesteros/jupytext.nvim (ipynb <-> markdown conversion)
    # ^ jupyter notebook support
    # file manager
    rnvimr # https://github.com/kevinhwang91/rnvimr
    # ^ file manager
    # navigation/editing enhancement plugins
    vim-eunuch # UNIX shell command helpers | https://github.com/tpope/vim-eunuch
    vim-unimpaired # predefined ] and [ navigation keymaps | https://github.com/tpope/vim-unimpaired/
    eyeliner-nvim # Highlights unique characters for f/F and t/T motions | https://github.com/jinh0/eyeliner.nvim
    flash-nvim # Enhanced jump/search motions | https://github.com/folke/flash.nvim
    nvim-surround # https://github.com/kylechui/nvim-surround/
    nvim-treesitter-textobjects # https://github.com/nvim-treesitter/nvim-treesitter-textobjects/
    nvim-ts-context-commentstring # https://github.com/joosepalviste/nvim-ts-context-commentstring/
    # ^ navigation/editing enhancement plugins
    # Useful utilities
    nvim-unception # Prevent nested neovim sessions | nvim-unception
    auto-session # Session management | https://github.com/rmagatti/auto-session
    # ^ Useful utilities
    # libraries that other plugins depend on
    sqlite-lua
    plenary-nvim
    nvim-web-devicons
    vim-repeat
    # ^ libraries that other plugins depend on
    # bleeding-edge plugins from flake inputs
    # (mkNvimPlugin inputs.wf-nvim "wf.nvim") # (example) keymap hints | https://github.com/Cassin01/wf.nvim
    # ^ bleeding-edge plugins from flake inputs
    which-key-nvim
  ];

  extraPackages = with pkgs; [
    # language servers, etc.
    lua-language-server
    nil # nix LSP
    ruff # python linter/formatter language server (`ruff server`)
    ty # python type checker language server (`ty server`)
    opencode # OpenCode CLI required by opencode.nvim
    lazygit
    nodejs
    curl
    # jupyter notebook support
    imagemagick # required by image.nvim
    (pkgs.python3.withPackages (ps: [ps.jupytext])) # jupytext CLI for jupytext.nvim
  ];

in {
  # This is the neovim derivation
  # returned by the overlay
  nvim-pkg = mkNeovim {
    plugins = all-plugins;
    inherit extraPackages;
    extraLuaPackages = p: [p.magick]; # required by image.nvim
    extraPython3Packages = p:
      with p; [
        pynvim # required by molten-nvim (remote plugin API)
        jupyter-client # required by molten-nvim (jupyter kernel interaction)
        nbformat # required by molten-nvim (import/export notebook outputs)
        cairosvg # optional: SVG image rendering with transparency
        plotly # optional: Plotly figure rendering
        kaleido # optional: required with plotly for image conversion
        pyperclip # optional: used by molten_copy_output
        jupytext # allows python3_host_prog -m jupytext fallback for session restore
        ipykernel # provides the default Python jupyter kernel
      ];
  };

  # This is meant to be used within a devshell.
  # Instead of loading the lua Neovim configuration from
  # the Nix store, it is loaded from $XDG_CONFIG_HOME/nvim-dev
  nvim-dev = mkNeovim {
    plugins = all-plugins;
    inherit extraPackages;
    extraLuaPackages = p: [p.magick];
    extraPython3Packages = p:
      with p; [
        pynvim
        jupyter-client
        nbformat
        cairosvg
        plotly
        kaleido
        pyperclip
        jupytext
        ipykernel
      ];
    appName = "nvim-dev";
    wrapRc = false;
  };

  # This can be symlinked in the devShell's shellHook
  nvim-luarc-json = final.mk-luarc-json {
    plugins = all-plugins;
  };

  # You can add as many derivations as you like.
  # Use `ignoreConfigRegexes` to filter out config
  # files you would not like to include.
  #
  # For example:
  #
  # nvim-pkg-no-telescope = mkNeovim {
  #   plugins = [];
  #   ignoreConfigRegexes = [
  #     "^plugin/telescope.lua"
  #     "^ftplugin/.*.lua"
  #   ];
  #   inherit extraPackages;
  # };
}
