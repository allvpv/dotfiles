" ===================
"  => Basic setup
" ====================

" Sets how many lines of history VIM has to remember
set history=10000

" Enable support for: plugins specific to filetype
filetype plugin on
"
" Enable support for: indentation specific to filetype
filetype indent on

" Set to auto read when a file is changed from the outside
set autoread

" Turn on the WiLd menu
set wildmenu
set wildmode=full

" By default, Vim’s backspace option is set to an empty list.
" indent: Vim will allow you to backspace over indentation
" eol: You can backspace over an end of line
" start: You can backspace past the position where you started Insert mode
set backspace=eol,start,indent

" By default, when pressing h/l keys, Vim won't move to the previous/next line
" < > are the cursor keys used in normal and visual mode
" [ ] are the cursor keys in insert mode
set whichwrap+=<,>,h,l

" Highlight search results
set hlsearch

" Search dynamically while typing
set incsearch

" Don't redraw while executing macros (good performance config)
set lazyredraw

" Show matching brackets when text indicator is over them
let loaded_matchparen=1

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Don't display line numbers
set number

" Enable syntax highlighting
syntax enable

" Enable truecolor palette in TMUX
set termguicolors

" Enable mouse in every mode (always)
set mouse=a

" Turn backup off
set nobackup
set nowritebackup
set nowb
set noswapfile

" Use spaces instead of tabs
set expandtab

" General setting: 1 tab => 2 spaces
set shiftwidth=2
set tabstop=2

" Don't break lines automatically
set nolinebreak
set textwidth=80

set wrapmargin=0

" Indent automatical and language sensitive
set autoindent
set smartindent

" Don't wrap lines automatically
set nowrap

" Show the status line when only one window is open
set laststatus=2

" Synchronize clipboard with default register
set clipboard^=unnamedplus

" Preview of differences in search&replace command :s
set inccommand=split

" Case-insensitive search (when pattern is lowercase)
set ignorecase
set smartcase
" Alternatives:
" set ignorecase
" set noignorecase

" Automatically change working directory to current file directory
set autochdir

" Minimal number of screen lines to keep above and below the cursor -- 4 lines
set scrolloff=4

" New window below actual
set splitbelow

" Prevent windows resize
set noequalalways

" ====================
"  => Filetype specific
" ====================

autocmd FileType netrw setl bufhidden=delete

autocmd FileType python,c,cpp,java,asm setl number
autocmd FileType c,cpp,java set shiftwidth=4 tabstop=4
autocmd FileType tex,latex set shiftwidth=2 tabstop=2

autocmd FileType tex setlocal textwidth=120

augroup TerminalStuff
  autocmd!
  " Insert mode when entering terminal
  autocmd TermOpen  * startinsert
  autocmd TermOpen  * set winfixheight
  autocmd TermOpen  * setlocal nonumber
  autocmd BufLeave term://* call AutoSaveWinView()
  autocmd BufEnter term://* call AutoRestoreWinView()
augroup END


" ====================
"  => Hacks
" ====================

if has('macunix')
  let g:python3_host_prog = '/opt/homebrew/bin/python3'
end

" Return to last edit position when opening files
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif

" Ignore compiled files
set wildignore=*.o,*~,*.pyc,*/.git/*,*/.hg/*,*/.svn/*,*/.DS_Store

" AutoSave
autocmd TextChanged,TextChangedI * silent! write

" ====================
"  => Mappings
" ====================

" Set "," as key leader
let mapleader = ","

" Visual mode pressing * or # searches for the current selection
vnoremap <silent> * :<C-u>call VisualSelection('', '')<CR>/<C-R>=@/<CR><CR>

" Turn off search highlight by pressing <D-N>
noremap <D-n> :noh<cr>
tnoremap <D-n> <Esc>:noh<cr>

noremap <Space>/ :vsplit<cr><C-W>l
noremap <Space>- :split<cr><C-W>j
noremap <M-/> :vsplit<cr><C-W>l

" <C-h,j,k,l> to move between windows
noremap <C-h> <C-W>h
noremap <C-j> <C-W>j
noremap <C-k> <C-W>k
noremap <C-l> <C-W>l

" <Space>c or <C-c> closes window
map <Space>c <C-W>c
map <C-c> <C-W>c

" <D-Shift-=> makes windows equal in size
map <C-=> <C-W>=

" delete without yanking
nnoremap ,d "_d
vnoremap ,d "_d
" replace currently selected text with default register
" without yanking it
vnoremap ,p "_dP

" Allow buffer switching without saving
set hidden

" Plugin-specific mappings
"
" <D-c> to close buffer; uses function suited for vem-tabline
nmap <D-c> :Bclose<CR>
"
nmap <D-k> <Plug>vem_prev_buffer-
nmap <D-j> <Plug>vem_next_buffer-
tmap <D-k> <Esc><Plug>vem_prev_buffer-
tmap <D-j> <Esc><Plug>vem_next_buffer-

nmap <D-C-k> <Plug>vem_move_buffer_left-
nmap <D-C-j> <Plug>vem_move_buffer_right-

let g:ctrlp_map = '<D-p>'
tmap <D-p> <Esc>:CtrlP<CR>

nmap <D-x> :Fern .<CR>
tmap <D-x> <Esc>:Fern .<CR>

nmap <space>v :VenterToggle<CR>

" Use Escape in terminal to exit insert mode
tnoremap <Esc> <C-\><C-n>

" Unmap (and remap) <Esc> in terminal mode in order to make nested Vim usable
" inside terminal buffer
command! L tunmap <Esc>
command! U tnoremap <Esc> <C-\><C-N>

" Clear terminal buffer
nmap <D-T> :set scrollback=1 \| sleep 100m \| set scrollback=10000<cr>

nmap <D-e> <C-e>
nmap <D-y> <C-y>

" +/- fontsize
map <D-=> :ResizeFontBigger<cr>
map <D--> :ResizeFontSmaller<cr>

" ====================
"  => Custom functions and commands
" ====================

" Don't close window, when deleting a buffer
command! Bclose call <SID>BufcloseCloseIt()

function! <SID>BufcloseCloseIt()
    let l:currentBufNum = bufnr("%")
    let l:alternateBufNum = g:vem_tabline#tabline.get_replacement_buffer()

    if l:alternateBufNum != 0
        exec l:alternateBufNum . 'buffer'
    endif

    if bufnr("%") == l:currentBufNum
        enew
    endif

    if buflisted(l:currentBufNum)
        execute("bdelete! " . l:currentBufNum)
    endif
endfunction

" Delete trailing white space (useful for some filetypes)
command! CleanWhites call CleanWhites()

" Execute coc.nvim specific mappings (see function below)
command! CocMappings call CocMappings()

fun! CleanWhites()
  let save_cursor = getpos(".")
  let old_query = getreg('/')
  silent! %s/\s\+$//e
  call setpos('.', save_cursor)
  call setreg('/', old_query)
endfun


" This function is specific for terminal buffer type (see TerminalStuff
" augroup).  Save current view settings on a per-window, per-buffer basis.
function! AutoSaveWinView()
    if !exists("w:SavedBufView")
        let w:SavedBufView = {}
    endif
    let w:SavedBufView[bufnr("%")] = winsaveview()
endfunction

" This function is specific for terminal buffer type (see TerminalStuff
" augroup). Restore current view settings on a per-window, per-buffer basis.
function! AutoRestoreWinView()
    let buf = bufnr("%")
    if exists("w:SavedBufView") && has_key(w:SavedBufView, buf)
        let v = winsaveview()
        let atStartOfFile = v.lnum == 1 && v.col == 0
        if atStartOfFile && !&diff
            call winrestview(w:SavedBufView[buf])
        endif
        unlet w:SavedBufView[buf]
    endif
endfunction

command! Term :call SpawnTerm()

function! SpawnTerm()
  if !exists("g:termcnt")
    let g:termcnt=1
  else
    let g:termcnt+=1
  endif

  exec ":terminal"
  exec ":file shell:" . g:termcnt
endfunction

function! VisualSelection(direction, extra_filter) range
    let l:saved_reg = @"
    execute "normal! vgvy"

   let l:pattern = escape(@", "\\/.*'$^~[]")
    let l:pattern = substitute(l:pattern, "\n$", "", "")

    if a:direction == 'gv'
        call CmdLine("Ack '" . l:pattern . "' " )
    elseif a:direction == 'replace'
        call CmdLine("%s" . '/'. l:pattern . '/')
    endif

    let @/ = l:pattern
    let @" = l:saved_reg
endfunction

command! Cdc :cd %:p:h


" Use `vim-alias` plugin for more convinient user-defined command typing
"
"
if exists('s:loaded_vimafter')
  silent doautocmd VimAfter VimEnter *
else
  let s:loaded_vimafter = 1
  augroup VimAfter
    autocmd!
    autocmd VimEnter * Alias man Man
    autocmd VimEnter * Alias ren Rename
    autocmd VimEnter * Alias rm Delete
    autocmd VimEnter * Alias term Term
    autocmd VimEnter * Alias bclose Bclose
    autocmd VimEnter * Alias cleanwhites CleanWhites
    autocmd VimEnter * Alias cdc Cdc
  augroup END
endif


" =============================================================================
"  => Plugins installation and configuration
" =============================================================================

" Specify a directory for plugins
call plug#begin('~/.config/nvim/plugins')

" GfCD ui
Plug 'allvpv/resize-font.nvim'

" Colorschemes
Plug 'aseom/snowcake16'
Plug 'morhetz/gruvbox'
Plug 'drewtempelmeyer/palenight.vim'
Plug 'Rigellute/shades-of-purple.vim'
Plug 'cocopon/iceberg.vim'
Plug 'arcticicestudio/nord-vim'
Plug 'rakr/vim-one'
Plug 'huyvohcmc/atlas.vim'
Plug 'Lokaltog/vim-monotone'
Plug 'lifepillar/vim-solarized8'
Plug 'liuchengxu/space-vim-theme'
Plug 'whatyouhide/vim-gotham'
Plug 'dracula/vim'

" Usability plugins
Plug 'pacha/vem-tabline'
Plug 'itchyny/lightline.vim'
Plug 'ryanoasis/vim-devicons'
Plug 'lambdalisue/fern.vim'
Plug 'lambdalisue/nerdfont.vim'
Plug 'lambdalisue/fern-renderer-nerdfont.vim'
Plug 'Konfekt/vim-alias'
Plug 'jmckiern/vim-venter'
Plug 'junegunn/goyo.vim'
Plug 'SirVer/ultisnips'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-eunuch' " rename, remove file, etc.

" Autocomplete + IDE
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Filetype
Plug 'dag/vim-fish'
Plug 'arrufat/vala.vim'
Plug 'vim-scripts/aspvbs.vim'
Plug 'bilalq/lite-dfm'
Plug 'antoinemadec/FixCursorHold.nvim'
Plug 'ripxorip/bolt.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'arzg/vim-substrata'
Plug 'tpope/vim-fugitive'
Plug 'jocap/rich.vim'
Plug 'lervag/vimtex'
Plug 'ziglang/zig.vim'

" Initialize plugin system and set colorscheme
call plug#end()

" Options 'lineinfo', 'column': use logical instead of physical columun
let g:lightline = {}
let g:lightline.component = {
    \      'lineinfo': '%3l:%-2v',
    \      'column': '%v'
    \      }

" Do not use built-in lightline tabline (`vem-tabline` changing order of buffers
" on tabline)
let g:lightline.enable = {
    \ 'statusline': 1,
    \ 'tabline': 0
    \ }

" ctrlpvim/ctrlp.vim
let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_cmd = 'CtrlPMixed'
" bilalq/lite-dfm
let g:lite_dfm_keep_ruler=1
let g:fern#renderer = "nerdfont"
" Rigellute/shades-of-purple.vim
let g:shades_of_purple_lightline = 1
let g:shades_of_purple_italic=1
let g:shades_of_purple_bold=1
" morhetz/gruvbox
let gruvbox_bold = 1
let gruvbox_italic = 1
let gruvbox_contrast_light = "soft"
" Lokaltog/vim-monoton
let g:monotone_color = [26, 101, 73] " Sets theme color to bright green
let g:monotone_emphasize_comments = 0 " Emphasize comments
" drewtempelmeyer/palenight.vim
let g:palenight_terminal_italics=1
" lervag/vimtex
let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
let g:vimtex_quickfix_mode=0
" SirVer/ultisnips
let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'
let g:UltiSnipsEditSplit="horizontal"

" =============================================================================
"  => Various GUI-specific settings
" =============================================================================

let g:neovide_input_use_logo=v:true
let g:neovide_transparency=0.92
let g:neovide_remember_window_size=v:true

set guifont=Iosevka\ Nerd\ Font\ Mono:h11.5

let g:neovide_cursor_animation_length=0.15
let g:neovide_scroll_animation_length=0.4
let g:neovide_cursor_trail_size=0

" =============================================================================
"  => Coc.nvim recommended settings
" =============================================================================

" Give more space for displaying messages; 2 is recommended, but it takes too
" much space on Macbook sadly.
set cmdheight=1

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved. Additionally, it just looks nice.
set signcolumn=yes

function! CocMappings()
  " Use tab for trigger completion with characters ahead and navigate.
  " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
  " other plugin before putting this into your config.
  inoremap <silent><expr> <TAB>
        \ pumvisible() ? "\<C-n>" :
        \ <SID>check_back_space() ? "\<TAB>" :
        \ coc#refresh()
  inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

  function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
  endfunction

  " Use <c-space> to trigger completion.
  if has('nvim')
    inoremap <silent><expr> <c-space> coc#refresh()
  else
    inoremap <silent><expr> <c-@> coc#refresh()
  endif

  " Make <CR> auto-select the first completion item and notify coc.nvim to
  " format on enter, <cr> could be remapped by other vim plugin
  " inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
  "                               \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

  " Use `[g` and `]g` to navigate diagnostics
  " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
  nmap <silent> [g <Plug>(coc-diagnostic-prev)
  nmap <silent> ]g <Plug>(coc-diagnostic-next)

  " GoTo code navigation.
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gi <Plug>(coc-implementation)
  nmap <silent> gr <Plug>(coc-references)
  nmap <silent> gr <Plug>(coc-references)
  nmap <silent> gh :CocCommand clangd.switchSourceHeader<CR>

  " Use K to show documentation in preview window.
  nnoremap <silent> K :call <SID>show_documentation()<CR>

  function! s:show_documentation()
    if (index(['vim','help'], &filetype) >= 0)
      execute 'h '.expand('<cword>')
    elseif (coc#rpc#ready())
      call CocActionAsync('doHover')
    else
      execute '!' . &keywordprg . " " . expand('<cword>')
    endif
  endfunction

  " Highlight the symbol and its references when holding the cursor.
  autocmd CursorHold * silent call CocActionAsync('highlight')

  " Symbol renaming.
  nmap <leader>rn <Plug>(coc-rename)

  " Formatting selected code.
  xmap <leader>f <Plug>(coc-format-selected)
  nmap <leader>f <Plug>(coc-format-selected)

  augroup mygroup
    autocmd!
    " Setup formatexpr specified filetype(s).
    autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
    " Update signature help on jump placeholder.
    autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
  augroup end

  " Applying codeAction to the selected region.
  " Example: `<leader>aap` for current paragraph
  xmap <leader>a  <Plug>(coc-codeaction-selected)
  nmap <leader>a  <Plug>(coc-codeaction-selected)

  " Remap keys for applying codeAction to the current buffer.
  nmap <leader>ac  <Plug>(coc-codeaction)
  " Apply AutoFix to problem on the current line.
  nmap <leader>qf  <Plug>(coc-fix-current)

  " Map function and class text objects
  " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
  xmap if <Plug>(coc-funcobj-i)
  omap if <Plug>(coc-funcobj-i)
  xmap af <Plug>(coc-funcobj-a)
  omap af <Plug>(coc-funcobj-a)
  xmap ic <Plug>(coc-classobj-i)
  omap ic <Plug>(coc-classobj-i)
  xmap ac <Plug>(coc-classobj-a)
  omap ac <Plug>(coc-classobj-a)

  " Remap <C-f> and <C-b> for scroll float windows/popups.
  if has('nvim-0.4.0') || has('patch-8.2.0750')
    nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
    nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
    inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
    inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
    vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
    vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  endif

  " Use CTRL-S for selections ranges.
  " Requires 'textDocument/selectionRange' support of language server.
  nmap <silent> <C-s> <Plug>(coc-range-select)
  xmap <silent> <C-s> <Plug>(coc-range-select)

  " Add `:Format` command to format current buffer.
  command! -nargs=0 Format :call CocAction('format')

  " Add `:Fold` command to fold current buffer.
  command! -nargs=? Fold :call     CocAction('fold', <f-args>)

  " Add `:OR` command for organize imports of the current buffer.
  command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

  " Add (Neo)Vim's native statusline support.
  " NOTE: Please see `:h coc-status` for integrations with external plugins that
  " provide custom statusline: lightline.vim, vim-airline.
  " set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

  " Mappings for CoCList
  " Show all diagnostics.
  nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
  " Manage extensions.
  nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
  " Show commands.
  "nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
  " Find symbol of current document.
  nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
  " Search workspace symbols.
  nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
  " Do default action for next item.
  nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
  " Do default action for previous item.
  nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
  " Resume latest coc list.
  nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
  " Auto fix.
  nnoremap <silent><nowait> <space>f  :<C-u>CocFix<CR>

endfunction

" =============================================================================
"  => Session-specific settings
" =============================================================================

if g:neovim_session_type == "document"
  set background=light
  let g:lightline.colorscheme = 'iceberg'
  let g:tex_conceal='abdmg'
  set conceallevel=1
  colorscheme iceberg
elseif g:neovim_session_type == "linux_vm"
  set background=dark
  let g:lightline.colorscheme = 'nord'
  colorscheme nord
  call CocMappings()
else
  set background=dark
  let g:lightline.colorscheme = 'dracula'
  colorscheme dracula
  call CocMappings()
endif

