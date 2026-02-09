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

        -- Configuration Variables
        local small_step_duration = 250
        local mid_step_duration = 325
        local full_step_duration = 425
        local max_step_duration = 600
        local easing_profile = 'circular'

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
          neoscroll.scroll(-get_small_step(), { move_cursor = true, duration = small_step_duration, easing = easing_profile })
        end)
        vim.keymap.set("n", "<C-e>", function()
          neoscroll.scroll(get_small_step(), { move_cursor = true, duration = small_step_duration, easing = easing_profile })
        end)

        -- bind ^d and ^u (1/3 page)
        vim.keymap.set("n", "<C-d>", function()
          neoscroll.scroll(get_step(), { move_cursor = true, duration = mid_step_duration, easing = easing_profile })
        end)
        vim.keymap.set("n", "<C-u>", function()
          neoscroll.scroll(-get_step(), { move_cursor = true, duration = mid_step_duration, easing = easing_profile })
        end)

        -- bind ^b and ^f (full page)
        vim.keymap.set("n", "<C-f>", function()
          neoscroll.scroll(get_full_page(), { move_cursor = true, duration = full_step_duration, easing = easing_profile })
        end)
        vim.keymap.set("n", "<C-b>", function()
          neoscroll.scroll(-get_full_page(), { move_cursor = true, duration = full_step_duration, easing = easing_profile })
        end)

        -- ... (inside your config function) ...

        -- Helper to calculate duration for "normal" scrolling behavior
        local get_duration = function(distance, screen_height)
          local ratio = distance / screen_height
          
          -- 1. Small scrolls (< 1/8 screen): Fixed 250ms
          if ratio <= 0.125 then
            return 250
          
          -- 2. Medium scrolls (1/8 to 1 screen): Scale 250 -> 425ms
          elseif ratio <= 1.0 then
            return math.floor(250 + (ratio - 0.125) * (425 - 250) / (1.0 - 0.125))
          
          -- 3. Large scrolls (> 1 screen): Scale 425 -> 600ms (capped at 3 screens)
          else
            return math.floor(425 + math.min(1, (ratio - 1.0) / 2.0) * (600 - 425))
          end
        end

        local smart_jump = function(target_line)
          local total_lines = vim.fn.line('$')
          -- Clamp target to valid lines
          target_line = math.max(1, math.min(target_line, total_lines))

          local current_line = vim.fn.line('.')
          local diff = target_line - current_line
          local abs_diff = math.abs(diff)
          local screen_height = vim.api.nvim_win_get_height(0)

          if abs_diff == 0 then return end

          -- CASE A: Small jump (< 2 screens) -> Animate the whole way
          if abs_diff < screen_height * 2 then
             local duration = get_duration(abs_diff, screen_height)
             neoscroll.scroll(diff, { move_cursor = true, duration = duration, easing = 'circular' })
          
          -- CASE B: Huge jump -> Teleport then slide
          else
             -- We "land" 1/2 screen away to give a nice settling effect
             local land_distance = screen_height * 3
             local duration = 600 -- Fixed short duration for the landing slide

             if diff > 0 then
                -- Jumping DOWN: Teleport slightly ABOVE target
                local teleport_line = target_line - land_distance
                vim.api.nvim_win_set_cursor(0, { teleport_line, 0 })
                neoscroll.scroll(land_distance, { move_cursor = true, duration = duration, easing = 'circular' })
             else
                -- Jumping UP: Teleport slightly BELOW target
                local teleport_line = target_line + land_distance
                vim.api.nvim_win_set_cursor(0, { teleport_line, 0 })
                neoscroll.scroll(-land_distance, { move_cursor = true, duration = duration, easing = 'circular' })
             end
          end
        end

        -- Helper for j/k scrolloff logic
        local move_with_scrolloff = function(direction)
          local count = vim.v.count
          if count == 0 then
            vim.cmd("normal! " .. direction)
            return
          end

          local current_line = vim.fn.line('.')
          local target_line
          if direction == "j" then
            target_line = current_line + count
          else
            target_line = current_line - count
          end
          
          -- Clamp target so we don't error out
          target_line = math.max(1, math.min(target_line, vim.fn.line('$')))

          -- Check if target is visible within scrolloff limits
          local scrolloff = vim.wo.scrolloff
          local top_limit = vim.fn.line('w0') + scrolloff
          local bottom_limit = vim.fn.line('w$') - scrolloff
          
          local is_visible = (target_line >= top_limit and target_line <= bottom_limit)

          if is_visible then
            vim.cmd("normal! " .. count .. direction)
          else
            smart_jump(target_line)
          end
        end

        -- Bindings
        vim.keymap.set("n", "j", function() move_with_scrolloff("j") end, { silent = true })
        vim.keymap.set("n", "k", function() move_with_scrolloff("k") end, { silent = true })
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
