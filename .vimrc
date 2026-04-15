vim9script
g:mapleader = ' '



def g:Str_in_str(str: string, pattern: string): bool
	var i = 0
	var str_len = strlen(str)
	var pattern_len = strlen(pattern)
	while i < str_len
		if str[i] == pattern[0]
			var j = 0
			while j < pattern_len
				if str[i] != pattern[j]
					break
				endif
				i += 1
				j += 1
			endwhile
			if j == pattern_len
				return true
			endif
		endif
		i += 1
	endwhile
	return false
enddef





var USER =  "hdyani"
def g:Get_file_update_time_string(file: string): string
	var last_update_time = ""
	var date = substitute(substitute(system("stat --format=%y " .. file .. " \| awk '{ print $1 }'"), '-', '/', 'g'), '\n', '', '')
	var time = system("stat --format=%y " .. file .. " \| cut -d. -f1 \| awk '{ print $2 }'")
	last_update_time = join([date, time], ' ')
	if empty(last_update_time)
		return "" 
	endif
	var string = join(["Updated: ", substitute(last_update_time, "\n", "", ""), " by "], '')
	return string
enddef
def g:Get_file_creation_time_string(file: string): string
	var creation_time = ""
	var date = substitute(substitute(system("stat --format=%w " .. file .. " \| awk '{ print $1 }'"), '-', '/', 'g'), '\n', '', '')
	var time = system("stat --format=%w " .. file .. " \| cut -d. -f1 \| awk '{ print $2 }'")
	creation_time = join([date, time], ' ')
	if empty(creation_time)
		return "" 
	endif
	var string = join(["Created: ", substitute(creation_time, "\n", "", ""), " by "], '')
	return string
enddef
def g:Get_filename_line(file_name: string): string
	var filename_string = ""
	var num_of_spaces_after_filename = 10
	if strlen(file_name) > 41
		filename_string = file_name[: 40]
	else
		filename_string = file_name
		num_of_spaces_after_filename = 10 + (41 - strlen(file_name))
	endif
	var spaces_after_filename = repeat(" ", num_of_spaces_after_filename)
	return join(["/*   ", substitute(filename_string, "\n", "", "g"), substitute(spaces_after_filename, "\n", "", "g"), ":+:      :+:    :+:   */"], "")
enddef
def g:Get_mail_line(user_name: string): string
	var username_string = ""
	var num_of_spaces_after_mail = 19
	if strlen(user_name) > 9
		username_string = user_name[: 8]
	else
		username_string = user_name
		num_of_spaces_after_mail = 19 + (9 - strlen(user_name))
	endif
	var spaces_after_mail = repeat(" ", num_of_spaces_after_mail)
	return join(["/*   By: ", substitute(username_string, "\n", "", "g"), " <marvin@42.fr>", substitute(spaces_after_mail, "\n", "", "g"), "+#+  +:+       +#+        */"], "")
enddef
def g:Get_created_line(user_name: string, full_path: string): string
	var username_string = ""
	var file_creation_time_string = g:Get_file_creation_time_string(full_path)
	var num_of_spaces_after_name_in_file_info1 = 9
	if strlen(user_name) > 9
		username_string = user_name[: 8]
	else
		username_string = user_name
		num_of_spaces_after_name_in_file_info1 = 9 + (9 - strlen(user_name))
	endif
	var spaces_after_name_in_file_info1 = repeat(" ", num_of_spaces_after_name_in_file_info1)
	return join(["/*   ", substitute(file_creation_time_string, "\n", "", "g"), substitute(username_string, "\n", "", "g"), substitute(spaces_after_name_in_file_info1, "\n", "", "g"), "#+#    #+#             */"], "")
enddef
def g:Get_updated_line(user_name: string, full_path: string): string
	var username_string = ""
	var num_of_spaces_after_name_in_file_info2 = 8
	var file_update_time_string = g:Get_file_update_time_string(full_path)
	if strlen(user_name) > 9
		username_string = user_name[: 8]
	else
		username_string = user_name
		num_of_spaces_after_name_in_file_info2 = 8 + (9 - strlen(user_name))
	endif
	var spaces_after_name_in_file_info2 = repeat(" ", num_of_spaces_after_name_in_file_info2)
	return join(["/*   ", substitute(file_update_time_string, "\n", "", "g"), substitute(username_string, "\n", "", "g"), substitute(spaces_after_name_in_file_info2, "\n", "", "g"), "###   ########.fr       */"], "")
enddef
def g:Pattern_update()
	var user_name = ""
	var file_name = ""
	var file_directory = ""
	var full_path = ""
	var has_pattern = true
	var lines = [] 
	var mail_line = ""
	var created_line = ""
	var updated_line = ""
	var updated_line_str = ""
	if empty(USER)
		user_name = system("echo $USER")
	else
		user_name = USER
	endif
	try
		file_name = substitute(execute("echo @%"), '\n', '', '')
		file_directory = substitute(execute("pwd"), '\n', '', '')
		full_path = join([file_directory, file_name], '/')
		has_pattern = false
		lines = readfile(full_path)[: 10]
		mail_line = lines[5]
		created_line = lines[7]
		updated_line = lines[8]
		updated_line_str = g:Get_updated_line(user_name, full_path)
		if !g:Str_in_str(mail_line, "By") || !g:Str_in_str(created_line, "Created") || !g:Str_in_str(updated_line, "Updated")
			return
		else
			setline(9, updated_line_str)
		endif
	catch
		var exception = v:exception
		if g:Str_in_str(exception, "E684")
			return
		else
			return
		endif
	endtry
enddef
def g:Forty_Two_pattern()
	var user_name = ""
	var file_name = ""
	var file_directory = ""
	var full_path = ""
	var file_exists = ""
	if empty(USER)
		user_name = system("echo $USER")
	else
		user_name = USER
	endif


	try
		file_name = substitute(execute("echo @%"), '\n', '', '')
		file_directory = substitute(execute("pwd"), '\n', '', '')
		full_path = join([file_directory, file_name], '/')
		file_exists = system("if \[ \-f \"" .. full_path .. "\" \]; then echo \"true\"; else echo \"false\"; fi")

		if !file_exists
			echo "File does not exist!!"
			return
		endif
	catch
		echo "File does not exist!!"
		return
	endtry



	if empty(user_name)
		return
	endif
	var file_extention = file_name[-2 : -1]
	if file_extention != ".c"
		return
	endif


	try
		var lines = readfile(full_path)[: 10]
		var mail_line = lines[5]
		var created_line = lines[7]
		var updated_line = lines[8]
		var updated_line_str = g:Get_updated_line(user_name, full_path)
		if g:Str_in_str(mail_line, "By") && g:Str_in_str(created_line, "Created") && g:Str_in_str(updated_line, "Updated")
			g:Pattern_update()
			return
		endif
	catch
		var exception = v:exception
		if !g:Str_in_str(exception, "E684")
			return
		endif
	endtry



	var filename_line = g:Get_filename_line(file_name)
	var mail_line = g:Get_mail_line(user_name)
	var created_line = g:Get_created_line(user_name, full_path)
	var updated_line = g:Get_updated_line(user_name, full_path)
	var lines = [
		"/* ************************************************************************** */",
		"/*                                                                            */",
		"/*                                                        :::      ::::::::   */",
		filename_line,
		"/*                                                    +:+ +:+         +:+     */",
		mail_line,
		"/*                                                +#+#+#+#+#+   +#+           */",
		created_line,
		updated_line,
		"/*                                                                            */",
		"/* ************************************************************************** */",
		""
		]
	var index = len(lines) - 1
	while index >= 0
		append(0, lines[index])
		index = index - 1
	endwhile
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
		var shell_env_var = split(execute("echo $SHELL"), "/")
		var shell = shell_env_var[-1]
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
	execute "normal! gv\"vy"
	var lines = getreg("v", 1, 1)
	system("xclip -selection clipboard", lines)
enddef

def g:Create_new_file()
	var f_name = input("\nInput the name of the file/directory (directories must end with a /): ", "", "file")
	if empty(f_name) || f_name !~ '\S'
		echo "\nFile or Directory name must not be empty or contain only spaces!!!"
		return
	endif
	var directory = b:netrw_curdir
	var full_path = directory .. "/" .. f_name
	var file_exists = system("if \[ \-f \"" .. full_path .. "\" \]; then echo \"true\"; else echo \"false\"; fi")

	if file_exists == "true\n" || isdirectory(full_path)
		 echo "\nFile or Directory already exists!!!"
		return
	endif
	if f_name[-1] == "/"
		var ret_str = system("mkdir " .. full_path)
		if !empty(ret_str)
			echo "\nYou don't have the required premissions to create this directory!!"
			return
		endif
	else
		var ret_str = system("touch " .. full_path)
		if !empty(ret_str)
			echo "\nYou don't have the required premissions to create this file!!"
			return
		endif
	endif
	call feedkeys("<CR>", 'n')
	execute "Ex"
enddef

def g:NetrwMaps()
	silent! nunmap <buffer> <CR>
	silent! nunmap <buffer> <Space>
	silent! nunmap <buffer> <C-l>
	silent! nunmap <buffer> <C-h>
	silent! nunmap <buffer> <C-k>
	silent! nunmap <buffer> <C-j>
	silent! nunmap <buffer> %
	silent! nunmap <buffer> v
	nnoremap <buffer> <silent> :normal v<CR>
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

set number
set relativenumber
set noswapfile
set showcmd
execute "set mouse=a"

colorscheme desert
syntax on
filetype on
filetype plugin indent on
set termguicolors
highlight Normal guibg=NONE ctermbg=NONE
highlight NonText guibg=NONE ctermbg=NONE
highlight EndOfBuffer guibg=NONE ctermbg=NONE

nnoremap <silent> <C-l> <C-w>l
nnoremap <silent> <C-h> <C-w>h
nnoremap <silent> <C-k> <C-w>k
nnoremap <silent> <C-j> <C-w>j

nnoremap <silent> <Leader>n :next<CR>
nnoremap <silent> <Leader>p :prev<CR>
nnoremap <silent> <Leader>bf :Ex<CR>
nnoremap <silent> <Leader>sc :source ~/.vimrc<CR>
nnoremap <silent> <Leader>ft :call Open_file_tree()<CR>
nnoremap <silent> <Leader>o :only<CR>
nnoremap <silent> <Leader>ter :call Popup_terminal()<CR>
nnoremap <silent> <Leader>man :call Popup_terminal("man " .. expand('<cword>'))<CR>
tnoremap <silent> <Leader><Esc> <C-\><C-n>:q!<CR>
tnoremap <silent> <Esc> <C-\><C-n>
vnoremap <silent> <Leader>y :call Copy_selected_text_to_clipboard()<CR>
nnoremap <silent> <Leader><Esc> :call Forty_Two_pattern()<CR>

tnoremap <silent> <Leader>qa :qa!<CR>
nnoremap <silent> <Leader>qa :qa!<CR>
vnoremap <silent> <Leader>qa :qa!<CR>
