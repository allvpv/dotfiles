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
        vim.api.nvim_buf_set_name(0, 'shell:'..termnum)
    end
})

vim.api.nvim_create_autocmd('TermClose', {
    callback = function(args)
        if termcnt == nil then
            return
        end

        local name = args.file -- shell:/num/

        if name ~= nil then
            local split = vim.split(name, ':', true)

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

-- At some point I should move all LSP-related things to separate file
vim.api.nvim_create_user_command('Fmt', function() vim.lsp.buf.format() end, {})

vim.api.nvim_exec([[
    fu AutoCd(directory) abort
        exe 'lcd '..a:directory
    endfu
]], {})
