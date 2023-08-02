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
        config = ''
          lua << EOF

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
            vim.cmd([[colorscheme ron]])
          else
            vim.opt.termguicolors = true
            vim.cmd([[colorscheme base16-${config.colorscheme.slug}]])
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
          EOF
        '';
      } # nvim-base16
      {
        plugin = lualine-nvim;
        config = ''
          lua << EOF

          require("lualine").setup{
            options = {
              icons_enabled = false,
              -- theme = "base16",
              theme = "auto",
              section_separators = "",
              component_separators = "",
            }
          }

          EOF
        '';
      } # lualine-nvim
      {
        plugin = trouble-nvim;
        config = ''
          lua << EOF

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

          EOF
        '';
      } # trouble-nvim
      {
        plugin = julia-vim;
        config = ''
          lua << EOF

          vim.g.julia_indent_align_brackets = 0
          vim.g.julia_indent_align_funcargs = 0

          EOF
        '';
      } # julia-vim
      {
        plugin = nvim-lspconfig;
        config =
          let
            # WORKAROUND: pylsp not in PATH
            pylspWrapper = pkgs.writeShellScriptBin "pylsp-wrapper" ''
              nvim-python3 -c 'from pylsp.__main__ import main; main()' "$@"
            '';
          in
          ''
            lua << EOF

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
            vim.o.updatetime = 250
            vim.cmd([[
              autocmd CursorHold,CursorHoldI *
              \ lua vim.diagnostic.open_float(nil, {focus = false})
            ]])

            EOF
          '';
      } # nvim-lspconfig
      {
        plugin = nvim-cmp;
        config = ''
          lua << EOF

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

          EOF
        '';
      } # nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      # FIXME: make option acceptance work in cmdline completion menu
      # {
      #   plugin = cmp-cmdline;
      #   config = ''
      #     lua << EOF

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


      #     EOF
      #   '';
      # }

      vim-commentary
      vim-dasht
      vim-markdown
      vim-nix
      vim-obsession
      vim-toml
    ];

    extraConfig = ''
      lua << EOF

      vim.opt.splitright = true
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
      vim.opt.signcolumn = "yes:1"
      vim.opt.completeopt = {"menu", "menuone", "noselect"}

      -- Italic comments
      vim.cmd([[hi Comment cterm=italic gui=italic]])
      vim.cmd([[hi Todo cterm=italic gui=italic]])

      -- File type-specific settings

      -- Set wraparound for Markdown
      vim.cmd([[au BufRead,BufNewFile *.md setlocal tw=79 wrap linebreak]])

      vim.g.mapleader = ","

      EOF

      """" KEYBOARD SHORTCUTS

      " Copy & paste to/from the clipboard

      " Copy to clipboard
      vnoremap  <leader>y  "+y
      nnoremap  <leader>Y  "+yg_
      nnoremap  <leader>y  "+y
      nnoremap  <leader>yy  "+yy
      " Paste from clipboard
      nnoremap <leader>p "+p
      nnoremap <leader>P "+P
      vnoremap <leader>p "+p
      vnoremap <leader>P "+P
      " Re-copy after pasting from buffer to easily paste multiple times
      " https://stackoverflow.com/a/7164121
      vnoremap p pgvy

      " Delete trailing white space
      noremap <leader>w :call DeleteTrailingWhiteSpace()<CR>

      " Move cursor by display lines (and not physical ones)
      noremap <silent> k gk
      noremap <silent> j gj
      noremap <silent> 0 g0
      noremap <silent> $ g$

      " Trouble integration
      noremap <leader>t :TroubleToggle<CR>

      " Dasht integration
      " https://github.com/sunaku/vim-dasht#dashtvim

      " Search docsets for something typed in
      " Related docsets only
      nnoremap <leader>k :Dasht<space>
      " All the docsets
      nnoremap <leader><leader>k :Dasht!<space>

      " Search docsets for words under the cursor
      " Related docsets only
      nnoremap <leader>K :call Dasht(dasht#cursor_search_terms())<return>
      " All the docsets
      nnoremap <leader>K :call
        \ Dasht(dasht#cursor_search_terms(), '!')<return>

      " Search docsets for selected text
      " Related docsets only
      vnoremap <silent> <leader>K y:<C-U>call Dasht(getreg(0))<return>
      " All the docsets
      vnoremap <silent>
        \ <leader><leader>K y:<C-U>call Dasht(getreg(0), '!')<return>

      """" CUSTOM FUNCTIONS

      " Delete trailing white space
      " https://stackoverflow.com/a/3475364
      function! DeleteTrailingWhiteSpace()
        exe "normal mz"
        %s/\s\+$//ge
        exe "normal `z"
      endfunction

      """" WORKAROUNDS

      " ftplugin for xdefaults has a wrong commenting
      autocmd FileType xdefaults set commentstring=!\ %s
    '';
  };
}
