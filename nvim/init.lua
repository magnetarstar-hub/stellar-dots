-- ~/.config/nvim/init.lua
-- Requires Neovim >= 0.11 (Arch ships current stable in [extra])

----------------------------------------------------------------------
-- Leaders (must be set before plugins load)
----------------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
vim.g.have_nerd_font = true

----------------------------------------------------------------------
-- Options
----------------------------------------------------------------------
local o = vim.opt
o.number = true
o.relativenumber = true
o.signcolumn = "yes"
o.cursorline = true
o.scrolloff = 8
o.sidescrolloff = 8
o.wrap = false
o.termguicolors = true
o.showmode = false            -- lualine shows it
o.splitright = true
o.splitbelow = true
o.mouse = "a"
o.clipboard = "unnamedplus"   -- needs wl-clipboard (Wayland) or xclip (X11)
o.undofile = true
o.swapfile = false
o.ignorecase = true
o.smartcase = true
o.inccommand = "split"
o.updatetime = 200
o.timeoutlen = 300
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.smartindent = true
o.breakindent = true
o.list = true
o.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
o.completeopt = { "menu", "menuone", "noselect" }
o.pumheight = 12
o.confirm = true
o.laststatus = 3              -- global statusline
o.fillchars = { eob = " " }
o.winborder = "rounded"       -- 0.11+

----------------------------------------------------------------------
-- Keymaps
----------------------------------------------------------------------
local map = vim.keymap.set

map("n", "<Esc>", "<cmd>nohlsearch<CR>")
map("n", "<C-s>", "<cmd>w<CR>", { desc = "Save" })
map("i", "<C-s>", "<Esc><cmd>w<CR>", { desc = "Save" })
map("n", "<leader>qq", "<cmd>qa<CR>", { desc = "Quit all" })

-- Window navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-l>", "<C-w>l")
map("n", "<C-Up>", "<cmd>resize +2<CR>")
map("n", "<C-Down>", "<cmd>resize -2<CR>")
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>")
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>")

-- Buffers
map("n", "<S-h>", "<cmd>bprevious<CR>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "Delete buffer" })

-- Move lines
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- Keep selection when indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Keep cursor centered
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Paste over selection without clobbering register
map("x", "<leader>p", [["_dP]], { desc = "Paste (keep register)" })

-- Diagnostics
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Prev diagnostic" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next diagnostic" })

-- Terminal
map("t", "<Esc><Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

----------------------------------------------------------------------
-- Autocommands
----------------------------------------------------------------------
local aug = vim.api.nvim_create_augroup("user", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = aug,
  callback = function() vim.hl.on_yank() end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = aug,
  desc = "Restore last cursor position",
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = aug,
  command = "tabdo wincmd =",
})

vim.api.nvim_create_autocmd("FileType", {
  group = aug,
  pattern = { "python", "rust", "c", "cpp", "java", "go" },
  callback = function()
    vim.bo.shiftwidth = 4
    vim.bo.tabstop = 4
  end,
})

----------------------------------------------------------------------
-- Bootstrap lazy.nvim
----------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n" .. out, "ErrorMsg" } }, true, {})
    return
  end
end
vim.opt.rtp:prepend(lazypath)

----------------------------------------------------------------------
-- Plugins
----------------------------------------------------------------------
require("lazy").setup({

  -- Colorscheme --------------------------------------------------------
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = false,
      integrations = {
        blink_cmp = true, gitsigns = true, telescope = { enabled = true },
        which_key = true, mason = true, flash = true, trouble = true,
        treesitter = true, mini = { enabled = true }, neotree = true,
        indent_blankline = { enabled = true },
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- Icons --------------------------------------------------------------
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Which-key ----------------------------------------------------------
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      spec = {
        { "<leader>f", group = "find" },
        { "<leader>g", group = "git" },
        { "<leader>c", group = "code" },
        { "<leader>b", group = "buffer" },
        { "<leader>x", group = "diagnostics" },
        { "<leader>q", group = "quit" },
      },
    },
  },

  -- Statusline ---------------------------------------------------------
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "catppuccin",
        globalstatus = true,
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff" },
        lualine_c = { { "filename", path = 1 }, "diagnostics" },
        lualine_x = { "encoding", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },

  -- Indent guides ------------------------------------------------------
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = { indent = { char = "│" }, scope = { enabled = true } },
  },

  -- File explorer ------------------------------------------------------
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
    cmd = "Neotree",
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Explorer" },
      { "<leader>E", "<cmd>Neotree reveal<CR>", desc = "Reveal file in explorer" },
    },
    opts = {
      filesystem = {
        filtered_items = { hide_dotfiles = false, hide_gitignored = false },
        follow_current_file = { enabled = true },
        use_libuv_file_watcher = true,
      },
      window = { width = 32 },
    },
  },

  -- Oil: edit the filesystem like a buffer -----------------------------
  {
    "stevearc/oil.nvim",
    lazy = false,
    keys = { { "-", "<cmd>Oil<CR>", desc = "Open parent directory" } },
    opts = { default_file_explorer = false, view_options = { show_hidden = true } },
  },

  -- Telescope ----------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-ui-select.nvim",
    },
    keys = {
      { "<leader><space>", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>ff", "<cmd>Telescope find_files<CR>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<CR>", desc = "Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<CR>", desc = "Buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<CR>", desc = "Recent files" },
      { "<leader>fh", "<cmd>Telescope help_tags<CR>", desc = "Help" },
      { "<leader>fk", "<cmd>Telescope keymaps<CR>", desc = "Keymaps" },
      { "<leader>fd", "<cmd>Telescope diagnostics<CR>", desc = "Diagnostics" },
      { "<leader>fw", "<cmd>Telescope grep_string<CR>", desc = "Word under cursor" },
      { "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>", desc = "Document symbols" },
      { "<leader>/", "<cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Search in buffer" },
    },
    config = function()
      local t = require("telescope")
      t.setup({
        defaults = {
          prompt_prefix = "   ",
          selection_caret = " ",
          sorting_strategy = "ascending",
          layout_config = { prompt_position = "top" },
          file_ignore_patterns = { "node_modules", "%.git/", "target/", "__pycache__" },
        },
        pickers = { find_files = { hidden = true } },
        extensions = { ["ui-select"] = require("telescope.themes").get_dropdown() },
      })
      t.load_extension("fzf")
      t.load_extension("ui-select")
    end,
  },

  -- Treesitter ---------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSUpdate", "TSInstall" },
    main = "nvim-treesitter.configs",
    opts = {
      ensure_installed = {
        "bash", "c", "cpp", "css", "diff", "dockerfile", "git_config", "gitcommit",
        "html", "javascript", "json", "lua", "luadoc", "markdown", "markdown_inline",
        "python", "query", "regex", "rust", "toml", "tsx", "typescript",
        "vim", "vimdoc", "yaml",
      },
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          node_decremental = "<BS>",
        },
      },
    },
  },

  -- LSP ----------------------------------------------------------------
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "mason-org/mason.nvim", opts = { ui = { border = "rounded" } } },
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      -- Servers installed through Mason (rust_analyzer: install via pacman/rustup instead)
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = "Replace" },
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
        bashls = {},
        basedpyright = {},
        clangd = {},
        ts_ls = {},
        jsonls = {},
        yamlls = {},
        taplo = {},
        marksman = {},
      }

      -- Capabilities from blink.cmp, applied to every server
      vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
      for name, cfg in pairs(servers) do
        if next(cfg) then vim.lsp.config(name, cfg) end
      end

      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_enable = true,
      })

      require("mason-tool-installer").setup({
        ensure_installed = { "stylua", "prettierd", "shfmt", "ruff", "shellcheck" },
      })

      -- rust-analyzer from pacman (`sudo pacman -S rust-analyzer`)
      if vim.fn.executable("rust-analyzer") == 1 then
        vim.lsp.enable("rust_analyzer")
      end

      -- Diagnostics UI
      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = true,
        update_in_insert = false,
        virtual_text = { spacing = 4, prefix = "●" },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.INFO] = " ",
            [vim.diagnostic.severity.HINT] = "󰌵 ",
          },
        },
      })

      -- Buffer-local LSP keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user-lsp", { clear = true }),
        callback = function(ev)
          local b = function(keys, fn, desc, mode)
            map(mode or "n", keys, fn, { buffer = ev.buf, desc = "LSP: " .. desc })
          end
          local tb = require("telescope.builtin")
          b("gd", tb.lsp_definitions, "Go to definition")
          b("gr", tb.lsp_references, "References")
          b("gI", tb.lsp_implementations, "Implementation")
          b("gy", tb.lsp_type_definitions, "Type definition")
          b("gD", vim.lsp.buf.declaration, "Declaration")
          b("K", vim.lsp.buf.hover, "Hover")
          b("<leader>cr", vim.lsp.buf.rename, "Rename")
          b("<leader>ca", vim.lsp.buf.code_action, "Code action", { "n", "x" })
          b("<C-k>", vim.lsp.buf.signature_help, "Signature help", "i")

          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client:supports_method("textDocument/inlayHint") then
            b("<leader>ch", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
            end, "Toggle inlay hints")
          end
        end,
      })
    end,
  },

  -- Completion ---------------------------------------------------------
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      keymap = { preset = "default" }, -- <C-y> accept, <C-space> open, <C-n>/<C-p> navigate
      appearance = { nerd_font_variant = "mono" },
      completion = {
        documentation = { auto_show = true, auto_show_delay_ms = 250 },
        menu = { border = "rounded" },
        ghost_text = { enabled = true },
      },
      signature = { enabled = true },
      sources = { default = { "lsp", "path", "snippets", "buffer" } },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
  },

  -- Formatting ---------------------------------------------------------
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cf",
        function() require("conform").format({ async = true, lsp_format = "fallback" }) end,
        mode = { "n", "v" },
        desc = "Format",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "ruff_format", "ruff_organize_imports" },
        sh = { "shfmt" },
        bash = { "shfmt" },
        javascript = { "prettierd" },
        typescript = { "prettierd" },
        javascriptreact = { "prettierd" },
        typescriptreact = { "prettierd" },
        json = { "prettierd" },
        yaml = { "prettierd" },
        markdown = { "prettierd" },
        css = { "prettierd" },
        html = { "prettierd" },
        rust = { "rustfmt" },
        c = { "clang-format" },
        cpp = { "clang-format" },
      },
      format_on_save = { timeout_ms = 1000, lsp_format = "fallback" },
    },
  },

  -- Linting ------------------------------------------------------------
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost" },
    config = function()
      local lint = require("lint")
      lint.linters_by_ft = { sh = { "shellcheck" }, bash = { "shellcheck" } }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
        group = aug,
        callback = function() lint.try_lint() end,
      })
    end,
  },

  -- Git ----------------------------------------------------------------
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      on_attach = function(bufnr)
        local gs = require("gitsigns")
        local b = function(mode, l, r, desc) map(mode, l, r, { buffer = bufnr, desc = desc }) end
        b("n", "]h", function() gs.nav_hunk("next") end, "Next hunk")
        b("n", "[h", function() gs.nav_hunk("prev") end, "Prev hunk")
        b("n", "<leader>gs", gs.stage_hunk, "Stage hunk")
        b("n", "<leader>gr", gs.reset_hunk, "Reset hunk")
        b("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
        b("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame line")
        b("n", "<leader>gB", gs.toggle_current_line_blame, "Toggle inline blame")
        b("n", "<leader>gd", gs.diffthis, "Diff this")
      end,
    },
  },

  -- Motion -------------------------------------------------------------
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
    },
  },

  -- mini.nvim: pairs, surround, text objects ---------------------------
  {
    "nvim-mini/mini.nvim",
    version = false,
    event = "VeryLazy",
    config = function()
      require("mini.pairs").setup()
      require("mini.surround").setup()   -- gsa / gsd / gsr
      require("mini.ai").setup({ n_lines = 500 })
      require("mini.bufremove").setup()
    end,
  },

  -- Diagnostics list ---------------------------------------------------
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<CR>", desc = "Diagnostics (workspace)" },
      { "<leader>xb", "<cmd>Trouble diagnostics toggle filter.buf=0<CR>", desc = "Diagnostics (buffer)" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<CR>", desc = "Symbols" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<CR>", desc = "Quickfix" },
    },
  },

  -- TODO highlighting --------------------------------------------------
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = { { "<leader>ft", "<cmd>TodoTelescope<CR>", desc = "Todos" } },
  },

  -- Markdown rendering -------------------------------------------------
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = "markdown",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  -- Session / misc -----------------------------------------------------
  { "tpope/vim-sleuth", event = { "BufReadPost", "BufNewFile" } }, -- auto-detect indent

}, {
  ui = { border = "rounded" },
  checker = { enabled = false },
  change_detection = { notify = false },
  performance = {
    rtp = {
      disabled_plugins = { "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin" },
    },
  },
})
