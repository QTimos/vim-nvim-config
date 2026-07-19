vim.g.mapleader = " "
vim.g.localleader = " "

-- General settings
vim.opt.modelines = 0
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.swapfile = false
vim.opt.showcmd = true
vim.opt.mouse = "a"
vim.opt.pumheight = 10
vim.opt.cmdheight = 1
vim.opt.termguicolors = true
vim.opt.showmode = true
vim.opt.updatetime = 100
vim.opt.timeoutlen = 300

-- Folds & indentation
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.foldmethod = "syntax"
vim.opt.foldlevelstart = 99
vim.opt.foldcolumn = "1"
vim.opt.cursorline = true
vim.opt.colorcolumn = "80"
vim.opt.list = true
vim.opt.listchars = { tab = "»-", trail = "·", extends = "›", precedes = "‹" }

-- Colorscheme- Midnight Nexus
function MidnightNexus()
	local highlight = vim.api.nvim_set_hl
	local colors = {
		bg = "#0F111A",
		bg_alt = "#171B26",
		bg_dark = "#0A0C14",
		fg = "#C0CAF5",
		fg_dark = "#A9B1D6",
		grey = "#3B4261",
		red = "#F7768E",
		green = "#9ECE6A",
		yellow = "#E0AF68",
		blue = "#7AA2F7",
		magenta = "#BB9AF7",
		cyan = "#7DCFFF",
		orange = "#FFB86C",
		pink = "#F5C2E7",
		selection = "#2A3A5A",
	}
	vim.cmd("highlight clear")
	vim.cmd("syntax reset")
	vim.o.termguicolors = true
	vim.g.colors_name = "midnightnexus"

	-- Terminal
	vim.g.terminal_color_0  = colors.bg
	vim.g.terminal_color_1  = colors.red
	vim.g.terminal_color_2  = colors.green
	vim.g.terminal_color_3  = colors.yellow
	vim.g.terminal_color_4  = colors.blue
	vim.g.terminal_color_5  = colors.magenta
	vim.g.terminal_color_6  = colors.cyan
	vim.g.terminal_color_7  = colors.fg
	vim.g.terminal_color_8  = colors.grey
	vim.g.terminal_color_9  = colors.red
	vim.g.terminal_color_10 = colors.green
	vim.g.terminal_color_11 = colors.yellow
	vim.g.terminal_color_12 = colors.blue
	vim.g.terminal_color_13 = colors.magenta
	vim.g.terminal_color_14 = colors.cyan
	vim.g.terminal_color_15 = colors.fg

	-- Base
	highlight(0, "Normal",       { fg = colors.fg, bg = colors.bg })
	highlight(0, "NormalFloat",  { fg = colors.fg, bg = colors.bg_alt })
	highlight(0, "FloatBorder",  { fg = colors.blue, bg = colors.bg_alt })
	highlight(0, "Comment",      { fg = colors.grey, italic = true })

	-- Legacy Syntax
	highlight(0, "Constant", { fg = colors.cyan })
	highlight(0, "String", { fg = colors.green })
	highlight(0, "Character", { fg = colors.green })
	highlight(0, "Number", { fg = colors.yellow })
	highlight(0, "Boolean", { fg = colors.red })
	highlight(0, "Float", { fg = colors.yellow })
	highlight(0, "Identifier", { fg = colors.fg })
	highlight(0, "Function", { fg = colors.blue })
	highlight(0, "Statement", { fg = colors.magenta, bold = true })
	highlight(0, "Conditional", { fg = colors.magenta, bold = true })
	highlight(0, "Repeat", { fg = colors.magenta, bold = true })
	highlight(0, "Label", { fg = colors.yellow })
	highlight(0, "Operator", { fg = colors.magenta })
	highlight(0, "Keyword", { fg = colors.magenta, bold = true })
	highlight(0, "Exception", { fg = colors.red, bold = true })
	highlight(0, "PreProc", { fg = colors.orange })
	highlight(0, "Include", { fg = colors.magenta })
	highlight(0, "Define", { fg = colors.magenta })
	highlight(0, "Macro", { fg = colors.orange })
	highlight(0, "PreCondit", { fg = colors.orange })
	highlight(0, "Type", { fg = colors.yellow, bold = true })
	highlight(0, "StorageClass", { fg = colors.magenta })
	highlight(0, "Structure", { fg = colors.magenta })
	highlight(0, "Typedef", { fg = colors.magenta })
	highlight(0, "Special", { fg = colors.orange })
	highlight(0, "SpecialChar", { fg = colors.red })
	highlight(0, "Tag", { fg = colors.red })
	highlight(0, "Delimiter", { fg = colors.fg })
	highlight(0, "SpecialComment", { fg = colors.grey })
	highlight(0, "Debug", { fg = colors.red })

	-- UI
	highlight(0, "CursorLine",   { underline = true, bg = colors.bg_alt })
	highlight(0, "CursorColumn", { bg = colors.bg_alt })
	highlight(0, "ColorColumn",  { bg = colors.bg_alt })
	highlight(0, "CursorLineNr", { fg = colors.yellow, bg = colors.bg, bold = true, })
	highlight(0, "LineNr", { fg = colors.grey, bg = colors.bg, })
	highlight(0, "SignColumn", { fg = colors.grey, bg = colors.bg, })
	highlight(0, "StatusLine", { fg = colors.fg, bg = colors.bg_alt, })
	highlight(0, "StatusLineNC", { fg = colors.grey, bg = colors.bg, })
	highlight(0, "WinSeparator", { fg = colors.grey, bg = colors.bg, })
	highlight(0, "VertSplit", { fg = colors.grey, bg = colors.bg, })
	highlight(0, "Title", { fg = colors.blue, bold = true, })
	highlight(0, "Directory", { fg = colors.blue, })

	-- Popup Menu
	highlight(0, "Pmenu", { fg = colors.fg, bg = colors.bg_alt, })
	highlight(0, "PmenuSel", { fg = colors.bg, bg = colors.blue, bold = true, })
	highlight(0, "PmenuSbar", { bg = colors.grey, })
	highlight(0, "PmenuThumb", { bg = colors.fg, })

	-- Search
	highlight(0, "Search", { fg = colors.bg, bg = colors.yellow, })
	highlight(0, "IncSearch", { fg = colors.bg, bg = colors.orange, bold = true, })
	highlight(0, "CurSearch", { fg = colors.bg, bg = colors.orange, bold = true, })

	-- Visual
	highlight(0, "Visual", { bg = colors.selection, })
	highlight(0, "VisualNOS", { bg = colors.bg_alt, })
	highlight(0, "MatchParen", { fg = colors.bg, bg = colors.cyan, bold = true, })

	-- Messages
	highlight(0, "Error", { fg = colors.red, bold = true, })
	highlight(0, "ErrorMsg", { fg = colors.red, bold = true, })
	highlight(0, "WarningMsg", { fg = colors.yellow, })
	highlight(0, "MoreMsg", { fg = colors.green, })
	highlight(0, "Question", { fg = colors.blue, })
	highlight(0, "ModeMsg", { fg = colors.magenta, })
	highlight(0, "Todo", { fg = colors.yellow, bold = true, })

	-- Folding
	highlight(0, "Folded", { fg = colors.grey, bg = colors.bg_alt, })
	highlight(0, "FoldColumn", { fg = colors.grey, bg = colors.bg, })

	-- Diff
	highlight(0, "DiffAdd", { fg = colors.green, bg = colors.bg_dark, })
	highlight(0, "DiffDelete", { fg = colors.red, bg = colors.bg_dark, })
	highlight(0, "DiffChange", { fg = colors.yellow, bg = colors.bg_dark, })
	highlight(0, "DiffText", { fg = colors.blue, bg = colors.bg_dark, })

	-- Diagnostics
	highlight(0, "DiagnosticError", { fg = colors.red, })
	highlight(0, "DiagnosticWarn", { fg = colors.yellow, })
	highlight(0, "DiagnosticInfo", { fg = colors.blue, })
	highlight(0, "DiagnosticHint", { fg = colors.cyan, })
	highlight(0, "DiagnosticOk", { fg = colors.green, })
	highlight(0, "DiagnosticUnderlineError", { undercurl = true, sp = colors.red, })
	highlight(0, "DiagnosticUnderlineWarn", { undercurl = true, sp = colors.yellow, })
	highlight(0, "DiagnosticUnderlineInfo", { undercurl = true, sp = colors.blue, })
	highlight(0, "DiagnosticUnderlineHint", { undercurl = true, sp = colors.cyan, })

	-- Tree-sitter
	-- Comments
	highlight(0, "@comment", { fg = colors.grey, italic = true })
	-- Variables
	highlight(0, "@variable", { fg = colors.fg })
	highlight(0, "@variable.builtin", { fg = colors.red })
	highlight(0, "@variable.member", { fg = colors.cyan })
	-- Parameters
	highlight(0, "@parameter", { fg = colors.pink })
	highlight(0, "@parameter.reference", { fg = colors.pink })
	-- Properties / Fields
	highlight(0, "@property", { fg = colors.cyan })
	highlight(0, "@field", { fg = colors.cyan })
	-- Constants
	highlight(0, "@constant", { fg = colors.cyan })
	highlight(0, "@constant.builtin", { fg = colors.red })
	highlight(0, "@constant.macro", { fg = colors.magenta })
	-- Strings
	highlight(0, "@string", { fg = colors.green })
	highlight(0, "@string.documentation", { fg = colors.green })
	highlight(0, "@string.escape", { fg = colors.red })
	highlight(0, "@string.regex", { fg = colors.orange })
	highlight(0, "@string.special", { fg = colors.yellow })
	highlight(0, "@string.special.symbol", { fg = colors.yellow })
	-- Numbers
	highlight(0, "@number", { fg = colors.yellow })
	highlight(0, "@float", { fg = colors.yellow })
	highlight(0, "@boolean", { fg = colors.red })
	-- Types
	highlight(0, "@type", { fg = colors.yellow, bold = true })
	highlight(0, "@type.builtin", { fg = colors.yellow, bold = true })
	highlight(0, "@type.definition", { fg = colors.yellow, bold = true })
	highlight(0, "@constructor", { fg = colors.yellow })
	-- Functions
	highlight(0, "@function", { fg = colors.blue })
	highlight(0, "@function.method", { fg = colors.blue })
	highlight(0, "@function.call", { fg = colors.pink })
	highlight(0, "@function.method.call", { fg = colors.green })
	highlight(0, "@function.builtin", { fg = colors.yellow })
	highlight(0, "@function.macro", { fg = colors.orange })
	-- Keywords
	highlight(0, "@keyword", { fg = colors.magenta, bold = true })
	highlight(0, "@keyword.function", { fg = colors.magenta, bold = true })
	highlight(0, "@keyword.return", { fg = colors.magenta, bold = true })
	highlight(0, "@keyword.import", { fg = colors.magenta })
	highlight(0, "@keyword.operator", { fg = colors.magenta })
	highlight(0, "@keyword.repeat", { fg = colors.magenta })
	highlight(0, "@keyword.conditional", { fg = colors.magenta })
	highlight(0, "@keyword.exception", { fg = colors.red, bold = true })
	-- Operators
	highlight(0, "@operator", { fg = colors.magenta })
	-- Punctuation
	highlight(0, "@punctuation", { fg = colors.fg })
	highlight(0, "@punctuation.bracket", { fg = colors.fg })
	highlight(0, "@punctuation.delimiter", { fg = colors.fg })
	highlight(0, "@punctuation.special", { fg = colors.yellow })
	-- Modules
	highlight(0, "@module", { fg = colors.blue })
	highlight(0, "@module.builtin", { fg = colors.yellow })
	highlight(0, "@namespace", { fg = colors.blue })
	-- Attributes
	highlight(0, "@attribute", { fg = colors.magenta })
	-- Labels
	highlight(0, "@label", { fg = colors.orange })
	-- Tags
	highlight(0, "@tag", { fg = colors.red })
	highlight(0, "@tag.attribute", { fg = colors.yellow })
	highlight(0, "@tag.delimiter", { fg = colors.grey })

	-- LSP Semantic Tokens
	highlight(0, "@lsp.type.class", { link = "@type" })
	highlight(0, "@lsp.type.enum", { link = "@type" })
	highlight(0, "@lsp.type.interface", { link = "@type" })
	highlight(0, "@lsp.type.struct", { link = "@type" })
	highlight(0, "@lsp.type.type", { link = "@type" })
	highlight(0, "@lsp.type.typeParameter", { fg = colors.orange })
	highlight(0, "@lsp.type.function", { link = "@function" })
	highlight(0, "@lsp.type.method", { link = "@function.method" })
	highlight(0, "@lsp.type.parameter", { link = "@parameter" })
	highlight(0, "@lsp.type.property", { link = "@property" })
	highlight(0, "@lsp.type.variable", { link = "@variable" })
	highlight(0, "@lsp.type.namespace", { link = "@namespace" })
	highlight(0, "@lsp.type.keyword", { link = "@keyword" })
	highlight(0, "@lsp.type.enumMember", { fg = colors.cyan })

	-- Markdown
	highlight(0, "markdownH1", { fg = colors.red, bold = true })
	highlight(0, "markdownH2", { fg = colors.orange, bold = true })
	highlight(0, "markdownH3", { fg = colors.yellow, bold = true })
	highlight(0, "markdownH4", { fg = colors.green, bold = true })
	highlight(0, "markdownH5", { fg = colors.cyan, bold = true })
	highlight(0, "markdownH6", { fg = colors.magenta, bold = true })
	highlight(0, "markdownCode", { fg = colors.green })
	highlight(0, "markdownCodeBlock", { fg = colors.green })
	highlight(0, "markdownUrl", { fg = colors.blue, underline = true })

	-- Vim
	highlight(0, "vimCommand", { fg = "#BB9AF7", bold = true })
	highlight(0, "vimVar", { fg = "#7DCFFF" })
	highlight(0, "vimFunctionScope", { fg = "#7DCFFF", bold = true })
	highlight(0, "vimVarScope", { fg = "#7DCFFF", bold = true })
	highlight(0, "vimDefName", { fg = "#7AA2F7" })
	highlight(0, "vim9UserFunc", { fg = "#7AA2F7" })
	highlight(0, "vimFuncName", { fg = "#F5C2E7" })
	highlight(0, "vimFunction", { fg = "#F5C2E7" })
	highlight(0, "vimFuncParam", { fg = "#F5C2E7" })
	highlight(0, "vimComment", { fg = "#3B4261", italic = true })
	highlight(0, "vimLet", { fg = "#E0AF68" })
	highlight(0, "vimFBVar", { fg = "#E0AF68" })
	highlight(0, "vimHiGroup", { fg = "#E0AF68" })
	highlight(0, "vimHiGuiFgBg", { fg = "#7AA2F7" })
	highlight(0, "vimHiGui", { fg = "#7AA2F7" })
	highlight(0, "vimHiKeyList", { fg = "#BB9AF7" })
	highlight(0, "vimHiGuiRgb", { fg = "#9ECE6A" })
	highlight(0, "vimHiAttrib", { fg = "#9ECE6A" })
	highlight(0, "vimOptionVarName", { fg = "#9ECE6A" })
	highlight(0, "vimOptionVar", { fg = "#9ECE6A", bold = true })
	highlight(0, "vimHiCTerm", { fg = "#7AA2F7" })
	highlight(0, "CursorIM", { fg = "#0F111A", bg = "#F5C2E7" })
	highlight(0, "ToolbarLine", { bg = "#171B26" })
	highlight(0, "ToolbarButton", { fg = "#C0CAF5", bg = "#3B4261", bold = true })
	highlight(0, "StatusLineTerm", { fg = "#C0CAF5", bg = "#171B26" })
	highlight(0, "StatusLineTermNC", { fg = "#3B4261", bg = "#0F111A" })
	highlight(0, "SpellBad", { undercurl = true, sp = "#F7768E" })
	highlight(0, "SpellCap", { undercurl = true, sp = "#E0AF68" })
	highlight(0, "SpellRare", { undercurl = true, sp = "#7DCFFF" })
	highlight(0, "SpellLocal", { undercurl = true, sp = "#9ECE6A" })

	-- Misc
	highlight(0, "WinBar", { fg = colors.fg, bg = colors.bg })
	highlight(0, "WinBarNC", { fg = colors.grey, bg = colors.bg })
	highlight(0, "EndOfBuffer", { fg = colors.bg })
	highlight(0, "Conceal", { fg = colors.grey })
	highlight(0, "Whitespace", { fg = colors.grey })
	highlight(0, "NonText", { fg = colors.grey })
	highlight(0, "SpecialKey", { fg = colors.grey })
	highlight(0, "QuickFixLine", { bg = colors.bg_alt })
	highlight(0, "WildMenu", { fg = colors.bg, bg = colors.blue })
	highlight(0, "Cursor", { fg = colors.bg, bg = colors.fg })
	highlight(0, "lCursor", { fg = colors.bg, bg = colors.fg })
	highlight(0, "TermCursor", { fg = colors.bg, bg = colors.green })
end

-- File skeletons
function PY_skeleton()
	local bufnbr = vim.api.nvim_get_current_buf()
	local filetype = vim.bo[bufnbr].filetype
	if filetype ~= "python" then
		print("You are not in a python file!!")
		return
	end
	local lines = {
		"",
		"",
		"def main() -> None:",
		"    raise NotImplentedError()",
		"",
		"",
		"if __name__ == \"__main__\":",
		"    main()"
	}
	vim.api.nvim_buf_set_lines(bufnbr, 0, 0, false, lines)
end
vim.api.nvim_create_user_command("PYskell", PY_skeleton, {})
function CSS_skeleton()
	local bufnbr = vim.api.nvim_get_current_buf()
	local filetype = vim.bo[bufnbr].filetype
	if filetype ~= "css" then
		print("You are not in a css file!!")
		return
	end
	local lines = {
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
	}
	vim.api.nvim_buf_set_lines(bufnbr, 0, 0, false, lines)
end
vim.api.nvim_create_user_command("CSSskel", CSS_skeleton, {})
function HTML_skeleton()
	local bufnbr = vim.api.nvim_get_current_buf()
	local filetype = vim.bo[bufnbr].filetype
	if filetype ~= "html" then
		print("You are not in an html file!!")
		return
	end
	local lines = {
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
	}
	vim.api.nvim_buf_set_lines(bufnbr, 0, 0, false, lines)
end
vim.api.nvim_create_user_command("HTMLskel", HTML_skeleton, {})


-- Helpers
local function split(string, sep)
	local parts = {}
	if sep == nil or sep == "" or sep == {} then
		sep = "%s"
	end
	for str in string.gmatch(string, "([^"..sep.."]+)") do
		table.insert(parts, str)
	end
	return parts
end
local function substitute(string, from, to, flag)
	local stop = false
	local new_string = ""
	for char in string:gmatch(".") do
		if char == from and stop == false then
			if flag ~= "g" then
				stop = true
			end
			new_string = new_string..to
		else
			new_string = new_string..char
		end
	end
	return new_string
end
local function strstr(string, sub)
	local s, _ = string.find(string, sub, 1, true)
	if s == nil then
		return false
	end
	return true
end
local function table_index(table, value)
	for i, v in ipairs(table) do
		if v == value then
			return i
		end
	end
	return nil
end


-- 42 header pattern
USER = "hdyani"
function Get_file_update_time_string(file)
	if file == "" or file == nil then
		return ""
	end
	local success, open_file = pcall(io.open, file, "r")
	if not success or not open_file then
		return ""
	end
	local handle = io.popen("stat --format=%y "..file)
	local raw = handle:read("*a")
	handle:close()
	if raw == "" or raw == {} or raw == nil then
		return ""
	end
	local parts = split(raw)
	if #parts < 2 then
		return ""
	end
	local date = substitute(parts[1], "-", "/", "g")
	local time = split(parts[2], ".")[1]
	return "Updated: "..date.." "..time.." by "
end
function Get_file_creation_time_string(file)
	if file == "" or file == nil then
		return ""
	end
	local success, open_file = pcall(io.open, file, "r")
	if not success or not open_file then
		return ""
	end
	local handle = io.popen("stat --format=%w "..file)
	local raw = handle:read("*a")
	handle:close()
	if raw == "" or raw == {} or raw == nil then
		return ""
	end
	local parts = split(raw)
	if #parts < 2 then
		return ""
	end
	local date = substitute(parts[1], "-", "/", "g")
	local time = split(parts[2], ".")[1]
	return 'Created: '..date..' '..time..' by '
end
function Pad_username(user_name, base_spaces)
	if #user_name > 9 then
		return {string.sub(user_name, 1, 8), string.rep(" ", base_spaces)}
	end
	return {user_name, string.rep(" ", base_spaces + (9 - #user_name))}
end
function Get_filename_line(file_name)
	local name = (#file_name > 41) and string.sub(file_name, 1, 40) or file_name
	local spaces = string.rep(" ", 10 + (41 - #name))
	return "/*   "..name..spaces..":+:      :+:    :+:   */"
end
function Get_mail_line(user_name)
	local name, spaces = unpack(Pad_username(user_name, 19))
	return "/*   By: "..name.." <marvin@42.fr>"..spaces.."+#+  +:+       +#+        */"
end
function Get_created_line(user_name, full_path)
	local time_str = Get_file_creation_time_string(full_path)
	if time_str == "" then
		return ""
	end
	local name, spaces = unpack(Pad_username(user_name, 9))
	return "/*   "..time_str..name..spaces.."#+#    #+#             */"
end
function Get_updated_line(user_name, full_path)
	local time_str = Get_file_update_time_string(full_path)
	if time_str == "" then
		return ""
	end
	local name, spaces = unpack(Pad_username(user_name, 8))
	return "/*   "..time_str..name..spaces.."###   ########.fr       */"
end
function Pattern_update()
	local handle = io.popen("echo $USER")
	local raw = handle:read("*a")
	handle:close()
	local user_name = (USER == "") and raw or USER
	local full_path = vim.uv.fs_realpath(vim.api.nvim_buf_get_name(0))
	local file_name = vim.fs.basename(full_path)
	if full_path == "" or full_path == nil then
		return ""
	end
	local success, open_file = pcall(io.open, full_path, "r")
	if not success or not open_file then
		return
	end
	local mail_line = vim.fn.getline(6)
	local created_line = vim.fn.getline(8)
	local updated_line = vim.fn.getline(9)
	if not strstr(mail_line, "By") or not strstr(created_line, "Created") or not strstr(updated_line, "Updated") then
		return
	end
	local updated_line_str = Get_updated_line(user_name, full_path)
	local filename_line_str = Get_filename_line(file_name)
	if updated_line_str == "" or filename_line_str == "" then
		return
	end
	vim.fn.setline(4, filename_line_str)
	vim.fn.setline(9, updated_line_str)
end
function Forty_Two_pattern()
	local handle = io.popen("echo $USER")
	local raw = handle:read("*a")
	handle:close()
	local user_name = (USER == "") and raw or USER
	local full_path = vim.uv.fs_realpath(vim.api.nvim_buf_get_name(0))
	local file_name = vim.fs.basename(full_path)
	if file_name == "" or file_name == nil or full_path == "" or full_path == nil or user_name == "" or user_name == nil then
		return
	end
	local success, open_file = pcall(io.open, full_path, "r")
	if not success or not open_file then
		print("File does not exist or is not readable!")
		return
	end
	if vim.fn.fnamemodify(file_name, ":e") ~= "c" and vim.fn.fnamemodify(file_name, ":e") ~= "h" then
		print("File is not a c file!!")
		return
	end
	local mail_line = vim.fn.getline(6)
	local created_line = vim.fn.getline(8)
	local updated_line = vim.fn.getline(9)
	if strstr(mail_line, "By") and strstr(created_line, "Created") and strstr(updated_line, "Updated") then
		Pattern_update()
	   	return
	end
	local filename_line_str = Get_filename_line(file_name)
	local mail_line_str = Get_mail_line(user_name)
	local created_line_str = Get_created_line(user_name, full_path)
	local updated_line_str = Get_updated_line(user_name, full_path)
	if filename_line_str == "" or mail_line_str == "" or created_line_str == "" or updated_line_str == "" then
		print("Failed to generate header lines!")
		return
	end
	local lines = {
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
	}
	local bufnbr = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_lines(bufnbr, 0, 0, false, lines)
end
FtPatternMappingsGI = vim.api.nvim_create_augroup("FtPatternMappings", { clear = true })
vim.api.nvim_create_autocmd({"BufWritePre"}, {
	group = FtPatternMappingsGI,
	pattern = "*",
	callback = function()
		Pattern_update()
	end,
})


-- Netrw / file explorer
function Open_file_tree()
	local buftypes = {}
	for i = 1, vim.fn.winnr("$") do
		table.insert(buftypes, vim.fn.getwinvar(i, "&filetype"))
	end
	local tree_is_open = table_index(buftypes, "netrw")
	if tree_is_open ~= nil then
		print("You already have an Explorer instance opened!!!")
	return
	end
	vim.g.netrw_banner = 0
	vim.fn.execute(":25vsplit")
	vim.fn.execute("Ex")
end
function Open_file_under_cursor_while_split()
	local file_name = vim.fn.expand("<cfile>")
	local directory = vim.b.netrw_curdir
	local full_path = directory.."/"..file_name
	if full_path == nil or full_path == "" then
		return
	elseif vim.fn.isdirectory(full_path) ~= 0 then
		vim.fn.execute("Ex "..vim.fn.fnameescape(full_path))
		vim.fn.execute("cd "..vim.fn.fnameescape(full_path))
		return
	else
		vim.fn.execute("cd "..vim.fn.fnameescape(directory))
		vim.fn.execute("wincmd l")
		vim.fn.execute("e "..full_path)
	end
end
function Open_file_under_cursor()
	local file_name = vim.fn.expand("<cfile>")
	local directory = vim.b.netrw_curdir
	local full_path = directory.."/"..file_name
	if vim.fn.isdirectory(full_path) ~= 0 then
		vim.fn.execute("Ex "..vim.fn.fnameescape(full_path))
		vim.fn.execute("cd "..vim.fn.fnameescape(full_path))
		return
	end
	vim.fn.execute("cd %:p:h")
	vim.fn.execute("e "..vim.fn.fnameescape(full_path))
	vim.fn.execute("only")
end
function Open_file_under_cursor_in_vsplit()
	local file_name = vim.fn.expand("<cfile>")
	local directory = vim.b.netrw_curdir
	local full_path = directory.."/"..file_name
	print(vim.fn.isdirectory(full_path))
	if vim.fn.isdirectory(full_path) ~= 0 then
		vim.fn.execute("Ex "..vim.fn.fnameescape(full_path))
		vim.fn.execute("cd "..vim.fn.fnameescape(full_path))
		return
	end
	vim.fn.execute("wincmd l")
	vim.fn.execute("vs "..vim.fn.fnameescape(full_path))
	local thisbuf = vim.fn.bufnr("%")
	local lastwin = vim.fn.winnr("#")
	local lastbuf = vim.fn.winbufnr(lastwin)
	vim.fn.execute("buffer "..lastbuf)
	vim.fn.execute("wincmd l")
	vim.fn.execute("buffer "..thisbuf)
end
function Create_new_file_or_directory()
	local f_name = vim.fn.input("\nInput the name of the file/directory (directories must end with a /): ", "", "file")
	if f_name == nil or f_name == "" then
		print("\nFile or Directory name must not be empty or contain only spaces!!")
		return
	end
	local directory = vim.b.netrw_curdir
	local full_path = directory.."/"..f_name
	if vim.fn.filereadable(full_path) ~= 0 or vim.fn.isdirectory(full_path) ~= 0 then
		print("\nFile or Directory already exists!!")
		return
	end
	if string.sub(f_name, -1) == "/" then
		local handle = io.popen("mkdir -p "..full_path)
		local raw = handle:read("*a")
		handle:close()
		if vim.v.shell_error ~= 0 then
			print("You don't have the required permissions to create this directory!!")
			return
		end
	else
		local handle = io.popen("touch "..full_path)
		local raw = handle:read("*a")
		handle:close()
		if vim.v.shell_error ~= 0 then
			print("You don't have the required permissions to create this file!!")
			return
		end
	end
	vim.fn.feedkeys("<CR>", "n")
	vim.fn.execute("Ex")
end
function NetrwResize()
	local wins = vim.api.nvim_list_wins()
	if #wins == 2 then
		for _, win in ipairs(wins) do
			if vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "netrw" then
				vim.api.nvim_win_set_width(win, 25)
			end
		end
	end
end
function CdToCurrentFile()
	if vim.bo.buftype ~= "" then return end
	vim.fn.execute("cd %:p:h")
end
CdToFileGI = vim.api.nvim_create_augroup("CdToFile", { clear = true })
vim.api.nvim_create_autocmd({"BufEnter"}, {
	group = CdToFileGI,
	pattern = "*",
	callback = function()
		CdToCurrentFile()
	end
})
NetrwResizeGI = vim.api.nvim_create_augroup("NetrwResize", { clear = true })
vim.api.nvim_create_autocmd({"WinClosed"}, {
	group = NetrwResizeGI,
	pattern = "*",
	callback = function()
		vim.defer_fn(function()
			NetrwResize()
		end, 10)
	end
})
NetrwMapsGI = vim.api.nvim_create_augroup("NetrwMaps", { clear = true })
vim.api.nvim_create_autocmd({"FileType"}, {
	group = NetrwMapsGI,
	pattern = "netrw",
	callback = function()
		vim.opt.colorcolumn = "0"
		pcall(vim.keymap.del, "n", "<CR>", { buffer = 0, silent = true })
		pcall(vim.keymap.del, "n", "<Space>", { buffer = 0, silent = true })
		pcall(vim.keymap.del, "n", "<C-l>", { buffer = 0, silent = true })
		pcall(vim.keymap.del, "n", "<C-h>", { buffer = 0, silent = true })
		pcall(vim.keymap.del, "n", "<C-k>", { buffer = 0, silent = true })
		pcall(vim.keymap.del, "n", "<C-j>", { buffer = 0, silent = true })
		pcall(vim.keymap.del, "n", "%", { buffer = 0, silent = true })
		pcall(vim.keymap.del, "n", "v", { buffer = 0, silent = true })
		vim.keymap.set("n", "<Leader><CR>", function()
			Open_file_under_cursor()
		end, { buffer = 0, silent = true })
		vim.keymap.set("n", "<CR>", function()
			Open_file_under_cursor_while_split()
		end, { buffer = 0, silent = true })
		vim.keymap.set("n", "<Leader>s<CR>", function()
			Open_file_under_cursor_in_vsplit()
		end, { buffer = 0, silent = true })
		vim.keymap.set("n", "%", function()
			Create_new_file_or_directory()
		end, { buffer = 0, silent = true, nowait = true })
		vim.keymap.set("n", "<C-l>", "<C-w>l", { silent = true })
		vim.keymap.set("n", "<C-h>", "<C-w>h", { silent = true })
		vim.keymap.set("n", "<C-k>", "<C-w>k", { silent = true })
		vim.keymap.set("n", "<C-j>", "<C-w>j", { silent = true })
	end,
})


-- Terminal
Config = {
	width = 0.8,
	height = 0.8,
	border = "rounded",
	winblend = 0,
	shell = nil,
	toggle_keymap = "<Leader>ter",
	kill_keymap = "<Leader>q",
	terminal_mappings = true,
	title = "Floating Terminal",
	title_pos = "center"
}
TermRegistry = {}
function GetKey()
	if vim.bo.buftype == "terminal" and vim.b.source_buf then
		return vim.b.source_buf
	end
	return vim.api.nvim_get_current_buf()
end
function CreateFloatingWindow(buf)
	local width = math.floor(vim.o.columns * Config.width)
	local height = math.floor(vim.o.lines * Config.height)
	local win = vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		row = math.floor((vim.o.lines - vim.o.cmdheight - height)/2),
		col = math.floor((vim.o.columns - width)/2),
		width = width,
		height = height,
		style = "minimal",
		border = Config.border,
		title = Config.title,
		title_pos = Config.title_pos
	})
	vim.wo[win].winblend = Config.winblend
	vim.wo[win].cursorline = true
	return win
end
function ToggleTerminal()
	local key = GetKey()
	local entry = TermRegistry[key]
	if entry and entry.win and vim.api.nvim_win_is_valid(entry.win) then
		vim.api.nvim_win_close(entry.win, true)
		entry.win = nil
		return
	end
	for k, e in pairs(TermRegistry) do
		if k ~= key and e.win and vim.api.nvim_win_is_valid(e.win) then
			vim.api.nvim_win_close(e.win, true)
			e.win = nil
		end
	end
	if entry and entry.buf and vim.api.nvim_buf_is_valid(entry.buf) then
		entry.win = CreateFloatingWindow(entry.buf)
		vim.cmd("startinsert")
		return
	end
	local cwd = vim.fn.expand("%:p:h")
	if cwd == "" then
		cwd = vim.fn.getcwd()
	end
	local buf = vim.api.nvim_create_buf(false, true)
	vim.b[buf].source_buf = key
	local win = CreateFloatingWindow(buf)
	vim.fn.termopen(Config.shell or vim.o.shell, {
		cwd = cwd,
		on_exit = function()
			if TermRegistry[key] and TermRegistry[key].win and vim.api.nvim_win_is_valid(TermRegistry[key].win) then
				vim.api.nvim_win_close(TermRegistry[key].win, true)
			end
			TermRegistry[key] = nil
		end,
	})
	vim.bo[buf].buflisted = false
	vim.keymap.set({ "t", "n" }, Config.toggle_keymap, function()
		ToggleTerminal()
	end, { buffer = buf, noremap = true, silent = true })
	vim.keymap.set({ "t", "n" }, Config.kill_keymap, function()
		KillTerminal()
	end, { buffer = buf, noremap = true, silent = true })
	vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { buffer = buf, noremap = true, silent = true })
	TermRegistry[key] = { buf = buf, win = win }
	vim.cmd("startinsert")
end
function KillTerminal()
	local key = GetKey()
	local entry = TermRegistry[key]
	if not entry then
		return
	end
	if entry.win and vim.api.nvim_win_is_valid(entry.win) then
		vim.api.nvim_win_close(entry.win, true)
	end
	if entry.buf and vim.api.nvim_buf_is_valid(entry.buf) then
		vim.fn.jobstop(vim.b[entry.buf].terminal_job_id)
		vim.api.nvim_buf_delete(entry.buf, { force = true })
	end
	TermRegistry[key] = nil
end
TermOpsV = vim.api.nvim_create_augroup("TermOps", { clear = true })
vim.api.nvim_create_autocmd("TermOpen", {
	group = TermOpsV,
	pattern = "*",
	callback = function()
		vim.opt_local.number = false
		vim.opt_local.relativenumber = false
	end
})


-- C syntax highlighting and tags
CSyntaxV = vim.api.nvim_create_augroup("CSyntax", { clear = true })
vim.api.nvim_create_autocmd({"FileType"}, {
	group = CSyntaxV,
	pattern = "c",
	callback = function(args)
		vim.treesitter.start(args.buf, "c")
	end
})
function CCtags()
	local handle = io.popen("which ctags")
	local ctags = vim.trim(handle:read("*a"))
	handle:close()
	if vim.fn.executable(ctags) == 0 then
		print("Ctags doesn't exist on your machine!!")
		return
	end
	local compiler = (vim.fn.executable("gcc") ~= 0) and "gcc" or (vim.fn.executable("clang") ~= 0 ) and "clang" or ""
	if compiler == "" then
		print("No C compiler found to detect include paths!!")
		return
	end
	local file_path = vim.fn.expand("%:p:h")
	local handle = io.popen("echo | "..compiler.." -v -x c - 2>&1")
	if not handle then
		return
	end
	local raw = handle:read("*a")
	handle:close()
	local include_dirs = {}
	local in_includes = false
	for _, line in ipairs(split(raw, "\n")) do
		if string.find(line, "#include <...>", 1, true) then
			in_includes = true
			goto continue
		end
		if in_includes then
			if string.find(line, "End of search list", 1, true) then
				break
			end
			local dir = vim.trim(line)
			if vim.fn.isdirectory(dir) == 1 then
				table.insert(include_dirs, dir)
			end
		end
		::continue::
	end
	print("Generating tags...")
	local cmd1 = ctags.." -R --languages=C --c-kinds=+p "..vim.fn.shellescape(file_path)..">/dev/null 2>&1"
	local cmd2 = ctags.." -R --language-force=C --c-kinds=+p -a "..table.concat(include_dirs, " ")..">/dev/null 2>&1"
	vim.fn.system(cmd1)
	if vim.v.shell_error ~= 0 then
		print("Failed to generate Tags!!")
		return
	end
	vim.fn.system(cmd2)
	if vim.v.shell_error ~= 0 then
		print("Failed to generate Tags!!")
		return
	end
	print("Tags generated successfully!")
end
vim.api.nvim_create_user_command("Cctags", function()
	CCtags()
end, {})


-- Python syntax highlighting and tags
local PYSyntaxGI = vim.api.nvim_create_augroup("PYSyntax", { clear = true })
vim.api.nvim_create_autocmd({"FileType"}, {
	group = PYSyntaxGI,
	pattern = "python",
	callback = function(args)
		vim.opt_local.expandtab = true
		local dir = vim.fn.stdpath("config")
		local parser = dir.."/python.so"
		pcall(vim.treesitter.language.add, "python", { path = parser })
		if vim.fn.filereadable(parser) == 0 then
			print("[Bootstrap] Building tree-sitter-python directly in config folder...")
			local temp_clone_dir = dir.."/tmp_clone"
			local compile_cmd = string.format(
				"rm -rf '%s' && " ..
				"git clone --depth=1 https://github.com/tree-sitter/tree-sitter-python.git '%s' && " ..
				"cd '%s' && " ..
				"cc -o '%s' -shared -fPIC -O2 src/parser.c src/scanner.c -Isrc && " ..
				"rm -rf '%s'",
				temp_clone_dir, temp_clone_dir, temp_clone_dir, parser, temp_clone_dir
			)
			vim.fn.jobstart(compile_cmd, {
				on_exit = function(_, exit_code)
					if exit_code == 0 then
						print("[Bootstrap] Python parser successfully compiled!")
						pcall(vim.treesitter.language.add, "python", { path = parser })
						pcall(vim.treesitter.start, args.buf, "python")
					end
				end
			})
		end
		local query_string = [[
			((identifier) @constant.builtin (#any-of? @constant.builtin "__name__" "__main__" "__init__"))
			((call
			  function: (identifier) @function.builtin)
			 (#match?
			   @function.builtin
			   "^(abs|all|any|ascii|bin|bool|breakpoint|bytearray|bytes|callable|chr|classmethod|compile|complex|delattr|dict|dir|divmod|enumerate|eval|exec|filter|float|format|frozenset|getattr|globals|hasattr|hash|help|hex|id|input|int|isinstance|issubclass|iter|len|list|locals|map|max|memoryview|min|next|object|oct|open|ord|pow|print|property|range|repr|reversed|round|set|setattr|slice|sorted|staticmethod|str|sum|super|tuple|type|vars|zip|__import__)$"))
			(function_definition name: (identifier) @function.method)
			(call function: (attribute attribute: (identifier) @function.call))
			(call function: (identifier) @function.call)
			(decorator) @function.call
			(decorator (identifier) @function.call)
			((identifier) @constructor (#match? @constructor "^[A-Z]"))
			((identifier) @constant (#match? @constant "^[A-Z][A-Z_]*$"))
			(attribute attribute: (identifier) @property)
			(type (identifier) @type)
			[ (none) (true) (false) ] @constant.builtin
			[ (integer) (float) ] @number
			(comment) @comment
			(string) @string
			(escape_sequence) @escape
			(interpolation "{" @punctuation.special "}" @punctuation.special) @embedded
			[
			  "-" "-=" "!=" "*" "**" "**=" "*=" "/" "//" "//=" "/=" "&" "&=" "%" "%=" 
			  "^" "^=" "+" "->" "+=" "<" "<<" "<<=" "<=" "<>" "=" ":=" "==" ">" ">=" 
			  ">>" ">>=" "|" "|=" "~" "@=" "and" "in" "is" "not" "or" "is not" "not in"
			 ] @operator
			[
			  "as" "assert" "async" "await" "break" "class" "continue" "def" "del" "elif" 
			  "else" "except" "exec" "finally" "for" "from" "global" "if" "import" "lambda" 
			  "nonlocal" "pass" "print" "raise" "return" "try" "while" "with" "yield" "match" "case"
			] @keyword
		]]
		vim.treesitter.query.set("python", "highlights", query_string)
		pcall(vim.treesitter.start, args.buf, "python")
	end
})
function PyCtags()
	local handle = io.popen("which ctags")
	local ctags = vim.trim(handle:read("*a"))
	handle:close()
	if vim.fn.executable(ctags) == 0 then
		print("Ctags doesn't exist on your machine!!")
		return
	end
	local handle = io.popen("which python3")
	local python3 = vim.trim(handle:read("*a"))
	handle:close()
	if vim.fn.executable(python3) == 0 then
		print("Python3 doesn't exist on your machine!!")
		return
	end
	local file_path = vim.fn.expand("%:p:h")
	local handle = io.popen('python3 -c "import sys; print(\"\n\".join(sys.path))"')
	if not handle then
		return
	end
	local raw = handle:read("*a")
	handle:close()
	local include_dirs = {}
	for _, line in ipairs(split(raw, "\n")) do
		local dir = vim.trim(line)
		if dir ~= nil and dir ~= "" and vim.fn.isdirectory(dir) ~= 0 then
			table.insert(include_dirs, dir)
		end
	end
	if include_dirs == {} then
		print("No python include paths found!!")
		return
	end
	print("Generating tags...")
	local cmd1 = ctags.." -R --languages=Python --python-kinds=+cfmi "..vim.fn.shellescape(file_path)..">/dev/null 2>&1"
	local cmd2 = ctags.." -R --languages=Python --python-kinds=+cfmi -a "..table.concat(include_dirs, " ")..">/dev/null 2>&1"
	vim.fn.system(cmd1)
	if vim.v.shell_error ~= 0 then
		print("Failed to generate Tags!!")
		return
	end
	vim.fn.system(cmd2)
	if vim.v.shell_error ~= 0 then
		print("Failed to generate Tags!!")
		return
	end
	print("Tags generated!")
end
vim.api.nvim_create_user_command("Pyctags", function()
	PyCtags()
end, {})


-- Rust syntax highlighting
local RSSyntaxGI = vim.api.nvim_create_augroup("RSSyntax", { clear = true })
vim.api.nvim_create_autocmd({"FileType"}, {
	group = RSSyntaxGI,
	pattern = "rust",
	callback = function(args)
		vim.opt_local.expandtab = true
		local dir = vim.fn.stdpath("config")
		local parser = dir.."/rust.so"
		pcall(vim.treesitter.language.add, "rust", { path = parser })
		if vim.fn.filereadable(parser) == 0 then
			print("[Bootstrap] Building tree-sitter-rust directly in config folder...")
			local temp_clone_dir = dir.."/tmp_clone"
			local compile_cmd = string.format(
				"rm -rf '%s' && " ..
				"git clone --depth=1 https://github.com/tree-sitter/tree-sitter-rust.git '%s' && " ..
				"cd '%s' && " ..
				"cc -o '%s' -shared -fPIC -O2 src/parser.c src/scanner.c -Isrc && " ..
				"rm -rf '%s'",
				temp_clone_dir, temp_clone_dir, temp_clone_dir, parser, temp_clone_dir
			)
			vim.fn.jobstart(compile_cmd, {
				on_exit = function(_, exit_code)
					if exit_code == 0 then
						print("[Bootstrap] Rust parser successfully compiled!")
						pcall(vim.treesitter.language.add, "rust", { path = parser })
						pcall(vim.treesitter.start, args.buf, "rust")
					end
				end
			})
		end
		local query_string= [[
			(type_identifier) @type
			(primitive_type) @type.builtin
			(field_identifier) @property
			((identifier) @constant
			 (#match? @constant "^[A-Z][A-Z\\d_]+$"))
			((identifier) @constructor
			 (#match? @constructor "^[A-Z]"))
			((scoped_identifier
			  path: (identifier) @type)
			 (#match? @type "^[A-Z]"))
			((scoped_identifier
			  path: (scoped_identifier
				name: (identifier) @type))
			 (#match? @type "^[A-Z]"))
			((scoped_type_identifier
			  path: (identifier) @type)
			 (#match? @type "^[A-Z]"))
			((scoped_type_identifier
			  path: (scoped_identifier
				name: (identifier) @type))
			 (#match? @type "^[A-Z]"))
			(struct_pattern
			  type: (scoped_type_identifier
				name: (type_identifier) @constructor))
			(call_expression
			  function: (identifier) @function.call)
			(call_expression
			  function: (field_expression
				field: (field_identifier) @function.call))
			(call_expression
			  function: (scoped_identifier
				"::"
				name: (identifier) @function.call))
			(generic_function
			  function: (identifier) @function.call)
			(generic_function
			  function: (scoped_identifier
				name: (identifier) @function.call))
			(generic_function
			  function: (field_expression
				field: (field_identifier) @function.call))
			(macro_invocation
			  macro: (identifier) @function.macro
			  "!" @function.macro)
			(function_item (identifier) @function)
			(function_signature_item (identifier) @function)
			(line_comment) @comment
			(block_comment) @comment
			(line_comment (doc_comment)) @comment.documentation
			(block_comment (doc_comment)) @comment.documentation
			"(" @punctuation.bracket
			")" @punctuation.bracket
			"[" @punctuation.bracket
			"]" @punctuation.bracket
			"{" @punctuation.bracket
			"}" @punctuation.bracket
			(type_arguments
			  "<" @punctuation.bracket
			  ">" @punctuation.bracket)
			(type_parameters
			  "<" @punctuation.bracket
			  ">" @punctuation.bracket)
			"::" @punctuation.delimiter
			":" @punctuation.delimiter
			"." @punctuation.delimiter
			"," @punctuation.delimiter
			";" @punctuation.delimiter
			(parameter (identifier) @variable.parameter)
			(lifetime (identifier) @label)
			[
			  "as" "async" "await" "break" "const" "continue" "default"
			  "dyn" "else" "enum" "extern" "fn" "for" "gen" "if" "impl"
			  "in" "let" "loop" "macro_rules!" "match" "mod" "move" "pub"
			  "raw" "ref" "return" "static" "struct" "trait" "type"
			  "union" "unsafe" "use" "where" "while" "yield"
			] @keyword
			(crate) @keyword
			(mutable_specifier) @keyword
			(use_list (self) @keyword)
			(scoped_use_list (self) @keyword)
			(scoped_identifier (self) @keyword)
			(super) @keyword
			(self) @variable.builtin
			(char_literal) @string
			(string_literal) @string
			(raw_string_literal) @string
			(boolean_literal) @constant.builtin
			(integer_literal) @constant.builtin
			(float_literal) @constant.builtin
			(escape_sequence) @escape
			(attribute_item) @attribute
			(inner_attribute_item) @attribute
			[
			  "+" "-" "*" "/" "%" "=" "==" "!=" "<" ">" "<=" ">="
			  "&&" "||" "!" "&" "|" "^" "<<" ">>"
			  "+=" "-=" "*=" "/=" "%=" "&=" "|=" "^=" "<<=" ">>="
			  "->" ".." "..."
			] @operator
			"*" @operator
			"&" @operator
			"'" @operator
		]]
		vim.treesitter.query.set("rust", "highlights", query_string)
		pcall(vim.treesitter.start, args.buf, "rust")
	end
})


-- Auto-pairs
PairsV = vim.api.nvim_create_augroup("Pairs", { clear = true })
vim.api.nvim_create_autocmd({"FileType"}, {
	group = PairsV,
	pattern = { "c", "python", "lua", "vim" },
	callback = function()
		vim.keymap.set("i", "(", "()<Left>", { buffer = 0, silent = true })
		vim.keymap.set("i", "[", "[]<Left>", { buffer = 0, silent = true })
		vim.keymap.set("i", "{", "{}<Left>", { buffer = 0, silent = true })
		vim.keymap.set("i", "\"", "\"\"<Left>", { buffer = 0, silent = true })
		vim.keymap.set("i", "'", "''<Left>", { buffer = 0, silent = true })
		vim.keymap.set("i", ")", "getline('.')[col('.')-1] == ')' ? '<Right>' : ')'", { buffer = 0, expr = true, silent = true, replace_keycodes = false })
		vim.keymap.set("i", "]", "getline('.')[col('.')-1] == ']' ? '<Right>' : ']'", { buffer = 0, expr = true, silent = true, replace_keycodes = false })
		vim.keymap.set("i", "}", "getline('.')[col('.')-1] == '}' ? '<Right>' : '}'", { buffer = 0, expr = true, silent = true, replace_keycodes = false })
		vim.keymap.set("i", "<BS>", function()
			local line = vim.fn.getline('.')
			local col = vim.fn.col('.')
			local pair = string.sub(line, col - 1, col)
			local pairs = { ['""']=true, ["''"]=true, ['()']=true, ['[]']=true, ['{}']=true }
			if pairs[pair] then
				return "<BS><Del>"
			else
				return "<BS>"
			end
		end, { buffer = 0, expr = true, silent = true })
	end
})


-- LSP bootstrap
LSPBootstrapV = vim.api.nvim_create_augroup("LSPBootstrap", { clear = true })
BinDir = vim.fn.stdpath("config").."/bin"
vim.fn.mkdir(BinDir, "p")
vim.env.PATH = BinDir..":"..vim.env.PATH
Servers = {
	python = {
		name = "pyright",
		cmd_name = "pyright-langserver",
		check = function()
			return vim.fn.executable("pyright-langserver") == 1
		end,
		install_cmd = string.format(
			"npm install --prefix '%s' pyright && ln -sf '%s/node_modules/.bin/pyright-langserver' '%s/pyright-langserver'",
			BinDir, BinDir, BinDir
		),
		lsp_cmd = { "pyright-langserver", "--stdio" },
		filetypes = { "python" },
		root_markers = { "pyproject.toml", "setup.py", ".git" }
	},
	rust = {
		name = "rust-analyzer",
		cmd_name = "rust-analyzer",
		check = function()
			return vim.fn.executable(BinDir.."/rust-analyzer_dist/rust-analyzer") == 1
		end,
		install_cmd = table.concat({
			"rm -rf '"..BinDir.."/rust-analyzer_dist' '"..BinDir.."/rust-analyzer_tmp.gz' && ",
			"mkdir -p '"..BinDir.."/rust-analyzer_dist' && ",
			"URL=$(curl -s https://api.github.com/repos/rust-lang/rust-analyzer/releases/latest ",
			"| grep -o '\"browser_download_url\": *\"[^\"]*rust-analyzer-x86_64-unknown-linux-gnu\\.gz\"' ",
			"| grep -o 'https://[^\"]*') && ",
			"echo \"Resolved URL: $URL\" && ",
			"curl -L -o '"..BinDir.."/rust-analyzer_tmp.gz' \"$URL\" && ",
			"gunzip -c '"..BinDir.."/rust-analyzer_tmp.gz' > '"..BinDir.."/rust-analyzer_dist/rust-analyzer' && ",
			"chmod +x '"..BinDir.."/rust-analyzer_dist/rust-analyzer' && ",
			"rm -f '"..BinDir.."/rust-analyzer_tmp.gz'",
		}),
		lsp_cmd = { BinDir.."/rust-analyzer_dist/rust-analyzer" },
		filetypes = { "rust" },
		root_markers = { "Cargo.toml", ".git" }
	},
	c = {
		name = "clangd",
		cmd_name = "clangd",
		check = function()
			return vim.fn.executable(BinDir.."/clangd_dist/bin/clangd") == 1
		end,
		install_cmd = table.concat({
			"rm -rf '"..BinDir.."/clangd_dist' '".. BinDir.."/clangd_tmp.zip' && ",
			"URL=$(curl -s https://api.github.com/repos/clangd/clangd/releases/latest ",
			"| grep -o '\"browser_download_url\": *\"[^\"]*clangd-linux-[0-9.]*\\.zip\"' ",
			"| grep -o 'https://[^\"]*') && ",
			"echo \"Resolved URL: $URL\" && ",
			"curl -L -o '"..BinDir.."/clangd_tmp.zip' \"$URL\" && ",
			"unzip -q '"..BinDir.."/clangd_tmp.zip' -d '"..BinDir.."' && ",
			"rm -f '"..BinDir.."/clangd_tmp.zip' && ",
			"mv '"..BinDir.."'/clangd_* '"..BinDir.."/clangd_dist'",
		}),
		lsp_cmd = { BinDir.."/clangd_dist/bin/clangd" },
		filetypes = { "c", "cpp" },
		root_markers = { "compile_commands.json", ".git" }
	},
	lua = {
		name = "lua_ls",
		cmd_name = "lua-language-server",
		check = function()
			return vim.fn.executable(BinDir.."/lua-language-server-dist/bin/lua-language-server") == 1
		end,
		install_cmd = string.format(
			"rm -rf '%s/tmp_lualsp' '%s/lua-language-server-dist' && " ..
			"git clone --depth=1 --recurse-submodules https://github.com/LuaLS/lua-language-server '%s/tmp_lualsp' && " ..
			"cd '%s/tmp_lualsp' && ./make.sh && " ..
			"mv '%s/tmp_lualsp' '%s/lua-language-server-dist'",
			BinDir, BinDir, BinDir, BinDir, BinDir, BinDir
		),
		lsp_cmd = { BinDir.."/lua-language-server-dist/bin/lua-language-server" },
		filetypes = { "lua" },
		root_markers = { ".luarc.json", ".git" },
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim" }
				},
			}
		}
	}
}
function BootstrapAndStart(server, bufnr)
	if server.check() then
		vim.lsp.start({
			name = server.name,
			cmd = server.lsp_cmd,
			filetypes = server.filetypes,
			root_dir = vim.fs.root(bufnr, server.root_markers),
			settings = server.settings
		})
		return
	end
	if not server.install_cmd then
		vim.notify("[Bootstrap] "..server.name.." not found and has no auto-install (install manually)", vim.log.levels.WARN)
		return
	end
	vim.notify("[Bootstrap] Installing "..server.name.."...")
	vim.fn.jobstart(server.install_cmd, {
		cwd = BinDir,
		on_exit = function(_, code)
			if code == 0 then
				vim.notify("[Bootstrap] "..server.name.." installed")
				vim.lsp.start({
					name = server.name,
					cmd = server.lsp_cmd,
					filetypes = server.filetypes,
					root_dir = vim.fs.root(bufnr, server.root_markers),
				})
			else
				vim.notify("[Bootstrap] failed to install "..server.name, vim.log.levels.ERROR)
			end
		end,
	})
end
vim.api.nvim_create_autocmd("FileType", {
	group = LSPBootstrapV,
	pattern = { "python", "c", "cpp", "lua", "rust" },
	callback = function(args)
		local ft = vim.bo[args.buf].filetype
		local key = (ft == "cpp") and "c" or ft
		local server = Servers[key]
		if server then
			BootstrapAndStart(server, args.buf)
		end
	end,
})


-- Completions
vim.api.nvim_create_autocmd("LspAttach", {
	group = LSPBootstrapV,
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = false })
		end
	end,
})
vim.keymap.set("i", "<C-n>", function()
	vim.lsp.completion.get()
end)
vim.keymap.set("i", "<Tab>", function()
	if vim.fn.pumvisible() == 1 then
		return "<C-n>"
	end
	return "<Tab>"
end, { expr = true })
vim.keymap.set("i", "<S-Tab>", function()
	if vim.fn.pumvisible() == 1 then
		return "<C-p>"
	end
	return "<S-Tab>"
end, { expr = true })
vim.keymap.set("i", "<CR>", function()
	if vim.fn.pumvisible() == 1 then
		return "<C-y>"
	end
	return "<CR>"
end, { expr = true })


-- Status line theming
function StatusLineSetup()
	local colors = { bg = "#0F111A", bg_alt = "#171B26", bg_dark = "#0A0C14",
		fg = "#C0CAF5", fg_dark = "#A9B1D6", grey = "#3B4261", red = "#F7768E",
		green = "#9ECE6A", yellow = "#E0AF68", blue = "#7AA2F7", magenta = "#BB9AF7",
		cyan = "#7DCFFF", orange = "#FFB86C", pink = "#F5C2E7", selection = "#2A3A5A",
	}
	local hl = vim.api.nvim_set_hl
	hl(0, "MyStlNormal", { bg = colors.cyan, fg = colors.bg, bold = true })
	hl(0, "MyStlInsert", { bg = colors.yellow, fg = colors.bg, italic = true, bold = true })
	hl(0, "MyStlVisual", { bg = colors.pink, fg = colors.bg, italic = true })
	hl(0, "MyStlCommand", { bg = colors.red, fg = colors.bg, bold = true })
	hl(0, "MyStlReplace", { bg = colors.magenta, fg = colors.bg, bold = true })
	hl(0, "MyStlICompletion", { bg = colors.green, fg = colors.bg, bold = true })
	hl(0, "MyStlTerminal", { bg = colors.fg_dark, fg = colors.bg, bold = true, italic = true })
	hl(0, "MyStlFileType", { bg = colors.pink, fg = colors.bg, bold = true, italic = true })
	hl(0, "MyStlFileLines", { bg = colors.bg_alt, fg = colors.red, bold = true, italic = true })
	vim.o.laststatus = 2
	vim.o.statusline = "%!v:lua.StatusLineRender()"
end
function StatusLineRender()
	local mode_names = {
	  n = "NORMAL", i = "INSERT", v = "VISUAL", V = "V-LINE", ic = "I-COMPLETION",
	  ["\22"] = "V-BLOCK", c = "COMMAND", R = "REPLACE", t = "TERMINAL" }
	local mode_hl = {
	  n = "MyStlNormal", i = "MyStlInsert", v = "MyStlVisual", V = "MyStlVisual", ic = "MyStlICompletion",
	  ["\22"] = "MyStlVisual", c = "MyStlCommand", R = "MyStlReplace", t = "MyStlTerminal" }
	local file_types = { lua        = "", vim        = "", python     = "",
		py         = "", c          = "", h          = "", cpp        = "",
		hpp        = "", cc         = "", cxx        = "", java       = "",
		javascript = "", js         = "", typescript = "", ts         = "",
		jsx        = "", tsx        = "", html       = "", css        = "",
		scss       = "", json       = "", yaml       = "", yml        = "",
		toml       = "", xml        = "󰗀", sh         = "", bash       = "",
		zsh        = "", fish       = "󰈺", make       = "", makefile   = "",
		cmake      = "", go         = "", rust       = "", rs         = "",
		php        = "", ruby       = "", perl       = "", swift      = "",
		kotlin     = "", dart       = "", r          = "󰟔", julia      = "",
		sql        = "", dockerfile = "󰡨", docker     = "󰡨", gitconfig  = "󰊢",
		gitignore  = "󰊢", gitattributes = "󰊢", markdown   = "", md         = "",
		tex        = "󰙩", txt        = "󰈙", conf       = "", config     = "",
		ini        = "", log        = "󰌱", csv        = "󰈛", tsv        = "󰈛",
		pdf        = "", zip        = "󰗄", tar        = "󰗄", gz         = "󰗄",
		xz         = "󰗄", mp3        = "󰎆", wav        = "󰎆", flac       = "󰎆",
		mp4        = "󰈫", mkv        = "󰈫", avi        = "󰈫", png        = "󰸭",
		jpg        = "󰸭", jpeg       = "󰸭", gif        = "󰵸", svg        = "󰜡",
		lock       = "󰌾", default    = "󰈚" }
	local mode_icons = { n  = "", i  = "", v  = "󰈈", V  = "󰈈", ["\22"] = "󰈈",
	  c  = "", r  = "󰑕", R  = "󰑕", t  = "", ic = "" }
	local m = vim.api.nvim_get_mode().mode
	local mode_comp = string.format("%%#%s#  %s %%*", mode_hl[m] or "MyStlNormal", mode_names[m] or m)..string.format("%%#%s#%s  %%*", mode_hl[m] or "MyStlNormal", mode_icons[m])
	local name = vim.fn.expand("%:t")
	if name == "" then name = "[No Name]" end
	local file_comp = vim.bo.modified and (name.." [+]") or name
	local file_type = string.format("%%#%s#  %s %s  %%*", "MyStlFileType", file_types[vim.bo.filetype] or file_types.default, vim.bo.filetype)
	local file_lines = string.format("%%#%s#  %s %%*", "MyStlFileLines", vim.fn.line(".")..":"..vim.fn.col(".").." ")
	local focused = vim.g.statusline_winid == vim.api.nvim_get_current_win()
	if not focused then
		return "  " .. file_comp
	end
	return table.concat({
		mode_comp, " ", file_comp,
		"%=",
		file_type,
		file_lines
	})
end


-- Cursor animations
OldCurPos = nil
NewCurPos = nil
FloatWin = nil
FloatBuf = nil
Timer = nil
local function ScreenPos(win, pos)
	local ok, sp = pcall(vim.fn.screenpos, win, pos[1], pos[2] + 1)
	if not ok or sp.row == 0 then
		return nil
	end
	return { row = sp.row, col = sp.col }
end
local function CharUnder(pos)
	local line = vim.fn.getline(pos[1])
	local col = pos[2] + 1
	local ch = vim.fn.strcharpart(line, vim.fn.charidx(line, col - 1), 1)
	if ch == "" then
		ch = " "
	end
	return ch
end
local function EnsureFloat()
	if FloatBuf == nil or not vim.api.nvim_buf_is_valid(FloatBuf) then
		FloatBuf = vim.api.nvim_create_buf(false, true)
	end
	if FloatWin == nil or not vim.api.nvim_win_is_valid(FloatWin) then
		FloatWin = vim.api.nvim_open_win(FloatBuf, false, {
			relative = "editor",
			row = 0,
			col = 0,
			width = 1,
			height = 1,
			style = "minimal",
			focusable = false,
			zindex = 200,
		})
		vim.api.nvim_set_hl(0, "AnimCursor", { reverse = true })
		vim.wo[FloatWin].winhighlight = "Normal:AnimCursor"
	end
end
function CursorAnimate()
	local win = vim.api.nvim_get_current_win()
	local cur = vim.api.nvim_win_get_cursor(0)
	if OldCurPos == nil then
		OldCurPos = cur
		return
	end
	NewCurPos = cur
	local from = ScreenPos(win, OldCurPos)
	local to = ScreenPos(win, NewCurPos)
	if from and to and (from.row ~= to.row or from.col ~= to.col) then
		EnsureFloat()
		vim.api.nvim_buf_set_lines(FloatBuf, 0, -1, false, { CharUnder(NewCurPos) })
		if Timer then
			Timer:stop()
			Timer:close()
			Timer = nil
		end
		local steps = 6
		local i = 0
		Timer = vim.uv.new_timer()
		Timer:start(0, 16, vim.schedule_wrap(function()
			i = i + 1
			local t = i / steps
			local row = math.floor(from.row + (to.row - from.row) * t + 0.5)
			local col = math.floor(from.col + (to.col - from.col) * t + 0.5)
			if FloatWin and vim.api.nvim_win_is_valid(FloatWin) then
			vim.api.nvim_win_set_config(FloatWin, {
					relative = "editor",
					row = row - 1,
					col = col - 1,
				})
			end
			if i >= steps then
				if Timer == nil then return end
				Timer:stop()
				Timer:close()
				Timer = nil
			end
		end))
	end
	OldCurPos = NewCurPos
end
CurAnimGI = vim.api.nvim_create_augroup("CurAnim", { clear = true })
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
	group = CurAnimGI,
	pattern = "",
	callback = CursorAnimate
})


-- Keymaps
vim.keymap.set("n", "<C-l>", "<C-w>l", { silent = true })
vim.keymap.set("n", "<C-h>", "<C-w>h", { silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { silent = true })
vim.keymap.set("n", "<Leader>n", ":next<CR>", { silent = true })
vim.keymap.set("n", "<Leader>p", ":prev<CR>", { silent = true })
vim.keymap.set("n", "<Leader>bf", ":let g:netrw_banner = 1<CR>:Ex<CR>", { silent = true })
vim.keymap.set("n", "<Leader>sc", ":so ~/.config/nvim/init.lua <CR>", { silent = true })
vim.keymap.set("n", "<Leader>ft", function()
	Open_file_tree()
end, { silent = true })
vim.keymap.set("n", "<Leader>o", ":only<CR>", { silent = true })
vim.keymap.set("n", Config.toggle_keymap, function()
	ToggleTerminal()
end, { noremap = true, silent = true })
vim.keymap.set("n", "<Leader>q", "<C-\\><C-n>:q!<CR>", { silent = true })
vim.keymap.set({ "n", "v" }, "<Leader>y", '"+y', { silent = true })
vim.keymap.set("n", "<Leader><Esc>", function()
	Forty_Two_pattern()
end, { silent = true })
vim.keymap.set("n", "<CR>", "za", { silent = true })
vim.keymap.set({ "n", "v" }, "<Leader>qa", ":qa!<CR>", { silent = true })
vim.keymap.set("t", "<Leader>qa", "<C-\\><C-n>:qa!<CR>", { silent = true })


-- Always keep at the bottom
MidnightNexus()
StatusLineSetup()
