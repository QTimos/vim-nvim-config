vim9script
g:mapleader = ' '
set nomodeline
set modelines=0

def g:MidnightNexus()
	set background=dark
	hi clear

	# base
	hi Normal 	   guifg=#C0CAF5 guibg=#0F111A
	hi Comment         guifg=#3B4261 gui=italic

	# constants
	hi Constant        guifg=#7DCFFF
	hi String          guifg=#9ECE6A
	hi Character       guifg=#9ECE6A
	hi Number          guifg=#E0AF68
	hi Boolean         guifg=#E0AF68
	hi Float           guifg=#E0AF68

	# identifiers
	hi Identifier      guifg=#7DCFFF
	hi Function        guifg=#7AA2F7

	# statements
	hi Statement       guifg=#BB9AF7 gui=bold
	hi Conditional     guifg=#BB9AF7 gui=bold
	hi Repeat          guifg=#BB9AF7 gui=bold
	hi Label           guifg=#BB9AF7
	hi Operator        guifg=#BB9AF7
	hi Keyword         guifg=#BB9AF7 gui=bold
	hi Exception       guifg=#F7768E

	# preprocessor
	hi PreProc         guifg=#E0AF68
	hi Include         guifg=#BB9AF7
	hi Define          guifg=#BB9AF7
	hi Macro           guifg=#E0AF68
	hi PreCondit       guifg=#E0AF68

	# types
	hi Type            guifg=#7DCFFF gui=bold
	hi StorageClass    guifg=#BB9AF7
	hi Structure       guifg=#BB9AF7
	hi Typedef         guifg=#BB9AF7

	# special
	hi Special         guifg=#7AA2F7
	hi SpecialChar     guifg=#E0AF68
	hi Tag             guifg=#7AA2F7
	hi Delimiter       guifg=#C0CAF5
	hi SpecialComment  guifg=#3B4261
	hi Debug           guifg=#F7768E

	# ui
	hi Error           guifg=#F7768E guibg=#0F111A gui=bold
	hi Todo            guifg=#E0AF68 guibg=#0F111A gui=bold
	hi Underlined      guifg=#7AA2F7 gui=underline

	hi StatusLine      guifg=#C0CAF5 guibg=#3B4261
	hi StatusLineNC    guifg=#3B4261 guibg=#0F111A
	hi VertSplit       guifg=#3B4261 guibg=#0F111A

	hi TabLine         guifg=#C0CAF5 guibg=#3B4261
	hi TabLineFill     guifg=#C0CAF5 guibg=#0F111A
	hi TabLineSel      guifg=#0F111A guibg=#7AA2F7

	hi Title           guifg=#7AA2F7 gui=bold
	hi LineNr          guifg=#3B4261 guibg=#0F111A
	hi CursorLineNr    guifg=#7AA2F7 guibg=#0F111A gui=bold
	hi CursorLine 	   guibg=#1a1b26
	hi CursorColumn    guibg=#3B4261

	hi ColorColumn     guibg=#3B4261
	hi SignColumn      guifg=#3B4261 guibg=#0F111A

	hi Folded          guifg=#3B4261 guibg=#0F111A
	hi FoldColumn      guifg=#3B4261 guibg=#0F111A

	hi Pmenu           guifg=#C0CAF5 guibg=#3B4261
	hi PmenuSel        guifg=#0F111A guibg=#7AA2F7
	hi PmenuSbar       guibg=#3B4261
	hi PmenuThumb      guibg=#C0CAF5

	hi Search          guifg=#0F111A guibg=#E0AF68
	hi IncSearch       guifg=#0F111A guibg=#9ECE6A
	hi Visual          guifg=#0F111A guibg=#7AA2F7
	hi VisualNOS       guibg=#3B4261

	hi MatchParen      guifg=#0F111A guibg=#7DCFFF gui=bold

	hi NonText         guifg=#3B4261
	hi SpecialKey      guifg=#3B4261
	hi EndOfBuffer     guifg=#3B4261

	hi Directory       guifg=#7AA2F7
	hi ErrorMsg        guifg=#F7768E guibg=#0F111A gui=bold
	hi WarningMsg      guifg=#E0AF68
	hi MoreMsg         guifg=#9ECE6A
	hi ModeMsg         guifg=#7AA2F7
	hi Question        guifg=#7AA2F7

	hi DiffAdd         guifg=#9ECE6A guibg=#0F111A
	hi DiffChange      guifg=#E0AF68 guibg=#0F111A
	hi DiffDelete      guifg=#F7768E guibg=#0F111A
	hi DiffText        guifg=#7AA2F7 guibg=#0F111A
enddef

def g:Str_in_str(str: string, pattern: string): bool
	return stridx(str, pattern) != -1
enddef



def g:CSS_skeleton()
	if &filetype != 'css'
		echo "You are not in an css file!!"
		return
	endif
	var lines = [
			":root {",
		"	--primary: ;",
		"	--secondary: ;",
		"	--bg-body: ;",
		"	--text-main: ;",
		"	--font-body: ;",
		"	--font-heading: ;",
		"	--radius: ;",
		"	--container-width: ;",
		"}",
		"",
		"*, *::before, *::after {",
		"	box-sizing: border-box;",
		"}",
		"",
		"* {",
		"	margin: 0;",
		"	padding: 0;",
		"}",
		"",
		"html {",
		"	-webkit-text-size-adjust: none;",
		"	text-size-adjust: none;",
		"	scroll-behavior: smooth;",
		"	height: 100%;",
		"}",
		"",
		"body {",
		"	min-height: 100vh;",
		"	line-height: 1.5;",
		"	-webkit-font-smoothing: antialiased;",
		"	-moz-osx-font-smoothing: grayscale;",
		"	text-rendering: optimizeSpeed;",
		"}",
		"",
		"img, picture, video, canvas, svg {",
		"	display: block;",
		"	max-width: 100%;",
		"	height: auto;",
		"}",
		"",
		"input, button, textarea, select {",
		"	font: inherit;",
		"}",
		"",
		"ul, ol {",
		"	list-style: none;",
		"}",
		"",
		"button, [type=\"button\"], [type=\"submit\"] {",
		"	cursor: pointer;",
		"}",
		"",
		"@media (prefers-reduced-motion: reduce) {",
		"	*, *::before, *::after {",
		"		animation-duration: 0.01ms !important;",
		"		animation-iteration-count: 1 !important;",
		"		transition-duration: 0.01ms !important;",
		"		scroll-behavior: auto !important;",
		"	}",
		"}"
	]
	for ln in range(1, len(lines))
		setline(ln, lines[ln - 1])
	endfor
enddef
command! CSSSkell call g:CSS_skeleton()

def g:HTML_skeleton()
	if &filetype != 'html'
		echo "You are not in an html file!!"
		return
	endif
	var lines = [
		"<!DOCTYPE html>",
		"<html lang=\"en\">",
		"<head>",
		"	<meta charset=\"UTF-8\">",
		"	<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">",
		"	<title>Page Title</title>",
		"</head>",
		"<body>",
		"	",
		"</body>",
		"</html>"
	]
	for ln in range(1, len(lines))
		setline(ln, lines[ln - 1])
	endfor
enddef
command! HTMLSkell call g:HTML_skeleton()



def g:ToggleCommentBlock(open_tag: string, close_tag: string, firstline: number, lastline: number)
	if firstline == lastline
		var l = getline(firstline)
		if l =~ escape(open_tag, '!/.*') && l =~ escape(close_tag, '!/.*')
			l = substitute(l, escape(open_tag, '!/.*') .. ' \?', '', '')
			l = substitute(l, ' \?' .. escape(close_tag, '!/.*'), '', '')
			setline(firstline, l)
		else
			setline(firstline, open_tag .. ' ' .. l .. ' ' .. close_tag)
		endif
	else
		if getline(firstline) =~ '^\s*' .. escape(open_tag, '!/') && getline(lastline) =~ escape(close_tag, '!/') .. '\s*$'
			deletebufline('%', lastline)
			deletebufline('%', firstline)
		else
			append(lastline, close_tag)
			append(firstline - 1, open_tag)
		endif
	endif
enddef
def g:ToggleCommentRange()
	var ft = &filetype
	var comment_str = ''
	if ft == 'c' || ft == 'cpp' || ft == 'rust' || ft == 'go' || ft == 'javascript' || ft == 'typescript'
		comment_str = '//'
	elseif ft == 'python' || ft == 'sh' || ft == 'bash' || ft == 'vim' || ft == 'ruby' || ft == 'perl'
		comment_str = '#'
	elseif ft == 'lua'
		comment_str = '--'
	elseif ft == 'html'
		g:ToggleCommentBlock('<!--', '-->', line("'<"), line("'>"))
		return
	elseif ft == 'css'
		g:ToggleCommentBlock('/*', '*/', line("'<"), line("'>"))
		return
	else
		echo "No comment string defined for filetype: " .. ft
		return
	endif
	var firstline = line("'<")
	var lastline  = line("'>")
	var clen = strlen(comment_str)
	var lc = 0
	for lnum in range(firstline, lastline)
		if matchstr(getline(lnum), '^\s*\zs.\{' .. clen .. '\}') == comment_str
			lc += 1
		endif
	endfor
	if lc < lastline - firstline + 1
		for lnum in range(firstline, lastline)
			setline(lnum, comment_str .. getline(lnum))
		endfor
	else
		for lnum in range(firstline, lastline)
			setline(lnum, substitute(getline(lnum), escape(comment_str, '/'), '', ''))
		endfor
	endif
enddef
def g:ToggleComment()
	var ft = &filetype
	var comment_str = ''
	if ft == 'c' || ft == 'cpp' || ft == 'rust' || ft == 'go' || ft == 'javascript' || ft == 'typescript'
		comment_str = '//'
	elseif ft == 'python' || ft == 'sh' || ft == 'bash' || ft == 'vim' || ft == 'ruby' || ft == 'perl'
		comment_str = '#'
	elseif ft == 'lua'
		comment_str = '--'
	elseif ft == 'html'
		g:ToggleCommentBlock('<!--', '-->', line('.'), line('.'))
		return
	elseif ft == 'css'
		g:ToggleCommentBlock('/*', '*/', line('.'), line('.'))
		return
	else
		echo "No comment string defined for filetype: " .. ft
		return
	endif
	var l = getline('.')
	if l =~ '^\s*' .. escape(comment_str, '/') .. '\s'
		setline('.', substitute(l, escape(comment_str, '/'), '', ''))
	else
		setline('.', comment_str .. l)
	endif
enddef





var USER =  "hdyani"
def g:Get_file_update_time_string(file: string): string
	if !filereadable(file)
		return ''
	endif
	var raw = system('stat --format=%y ' .. shellescape(file))
	if v:shell_error != 0 || empty(raw)
		return ''
	endif
	var parts = split(raw)
	if len(parts) < 2
		return ''
	endif
	var date = substitute(parts[0], '-', '/', 'g')
	var time = split(parts[1], '\.')[0]
	return 'Updated: ' .. date .. ' ' .. time .. ' by '
enddef
def g:Get_file_creation_time_string(file: string): string
	if !filereadable(file)
		return ''
	endif
	var raw = system('stat --format=%w ' .. shellescape(file))
	if v:shell_error != 0 || empty(raw) || raw =~ '^\-'
		raw = system('stat --format=%z ' .. shellescape(file))
		if v:shell_error != 0 || empty(raw)
			return ''
		endif
	endif
	var parts = split(raw)
	if len(parts) < 2
		return ''
	endif
	var date = substitute(parts[0], '-', '/', 'g')
	var time = split(parts[1], '\.')[0]
	return 'Created: ' .. date .. ' ' .. time .. ' by '
enddef
def g:Pad_username(user_name: string, base_spaces: number): list<any>
	if strlen(user_name) > 9
		return [user_name[: 8], repeat(' ', base_spaces)]
	endif
	return [user_name, repeat(' ', base_spaces + (9 - strlen(user_name)))]
enddef
def g:Get_filename_line(file_name: string): string
	var name = strlen(file_name) > 41 ? file_name[: 40] : file_name
	var spaces = repeat(' ', 10 + (41 - strlen(name)))
	return '/*   ' .. name .. spaces .. ':+:      :+:    :+:   */'
enddef
def g:Get_mail_line(user_name: string): string
	var [name, spaces] = g:Pad_username(user_name, 19)
	return '/*   By: ' .. name .. ' <marvin@42.fr>' .. spaces .. '+#+  +:+       +#+        */'
enddef
def g:Get_created_line(user_name: string, full_path: string): string
	var time_str = g:Get_file_creation_time_string(full_path)
	if empty(time_str)
		return ''
	endif
	var [name, spaces] = g:Pad_username(user_name, 9)
	return '/*   ' .. time_str .. name .. spaces .. '#+#    #+#             */'
enddef
def g:Get_updated_line(user_name: string, full_path: string): string
	var time_str = g:Get_file_update_time_string(full_path)
	if empty(time_str)
		return ''
	endif
	var [name, spaces] = g:Pad_username(user_name, 8)
	return '/*   ' .. time_str .. name .. spaces .. '###   ########.fr       */'
enddef
def g:Pattern_update()
	var user_name = empty(USER) ? systemlist('echo $USER')[0] : USER
	var full_path = expand('%:p')
	var file_name = expand('%:t')

	if empty(file_name) || !filereadable(full_path)
		return
	endif

	var mail_line    = getline(6)
	var created_line = getline(8)
	var updated_line = getline(9)

	if !g:Str_in_str(mail_line, 'By')
		|| !g:Str_in_str(created_line, 'Created')
		|| !g:Str_in_str(updated_line, 'Updated')
		return
	endif

	var updated_line_str  = g:Get_updated_line(user_name, full_path)
	var filename_line_str = g:Get_filename_line(file_name)

	if empty(updated_line_str) || empty(filename_line_str)
		return
	endif

	setline(4, filename_line_str)
	setline(9, updated_line_str)
enddef
def g:Forty_Two_pattern()
	var full_path = expand('%:p')
	var file_name = expand('%:t')
	var user_name = empty(USER) ? systemlist('echo $USER')[0] : USER

	if empty(file_name) || empty(user_name)
		return
	endif
	if !filereadable(full_path)
		echo "File does not exist or is not readable!"
		return
	endif
	if fnamemodify(file_name, ':e') != 'c' && fnamemodify(file_name, ':e') != 'h'
		return
	endif

	var mail_line    = getline(6)
	var created_line = getline(8)
	var updated_line = getline(9)

	if g:Str_in_str(mail_line, 'By')
		&& g:Str_in_str(created_line, 'Created')
		&& g:Str_in_str(updated_line, 'Updated')
		g:Pattern_update()
		return
	endif

	var filename_line_str = g:Get_filename_line(file_name)
	var mail_line_str     = g:Get_mail_line(user_name)
	var created_line_str  = g:Get_created_line(user_name, full_path)
	var updated_line_str  = g:Get_updated_line(user_name, full_path)

	if empty(filename_line_str) || empty(mail_line_str)
		|| empty(created_line_str) || empty(updated_line_str)
		echo "Failed to generate header lines!"
		return
	endif

	var lines = [
		'/* ************************************************************************** */',
		'/*                                                                            */',
		'/*                                                        :::      ::::::::   */',
		filename_line_str,
		'/*                                                    +:+ +:+         +:+     */',
		mail_line_str,
		'/*                                                +#+#+#+#+#+   +#+           */',
		created_line_str,
		updated_line_str,
		'/*                                                                            */',
		'/* ************************************************************************** */',
		''
	]

	for i in range(len(lines) - 1, 0, -1)
		append(0, lines[i])
	endfor
enddef
augroup FtPatterMappings
	autocmd!
	autocmd BufWritePre * g:Pattern_update()
augroup END


def g:Open_file_tree()
	var buftypes = []
	for i in range(1, winnr('$'))
		add(buftypes, getwinvar(i, '&filetype'))
	endfor
	var tree_is_open = index(buftypes, 'netrw')
	if tree_is_open != -1
		echo "You already have a Explorer instance opened!!!"
		return
	endif
	g:netrw_banner = 0
	execute ":25vsplit"
	execute "Ex"
enddef

var BUFFER_HANDLER = -1
var WINID = -1

var BUFFER_HANDLER_NO_PAR = -1
var WINID_NO_PAR = -1
def g:Close_terminal(flag: number = 0)
	if flag == 1
		if WINID != -1
			popup_close(WINID)
			WINID = -1
		endif
		if BUFFER_HANDLER != -1
			term_setkill(BUFFER_HANDLER, "kill")
			BUFFER_HANDLER = -1
		endif
	elseif flag == 2
		popup_close(WINID_NO_PAR)
		WINID_NO_PAR = -1
		term_setkill(BUFFER_HANDLER_NO_PAR, "kill")
		BUFFER_HANDLER_NO_PAR = -1
	else
		return
	endif
enddef
def g:Popup_terminal(command = "NONE")
	var ccc = ""
	var winwidth = &columns
	var winheight = &lines
	var termwidth = float2nr(winwidth * 0.8)
	var termheight = float2nr(winheight * 0.8)
	var buftype = &buftype
	if command == "NONE"
		var shell = fnamemodify(&shell, ':t')
		var buff_was_open = 0
		ccc = shell
		if BUFFER_HANDLER == -1
			BUFFER_HANDLER = term_start(ccc, {
				hidden: 1,
				term_rows: termheight,
				term_cols: termwidth,
				term_finish: "close"
			})
		else
			buff_was_open = 1
		endif
		if WINID == -1
			WINID = popup_create(BUFFER_HANDLER, {
				minwidth: termwidth,
				minheight: termheight,
				maxwidth: termwidth,
				maxheight: termheight,
				drag: 1, close: "button",
				highlight: "normal",
				border: [1, 1, 1, 1],
				pos: "center",
				mapping: 1
			})

			execute "silent! tunmap <buffer> <C-k>"
			execute "silent! tunmap <buffer> <C-j>"
			execute "silent! tunmap <buffer> <C-h>"
			execute "silent! tunmap <buffer> <C-l>"

			execute "tnoremap <buffer> <C-k> \<Esc>OA"
			execute "tnoremap <buffer> <C-j> \<Esc>OB"
			execute "tnoremap <buffer> <C-h> \<Esc>OD"
			execute "tnoremap <buffer> <C-l> \<Esc>OC"


			execute "tnoremap <silent> <buffer> <Space><Esc> <C-\\><C-n>:call Close_terminal(1)<CR>"
			execute "nnoremap <silent> <buffer> <Space><Esc> <C-\\><C-n>:call Close_terminal(1)<CR>"
			execute "tnoremap <silent> <buffer> <Space>ter <C-\\><C-n>:call Popup_terminal()<CR>"
		elseif buftype == "terminal"
			popup_close(WINID)
			WINID = -1
			return
		endif
		if buff_was_open == 1
			call feedkeys("i", 'n')
		endif
	else
		ccc = command
		BUFFER_HANDLER_NO_PAR = term_start(ccc, {
			hidden: 1,
			term_rows: termheight,
			term_cols: termwidth,
		})
		WINID_NO_PAR = popup_create(BUFFER_HANDLER_NO_PAR, {
			minwidth: termwidth,
			minheight: termheight,
			maxwidth: termwidth,
			maxheight: termheight,
			drag: 1,
			close: "button",
			highlight: "normal",
			border: [1, 1, 1, 1],
			pos: "center",
			mapping: 1
		})
		win_execute(WINID_NO_PAR, "noremap <buffer> <silent> q <C-\\><C-n>:call Close_terminal(2)<CR>")
	endif
enddef

def g:Open_file_under_cursor_while_split()
	var file_name = expand("<cfile>")
	var directory = b:netrw_curdir
	var full_path = directory .. "/" .. file_name

	if empty(full_path)
		return
	elseif isdirectory(full_path)
		execute "Ex " .. fnameescape(full_path)
		execute "cd " .. fnameescape(full_path)
		return
	else
		execute "cd %:p:h"
		execute "wincmd l"
		execute "e " .. file_name
	endif

enddef

def g:Open_file_under_cursor()
	var file_name = expand("<cfile>")
	var directory = b:netrw_curdir
	var full_path = directory .. "/" .. file_name

	if isdirectory(full_path)
		execute "Ex " .. fnameescape(full_path)
		execute "cd " .. fnameescape(full_path)
		return
	endif

	execute "cd %:p:h"
	execute "e " .. fnameescape(full_path)
	execute "only"
enddef

def g:Open_file_under_cursor_in_vsplit()
	var file_name = expand("<cfile>")
	var directory = b:netrw_curdir
	var full_path = directory .. "/" .. file_name

	if isdirectory(full_path)
		execute "Ex " .. fnameescape(full_path)
		execute "cd " .. fnameescape(full_path)
		return
	endif

	execute "wincmd l"
	execute "vs " .. fnameescape(full_path)

	var thisbuf = bufnr("%")
	var lastwin = winnr("#")
	var lastbuf = winbufnr(lastwin)

	execute "buffer " .. lastbuf
	execute "wincmd l"
	execute "buffer " .. thisbuf
enddef

def g:Copy_selected_text_to_clipboard()
	var clipboard = ""
	if !empty($WAYLAND_DISPLAY)
		clipboard = "wl-copy"
	elseif !empty($DISPLAY)
		clipboard = "xclip -selection clipboard"
	else
		echoerr "Can't tell what clipboard your system is using"
		return
	endif
	if executable(split(clipboard)[0]) == 0
		echoerr "Missing tool: " .. clipboard
		return
	endif

	execute "normal! gv\"vy"
	var lines = getreg("v", 1, 1)
	system(clipboard, lines)
enddef

def g:Create_new_file()
	var f_name = input("\nInput the name of the file/directory (directories must end with a /): ", "", "file")
	if empty(f_name) || f_name !~ '\S'
		echo "\nFile or Directory name must not be empty or contain only spaces!!!"
		return
	endif
	var directory = b:netrw_curdir
	var full_path = directory .. "/" .. f_name

	if filereadable(full_path) || isdirectory(full_path)
		 echo "\nFile or Directory already exists!!!"
		return
	endif
	if f_name[-1] == "/"
		var ret_str = system(['mkdir', '-p', full_path])
		if v:shell_error != 0
			echo "\nYou don't have the required permissions to create this directory!!"
			return
		endif
	else
		var ret_str = system(['touch', full_path])
		if v:shell_error != 0
			echo "\nYou don't have the required permissions to create this file!!"
			return
		endif
	endif
	call feedkeys("<CR>", 'n')
	execute "Ex"
enddef

def g:NetrwMaps()
	set colorcolumn=
	silent! nunmap <buffer> <CR>
	silent! nunmap <buffer> <Space>
	silent! nunmap <buffer> <C-l>
	silent! nunmap <buffer> <C-h>
	silent! nunmap <buffer> <C-k>
	silent! nunmap <buffer> <C-j>
	silent! nunmap <buffer> %
	silent! nunmap <buffer> v
	nnoremap <buffer> <silent> <Leader><CR> :call Open_file_under_cursor()<CR>
	nnoremap <buffer> <silent> <CR> :call Open_file_under_cursor_while_split()<CR>
	nnoremap <silent> <Leader>s<CR> :call Open_file_under_cursor_in_vsplit()<CR>
	nnoremap <silent> <nowait> % :call Create_new_file()<CR>
	nnoremap <silent> <C-l> <C-w>l
	nnoremap <silent> <C-h> <C-w>h
	nnoremap <silent> <C-k> <C-w>k
	nnoremap <silent> <C-j> <C-w>j
enddef
augroup MyCustomMappings
	autocmd!
	autocmd FileType netrw g:NetrwMaps()
augroup END
def g:NetrwResize(timer: number)
    if winnr('$') == 2
        for i in range(1, winnr('$'))
            if getwinvar(i, '&filetype') == 'netrw'
                win_execute(win_getid(i), 'vertical resize 25')
            endif
        endfor
    endif
enddef
augroup NetrwResize
    autocmd!
    autocmd WinClosed * timer_start(10, g:NetrwResize)
augroup END


set number
set relativenumber
set noswapfile
set showcmd
execute "set mouse=a"

syntax on
filetype on
filetype plugin indent on
set termguicolors

# C syntax highlighting
def g:CCtags()
	if executable('ctags') == 0
		echo "Ctags doesn't exist on your machine!!!"
		return
	endif
	var compiler = executable('gcc') ? 'gcc' : executable('clang') ? 'clang' : ''
	if empty(compiler)
		echo "No C compiler found to detect include paths!"
		return
	endif
	var file_path = expand('%:p:h')
	var raw = system('echo | ' .. compiler .. ' -v -x c - 2>&1')
	var include_dirs = []
	var in_includes = false
	for line in split(raw, '\n')
		if line =~ '#include <\.\.\.>'
			in_includes = true
			continue
		endif
		if in_includes
			if line =~ 'End of search list'
				break
			endif
			var dir = trim(line)
			if isdirectory(dir)
				add(include_dirs, dir)
			endif
		endif
	endfor
	system('ctags -R --languages=C --c-kinds=+p ' .. shellescape(file_path))
	system('ctags -R --language-force=C --c-kinds=+p -a ' .. join(include_dirs, ' '))
	echo "Tags generated!"
enddef
command! Cctags call g:CCtags()

g:c_c99 = 1
g:c_c11 = 1
g:c_posix = 1
g:c_space_errors = 1
augroup CSyntax
	autocmd!
	autocmd FileType c {
	syntax match cFunctionCall /\(\bif\|\bwhile\|\bfor\|\bswitch\|\breturn\)\@!\w\+\s*(/me=e-1
		highlight cFunctionCall guifg=#9ECE6A
		}
augroup END

# Python syntax highlighting
def g:PyCtags()
	if executable('ctags') == 0
		echo "Ctags doesn't exist on your machine!!!"
		return
	endif
	if executable('python3') == 0
		echo "Python3 not found!"
		return
	endif
	var file_path = expand('%:p:h')
	var raw = system('python3 -c "import sys; print(\"\n\".join(sys.path))"')
	var include_dirs = []
	for line in split(raw, '\n')
		var dir = trim(line)
		if !empty(dir) && isdirectory(dir)
			add(include_dirs, dir)
		endif
	endfor
	if empty(include_dirs)
		echo "No Python include paths found!"
		return
	endif
	echo "Generating tags..."
	system("ctags -R --languages=Python --python-kinds=+cfmi " .. shellescape(file_path))
	if v:shell_error != 0
		echo "failed to generate Tags!!!"
		return 
	endif
	system("ctags -R --languages=Python --python-kinds=+cfmi -a " .. join(include_dirs, ' '))
	if v:shell_error != 0
		echo "failed to generate Tags!!!"
		return 
	endif
	echo "Tags generated!"
enddef
command! Pyctags call g:PyCtags()

g:python_highlight_all = 1
g:python_highlight_builtins = 1
g:python_highlight_builtin_funcs = 1
g:python_highlight_builtin_objs = 1
g:python_highlight_exceptions = 1
g:python_highlight_string_formatting = 1
g:python_highlight_indent_errors = 1
augroup PySyntax
	autocmd!
	autocmd FileType python {
		syntax match pyFunctionCall /\(\bif\|\bwhile\|\bfor\|\bwith\|\bexcept\|\bassert\|\bprint\|\breturn\)\@!\w\+\s*(/me=e-1
		hi pyFunctionCall guifg=#7DCFFF
	}
augroup END

set complete=.,b,u,t
set completeopt=menuone,noinsert,noselect
set pumheight=10


augroup Pairs
	autocmd!
	autocmd FileType c,python,vim {
		inoremap <buffer> ( ()<Left>
		inoremap <buffer> [ []<Left>
		inoremap <buffer> { {}<Left>
		inoremap <buffer> " ""<Left>
		inoremap <buffer> ' ''<Left>
		inoremap <buffer> <expr> ) getline('.')[col('.') - 1] == ')' ? '<Right>' : ')'
		inoremap <buffer> <expr> ] getline('.')[col('.') - 1] == ']' ? '<Right>' : ']'
		inoremap <buffer> <expr> } getline('.')[col('.') - 1] == '}' ? '<Right>' : '}'
		inoremap <buffer> <expr> <BS> getline('.')[col('.') - 2] .. getline('.')[col('.') - 1] =~ '()\|\[\]\|{}\|""\|''' ? '<BS><Del>' : '<BS>'
	}
augroup END

# Folds
set tabstop=4
set shiftwidth=4
set softtabstop=4
set noexpandtab
set foldmethod=syntax
set foldlevelstart=99
set foldcolumn=1
set cursorline
set colorcolumn=80
set list
set listchars=tab:»\ ,trail:·,extends:›,precedes:‹
augroup IndentSettings
	autocmd!
	autocmd FileType python setlocal expandtab
augroup END


nnoremap <silent> <C-l> <C-w>l
nnoremap <silent> <C-h> <C-w>h
nnoremap <silent> <C-k> <C-w>k
nnoremap <silent> <C-j> <C-w>j

nnoremap <silent> <Leader>n :next<CR>
nnoremap <silent> <Leader>p :prev<CR>
nnoremap <silent> <Leader>bf :let g:netrw_banner = 1 <CR>:Ex<CR>
nnoremap <silent> <Leader>sc :source ~/.vimrc<CR>
nnoremap <silent> <Leader>ft :call Open_file_tree()<CR>
nnoremap <silent> <Leader>o :only<CR>
nnoremap <silent> <Leader>ter :call Popup_terminal()<CR>
nnoremap <silent> <Leader>man :call Popup_terminal("man " .. expand('<cword>'))<CR>
tnoremap <silent> <Leader><Esc> <C-\><C-n>:q!<CR>
tnoremap <silent> <Esc> <C-\><C-n>
vnoremap <silent> <Leader>y :call Copy_selected_text_to_clipboard()<CR>
nnoremap <silent> <Leader><Esc> :call Forty_Two_pattern()<CR>
nnoremap <silent> <CR> za

nnoremap <silent> gcc :call g:ToggleComment()<CR>
vnoremap <silent> gcc :<C-u>call g:ToggleCommentRange()<CR>

tnoremap <silent> <Leader>qa :qa!<CR>
nnoremap <silent> <Leader>qa :qa!<CR>
vnoremap <silent> <Leader>qa :qa!<CR>

# Always keep at the bottom
g:MidnightNexus()
