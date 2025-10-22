--------------------
--> Autocommands
--------------------
-- Save buffer view for every window
function SaveWinViewForBuffer()
    local bufnr = vim.api.nvim_get_current_buf()
    local view = vim.fn.winsaveview()

    if vim.w.saved_buffer_position == nil then
        vim.w.saved_buffer_position = {}
    end

    vim.w.saved_buffer_position[bufnr] = view
end

-- Restore buffer view for every window
function RestoreWinViewForBuffer()
    local bufnr = vim.api.nvim_get_current_buf()
    local view = vim.fn.winsaveview()

    if vim.w.saved_buffer_position ~= nil then
        local view = vim.w.saved_buffer_position[bufnr]

        if view ~= nil then
            vim.fn.winrestview(view)
            vim.w.saved_buffer_position[bufnr] = nil
        end
    end
end

vim.api.nvim_create_autocmd('TermOpen', {
    callback = function(args)
        vim.opt_local.winfixheight = true -- Don't resize terminal automatically
        vim.cmd [[ startinsert ]] -- Start terminal mode when opening new one
        vim.opt_local.number = false -- No line numbers in terminal

        if termcnt == nil then
            termcnt = {}
        end

        local termnum = 0

        while termcnt[termnum] ~= nil do
            termnum = termnum + 1
        end

        termcnt[termnum] = 1
        vim.api.nvim_buf_set_name(0, 'term://'..termnum)
    end
})

vim.api.nvim_create_autocmd('TermClose', {
    callback = function(args)
        if termcnt == nil then
            return
        end

        local name = args.file -- term://<num>

        if name ~= nil then
            local split = vim.split(name, '//', true)

            if split[2] ~= nil then
                local termnum = tonumber(split[2])
                termcnt[termnum] = nil
            end
        end

    end
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd('BufReadPost', {
  command = [[ if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif ]]
})

-- Auto save file on every change
vim.api.nvim_create_autocmd({'TextChanged', 'TextChangedI'}, {
  command = 'silent! write'
})

vim.api.nvim_create_autocmd('BufEnter', {
    callback = RestoreWinViewForBuffer
})

vim.api.nvim_create_autocmd('BufLeave', {
    callback = SaveWinViewForBuffer
})

-- Automatically clean whitespaces on save
vim.api.nvim_create_autocmd("BufWritePre", {
  command = [[ %s/\s\+$//e ]],
})

---------------------
--> User commands <--
---------------------
-- Use Escape in terminal to exit terminal mode
function MapEscapeInTerminal()
    vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]])
end

function UnmapEscapeInTerminal()
    vim.keymap.del('t', '<Esc>')
end

-- Not very convenient, but sometimes needed. Unmap (with ':L') and remap (with ':U') <Esc> in
-- terminal mode to be able to use nested Vim running inside terminal buffer
vim.api.nvim_create_user_command('L', UnmapEscapeInTerminal, {})
vim.api.nvim_create_user_command('U', MapEscapeInTerminal, {})

MapEscapeInTerminal()

-- https://neovim.io/doc/user/terminal.html#terminal-events
vim.api.nvim_create_autocmd({ 'TermRequest' }, {
  desc = 'Handles OSC 7 dir change requests',
  callback = function(ev)
    if string.sub(vim.v.termrequest, 1, 4) == '\x1b]7;' then
      local dir = string.gsub(vim.v.termrequest, '\x1b]7;file://[^/]*', '')
      if vim.fn.isdirectory(dir) == 0 then
        vim.notify('invalid dir: '..dir)
        return
      end
      vim.api.nvim_buf_set_var(ev.buf, 'osc7_dir', dir)
      if vim.o.autochdir and vim.api.nvim_get_current_buf() == ev.buf then
        vim.cmd.cd(dir)
      end
    end
  end
})

vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter', 'DirChanged' }, {
  callback = function(ev)
    if vim.b.osc7_dir and vim.fn.isdirectory(vim.b.osc7_dir) == 1 then
      vim.cmd.cd(vim.b.osc7_dir)
    end
  end
})

-- :CopyPathBasename copies the file basename to clipboard
-- :CopyPath copies the full file path
vim.api.nvim_create_user_command('CopyPathBasename', [[let @*=expand("%")]], {})
vim.api.nvim_create_user_command('CopyPath', [[let @*=expand("%:p")]], {})
