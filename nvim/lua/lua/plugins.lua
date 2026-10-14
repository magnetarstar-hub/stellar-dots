-- ~/.config/nvim/lua/plugins.lua

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

    -- ── Pywal colorscheme (reads ~/.cache/wal/colors) ─────────
    {
        "dylanaraps/wal.vim",
        lazy = false,
        priority = 1000,
        config = function()
            vim.cmd("colorscheme wal")
        end,
    },

    -- ── Statusline ────────────────────────────────────────────
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("lualine").setup({
                options = {
                    theme = "auto",
                    component_separators = { left = "", right = "" },
                    section_separators   = { left = "", right = "" },
                    globalstatus = true,
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = { "branch", "diff", "diagnostics" },
                    lualine_c = { { "filename", path = 1 } },
                    lualine_x = { "encoding", "filetype" },
                    lualine_y = { "progress" },
                    lualine_z = { "location" },
                },
            })
        end,
    },

    -- ── File tree ─────────────────────────────────────────────
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("nvim-tree").setup({
                view = { width = 30 },
                renderer = {
                    group_empty = true,
                    highlight_git = true,
                    icons = { show = { git = true, folder = true, file = true } },
                },
                filters = { dotfiles = false },
            })
        end,
    },

    -- ── Fuzzy finder ──────────────────────────────────────────
    {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("telescope").setup({
                defaults = {
                    layout_config = { prompt_position = "top" },
                    sorting_strategy = "ascending",
                    winblend = 10,
                },
            })
        end,
    },

    -- ── Syntax highlighting ───────────────────────────────────
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = { "lua", "python", "bash", "json", "css", "html", "markdown" },
                highlight = { enable = true },
                indent    = { enable = true },
            })
        end,
    },

    -- ── Auto pairs ────────────────────────────────────────────
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true,
    },

    -- ── Comments ──────────────────────────────────────────────
    {
        "numToStr/Comment.nvim",
        event = "VeryLazy",
        config = true,
    },

    -- ── Git signs in gutter ───────────────────────────────────
    {
        "lewis6991/gitsigns.nvim",
        config = true,
    },

    -- ── Indent guides ─────────────────────────────────────────
    {
        "lukas-reineke/indent-blankline.nvim",
        main = "ibl",
        config = function()
            require("ibl").setup({
                indent = { char = "│" },
                scope  = { enabled = true },
            })
        end,
    },

    -- ── Which-key (shows keybind hints) ───────────────────────
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = true,
    },

}, {
    ui = { border = "rounded" },
})
