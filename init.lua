-- ------------------------------------------------------ --
-- ╔════════════════════════════════════════════════════╗ --
-- ║ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ║ --
-- ║ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ║ --
-- ║ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ║ --
-- ║ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ║ --
-- ║ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ║ --
-- ║ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ║ --
-- ╚════════════════════════════════════════════════════╝ --
-- ------------------------------------------------------ --

-- Bootstrap lazy.nvim -------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    lazyrepo, lazypath
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Leader keys ---------------------------------------------------------------
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- xsel for clipboard --------------------------------------------------------
vim.g.clipboard = {
  name = 'xsel',
  copy = {
    ['+'] = 'xsel --clipboard --input',
    ['*'] = 'xsel --primary --input',
  },
  paste = {
    ['+'] = 'xsel --clipboard --output',
    ['*'] = 'xsel --primary --output',
  },
  cache_enabled = 0,
}

-- Statusline ----------------------------------------------------------------
vim.o.statusline = table.concat({
  " %<%F",
  " %=",
  "%{&expandtab ? 'spaces:' . &shiftwidth : 'tabs:' . &tabstop}",
  " %5l / %2L ",
})

-- Basic settings ------------------------------------------------------------
vim.o.number = true
vim.o.cursorcolumn = true
vim.o.cursorline = true
vim.o.relativenumber = true
vim.o.showmatch = true
vim.o.wrap = false
vim.o.smartcase = true
vim.o.ignorecase = true
vim.o.hlsearch = true
vim.o.scrolloff = 5
vim.o.expandtab = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.clipboard = "unnamedplus"

-- Better up/down ------------------------------------------------------------
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Turn the line bar red when recording a macro ------------------------------
local macro_group = vim.api.nvim_create_augroup("macro", { clear = true })
local cursorline = nil

local function get_hl_color(name, key) -- helper function to reliably get the theme's red color
  local hl = vim.api.nvim_get_hl(0, { name = name })
  local color = hl[key]

  if color then
    return string.format("#%06x", color)
  elseif hl.link then
    return get_hl_color(hl.link, key)
  end

  return nil 
end

vim.api.nvim_create_autocmd("RecordingEnter", { -- change the line to red
  group = macro_group,
  callback = function()
    local theme_red = get_hl_color("Error", "fg")
    local recording_color = theme_red or "#cc241d" 
    local text_color = theme_background or "#1d2021"
    cursorline = vim.api.nvim_get_hl(0, { name = "CursorLine" })
    vim.api.nvim_set_hl(0, "CursorLine", { bg = recording_color, fg = text_color })
  end,
})

vim.api.nvim_create_autocmd("RecordingLeave", { -- restore the original line color
  group = macro_group,
  callback = function()
    if cursorline then
      vim.api.nvim_set_hl(0, "CursorLine", cursorline)
    end
  end,
})

-- ----------------------------------------------------------- --
-- ╔═════════════════════════════════════════════════════════╗ --
-- ║ ██████╗ ██╗     ██╗   ██╗ ██████╗ ██╗███╗   ██╗███████╗ ║ --
-- ║ ██╔══██╗██║     ██║   ██║██╔════╝ ██║████╗  ██║██╔════╝ ║ --
-- ║ ██████╔╝██║     ██║   ██║██║  ███╗██║██╔██╗ ██║███████╗ ║ --
-- ║ ██╔═══╝ ██║     ██║   ██║██║   ██║██║██║╚██╗██║╚════██║ ║ --
-- ║ ██║     ███████╗╚██████╔╝╚██████╔╝██║██║ ╚████║███████║ ║ --
-- ║ ╚═╝     ╚══════╝ ╚═════╝  ╚═════╝ ╚═╝╚═╝  ╚═══╝╚══════╝ ║ --
-- ╚═════════════════════════════════════════════════════════╝ --
-- ----------------------------------------------------------- --

require("lazy").setup({
  spec = {
    "psliwka/vim-smoothie",
    "tpope/vim-sleuth",

    {
      "sonph/onehalf",
      priority = 1000,
      config = function()
        vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/onehalf/vim")
        vim.cmd.colorscheme("onehalfdark")
      end,
    },

    {
      "numToStr/Comment.nvim",
      dependencies = { "nvim-treesitter/nvim-treesitter" },
      config = function()
        local comment = require("Comment")
        local api = require("Comment.api")

        comment.setup()

        -- Keymap <C-\> for intelligent commenting
        vim.keymap.set("n", "<C-\\>", function()
          local count = vim.v.count1
          for _ = 1, count do
            api.toggle.linewise.current()
            vim.cmd("normal! j")
          end
        end, { noremap = true, silent = true, desc = "Toggle comment line(s)" })

        vim.keymap.set("x", "<C-\\>", function()
          local esc = vim.api.nvim_replace_termcodes("<ESC>", true, false, true)
          vim.api.nvim_feedkeys(esc, "nx", false)
          api.toggle.linewise(vim.fn.visualmode())
          vim.cmd("normal! j")
        end, { noremap = true, silent = true, desc = "Toggle comment selection" })

        vim.keymap.set("i", "<C-\\>", function()
          vim.cmd("stopinsert")
          api.toggle.linewise.current()
          vim.cmd("normal! jA")
        end, { noremap = true, silent = true, desc = "Toggle comment from insert" })
      end,
    },


    {
      "andrewferrier/wrapping.nvim",
      config = function()
        require("wrapping").setup({
          softener = { markdown = true, text = true },
          create_keymaps = true,
          keymaps = {
            motion = true,
            text_obj = true,
          },
        })
      end,
    },

    {
      "nvim-telescope/telescope.nvim",
      tag = "0.1.8",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        local telescope = require("telescope")
        local builtin = require("telescope.builtin")

        telescope.setup({
          defaults = {
            prompt_prefix = "🔍 ",
            selection_caret = " ",
            sorting_strategy = "ascending",
            layout_config = {
              prompt_position = "top",
            },
            mappings = {
              i = {
                ["<C-j>"] = "move_selection_next",
                ["<C-k>"] = "move_selection_previous",
              },
            },
          },
        })

        -- Keymaps for quick access
        local map = vim.keymap.set
        map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
        map("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
        map("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
        map("n", "<leader>fh", builtin.help_tags, { desc = "Find help" })
      end,
    },

    {
      "folke/snacks.nvim",
      opts = {
        indent = { enabled = true },
        input = { enabled = true },
        notifier = { enabled = false },
        scope = { enabled = true },
        statuscolumn = { enabled = false },
        words = { enabled = true },
      },
    },
      
    {
      "nvim-lualine/lualine.nvim",
      config = function()
        vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/onehalf/vim")
        local config = {
          options = {
            component_separators = "",
            section_separators = "",
          },
          sections = {
            lualine_a = {
              {
                "mode",
                fmt = function(s)
                  local map = {
                    NORMAL = "N", INSERT = "I", VISUAL = "V", ["V-LINE"] = "VL",
                    REPLACE = "R", COMMAND = "!", TERMINAL = "T",
                  }
                  return map[s] or s
                end,
              },
            },
            lualine_b = {
              { "branch", icon = "" },
            },
            lualine_c = {
              { "filename", path = 1 },
            },
            lualine_x = {
              { "diagnostics", sources = { "nvim_diagnostic" } },
              {
                function()
                  return "lines:" .. vim.api.nvim_buf_line_count(0)
                end,
              },
              { "progress" },   -- percentage through the file
              { "location" },   -- current line:column
              { "fileformat", fmt = string.upper },
            },
            lualine_y = {},
            lualine_z = {},
          },
          inactive_sections = {
            lualine_a = {}, lualine_b = {}, lualine_y = {},
            lualine_z = {}, lualine_c = {}, lualine_x = {},
          },
        }

        require("lualine").setup(config)
      end,
    },
    -- end of plugins
  },

  -- General lazy.nvim settings
  checker = { enabled = true, notify = false },
  change_detection = { enabled = true, notify = false },
  ui = { wrap = true },
})
