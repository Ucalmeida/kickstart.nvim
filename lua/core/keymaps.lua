-- Set leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Disable the spacebar key's default behavior in Normal and Visual modes
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- For conciseness
local opts = { noremap = true, silent = true }

-- save file
vim.keymap.set('n', '<C-s>', '<cmd> w <CR>', opts)

-- save file without auto-formatting
vim.keymap.set('n', '<leader>sn', '<cmd>noautocmd w <CR>', opts)

-- quit file
vim.keymap.set('n', '<C-q>', '<cmd> q <CR>', opts)

-- delete single character without copying into register
vim.keymap.set('n', 'x', '"_x', opts)

-- Vertical scroll and center
vim.keymap.set('n', '<C-d>', '<C-d>zz', opts)
vim.keymap.set('n', '<C-u>', '<C-u>zz', opts)

-- Find and center
vim.keymap.set('n', 'n', 'nzzzv', opts)
vim.keymap.set('n', 'N', 'Nzzzv', opts)

-- Resize with arrows
vim.keymap.set('n', '<Up>', ':resize -2<CR>', opts)
vim.keymap.set('n', '<Down>', ':resize +2<CR>', opts)
vim.keymap.set('n', '<Left>', ':vertical resize -2<CR>', opts)
vim.keymap.set('n', '<Right>', ':vertical resize +2<CR>', opts)

-- Buffers
vim.keymap.set('n', '<Tab>', ':bnext<CR>', opts)
vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>', opts)
vim.keymap.set('n', '<leader>x', ':bdelete!<CR>', opts) -- close buffer
vim.keymap.set('n', '<leader>b', '<cmd> enew <CR>', opts) -- new buffer

-- Window management
vim.keymap.set('n', '<leader>v', '<C-w>v', opts) -- split window vertically
vim.keymap.set('n', '<leader>h', '<C-w>s', opts) -- split window horizontally
vim.keymap.set('n', '<leader>se', '<C-w>=', opts) -- make split windows equal width & height
vim.keymap.set('n', '<leader>xs', ':close<CR>', opts) -- close current split window

-- Navigate between splits
vim.keymap.set('n', '<C-k>', ':wincmd k<CR>', opts)
vim.keymap.set('n', '<C-j>', ':wincmd j<CR>', opts)
vim.keymap.set('n', '<C-h>', ':wincmd h<CR>', opts)
vim.keymap.set('n', '<C-l>', ':wincmd l<CR>', opts)

-- Tabs
vim.keymap.set('n', '<leader>to', ':tabnew<CR>', opts) -- open new tab
vim.keymap.set('n', '<leader>tx', ':tabclose<CR>', opts) -- close current tab
vim.keymap.set('n', '<leader>tn', ':tabn<CR>', opts) --  go to next tab
vim.keymap.set('n', '<leader>tp', ':tabp<CR>', opts) --  go to previous tab

-- Toggle line wrapping
vim.keymap.set('n', '<leader>lw', '<cmd>set wrap!<CR>', opts)

-- Stay in indent mode
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)

-- Keep last yanked when pasting
vim.keymap.set('v', 'p', '"_dP', opts)

-- Diagnostic keymaps
vim.keymap.set('n', '[d', function()
    vim.diagnostic.jump { count = -1, float = true }
end, { desc = 'Go to previous diagnostic message' })

vim.keymap.set('n', ']d', function()
    vim.diagnostic.jump { count = 1, float = true }
end, { desc = 'Go to next diagnostic message' })

vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- NOTE Compile and execute a C file
local function compile_and_run_c_in_terminal()
    local current_file = vim.fn.expand '%:p' -- Complete path of the current file
    local executable_name = vim.fn.expand '%:t:r' -- File name with out extension
    -- 1. Compile C code
    -- The 'silent' suprime the output of the command in the main buffer of Neovim
    vim.cmd('silent !gcc ' .. current_file .. ' -o ' .. executable_name)

    -- Looking for compilation errors
    if vim.v.shell_error ~= 0 then
        vim.notify('Compilation Error: Verify the exit of the GCC.', vim.log.levels.ERROR)
        return
    end

    -- 2. Open a new Horizontal Split
    vim.cmd 'sp'

    -- Store the buffer number of the newly created terminal
    local term_bufnr = nil

    -- Create a temporary autocommand to capture the buffer number
    -- and potentially send 'i' if the mode isn't correct.
    local temp_term_augroup = vim.api.nvim_create_augroup('TempTermStartup', { clear = true })
    vim.api.nvim_create_autocmd('TermOpen', {
        group = temp_term_augroup,
        once = true,
        callback = function(args)
            term_bufnr = args.buf
            vim.api.nvim_set_current_buf(term_bufnr) -- Switch to the terminal buffer

            -- This is the crucial part:
            -- When `term_open` happens, Neovim should be in Terminal-Job mode (like insert mode).
            -- If it's not, it means it's in Normal mode within the terminal.
            -- We can explicitly send the 'i' key to ensure insert mode, but only if needed.
            -- Let's try sending 'i' explicitly as a `feedkeys` if the mode is Normal after opening.
            -- This is a bit of a workaround if the default 'terminal-job' mode isn't kicking in.

            -- Check the current mode after the terminal opens
            -- This is complex in a direct autocommand.
            -- A simpler approach for the user's observed behavior is to just try sending 'i' if they say it's needed.
            vim.api.nvim_feedkeys('i', 'n', true) -- Sends 'i' key as if typed in Normal mode to enter Insert mode.
            -- The 'n' means Normal mode, 'true' means don't remap.

            -- Clean up the temporary autocommand group
            vim.api.nvim_del_augroup_by_id(temp_term_augroup)
        end,
    })

    -- Run the program in the terminal
    vim.cmd('term ./' .. executable_name)
end
vim.keymap.set('n', '<leader>rc', compile_and_run_c_in_terminal, { desc = 'Run C program in split terminal' })
