vim9script
g:mapleader = ' '

def g:Open_file_tree()
	:25vs %
	:Ex
enddef


def g:Open_file_under_cursor_while_split()
	var ii = expand("<cfile>:p")
	if empty(ii)
		return
	endif
	:wincmd l
	execute "e " .. ii
	:cd %:p:h
enddef

def g:Popup_terminal()
	var winwidth = &columns
	var winheight = &lines
	var termwidth = float2nr(winwidth * 0.8)
	var termheight = float2nr(winheight * 0.8)
	var buftype = &buftype
	var buffer_handler = 0
	var winid = -1
	if buftype != 'popup'
		buffer_handler = term_start('zsh', {
			hidden: 1,
			term_rows: termheight,
			term_cols: termwidth,
			term_finish: 'close'
		})
		winid = popup_create(buffer_handler, {
			minwidth: termwidth,
			minheight: termheight,
			maxwidth: termwidth,
			maxheight: termheight,
			drag: 1,
			close: "button",
			highlight: 'normal',
			border: [1, 1, 1, 1],
			pos: "center",
			mapping: 1
		})
		execute "tnoremap <buffer> <Space><Esc> <C-\\><C-n>:call popup_close(" .. winid .. ")<CR>"
		execute "tnoremap <buffer> <Space>ter <C-\\><C-n>:call Popup_terminal()<CR>"
	else
		execute "call popup_close(" .. winid .. ")"
	endif
enddef

def g:Open_file_under_cursor()
	var filename = expand("<cfile>")
	var directory = b:netrw_curdir
	var full_path = directory .. "/" .. filename
	if isdirectory(full_path)
	execute "Ex " .. fnameescape(full_path)
	return
	endif
	execute "e " .. fnameescape(full_path)
	:only
	:cd %:p:h
enddef

set number
set relativenumber
set noswapfile
execute "set mouse=a"
colorscheme desert


augroup MyCustomMappings
	autocmd!
	autocmd FileType netrw nnoremap <buffer> <CR> :call Open_file_under_cursor()<CR>
	autocmd FileType netrw nnoremap <Leader> <CR> :call Open_file_under_cursor_while_split()<CR>
	autocmd TerminalOpen * tnoremap <buffer> <Leader><Esc> <C-\><C-n>:q!<CR>
augroup END

set termguicolors
highlight Normal guibg=NONE ctermbg=NONE
highlight NonText guibg=NONE ctermbg=NONE
highlight EndOfBuffer guibg=NONE ctermbg=NONE

nnoremap <Leader>n :next<CR>
nnoremap <Leader>p :prev<CR>
nnoremap <Leader>bf :Ex<CR>
nnoremap <Leader>sc :source ~/.vimrc<CR>
nnoremap <Leader>ft :call Open_file_tree()<CR>
nnoremap <Leader>o :only<CR>
nnoremap <Leader>ter :call Popup_terminal()<CR>
