-- ~/.config/nvim/lua/keymaps.lua

local map = vim.keymap.set

vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- ── General ──────────────────────────────────────────────────
map("i", "jk",          "<Esc>",              { desc = "Exit insert mode" })
map("n", "<leader>w",   "<cmd>w<cr>",         { desc = "Save file" })
map("n", "<leader>q",   "<cmd>q<cr>",         { desc = "Quit" })
map("n", "<leader>x",   "<cmd>x<cr>",         { desc = "Save and quit" })

-- ── Window navigation ────────────────────────────────────────
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to upper window" })

-- ── Buffer navigation ────────────────────────────────────────
map("n", "<S-l>", "<cmd>bnext<cr>",     { desc = "Next buffer" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete buffer" })

-- ── Move lines ───────────────────────────────────────────────
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move line up" })

-- ── Keep cursor centered ─────────────────────────────────────
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n",     "nzzzv")
map("n", "N",     "Nzzzv")

-- ── File tree ────────────────────────────────────────────────
map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file tree" })

-- ── Fuzzy finder ─────────────────────────────────────────────
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>",  { desc = "Find files" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>",   { desc = "Live grep" })
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>",     { desc = "Find buffers" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>",    { desc = "Recent files" })

-- ── Diagnostics ──────────────────────────────────────────────
map("n", "[d", vim.diagnostic.goto_prev,  { desc = "Prev diagnostic" })
map("n", "]d", vim.diagnostic.goto_next,  { desc = "Next diagnostic" })
map("n", "<leader>d", vim.diagnostic.open_float, { desc = "Open diagnostic" })
