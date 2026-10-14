-- ~/.config/nvim/lua/options.lua

local o = vim.opt

-- ── Appearance ───────────────────────────────────────────────
o.termguicolors  = true        -- true color support
o.number         = true        -- line numbers
o.relativenumber = true        -- relative line numbers
o.cursorline     = true        -- highlight current line
o.signcolumn     = "yes"       -- always show sign column
o.scrolloff      = 8           -- keep 8 lines above/below cursor
o.sidescrolloff  = 8
o.wrap           = false       -- no line wrap
o.showmode       = false       -- mode shown in statusline instead

-- ── Tabs & Indentation ───────────────────────────────────────
o.tabstop        = 4
o.shiftwidth     = 4
o.expandtab      = true
o.smartindent    = true
o.autoindent     = true

-- ── Search ───────────────────────────────────────────────────
o.ignorecase     = true
o.smartcase      = true
o.hlsearch       = false
o.incsearch      = true

-- ── Files ────────────────────────────────────────────────────
o.swapfile       = false
o.backup         = false
o.undofile       = true
o.undodir        = vim.fn.expand("~/.cache/nvim/undo")

-- ── UI ───────────────────────────────────────────────────────
o.splitbelow     = true
o.splitright     = true
o.pumheight      = 10          -- popup menu height
o.conceallevel   = 0
o.fileencoding   = "utf-8"
o.mouse          = "a"
o.clipboard      = "unnamedplus"  -- use system clipboard
o.updatetime     = 250
o.timeoutlen     = 400

-- ── Transparent background (lets pywal bg show through) ─────
vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
        vim.api.nvim_set_hl(0, "Normal",     { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalNC",   { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalFloat",{ bg = "none" })
        vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
        vim.api.nvim_set_hl(0, "EndOfBuffer",{ bg = "none" })
    end,
})
