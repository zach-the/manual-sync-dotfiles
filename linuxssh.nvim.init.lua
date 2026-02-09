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
-- vim.g.clipboard = {
  -- name = 'xsel',
  -- copy = {
    -- ['+'] = 'xsel --clipboard --input',
    -- ['*'] = 'xsel --primary --input',
  -- },
  -- paste = {
    -- ['+'] = 'xsel --clipboard --output',
    -- ['*'] = 'xsel --primary --output',
  -- },
  -- cache_enabled = 0,
-- }

-- Statusline ----------------------------------------------------------------
vim.o.statusline = table.concat({
  " %<%F",
  " %=",
  "%{&expandtab ? 'spaces:' . &shiftwidth : 'tabs:' . &tabstop}",
  " %5l / %2L ",
})

-- Basic settings ------------------------------------------------------------
vim.o.number = true
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
-- vim.o.clipboard = "unnamedplus"
vim.o.termguicolors = true
vim.o.cursorline = true
vim.o.cursorcolumn = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Better up/down ------------------------------------------------------------
vim.keymap.set({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
vim.keymap.set({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- Scroll 1/3 of the page instead of 1/2 fo the page -------------------------
vim.keymap.set('n', '<C-d>', function()
  local step = math.floor(vim.api.nvim_win_get_height(0) / 3)
  return step .. '<C-d>'
end, { expr = true, replace_keycodes = true })
vim.keymap.set('n', '<C-u>', function()
  local step = math.floor(vim.api.nvim_win_get_height(0) / 3)
  return step .. '<C-u>'
end, { expr = true, replace_keycodes = true })

-- Make macro recording purple -----------------------------------------------
-- Create the group for our autocommands
local macro_group = vim.api.nvim_create_augroup("macro", { clear = true })

-- Helper to get colors safely
local function get_hl_color(name, key)
  local hl = vim.api.nvim_get_hl(0, { name = name })
  if not hl or vim.tbl_isempty(hl) then return nil end
  
  local color = hl[key]
  if color then
    return string.format("#%06x", color)
  elseif hl.link then
    return get_hl_color(hl.link, key)
  end
  return nil 
end

vim.api.nvim_create_autocmd("RecordingEnter", {
  group = macro_group,
  callback = function()
    local text_color = get_hl_color("Normal", "fg") or "#1d2021"
    vim.api.nvim_set_hl(0, "MacroLine", { bg = "#c678dd", fg = text_color, bold = true })
    vim.opt_local.winhighlight = "CursorLine:MacroLine"
  end,
})

vim.api.nvim_create_autocmd("RecordingLeave", {
  group = macro_group,
  callback = function()
    -- Simply remove the window override. 
    -- Neovim falls back to the standard (transparent) CursorLine.
    vim.opt_local.winhighlight = ""
  end,
})

-- Normal/Visual Mode: Move line/block up/down ------------------------------
vim.keymap.set('n', '<S-j>', ':m .+1<CR>==', { silent = true })
vim.keymap.set('n', '<S-k>', ':m .-2<CR>==', { silent = true })
vim.keymap.set('v', '<S-j>', ":m '>+1<CR>gv=gv", { silent = true })
vim.keymap.set('v', '<S-k>', ":m '<-2<CR>gv=gv", { silent = true })

-- Make matches blue --------------------------------------------------------
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "CurSearch", { bg = "#61afef", fg = "#dcdfe4" })
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
    "tpope/vim-sleuth",

    {
      "karb94/neoscroll.nvim",
      config = function()
        local neoscroll = require("neoscroll")
        neoscroll.setup({})

        local get_step = function()
          return math.floor(vim.api.nvim_win_get_height(0) * 4 / 9)
        end
        
        local get_small_step = function()
          return math.floor(vim.api.nvim_win_get_height(0) * 1 / 8)
        end

        local get_full_page = function()
          return vim.api.nvim_win_get_height(0)
        end

        -- bind ^e and ^y (small step)
        vim.keymap.set("n", "<C-y>", function()
          neoscroll.scroll(-get_small_step(), { move_cursor = true, duration = 250, easing = 'circular' })
        end)
        vim.keymap.set("n", "<C-e>", function()
          neoscroll.scroll(get_small_step(), { move_cursor = true, duration = 250, easing = 'circular' })
        end)

        -- bind ^d and ^u (1/2 page)
        vim.keymap.set("n", "<C-d>", function()
          neoscroll.scroll(get_step(), { move_cursor = true, duration = 325, easing = 'circular' })
        end)
        vim.keymap.set("n", "<C-u>", function()
          neoscroll.scroll(-get_step(), { move_cursor = true, duration = 325, easing = 'circular' })
        end)

        -- bind ^b and ^f (full page)
        vim.keymap.set("n", "<C-f>", function()
          neoscroll.scroll(get_full_page(), { move_cursor = true, duration = 425, easing = 'circular' })
        end)
        vim.keymap.set("n", "<C-b>", function()
          neoscroll.scroll(-get_full_page(), { move_cursor = true, duration = 425, easing = 'circular' })
        end)

        local get_dynamic_duration = function(abs_diff, screen_height)
          local ratio = abs_diff / screen_height
        
          if ratio <= 0.125 then -- Less than 1/8 screen
            return 250
          elseif ratio <= 1.0 then -- Between 1/8 and 1 full screen
            -- Scale 250ms (at 0.125) to 425ms (at 1.0)
            -- Formula: min + (ratio - min_ratio) * (max - min) / (max_ratio - min_ratio)
            return math.floor(250 + (ratio - 0.125) * (425 - 250) / (1.0 - 0.125))
          else -- Greater than 1 full screen
            -- Scale 425ms (at 1.0) to 600ms (at 3.0)
            -- We'll let it keep scaling past 600ms if the jump is even larger
            return math.floor(425 + (ratio - 1.0) * (600 - 425) / (3.0 - 1.0))
          end
        end
        
        local smart_jump = function(target_line)
          local total_lines = vim.fn.line('$')
          target_line = math.max(1, math.min(target_line, total_lines))
        
          local current_line = vim.fn.line('.')
          local diff = target_line - current_line
          local abs_diff = math.abs(diff)
          local screen_height = vim.api.nvim_win_get_height(0)
        
          if abs_diff == 0 then return end
        
          -- Calculate dynamic duration based on distance
          local duration = get_dynamic_duration(abs_diff, screen_height)
        
          if abs_diff < screen_height * 2 then
            neoscroll.scroll(diff, { move_cursor = true, duration = duration, easing = 'circular' })
          else
            -- For huge jumps, we use the "Teleport + Slide" logic
            -- We'll use a fixed 600ms or higher for the slide portion
            local close_snap = screen_height * 4
            local teleport_line
            
            if diff > 0 then
              teleport_line = math.max(1, target_line - close_snap)
              vim.api.nvim_win_set_cursor(0, { teleport_line, 0 })
              neoscroll.scroll(target_line - teleport_line, { move_cursor = true, duration = math.max(600, duration), easing = 'circular' })
            else
              teleport_line = math.min(total_lines, target_line + close_snap)
              vim.api.nvim_win_set_cursor(0, { teleport_line, 0 })
              neoscroll.scroll(target_line - teleport_line, { move_cursor = true, duration = math.max(600, duration), easing = 'circular' })
            end
          end
        end       
        -- Reusable helper to handle j/k logic
        local move_with_scrolloff = function(direction)
          local count = vim.v.count
          if count > 0 then
            local target_line = (direction == "j") and (vim.fn.line('.') + count) or (vim.fn.line('.') - count)
            local scrolloff = vim.wo.scrolloff
            
            -- Check boundaries relative to viewport + scrolloff
            local is_on_screen = false
            if direction == "j" then
              is_on_screen = target_line <= (vim.fn.line('w$') - scrolloff)
            else
              is_on_screen = target_line >= (vim.fn.line('w0') + scrolloff)
            end
        
            if is_on_screen then
              vim.cmd("normal! " .. count .. direction)
            else
              smart_jump(target_line)
            end
          else
            vim.cmd("normal! " .. direction)
          end
        end
        
        -- Clean Keybinds
        vim.keymap.set("n", "j", function() move_with_scrolloff("j") end, { silent = true })
        vim.keymap.set("n", "k", function() move_with_scrolloff("k") end, { silent = true })

        -- bind gg and G
        vim.keymap.set("n", "gg", function() smart_jump(1) end)
        vim.keymap.set("n", "G", function() smart_jump(vim.fn.line('$')) end)
      end,
    },

    {
      "sonph/onehalf",
      priority = 1000,
      config = function()
        vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/onehalf/vim")
        vim.cmd.colorscheme("onehalfdark")
      end,
    },


    {
      'tribela/transparent.nvim',
      event = 'VimEnter',
      config = function()
        require('transparent').setup({
          exclude_groups = { "CursorLine" },
        })
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
        -- indent = { enabled = true }, -- this is the one that creates the long vertical pipes
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
              {
                "filename",
                path = 2, -- Absolute path (as discussed)
                
                -- Dynamic color logic
                color = function()
                  -- Check if the buffer is modified
                  local is_modified = vim.bo.modified
                  
                  -- Return specific hex color if modified, otherwise use default (nil)
                  -- '#ff9e64' is a bright orange. You can change this to any hex code.
                  return { fg = is_modified and "#e06c75" or nil, gui = is_modified and "bold" or nil }
                end,
              },
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
