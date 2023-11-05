{ inputs, config, pkgs, lib, ... }:

let
  nix-colors-lib = inputs.nix-colors.lib-contrib { inherit pkgs; };
in
{
  home = {
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      shellcheck
      rnix-lsp
    ];
    extraPython3Packages = ps: with ps; [
      python-lsp-server
      # pynvim
    ];
    plugins = with pkgs.vimPlugins; [
      {
        plugin = nvim-base16;
        type = "lua";
        config = ''
          local function isempty(s)
            return s == nil or s == ""
          end

          is_tty = (
            string.match(vim.env.TERM, "linux") or (
              isempty(vim.env.DISPLAY) and
              isempty(vim.env.WAYLAND_DISPLAY)
            )
          )

          vim.opt.background = "dark"
          if is_tty then
            vim.cmd.colorscheme("ron")
          else
            vim.opt.termguicolors = true
            vim.cmd.colorscheme("base16-${config.colorscheme.slug}")
          end

          -- Fix float window and border bg color
          vim.api.nvim_set_hl(0, "NormalFloat",
            {
              fg="#${config.colorscheme.colors.base05}",
              bg="#${config.colorscheme.colors.base01}"
            }
          )
          vim.api.nvim_set_hl(0, "FloatBorder",
            {
              fg="#${config.colorscheme.colors.base05}",
              bg="#${config.colorscheme.colors.base01}"
            }
          )
          -- vim.cmd.highlight({
          --   "NormalFloat",
          --   "fg=#${config.colorscheme.colors.base05}",
          --   "bg=#${config.colorscheme.colors.base01}"
          -- })
          -- vim.cmd.highlight({
          --   "FloatBorder",
          --   "fg=#${config.colorscheme.colors.base05}",
          --   "bg=#${config.colorscheme.colors.base01}"
          -- })
        '';
      } # nvim-base16
      {
        plugin = lualine-nvim;
        type = "lua";
        config = ''
          require("lualine").setup{
            options = {
              icons_enabled = false,
              -- theme = "base16",
              theme = "auto",
              section_separators = "",
              component_separators = "",
            }
          }
        '';
      } # lualine-nvim
      {
        plugin = trouble-nvim;
        type = "lua";
        config = ''
          require("trouble").setup{
            -- Disable icons
            icons = false,
            fold_open = "v",
            fold_closed = ">",
            -- Add an indent guide below the fold icons
            indent_lines = false,
            signs = {
              -- Icons / text used for a diagnostic
              error = "E",
              warning = "W",
              hint = "H",
              information = "I"
            },
            -- Disable signs defined in your lsp client
            use_diagnostic_signs = false
          }
        '';
      } # trouble-nvim
      {
        plugin = julia-vim;
        type = "lua";
        config = ''
          vim.g.julia_indent_align_brackets = 0
          vim.g.julia_indent_align_funcargs = 0

          vim.keymap.set("", "<leader>t", [[:TroubleToggle<CR>]])
        '';
      } # julia-vim
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config =
          let
            # WORKAROUND: pylsp not in PATH
            pylspWrapper = pkgs.writeShellScriptBin "pylsp-wrapper" ''
              nvim-python3 -c 'from pylsp.__main__ import main; main()' "$@"
            '';
          in
          ''
            local lspconfig = require("lspconfig")

            lspconfig["rnix"].setup{
              on_attach = on_attach,
            }

            -- WORKAROUND: for broken gq with python-lsp-server
            local pylsp_on_attach = function(client, bufnr)
              -- Clear the formatexpr function call set by python-lsp-server
              vim.api.nvim_buf_set_option(bufnr, "formatexpr", "")
            end

            lspconfig["pylsp"].setup{
              cmd = {"${pylspWrapper}/bin/pylsp-wrapper"},
              on_attach = pylsp_on_attach,
              plugins = {
                pycodestyle = {maxLineLength = 79}
              }
            }

            vim.diagnostic.config({virtual_text = false})

            -- Show line diagnostics automatically in hover window
            vim.opt.updatetime = 250
            vim.api.nvim_create_autocmd({"CursorHold", "CursorHoldI"}, {
              pattern = {"*"},
              callback = function()
                vim.diagnostic.open_float(nil, {focus = false})
              end
            })
          '';
      } # nvim-lspconfig
      {
        plugin = nvim-cmp;
        type = "lua";
        config = ''
          local cmp = require("cmp")
          local select_opts = {behavior = cmp.SelectBehavior.Select}

          cmp.setup {
            completion = {
              autocomplete = false,
            },
            mapping = {
              ['<Up>'] = cmp.mapping.select_prev_item(select_opts),
              ['<Down>'] = cmp.mapping.select_next_item(select_opts),
              ['<C-e>'] = cmp.mapping.abort(),
              ['<CR>'] = cmp.mapping.confirm({select = true}),

              ['<Tab>'] = cmp.mapping(function(fallback)
                local col = vim.fn.col('.') - 1

                if cmp.visible() then
                  cmp.select_next_item(select_opts)
                elseif col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') then
                  fallback()
                else
                  cmp.complete()
                end
              end, {'i', 's'}),

              ['<S-Tab>'] = cmp.mapping(function(fallback)
                if cmp.visible() then
                  cmp.select_prev_item(select_opts)
                else
                  fallback()
                end
              end, {'i', 's'}),
            },
            sources = cmp.config.sources({
              {name = 'nvim_lsp', keyword_length=3},
              {name = 'buffer', keyword_length=3},
              {name = 'path'},
            }),
          }
        '';
      } # nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      # FIXME: make option acceptance work in cmdline completion menu
      # {
      #   plugin = cmp-cmdline;
      #   type = "lua";
      #   config = ''
      #     local cmp = require("cmp")

      #     -- Use buffer source for `/`
      #     -- (if you enabled `native_menu`, this won't work anymore).
      #     cmp.setup.cmdline('/', {
      #       mapping = cmp.mapping.preset.cmdline({}),
      #       sources = cmp.config.sources({
      #         {name = 'buffer'},
      #       })
      #     })

      #     -- Use cmdline & path source for ':'
      #     -- (if you enabled `native_menu`, this won't work anymore).
      #     cmp.setup.cmdline(':', {
      #       mapping = cmp.mapping.preset.cmdline({}),
      #       sources = cmp.config.sources({
      #         {name = 'path'},
      #         {name = 'cmdline'},
      #       }),
      #       formatting = {fields = {'menu', 'abbr'}},
      #     })
      #   '';
      # }

      {
        plugin = vim-dasht;
        type = "lua";
        config = ''
          -- https://github.com/sunaku/vim-dasht#dashtvim

          -- Search docsets for something you type
          -- Related docsets only
          vim.keymap.set("n", "<leader>k", [[:Dasht<space>]])
          -- All the docsets
          vim.keymap.set("n", "<leader><leader>k",  [[:Dasht!<space>]])

          -- Search docsets for words under the cursor
          -- Related docsets only
          vim.keymap.set(
            "n", "<leader>K",
            [[:call Dasht(dasht#cursor_search_terms())<return>]],
            { silent = true }
          )
          -- All the docsets
          vim.keymap.set(
            "n", "<leader><leader>K",
            [[:call Dasht(dasht#cursor_search_terms(), '!')<return>]],
            { silent = true }
          )

          -- Search docsets for selected text
          -- Related docsets only
          vim.keymap.set(
            "v", "<leader>K",
            [[y:<C-U>call Dasht(getreg(0))<return>]],
            { silent = true }
          )
          -- All the docsets
          vim.keymap.set(
            "v", "<leader><leader>K",
            [[y:<C-U>call Dasht(getreg(0), '!')<return>]],
            { silent = true }
          )
        '';
      } # vim-dasht
      vim-commentary
      vim-markdown
      vim-nix
      vim-obsession
      vim-toml
    ];

    extraLuaConfig = ''
      vim.opt.splitright = true
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.colorcolumn = "+1"
      vim.opt.textwidth = 79
      vim.opt.formatexpr = ""
      vim.opt.tabstop = 8
      vim.opt.softtabstop = 0
      vim.opt.expandtab = true
      vim.opt.shiftwidth = 4
      vim.opt.modeline = true
      vim.opt.modelines = 5
      vim.opt.list = true
      vim.opt.listchars = {tab = "▸ ", trail = "·"}
      vim.opt.signcolumn = "number"
      vim.opt.completeopt = {"menu", "menuone", "noselect"}

      -- Italic comments
      vim.cmd.highlight({"Comment", "cterm=italic", "gui=italic"})
      vim.cmd.highlight({"Todo", "cterm=italic", "gui=italic"})

      -- File type-specific settings

      -- Set wraparound for Markdown
      vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
        pattern = {"*.md"},
        callback = function()
          vim.opt_local.textwidth = 79
          vim.opt_local.wrap = true
          vim.opt_local.linebreak = true
        end
      })
      -- ftplugin for xdefaults has a wrong commenting
      vim.api.nvim_create_autocmd({"FileType"}, {
        pattern = {"xdefaults"},
        callback = function()
          vim.opt.commentstring = "! %s"
        end
      })

      vim.g.mapleader = ","

      -- Copy to clipboard
      vim.keymap.set("v", "<leader>y", '"+y')
      vim.keymap.set("n", "<leader>Y", '"+yg_')
      vim.keymap.set("n", "<leader>y", '"+y')
      vim.keymap.set("n", "<leader>yy", '"+yy')
      -- Paste from clipboard
      vim.keymap.set("n", "<leader>p", '"+p')
      vim.keymap.set("n", "<leader>P", '"+P')
      vim.keymap.set("v", "<leader>p", '"+p')
      vim.keymap.set("v", "<leader>P", '"+P')
      -- Re-copy after pasting from buffer to easily paste multiple times
      -- https://stackoverflow.com/a/7164121
      vim.keymap.set("v", "p", 'pgvy')

      -- Move cursor by display lines (and not physical ones)
      vim.keymap.set("n", "k", 'gk', { silent = true })
      vim.keymap.set("n", "j", 'gj', { silent = true })
      vim.keymap.set("n", "0", 'g0', { silent = true })
      vim.keymap.set("n", "$", 'g$', { silent = true })

      -- Delete trailing white space
      -- https://stackoverflow.com/a/3475364
      vim.keymap.set(
        "n",
        "<leader>w",
        function()
          vim.cmd([[exe "normal mz"]])
          vim.cmd([[%s/\s\+$//ge]])
          vim.cmd([[exe "normal `z"]])
        end
      )
    '';
  };
}
