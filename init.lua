local unpack = table.unpack or unpack
-- Helpers
local Helpers = {}
function Helpers.get_os()
	if Helpers._os_cache then
		return Helpers._os_cache.os, Helpers._os_cache.arch, Helpers._os_cache
	end
	local raw_os, raw_arch, raw_release, raw_version = "", "", "", ""
	local uv = vim and (vim.uv or vim.loop)
	if uv and uv.os_uname then
		local uname = uv.os_uname()
		raw_os      = uname.sysname or ""
		raw_arch    = uname.machine or ""
		raw_release = uname.release or ""
		raw_version = uname.version or ""
	end
	if jit then
		if raw_os == "" then raw_os = jit.os or "" end
		if raw_arch == "" then raw_arch = jit.arch or "" end
	end
	if raw_os == "" then
		local sep = package and package.config and package.config:sub(1, 1)
		if sep == "\\" or (os and os.getenv and (os.getenv("WINDIR") or os.getenv("COMSPEC"))) then
			raw_os = "windows"
		elseif os and os.getenv and os.getenv("OSTYPE") then
			raw_os = os.getenv("OSTYPE") or ""
		else
			local cpath = package and package.cpath or ""
			if cpath:match("%.dll") then raw_os = "windows"
			elseif cpath:match("%.dylib") then raw_os = "mac"
			elseif cpath:match("%.so") then raw_os = "linux" end
		end
	end
	if raw_arch == "" and os and os.getenv then
		raw_arch = os.getenv("PROCESSOR_ARCHITEW6432")
			or os.getenv("PROCESSOR_ARCHITECTURE")
			or os.getenv("HOSTTYPE")
			or ""
	end
	local norm_os   = raw_os:lower()
	local norm_arch = raw_arch:lower()
	local exact_os = {
		windows = "Windows", windows_nt = "Windows", win32 = "Windows", win64 = "Windows",
		linux   = "Linux",
		darwin  = "Mac", mac = "Mac", macos = "Mac", osx = "Mac",
		freebsd = "BSD", openbsd = "BSD", netbsd = "BSD",
		sunos   = "Solaris",
	}
	local exact_arch = {
		x86_64 = "x86_64", ["x86-64"] = "x86_64", amd64 = "x86_64", x64 = "x86_64",
		i386 = "x86", i486 = "x86", i586 = "x86", i686 = "x86", x86 = "x86",
		aarch64 = "arm64", arm64 = "arm64",
		arm = "arm",
		ppc64 = "ppc64", ppc64le = "ppc64le",
		riscv64 = "riscv64",
	}
	local os_name   = exact_os[norm_os]
	local arch_name = exact_arch[norm_arch]
	if not os_name and norm_os ~= "" then
		local os_patterns = {
			{ pat = "^windows", val = "Windows" },
			{ pat = "^mingw",   val = "Windows" },
			{ pat = "^cygwin",  val = "Windows" },
			{ pat = "^msys",    val = "Windows" },
			{ pat = "bsd$",     val = "BSD" },
		}
		for _, rule in ipairs(os_patterns) do
			if norm_os:match(rule.pat) then
				os_name = rule.val
				break
			end
		end
	end
	if not arch_name and norm_arch ~= "" then
		local arch_patterns = {
			{ pat = "^aarch64", val = "arm64" },
			{ pat = "^arm64",   val = "arm64" },
			{ pat = "^armv",    val = "arm" },
			{ pat = "^ppc64",   val = "ppc64" },
			{ pat = "power",    val = "powerpc" },
			{ pat = "^mips",    val = "mips" },
		}
		for _, rule in ipairs(arch_patterns) do
			if norm_arch:match(rule.pat) then
				arch_name = rule.val
				break
			end
		end
	end
	os_name   = os_name or "unknown"
	arch_name = arch_name or "unknown"
	local is_wsl = false
	if os_name == "Linux" then
		local rel = raw_release:lower()
		if rel:find("microsoft", 1, true) or rel:find("wsl", 1, true) or (os and os.getenv and os.getenv("WSL_DISTRO_NAME")) then
			is_wsl = true
		end
	end
	local ptr_bits, endian = nil, nil
	local ok_ffi, ffi = pcall(require, "ffi")
	if ok_ffi and ffi then
		ptr_bits = ffi.sizeof("void*") * 8
		endian   = ffi.abi("le") and "little" or "big"
		if arch_name == "unknown" then
			arch_name = (ptr_bits == 64) and "64bit_unknown" or "32bit_unknown"
		end
	end
	local host_arch = arch_name
	if os_name == "Mac" and arch_name == "x86_64" and raw_version:find("RELEASE_ARM64", 1, true) then
		host_arch = "arm64"
	elseif os_name == "Windows" and arch_name == "x86_64" and os and os.getenv then
		local proc_id = (os.getenv("PROCESSOR_IDENTIFIER") or ""):lower()
		if proc_id:find("arm", 1, true) then
			host_arch = "arm64"
		end
	end
	Helpers._os_cache = {
		os        = os_name,
		arch      = arch_name,
		host_arch = host_arch,
		is_wsl    = is_wsl,
		ptr_bits  = ptr_bits,
		endian    = endian,
	}
	return Helpers._os_cache.os, Helpers._os_cache.arch, Helpers._os_cache
end
function Helpers.split(str, sep)
	if str == nil then return {} end
	local parts = {}
	if sep == nil then
		for word in str:gmatch("%S+") do
			parts[#parts + 1] = word
		end
		return parts
	end
	if sep == "" then
		for i = 1, #str do
			parts[#parts + 1] = str:sub(i, i)
		end
		return parts
	end
	local start_idx = 1
	local sep_len = #sep
	while true do
		local match_start = str:find(sep, start_idx, true)
		if not match_start then
			parts[#parts + 1] = str:sub(start_idx)
			break
		end
		parts[#parts + 1] = str:sub(start_idx, match_start - 1)
		start_idx = match_start + sep_len
	end
	return parts
end
function Helpers.substitute(str, from, to, flag)
	if str == nil then return nil end
	if not from or #from == 0 then return str end
	to = to or ""
	local res = {}
	local start_idx = 1
	local from_len = #from
	local global = (flag == "g")
	while true do
		local match_start = str:find(from, start_idx, true)
		if not match_start then
			res[#res + 1] = str:sub(start_idx)
			break
		end
		res[#res + 1] = str:sub(start_idx, match_start - 1)
		res[#res + 1] = to
		start_idx = match_start + from_len
		if not global then
			res[#res + 1] = str:sub(start_idx)
			break
		end
	end
	return table.concat(res)
end
function Helpers.replace_char(str, chars, to, flag)
	if str == nil then return nil end
	if not chars or #chars == 0 then return str end
	to = to or ""
	local utf8_char = "[%z\1-\127\194-\244][\128-\191]*"
	local lookup = {}
	for cp in chars:gmatch(utf8_char) do
		lookup[cp] = true
	end
	local res = {}
	local global = (flag == "g")
	local replaced = false
	for cp in str:gmatch(utf8_char) do
		if (global or not replaced) and lookup[cp] then
			res[#res + 1] = to
			replaced = true
		else
			res[#res + 1] = cp
		end
	end
	return table.concat(res)
end
function Helpers.contains(str, sub)
	if str == nil or sub == nil then return false end
	return str:find(sub, 1, true) ~= nil
end
function Helpers.index_of(list, value)
	for i, v in ipairs(list) do
		if v == value then
			return i
		end
	end
	return nil
end
function Helpers.in_list(value, list)
	return Helpers.index_of(list, value) ~= nil
end
function Helpers.with_job_progress(title, start_fn)
	local width = 20
	local bar_len = math.min(5, width)
	local pos = 0
	local dir = 1
	local finished = false
	local timer = vim.uv.new_timer()
	local function cleanup(clear_echo)
		if finished then return end
		finished = true
		if timer and not timer:is_closing() then
			timer:stop()
			timer:close()
		end
		if clear_echo then
			vim.api.nvim_echo({ { "", "None" } }, false, {})
		end
	end
	local function render()
		if finished then return end
		local left = string.rep("-", pos)
		local block = string.rep("#", bar_len)
		local right = string.rep("-", math.max(0, width - bar_len - pos))
		local msg = string.format("%s [%s%s%s]", title, left, block, right)
		local max_cols = math.max(1, (vim.o.columns or 80) - 12)
		if #msg > max_cols then
			msg = msg:sub(1, max_cols)
		end
		vim.api.nvim_echo({ { msg, "None" } }, false, {})
		pos = pos + dir
		if pos + bar_len >= width or pos <= 0 then
			dir = -dir
		end
	end
	local function done(final_msg, level)
		vim.schedule(function()
			cleanup(final_msg == nil)
			if final_msg then
				vim.notify(final_msg, level or vim.log.levels.INFO)
			end
		end)
	end
	timer:start(0, 80, vim.schedule_wrap(render))
	local ok, err = pcall(start_fn, done)
	if not ok then
		cleanup(false)
		vim.notify(string.format("%s failed: %s", title, tostring(err)), vim.log.levels.ERROR)
	end
end
local function is_windows_host()
	if SYS and SYS.is_win ~= nil then return SYS.is_win end
	return Helpers.get_os() == "Windows"
end
local function is_root_path(norm)
	if norm == "/"
		or norm:match("^[A-Za-z]:/?$") ~= nil
		or norm:match("^//[%?%.]/?$") ~= nil
		or norm:match("^//[%?%.]/[A-Za-z]:/?$") ~= nil
		or norm:match("^//%?/UNC/?$") ~= nil
		or norm:match("^//%?/UNC/[^/]+/?$") ~= nil
		or norm:match("^//%?/UNC/[^/]+/[^/]+/?$") ~= nil
		or norm:match("^//%?/GLOBALROOT") ~= nil
		or norm:match("^//[^/]+/?$") ~= nil
		or norm:match("^//[^/]+/[^/]+/?$") ~= nil then
		return true
	end
	if norm:match("^//%./") ~= nil and norm:match("^//%./[A-Za-z]:/") == nil then
		return true
	end
	return false
end
function Helpers.join_path(...)
	local args = {}
	for i = 1, select("#", ...) do
		local v = select(i, ...)
		if v and v ~= "" then
			args[#args + 1] = v
		end
	end
	if #args == 0 then return "" end
	return Helpers.norm_path(vim.fs.joinpath(unpack(args)))
end
function Helpers.resolve_path(path)
	local norm = Helpers.norm_path(path)
	if norm == "" then return "" end
	local real = vim.uv.fs_realpath(norm)
	return real and Helpers.norm_path(real) or norm
end
function Helpers.is_valid_filename(name)
	if not name or name == "" or name == "." or name == ".." or name:find("%z") or name:find("/", 1, true) then
		return false, "Invalid name."
	end
	if is_windows_host() then
		if name:find("\\", 1, true) or name:match('[<>:"|?*\1-\31]') or name:match("[%s%.]+$") then
			return false, "Invalid Windows filename characters, separator, or trailing dot/space."
		end
		local base = name:lower():match("^([^%.]+)")
		if base and (base == "con" or base == "prn" or base == "aux" or base == "nul"
			or base:match("^com[0-9]$") or base:match("^lpt[0-9]$")) then
			return false, "Reserved Windows device name: " .. name
		end
	end
	return true
end
function Helpers.stat(path)
	if not path or path == "" then return nil end
	return vim.uv.fs_stat(path)
end
function Helpers.is_dir(path)
	local st = Helpers.stat(path)
	return st ~= nil and st.type == "directory"
end
function Helpers.exists(path)
	return Helpers.stat(path) ~= nil
end
function Helpers.mkdir_p(path)
	local norm = Helpers.norm_path(path)
	if norm == "" then return false, "Empty path." end
	if Helpers.is_dir(norm) then return true end
	if is_root_path(norm) then
		return false, "Root path unavailable: " .. norm
	end
	local parent = Helpers.norm_path(vim.fs.dirname(norm))
	if parent ~= "" and parent ~= norm then
		local ok, err = Helpers.mkdir_p(parent)
		if not ok then return false, err end
	end
	local ok, err = vim.uv.fs_mkdir(norm, 493) -- 0755
	if not ok and not Helpers.is_dir(norm) then
		return false, err
	end
	return true
end
function Helpers.rm_rf(path)
	local norm = Helpers.norm_path(path)
	if norm == "" then return false, "Empty path." end
	if is_root_path(norm) then
		return false, "Refusing to remove root path: " .. norm
	end
	local lst = vim.uv.fs_lstat(norm)
	if not lst then return true end
	local win = is_windows_host()
	if lst.type ~= "directory" then
		if win then
			pcall(vim.uv.fs_chmod, norm, 438) -- 0666: clear read-only bit (e.g., .git objects)
		end
		local ok, err = vim.uv.fs_unlink(norm)
		if not ok and win and lst.type == "link" then
			return vim.uv.fs_rmdir(norm)
		end
		return ok, err
	end
	local req, scan_err = vim.uv.fs_scandir(norm)
	if not req then
		pcall(vim.uv.fs_chmod, norm, 493) -- 0755 retry if directory lacked read/exec
		req, scan_err = vim.uv.fs_scandir(norm)
		if not req then return false, scan_err end
	end
	while true do
		local name = vim.uv.fs_scandir_next(req)
		if not name then break end
		local ok, err = Helpers.rm_rf(Helpers.join_path(norm, name))
		if not ok then return false, err end
	end
	pcall(vim.uv.fs_chmod, norm, win and 511 or 493)
	return vim.uv.fs_rmdir(norm)
end
function Helpers.norm_path(path)
	if type(path) ~= "string" or path == "" then return "" end
	local p = vim.fs.normalize(path)
	if p:match("^/+$") then
		return "/"
	end
	if p:match("^[A-Za-z]:$") or p:match("^//[%?%.]/[A-Za-z]:$") then
		return p .. "/"
	end
	if p == "/"
		or p:match("^[A-Za-z]:/$")
		or p:match("^//[%?%.]/[A-Za-z]:/$") then
		return p
	end
	return (p:gsub("/+$", ""))
end
function Helpers.touch(path)
	local norm = Helpers.norm_path(path)
	if norm == "" then return false, "Empty path." end
	if is_root_path(norm) then
		return false, "Cannot touch root path: " .. norm
	end
	local sec, usec = vim.uv.gettimeofday()
	if not sec then return false, usec end
	local now = sec + (usec / 1e6)
	if Helpers.stat(norm) ~= nil then
		local ok, err = vim.uv.fs_utime(norm, now, now)
		if not ok then return false, err end
		return true
	end
	local parent = Helpers.norm_path(vim.fs.dirname(norm))
	if parent ~= "" and not Helpers.is_dir(parent) then
		local ok, err = Helpers.mkdir_p(parent)
		if not ok then return false, err end
	end
	local fd, err = vim.uv.fs_open(norm, "a", 420) -- 0644, non-truncating
	if not fd then return false, err end
	pcall(vim.uv.fs_futime, fd, now, now)
	vim.uv.fs_close(fd)
	return true
end
function Helpers.is_list(tbl)
	if type(tbl) ~= "table" then return false end
	if vim and vim.islist then
		return vim.islist(tbl)
	end
	local count = 0
	local k = next(tbl)
	while k ~= nil do
		if type(k) ~= "number" or k < 1 or k % 1 ~= 0 then
			return false
		end
		count = count + 1
		k = next(tbl, k)
	end
	for i = 1, count do
		if rawget(tbl, i) == nil then
			return false
		end
	end
	return true
end
local function safe_tostring(val)
	local ok, str = pcall(tostring, val)
	str = ok and str or ("<" .. type(val) .. ">")
	return (str:gsub("%z", "\\000"))
end
local function safe_quote(str)
	return (string.format("%q", str):gsub("%z", "\\000"))
end
function Helpers.print_list(list, indent, visited)
	indent = math.max(0, indent or 0)
	if type(list) ~= "table" then
		print(string.rep("  ", indent) .. safe_tostring(list))
		return
	end
	visited = visited or {}
	if visited[list] then
		print(string.rep("  ", indent) .. "<cycle>")
		return
	end
	visited[list] = true
	if indent == 0 then
		print("[")
	end
	for index, value in ipairs(list) do
		local item_padding = string.rep("  ", indent + 1)
		if type(value) == "table" then
			print(item_padding .. "[" .. index .. "] = {")
			Helpers.print_table(value, indent + 2, visited)
			print(item_padding .. "}")
		elseif type(value) == "string" then
			print(item_padding .. safe_quote(value))
		else
			print(item_padding .. safe_tostring(value))
		end
	end
	if indent == 0 then
		print("]")
	end
	visited[list] = nil
end
function Helpers.print_table(table_obj, indent, visited)
	indent = math.max(0, indent or 0)
	visited = visited or {}
	local padding = string.rep("  ", indent)
	if type(table_obj) ~= "table" then
		print(padding .. safe_tostring(table_obj))
		return
	end
	if visited[table_obj] then
		print(padding .. "<cycle>")
		return
	end
	visited[table_obj] = true
	if Helpers.is_list(table_obj) and next(table_obj) ~= nil then
		for _, value in ipairs(table_obj) do
			if type(value) == "table" then
				print(padding .. "{")
				Helpers.print_table(value, indent + 1, visited)
				print(padding .. "}")
			elseif type(value) == "string" then
				print(padding .. safe_quote(value))
			else
				print(padding .. safe_tostring(value))
			end
		end
		visited[table_obj] = nil
		return
	end
	local empty = true
	for key, value in pairs(table_obj) do
		empty = false
		local formatted_key = type(key) == "string"
			and ("[" .. safe_quote(key) .. "]")
			or ("[" .. safe_tostring(key) .. "]")
		if type(value) == "table" then
			print(padding .. formatted_key .. " = {")
			Helpers.print_table(value, indent + 1, visited)
			print(padding .. "}")
		elseif type(value) == "string" then
			print(padding .. formatted_key .. " = " .. safe_quote(value))
		else
			print(padding .. formatted_key .. " = " .. safe_tostring(value))
		end
	end
	if indent == 0 and empty then
		print("{}")
	end
	visited[table_obj] = nil
end
function Helpers.download_from_url(url, opts, cb)
	local DEFAULT_USER_AGENT = "nvim-download.lua (+https://github.com/QTimos/vim-nvim-config)"
	local PY_SCRIPT = [[
    import sys, json, urllib.request, urllib.error
    url, out, timeout = sys.argv[1], sys.argv[2], float(sys.argv[3])
    headers = dict(json.load(sys.stdin))
    class Https(urllib.request.HTTPRedirectHandler):
        def redirect_request(self, req, fp, code, msg, hdrs, newurl):
            if not newurl.lower().startswith("https://"):
                raise urllib.error.URLError("refusing non-https redirect: " + newurl)
            return urllib.request.HTTPRedirectHandler.redirect_request(
                self, req, fp, code, msg, hdrs, newurl)
    opener = urllib.request.build_opener(Https)
    req = urllib.request.Request(url, headers=headers)
    with opener.open(req, timeout=timeout) as r, open(out, "wb") as f:
        while True:
            chunk = r.read(65536)
            if not chunk:
                break
            f.write(chunk)
	]]
	PY_SCRIPT = ("\n" .. PY_SCRIPT):gsub("\n    ", "\n"):sub(2)
	local function tail(s)
		s = vim.trim(s or "")
		local lines = vim.split(s, "\n", { plain = true, trimempty = true })
		local line = (s:find("Traceback", 1, true) and lines[#lines]) or lines[1] or ""
		return #line > 300 and (line:sub(1, 300) .. "...") or line
	end
	if type(cb) ~= "function" then
		error("download_from_url: cb must be a function", 2)
	end
	opts = opts or {}
	local timeout_ms = opts.timeout or 30000
	local secs = math.max(1, math.floor(timeout_ms / 1000))
	local outpath = opts.outpath
	if outpath == "" then outpath = nil end
	local want_string = outpath == nil
	local part_path = outpath and (outpath .. ".part") or vim.fn.tempname()
	local called = false
	local function done(err, body)
		if called then return end
		called = true
		if err or want_string then pcall(vim.uv.fs_unlink, part_path) end
		if err then
			cb(err)
		elseif want_string then
			cb(nil, body)
		else
			cb(nil, outpath)
		end
	end
	local function fail_async(msg)
		vim.schedule(function() done(msg) end)
	end
	if type(url) ~= "string" or not url:lower():match("^https://") then
		return fail_async("only https:// URLs are supported: " .. tostring(url))
	end
	local headers = opts.headers or {}
	do
		local has_ua = false
		for k in pairs(headers) do
			if type(k) == "string" and k:lower() == "user-agent" then
				has_ua = true
				break
			end
		end
		if not has_ua then
			headers = vim.tbl_extend("force", headers, { ["User-Agent"] = opts.user_agent or DEFAULT_USER_AGENT })
		end
	end
	local hdr = {}
	for k, v in pairs(headers) do
		k, v = tostring(k), tostring(v)
		if k == "" or k:find("[:\r\n]") or v:find("[\r\n]") then
			return fail_async("invalid header: " .. k)
		end
		hdr[#hdr + 1] = { k, v }
	end
	table.sort(hdr, function(a, b) return a[1] < b[1] end)
	local native_headers = {}
	for _, h in ipairs(hdr) do native_headers[h[1]] = h[2] end
	local parent = vim.fn.fnamemodify(part_path, ":h")
	if vim.fn.isdirectory(parent) == 0 then
		pcall(vim.fn.mkdir, parent, "p")
		if vim.fn.isdirectory(parent) == 0 then
			return fail_async("Cannot create directory: " .. parent)
		end
	end
	local function read_file(path, max_bytes)
		local f = io.open(path, "rb")
		if not f then return nil, "cannot read downloaded file" end
		local data = max_bytes and (f:read(max_bytes) or "") or (f:read("*a") or "")
		f:close()
		return data
	end
	local function looks_like_error_page(head)
		local lower = vim.trim(head):lower()
		return lower:sub(1, 1) == "<" or lower:find("^<!doctype") ~= nil or lower:find("^<html") ~= nil
	end
	local function validate_payload(full_data_or_nil, path)
		local data = full_data_or_nil
		local need_full = opts.verify and opts.verify.sha256 ~= nil
		if data == nil and need_full then
			local d, err = read_file(path)
			if not d then return err end
			data = d
		end
		local head
		if data ~= nil then
			head = data:sub(1, 512)
		else
			local h, err = read_file(path, 512)
			if not h then return err end
			head = h
		end
		if looks_like_error_page(head) then
			return "downloaded content looks like an HTML error page, not the expected payload"
		end
		if opts.min_size then
			local size
			if data ~= nil then
				size = #data
			else
				local ok, stat = pcall(vim.uv.fs_stat, path)
				size = ok and stat and stat.size or nil
			end
			if size and size < opts.min_size then
				return string.format(
					"downloaded content is only %d bytes (expected at least %d) - likely an error response",
					size, opts.min_size)
			end
		end
		if need_full then
			local ok, actual = pcall(vim.fn.sha256, data)
			if not ok then
				return "cannot verify checksum: vim.fn.sha256() is unavailable in this Neovim build"
			end
			if actual:lower() ~= opts.verify.sha256:lower() then
				return string.format("checksum mismatch: expected sha256 %s, got %s", opts.verify.sha256, actual)
			end
		end
		return nil
	end
	local function finish()
		if want_string then
			local data, err = read_file(part_path)
			if not data then return done(err) end
			local verr = validate_payload(data, part_path)
			if verr then return done(verr) end
			return done(nil, data)
		end
		local verr = validate_payload(nil, part_path)
		if verr then return done(verr) end
		local ok, err = vim.uv.fs_rename(part_path, outpath)
		if not ok then
			return done("cannot move download into place: " .. tostring(err))
		end
		done(nil)
	end
	local tiers = {}
	local function add(name, start) tiers[#tiers + 1] = { name = name, start = start } end
	local function run_process(cmd, stdin, on_done)
		local ok, spawn_err = pcall(vim.system, cmd,
			{ text = true, stdin = stdin, timeout = timeout_ms + 1000 },
			vim.schedule_wrap(function(res)
				if res.code == 0 then return on_done(nil) end
				local why
				if res.code == nil or (res.signal or 0) ~= 0 then
					why = "timed out"
				else
					why = string.format("exit %d: %s", res.code, tail(res.stderr))
				end
				on_done(why)
			end))
		if not ok then
			on_done("spawn failed (" .. tail(tostring(spawn_err)) .. ")")
		end
	end
	add("curl", function(on_done)
		local bin = vim.fn.exepath("curl")
		if bin == "" then return "not found" end
		local cmd = {
			bin, "-fsSL",
			"--proto", "=https", "--proto-redir", "=https",
			"--connect-timeout", tostring(math.min(15, secs)),
			"--max-time", tostring(secs),
		}
		for _, h in ipairs(hdr) do
			vim.list_extend(cmd, { "-H", h[1] .. ": " .. h[2] })
		end
		vim.list_extend(cmd, { "-o", part_path, url })
		run_process(cmd, nil, on_done)
	end)
	add("wget", function(on_done)
		local bin = vim.fn.exepath("wget")
		if bin == "" then return "not found" end
		local cmd = { bin, "-q", "-T", tostring(secs) }
		for _, h in ipairs(hdr) do
			vim.list_extend(cmd, { "--header", h[1] .. ": " .. h[2] })
		end
		vim.list_extend(cmd, { "-O", part_path, url })
		run_process(cmd, nil, on_done)
	end)
	add("fetch", function(on_done)
		local bin = vim.fn.exepath("fetch")
		if bin == "" then return "not found" end
		if #hdr > 0 then return "cannot send custom headers" end
		run_process({ bin, "-q", "-T", tostring(secs), "-o", part_path, url }, nil, on_done)
	end)
	if vim.fn.has("win32") == 1 then
		add("powershell", function(on_done)
			local bin = vim.fn.exepath("powershell.exe")
			if bin == "" then bin = vim.fn.exepath("pwsh") end
			if bin == "" then return "not found" end
			local function q(s) return "'" .. (tostring(s):gsub("'", "''")) .. "'" end
			local parts = {
				"$ErrorActionPreference='Stop'",
				"$ProgressPreference='SilentlyContinue'",
				"try{[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12}catch{}",
				"$h=@{}",
			}
			for _, h in ipairs(hdr) do
				parts[#parts + 1] = string.format("$h[%s]=%s", q(h[1]), q(h[2]))
			end
			parts[#parts + 1] = string.format(
				"Invoke-WebRequest -Uri %s -Headers $h -OutFile %s -UseBasicParsing -TimeoutSec %d",
				q(url), q(part_path), secs)
			run_process({ bin, "-NoProfile", "-NonInteractive", "-Command", table.concat(parts, ";") }, nil, on_done)
		end)
	end
	add("python", function(on_done)
		local bin = vim.fn.exepath("python3")
		if bin == "" then bin = vim.fn.exepath("python") end
		if bin == "" then return "not found" end
		run_process({ bin, "-c", PY_SCRIPT, url, part_path, tostring(secs) }, vim.json.encode(hdr), on_done)
	end)
	add("vim.net.request", function(on_done)
		if not (vim.net and vim.net.request) then return "not available" end
		local settled = false
		local function finish_once(err)
			if settled then return end
			settled = true
			on_done(err)
		end
		local ok, job_or_err = pcall(vim.net.request, "GET", url, {
			headers = native_headers,
			outpath = part_path,
		}, vim.schedule_wrap(function(err, res)
			if err then
				finish_once(string.format("status %s: %s", res and res.status or "?", tostring(err)))
			else
				finish_once(nil)
			end
		end))
		if not ok then return "spawn failed (" .. tail(tostring(job_or_err)) .. ")" end
		local job = job_or_err
		local timer = vim.uv.new_timer()
		if timer then
			timer:start(timeout_ms, 0, vim.schedule_wrap(function()
				pcall(function() timer:stop(); timer:close() end)
				if not settled then
					pcall(function() job:close() end)
					finish_once("timed out")
				end
			end))
		end
	end)
	local errors = {}
	local function run(i)
		if called then return end
		local tier = tiers[i]
		if not tier then
			return done("all downloaders failed:\n  " .. table.concat(errors, "\n  "))
		end
		local reported = false
		local function on_done(err)
			if reported then return end
			reported = true
			if err == nil then
				local ok, ferr = pcall(finish)
				if not ok then
					errors[#errors + 1] = tier.name .. ": finish() failed: " .. tail(tostring(ferr))
					pcall(vim.uv.fs_unlink, part_path)
					return run(i + 1)
				end
				return
			end
			errors[#errors + 1] = tier.name .. ": " .. err
			pcall(vim.uv.fs_unlink, part_path)
			run(i + 1)
		end
		local skip = tier.start(on_done)
		if skip then
			errors[#errors + 1] = tier.name .. ": skipped (" .. skip .. ")"
			run(i + 1)
		end
	end
	vim.schedule(function() run(1) end)
end
_G.Helpers = Helpers


-- Getting the os and architecture
local os_name, arch_name, os_info = Helpers.get_os()
local is_win   = (os_name == "Windows")
local is_mac   = (os_name == "Mac")
local is_linux = (os_name == "Linux")
local is_bsd   = (os_name == "BSD")
local SYS = {
	os        = os_name,
	arch      = arch_name,
	host_arch = os_info.host_arch,
	ptr_bits  = os_info.ptr_bits,
	endian    = os_info.endian,
	is_win    = is_win,
	is_mac    = is_mac,
	is_linux  = is_linux,
	is_bsd    = is_bsd,
	is_wsl    = os_info.is_wsl,
	is_unix   = (is_linux or is_mac or is_bsd),
	exe_ext   = is_win and ".exe" or "",
	lib_ext   = is_win and ".dll" or (is_mac and ".dylib" or ".so"),
	path_sep  = is_win and ";" or ":",
	dir_sep   = is_win and "\\" or "/",
}
_G.SYS = SYS


-- Bin directory for all external tools
BinDir = vim.fn.stdpath("config").."/bin"






vim.g.mapleader = " "
vim.g.localleader = " "
vim.g.markdown_syntax_conceal = 1
vim.g.netrw_list_hide = '^\\.\\.\\=/\\=$,^\\..*'
vim.g.netrw_hide = 0
vim.g.netrw_sizestyle = "b"
vim.g.netrw_timefmt = "%Y-%m-%d %H:%M:%S"

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
vim.opt.undofile = true

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
vim.highlight.priorities.semantic_tokens = 0
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
	highlight(0, "markdownH2", { fg = colors.magenta, bold = true })
	highlight(0, "markdownH3", { fg = colors.pink, bold = true })
	highlight(0, "markdownH4", { fg = colors.green, bold = true })
	highlight(0, "markdownH5", { fg = colors.cyan, bold = true })
	highlight(0, "markdownH6", { fg = colors.orange, bold = true })
	highlight(0, "markdownHeadingDelimiter", { fg = colors.grey })
	highlight(0, "markdownBold", { fg = colors.orange, bold = true })
	highlight(0, "markdownItalic", { fg = colors.yellow, italic = true })
	highlight(0, "markdownCode", { fg = colors.green })
	highlight(0, "markdownCodeBlock", { fg = colors.green })
	highlight(0, "markdownLinkText", { fg = colors.blue, underline = true })
	highlight(0, "markdownUrl", { fg = colors.blue, underline = true })
	highlight(0, "markdownListMarker", { fg = colors.magenta })
	highlight(0, "markdownBlockquote", { fg = colors.grey, italic = true })

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

	-- Netrw
	highlight(0, "NetrwConnector", { fg = colors.blue })
	highlight(0, "netrwDir", { fg = colors.cyan, bold = true })
	highlight(0, "netrwExe", { fg = colors.red })
	highlight(0, "netrwSymLink", { fg = colors.magenta, italic = true })
	highlight(0, "netrwClassify", { fg = colors.grey })
end


-- File skeletons
local Skeletons = {
	ext_map = {
		c = "c",
		h = "h",
		cpp = "cpp",
		cc = "cpp",
		cxx = "cpp",
		hpp = "hpp",
		hh = "hpp",
		hxx = "hpp",
		py = "python",
		css = "css",
		html = "html",
		htm = "html",
		rs = "rust",
		go = "go",
		lua = "lua",
		vim = "vim",
	},
}
function Skeletons.make_header_guard(file_name, fallback_name)
	local base = (file_name ~= "" and vim.fs.basename(file_name)) or fallback_name
	return base:upper():gsub("[^A-Z0-9]", "_")
end
Skeletons.templates = {
	c = {
		cursor_pos = { 7, 1 },
		lines = {
			"#include <stdio.h>",
			"#include <stdlib.h>",
			"",
			"",
			"int main(int argc, char **argv)",
			"{",
			"\t",
			"\treturn (0);",
			"}",
		},
	},
	cpp = {
		cursor_pos = { 5, 1 },
		lines = {
			"#include <iostream>",
			"",
			"int main(int argc, char **argv)",
			"{",
			"\t",
			"\treturn 0;",
			"}",
		},
	},
	h = function(file_name)
		local guard = Skeletons.make_header_guard(file_name, "HEADER_H")
		return {
			cursor_pos = { 4, 0 },
			lines = {
				"#ifndef " .. guard,
				"# define " .. guard,
				"",
				"",
				"#endif",
			},
		}
	end,
	hpp = function(file_name)
		local guard = Skeletons.make_header_guard(file_name, "HEADER_HPP")
		return {
			cursor_pos = { 4, 0 },
			lines = {
				"#ifndef " .. guard,
				"#define " .. guard,
				"",
				"",
				"#endif // " .. guard,
			},
		}
	end,
	rust = {
		cursor_pos = { 2, 1 },
		lines = {
			"fn main() {",
			"\t",
			"}",
		},
	},
	go = {
		cursor_pos = { 6, 1 },
		lines = {
			"package main",
			"",
			'import "fmt"',
			"",
			"func main() {",
			"\t",
			'\t_ = fmt.Sprint("")',
			"}",
		},
	},
	lua = {
		cursor_pos = { 4, 1 },
		lines = {
			"local M = {}",
			"",
			"function M.setup()",
			"\t",
			"end",
			"",
			"return M",
		},
	},
	vim = {
		cursor_pos = { 3, 0 },
		lines = {
			'" Vim script',
			"scriptencoding utf-8",
			"",
			"",
		},
	},
	python = {
		cursor_pos = { 4, 4 },
		lines = {
			"",
			"",
			"def main() -> None:",
			"    raise NotImplementedError()",
			"",
			"",
			'if __name__ == "__main__":',
			"    main()",
		},
	},
	css = {
		cursor_pos = { 2, 12 },
		lines = {
			":root {",
			"\t--primary: ;",
			"\t--secondary: ;",
			"\t--bg-body: ;",
			"\t--text-main: ;",
			"\t--font-body: ;",
			"\t--font-heading: ;",
			"\t--radius: ;",
			"\t--container-width: ;",
			"}",
			"",
			"*, *::before, *::after {",
			"\tbox-sizing: border-box;",
			"}",
			"",
			"* {",
			"\tmargin: 0;",
			"\tpadding: 0;",
			"}",
			"",
			"html {",
			"\t-webkit-text-size-adjust: none;",
			"\ttext-size-adjust: none;",
			"\tscroll-behavior: smooth;",
			"\theight: 100%;",
			"}",
			"",
			"body {",
			"\tmin-height: 100vh;",
			"\tline-height: 1.5;",
			"\t-webkit-font-smoothing: antialiased;",
			"\t-moz-osx-font-smoothing: grayscale;",
			"\ttext-rendering: optimizeSpeed;",
			"}",
			"",
			"img, picture, video, canvas, svg {",
			"\tdisplay: block;",
			"\tmax-width: 100%;",
			"\theight: auto;",
			"}",
			"",
			"input, button, textarea, select {",
			"\tfont: inherit;",
			"}",
			"",
			"ul, ol {",
			"\tlist-style: none;",
			"}",
			"",
			'button, [type="button"], [type="submit"] {',
			"\tcursor: pointer;",
			"}",
			"",
			"@media (prefers-reduced-motion: reduce) {",
			"\t*, *::before, *::after {",
			"\t\tanimation-duration: 0.01ms !important;",
			"\t\tanimation-iteration-count: 1 !important;",
			"\t\ttransition-duration: 0.01ms !important;",
			"\t\tscroll-behavior: auto !important;",
			"\t}",
			"}",
		},
	},
	html = {
		cursor_pos = { 9, 1 },
		lines = {
			"<!DOCTYPE html>",
			'<html lang="en">',
			"<head>",
			'\t<meta charset="UTF-8">',
			'\t<meta name="viewport" content="width=device-width, initial-scale=1.0">',
			"\t<title>Page Title</title>",
			"</head>",
			"<body>",
			"\t",
			"</body>",
			"</html>",
		},
	},
}
function Skeletons.get_template(bufnr, file_name)
	local lower_name = file_name:lower()
	local ext = vim.fn.fnamemodify(lower_name, ":e")
	local mapped_ext = Skeletons.ext_map[ext]
	local key = (mapped_ext == "h" or mapped_ext == "hpp") and mapped_ext or nil
	if not key then
		local ft = vim.bo[bufnr].filetype
		key = (ft and ft ~= "" and Skeletons.templates[ft]) and ft or mapped_ext
	end
	local tpl = key and Skeletons.templates[key] or nil
	if type(tpl) == "function" then
		return tpl(file_name), key
	end
	return tpl, key or vim.bo[bufnr].filetype
end
function Skeletons.is_buffer_empty(bufnr)
	if vim.api.nvim_buf_line_count(bufnr) ~= 1 then
		return false
	end
	local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1]
	return first_line == nil or first_line == ""
end
function Skeletons.insert_for_current_buf()
	local bufnr = vim.api.nvim_get_current_buf()
	if not vim.bo[bufnr].modifiable then
		vim.notify("Buffer is not modifiable.", vim.log.levels.ERROR)
		return
	end
	if not Skeletons.is_buffer_empty(bufnr) then
		vim.notify("Buffer is not empty; skipping skeleton.", vim.log.levels.WARN)
		return
	end
	local file_name = vim.api.nvim_buf_get_name(bufnr)
	local tpl, key = Skeletons.get_template(bufnr, file_name)
	if not tpl then
		local display_key = (key and key ~= "") and key or "none"
		vim.notify(("No skeleton defined for '%s'."):format(display_key), vim.log.levels.WARN)
		return
	end
	vim.api.nvim_buf_set_lines(bufnr, 0, 1, false, tpl.lines)
	if tpl.cursor_pos then
		local row, col = tpl.cursor_pos[1], tpl.cursor_pos[2]
		local line = tpl.lines[row] or ""
		if col >= #line then
			vim.api.nvim_win_set_cursor(0, { row, 0 })
			vim.cmd("startinsert!")
		else
			vim.api.nvim_win_set_cursor(0, { row, col })
			vim.cmd("startinsert")
		end
	end
end
vim.keymap.set("n", "<Leader> <Esc>", function()   --KEYMAP: INSERT FILE TYPE SPESIFIC SKELETON
		Skeletons.insert_for_current_buf()
end, { silent = true, desc = "Insert filetype skeleton" })


-- 42 header pattern
local Header42 = {
	user = "hdyani",
	mail_domain = "marvin@42.fr",
	comments = {
		c          = { left = "/*", right = "*/" },
		cpp        = { left = "/*", right = "*/" },
		objc       = { left = "/*", right = "*/" },
		objcpp     = { left = "/*", right = "*/" },
		java       = { left = "/*", right = "*/" },
		javascript = { left = "/*", right = "*/" },
		typescript = { left = "/*", right = "*/" },
		css        = { left = "/*", right = "*/" },
		scss       = { left = "/*", right = "*/" },
		rust       = { left = "/*", right = "*/" },
		go         = { left = "/*", right = "*/" },
		php        = { left = "/*", right = "*/" },
		make       = { left = "#",  right = "#"  },
		cmake      = { left = "#",  right = "#"  },
		sh         = { left = "#",  right = "#"  },
		bash       = { left = "#",  right = "#"  },
		zsh        = { left = "#",  right = "#"  },
		python     = { left = "#",  right = "#"  },
		ruby       = { left = "#",  right = "#"  },
		perl       = { left = "#",  right = "#"  },
		yaml       = { left = "#",  right = "#"  },
		toml       = { left = "#",  right = "#"  },
		dockerfile = { left = "#",  right = "#"  },
		lua        = { left = "--", right = "--" },
		sql        = { left = "--", right = "--" },
		haskell    = { left = "--", right = "--" },
		vim        = { left = '"',  right = '"'  },
		tex        = { left = "%",  right = "%"  },
		lisp       = { left = ";;", right = ";;" },
	},
}
function Header42.get_comment_delims(bufnr, file_name)
	local ft = vim.bo[bufnr].filetype
	local pair = (ft and ft ~= "") and Header42.comments[ft] or nil
	if pair then
		return pair.left, pair.right
	end
	local lower_name = file_name:lower()
	if lower_name == "makefile" or lower_name == "gnumakefile" or lower_name:match("%.mk$") or lower_name == "dockerfile" or lower_name == "cmakelists.txt" then
		return "#", "#"
	end
	local ext = vim.fn.fnamemodify(lower_name, ":e")
	local ext_map = {
		c = "c", h = "c",
		cpp = "cpp", hpp = "cpp", cc = "cpp", hh = "cpp", cxx = "cpp", hxx = "cpp",
		m = "objc", mm = "objcpp",
		py = "python", sh = "sh", bash = "bash", zsh = "zsh",
		lua = "lua", vim = "vim", rs = "rust", go = "go",
		js = "javascript", ts = "typescript", java = "java",
	}
	local mapped_ft = ext_map[ext]
	local mapped_pair = mapped_ft and Header42.comments[mapped_ft] or nil
	if mapped_pair then
		return mapped_pair.left, mapped_pair.right
	end
	return nil, nil
end
function Header42.wrap_line(inner, left, right)
	local left_pad = left .. string.rep(" ", 5 - #left)
	local right_pad = string.rep(" ", 5 - #right) .. right
	return left_pad .. inner .. right_pad
end
function Header42.border_line(left, right)
	local left_pad = left .. " "
	local right_pad = " " .. right
	local stars = string.rep("*", 80 - #left_pad - #right_pad)
	return left_pad .. stars .. right_pad
end
function Header42.get_user()
	if Header42.user and Header42.user ~= "" then
		return Header42.user
	end
	local uv = vim.uv or vim.loop
	if uv and uv.os_get_passwd then
		local ok, passwd = pcall(uv.os_get_passwd)
		if ok and passwd and passwd.username and passwd.username ~= "" then
			return passwd.username
		end
	end
	return os.getenv("USER") or os.getenv("USERNAME") or "marvin"
end
function Header42.format_time(sec)
	return os.date("%Y/%m/%d %H:%M:%S", sec or os.time())
end
function Header42.get_file_times(path, use_now_for_update)
	local now = os.time()
	local created_sec = now
	local updated_sec = now
	if path and path ~= "" then
		local uv = vim.uv or vim.loop
		local stat = uv.fs_stat(path)
		if stat then
			created_sec = (stat.birthtime and stat.birthtime.sec and stat.birthtime.sec > 0)
				and stat.birthtime.sec
				or (stat.ctime and stat.ctime.sec)
				or (stat.mtime and stat.mtime.sec)
				or now
			updated_sec = use_now_for_update
				and now
				or ((stat.mtime and stat.mtime.sec) or now)
		end
	end
	return "Created: " .. Header42.format_time(created_sec) .. " by ", "Updated: " .. Header42.format_time(updated_sec) .. " by "
end
function Header42.pad_username(user_name, base_spaces)
	if #user_name > 9 then
		return user_name:sub(1, 8), string.rep(" ", math.max(1, base_spaces))
	end
	return user_name, string.rep(" ", math.max(1, base_spaces + (9 - #user_name)))
end
function Header42.get_filename_line(file_name, left, right)
	local name = (#file_name > 41) and file_name:sub(1, 40) or file_name
	local spaces = string.rep(" ", 10 + (41 - #name))
	return Header42.wrap_line(name .. spaces .. ":+:      :+:    :+:", left, right)
end
function Header42.get_mail_line(user_name, left, right)
	local domain = Header42.mail_domain or "marvin@42.fr"
	if #domain > 30 then
		domain = domain:sub(1, 30)
	end
	local base_spaces = 19 + (12 - #domain)
	local name, spaces = Header42.pad_username(user_name, base_spaces)
	return Header42.wrap_line("By: " .. name .. " <" .. domain .. ">" .. spaces .. "+#+  +:+       +#+     ", left, right)
end
function Header42.get_created_line(user_name, created_prefix, left, right)
	local name, spaces = Header42.pad_username(user_name, 9)
	return Header42.wrap_line(created_prefix .. name .. spaces .. "#+#    #+#          ", left, right)
end
function Header42.get_updated_line(user_name, updated_prefix, left, right)
	local name, spaces = Header42.pad_username(user_name, 8)
	return Header42.wrap_line(updated_prefix .. name .. spaces .. "###   ########.fr    ", left, right)
end
function Header42.has_header(bufnr)
	if vim.api.nvim_buf_line_count(bufnr) < 11 then
		return false
	end
	local mail_line = vim.fn.getbufline(bufnr, 6)
	local created_line = vim.fn.getbufline(bufnr, 8)
	local updated_line = vim.fn.getbufline(bufnr, 9)
	local unpack_fn = table.unpack or unpack
	local m = unpack_fn(mail_line)
	local c = unpack_fn(created_line)
	local u = unpack_fn(updated_line)
	return (m and m:find("By:", 1, true) ~= nil)
		and (c and c:find("Created:", 1, true) ~= nil)
		and (u and u:find("Updated:", 1, true) ~= nil)
end
function Header42.update(bufnr, force)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	if not force and not vim.bo[bufnr].modified then
		return
	end
	if not Header42.has_header(bufnr) then
		return
	end
	local buf_path = vim.api.nvim_buf_get_name(bufnr)
	if buf_path == "" then
		return
	end
	local uv = vim.uv or vim.loop
	local full_path = uv.fs_realpath(buf_path) or buf_path
	local file_name = vim.fs.basename(full_path)
	local left, right = Header42.get_comment_delims(bufnr, file_name)
	if not left or not right then
		return
	end
	local _, updated_prefix = Header42.get_file_times(full_path, true)
	local user_name = Header42.get_user()
	local filename_line = Header42.get_filename_line(file_name, left, right)
	local updated_line = Header42.get_updated_line(user_name, updated_prefix, left, right)
	vim.api.nvim_buf_set_lines(bufnr, 3, 4, false, { filename_line })
	vim.api.nvim_buf_set_lines(bufnr, 8, 9, false, { updated_line })
end
function Header42.insert_or_update()
	local bufnr = vim.api.nvim_get_current_buf()
	local buf_path = vim.api.nvim_buf_get_name(bufnr)
	if buf_path == "" then
		vim.notify("Buffer has no filename!", vim.log.levels.WARN)
		return
	end
	local uv = vim.uv or vim.loop
	local full_path = uv.fs_realpath(buf_path) or buf_path
	local file_name = vim.fs.basename(full_path)
	local left, right = Header42.get_comment_delims(bufnr, file_name)
	if not left or not right then
		vim.notify("Unsupported filetype for 42 header: " .. file_name, vim.log.levels.WARN)
		return
	end
	if Header42.has_header(bufnr) then
		Header42.update(bufnr, true)
		return
	end
	local created_prefix, updated_prefix = Header42.get_file_times(full_path, true)
	local user_name = Header42.get_user()
	local lines = {
		Header42.border_line(left, right),
		Header42.wrap_line(string.rep(" ", 70), left, right),
		Header42.wrap_line(string.rep(" ", 53) .. ":::      ::::::::", left, right),
		Header42.get_filename_line(file_name, left, right),
		Header42.wrap_line(string.rep(" ", 49) .. "+:+ +:+         +:+  ", left, right),
		Header42.get_mail_line(user_name, left, right),
		Header42.wrap_line(string.rep(" ", 45) .. "+#+#+#+#+#+   +#+        ", left, right),
		Header42.get_created_line(user_name, created_prefix, left, right),
		Header42.get_updated_line(user_name, updated_prefix, left, right),
		Header42.wrap_line(string.rep(" ", 70), left, right),
		Header42.border_line(left, right),
		"",
	}
	vim.api.nvim_buf_set_lines(bufnr, 0, 0, false, lines)
end
local header42_group = vim.api.nvim_create_augroup("Header42AutoUpdate", { clear = true })
vim.api.nvim_create_autocmd("BufWritePre", {
	group = header42_group,
	pattern = "*",
	callback = function(args)
		Header42.update(args.buf, false)
	end,
})
vim.keymap.set("n", "<Leader><Esc>", function() --KEYMAP: INSERT 42 HEADER
	Header42.insert_or_update()
end, { silent = true, desc = "Insert 42 header" })


-- Netrw / file explorer
local Netrw = {
	cr_orig = nil,
}
local is_win_env = (SYS and SYS.is_win) or (Helpers.get_os() == "Windows")
vim.g.netrw_liststyle = 3
vim.g.netrw_banner = 0
vim.g.netrw_keepdir = 0
vim.g.netrw_browse_split = 4
vim.g.netrw_sort_by = "name"
vim.g.netrw_hide = 1
if not vim.g.netrw_list_hide or vim.g.netrw_list_hide == "" then
	vim.g.netrw_list_hide = [[\%(^\|\s\)\.\S\+]]
end
vim.g.netrw_localrmdir = is_win_env and "rmdir /s /q" or "rm -rf"
function Netrw.target_width()
	return math.max(15, math.floor(vim.o.columns * 0.15))
end
function Netrw.lock_width(win)
	win = win or Netrw.is_tree_open()
	if not win or not vim.api.nvim_win_is_valid(win) then return end
	vim.wo[win].winfixwidth = true
	if #vim.api.nvim_tabpage_list_wins(0) > 1 then
		local wanted = Netrw.target_width()
		if vim.api.nvim_win_get_width(win) ~= wanted then
			pcall(vim.api.nvim_win_set_width, win, wanted)
		end
	end
end
local function validate_relative_subpath(rel_path)
	local cleaned = rel_path:gsub("^[/\\]+", ""):gsub("[/\\]+$", "")
	if cleaned == "" then
		return false, "Path cannot consist solely of slashes."
	end
	for seg in cleaned:gmatch("[^/\\]+") do
		local ok, err = Helpers.is_valid_filename(seg)
		if not ok then
			return false, err
		end
	end
	return true
end
function Netrw.is_tree_open()
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].filetype == "netrw" then
			return win
		end
	end
	return nil
end
function Netrw.turn_off_banner(netrw_win)
	if vim.g.netrw_banner == 0 then return end
	vim.g.netrw_banner = 0
	if not vim.api.nvim_win_is_valid(netrw_win) then return end
	local buf = vim.api.nvim_win_get_buf(netrw_win)
	if vim.bo[buf].filetype == "netrw" then
		vim.api.nvim_win_call(netrw_win, function()
			vim.fn["netrw#Explore"](0, false, 0, "")
		end)
	end
end
function Netrw.refresh(target_dir)
	local tree_win = Netrw.is_tree_open() or vim.api.nvim_get_current_win()
	if not vim.api.nvim_win_is_valid(tree_win) then return end
	vim.api.nvim_win_call(tree_win, function()
		local root = vim.w.netrw_treetop or vim.b.netrw_curdir or target_dir
		if not root or root == "" then return end
		local saved_line = select(1, unpack(vim.api.nvim_win_get_cursor(tree_win)))
		vim.fn["netrw#Explore"](0, false, 0, root)
		local last_line = vim.api.nvim_buf_line_count(0)
		local target_line = math.max(1, math.min(saved_line, last_line))
		vim.api.nvim_win_set_cursor(tree_win, { target_line, 0 })
	end)
end
function Netrw.toggle_hidden_files()
	if not vim.g.netrw_list_hide or vim.g.netrw_list_hide == "" then
		vim.g.netrw_list_hide = [[\%(^\|\s\)\.\S\+]]
	end
	vim.g.netrw_hide = (vim.g.netrw_hide == 1) and 0 or 1
	Netrw.refresh()
end
function Netrw.get_root()
	local raw = vim.w.netrw_treetop or vim.b.netrw_curdir
	if not raw or raw == "" then return nil end
	return Helpers.norm_path(raw)
end
function Netrw.get_fullpath_under_cursor(target_lnum, resolve)
	if resolve == nil then resolve = true end
	local base_dir = Netrw.get_root()
	if not base_dir then return nil end
	local depth_str = "| "
	local classify = (vim.g.netrw_classify == nil or vim.g.netrw_classify ~= 0)
	local function depth_and_name(line)
		local d = 0
		local rest = line
		while rest:sub(1, #depth_str) == depth_str do
			d = d + 1
			rest = rest:sub(#depth_str + 1)
		end
		rest = rest:gsub("%s*%-+>.*$", "")
		if classify then
			rest = rest:gsub("[/@%*=|]%s*$", "")
		end
		return d, rest
	end
	local lnum = target_lnum or select(1, unpack(vim.api.nvim_win_get_cursor(0)))
	local line_str = table.concat(vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false))
	local cur_depth, name = depth_and_name(line_str)
	local raw_path
	if name == ".." then
		raw_path = Helpers.join_path(base_dir, "..")
	elseif name == "" or cur_depth == 0 then
		raw_path = base_dir
	else
		local parts = { name }
		local want_depth = cur_depth
		while want_depth > 1 and lnum > 1 do
			lnum = lnum - 1
			local prev_line = table.concat(vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false))
			local d, n = depth_and_name(prev_line)
			if d < want_depth and d > 0 then
				table.insert(parts, 1, n)
				want_depth = d
			end
		end
		raw_path = Helpers.join_path(base_dir, table.concat(parts, "/"))
	end
	return resolve and Helpers.resolve_path(raw_path) or raw_path
end
local function is_protected_path(path)
	local root = Netrw.get_root()
	if not path or not root then return true end
	local parent = Helpers.join_path(root, "..")
	return path == root or path == parent
end
local function invoke_orig_cr()
	if Netrw.cr_orig and Netrw.cr_orig.callback then
		Netrw.cr_orig.callback()
	elseif Netrw.cr_orig and Netrw.cr_orig.rhs then
		local keys = vim.api.nvim_replace_termcodes(Netrw.cr_orig.rhs, true, false, true)
		vim.api.nvim_feedkeys(keys, "n", false)
	end
end
function Netrw.enter_directory_under_cursor()
	local target = Netrw.get_fullpath_under_cursor()
	if not target or not Helpers.is_dir(target) then return end
	local tree_win = vim.api.nvim_get_current_win()
	vim.api.nvim_win_call(tree_win, function()
		vim.fn["netrw#SetTreetop"](1, target)
	end)
end
function Netrw.open_file_tree()
	vim.g.netrw_banner = 0
	vim.g.netrw_liststyle = 3
	vim.g.netrw_winsize = 15
	vim.g.netrw_keepdir = 0
	vim.g.netrw_browse_split = 4
	vim.g.netrw_sort_by = "name"
	local win = Netrw.is_tree_open()
	if win ~= nil then
		vim.api.nvim_set_current_win(win)
		return
	end
	local buf_path = vim.api.nvim_buf_get_name(0)
	local start_dir = (buf_path ~= "" and Helpers.exists(buf_path))
		and (Helpers.is_dir(buf_path) and buf_path or vim.fs.dirname(buf_path))
		or vim.uv.cwd()
		or vim.uv.os_homedir()
		or "."
	vim.cmd.Lexplore(Helpers.norm_path(start_dir))
	local opened_win = Netrw.is_tree_open()
	if opened_win then
		Netrw.lock_width(opened_win)
	end

end
function Netrw.open_under_cursor_split()
	local full_path = Netrw.get_fullpath_under_cursor()
	local root_norm = Netrw.get_root()
	if not full_path or full_path == root_norm then return end
	if Helpers.is_dir(full_path) then
		invoke_orig_cr()
		return
	end
	local netrw_win = vim.api.nvim_get_current_win()
	local right_winnr = vim.fn.winnr("l")
	if right_winnr ~= vim.fn.winnr() then
		local right_winid = vim.fn.win_getid(right_winnr)
		local right_buf = vim.api.nvim_win_get_buf(right_winid)
		if vim.bo[right_buf].buftype == "" then
			vim.api.nvim_set_current_win(right_winid)
			local ok, err = pcall(vim.cmd.edit, full_path)
			if not ok then
				vim.notify("Cannot open file: " .. tostring(err), vim.log.levels.WARN)
			end
			return
		end
	end
	Netrw.turn_off_banner(netrw_win)
	vim.cmd("rightbelow vsplit " .. vim.fn.fnameescape(full_path))
	local proportional_width = math.max(15, math.floor(vim.o.columns * 0.15))
	vim.api.nvim_win_set_width(netrw_win, proportional_width)
end
function Netrw.open_under_cursor_only()
	local full_path = Netrw.get_fullpath_under_cursor()
	local root_norm = Netrw.get_root()
	if not full_path or full_path == root_norm then return end
	if Helpers.is_dir(full_path) then
		Netrw.enter_directory_under_cursor()
		return
	end
	local ok = pcall(vim.cmd, "silent only")
	if not ok or #vim.api.nvim_tabpage_list_wins(0) > 1 then
		vim.notify("Cannot close other windows (unsaved changes).", vim.log.levels.WARN)
		return
	end
	vim.cmd.edit(full_path)
end
function Netrw.open_under_cursor_vsplit()
	local full_path = Netrw.get_fullpath_under_cursor()
	local root_norm = Netrw.get_root()
	if not full_path or full_path == root_norm then return end
	if Helpers.is_dir(full_path) then
		invoke_orig_cr()
		return
	end
	local netrw_win = vim.api.nvim_get_current_win()
	local was_single = (#vim.api.nvim_tabpage_list_wins(0) == 1)
	vim.cmd("silent botright vsplit " .. vim.fn.fnameescape(full_path))
	if was_single and vim.api.nvim_win_is_valid(netrw_win) then
		local proportional_width = math.max(15, math.floor(vim.o.columns * 0.15))
		vim.api.nvim_win_set_width(netrw_win, proportional_width)
	end
end
function Netrw.create_entry()
	vim.cmd("echohl Question")
	local f_name = vim.fn.input("\nInput name (directories must end with / or \\): ", "", "file")
	vim.cmd("echohl None")
	if not f_name or f_name:match("^%s*$") then
		vim.notify("File or directory name must not be empty.", vim.log.levels.WARN)
		return
	end
	local is_dir_req = f_name:match("[/\\]$") ~= nil
	local valid, v_err = validate_relative_subpath(f_name)
	if not valid then
		vim.notify(v_err, vim.log.levels.WARN)
		return
	end
	local directory
	local row = select(1, unpack(vim.api.nvim_win_get_cursor(0)))
	if row == 1 then
		directory = Netrw.get_root()
	else
		local target = Netrw.get_fullpath_under_cursor()
		directory = (target and Helpers.is_dir(target)) and target or vim.fs.dirname(target)
	end
	if not directory then return end
	local full_path = Helpers.join_path(directory, f_name)
	if Helpers.exists(full_path) then
		vim.notify("File or directory already exists: " .. f_name, vim.log.levels.WARN)
		return
	end
	local ok, err = is_dir_req and Helpers.mkdir_p(full_path) or Helpers.touch(full_path)
	if not ok then
		vim.notify("Create failed: " .. tostring(err), vim.log.levels.ERROR)
		return
	end
	Netrw.refresh()
end
function Netrw.delete_under_cursor()
	local path = Netrw.get_fullpath_under_cursor(nil, false)
	if not path or is_protected_path(path) then
		vim.notify("Cannot delete tree root or parent directory.", vim.log.levels.WARN)
		return
	end
	vim.cmd("echohl Question")
	local confirm = vim.fn.input(("Delete %s? (y/n): "):format(vim.fs.basename(path)))
	vim.cmd("echohl None")
	if confirm == "y" then
		local ok, err = Helpers.rm_rf(path)
		if not ok then
			vim.notify("Delete failed: " .. tostring(err), vim.log.levels.ERROR)
		end
		Netrw.refresh()
	end
end
function Netrw.delete_selected()
	local start_line = vim.fn.line("v")
	local end_line = select(1, unpack(vim.api.nvim_win_get_cursor(0)))
	if start_line > end_line then start_line, end_line = end_line, start_line end
	local paths = {}
	local seen = {}
	for lnum = start_line, end_line do
		local p = Netrw.get_fullpath_under_cursor(lnum, false)
		if p and not seen[p] and not is_protected_path(p) then
			seen[p] = true
			paths[#paths + 1] = p
		end
	end
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "nx", false)
	if #paths == 0 then
		vim.notify("No deletable items selected.", vim.log.levels.WARN)
		return
	end
	vim.cmd("echohl Question")
	local confirm = vim.fn.input(("Delete %d item(s)? (y/n): "):format(#paths))
	vim.cmd("echohl None")
	if confirm ~= "y" then return end
	for _, p in ipairs(paths) do
		if Helpers.exists(p) then
			local ok, err = Helpers.rm_rf(p)
			if not ok then
				vim.notify("Delete failed: " .. tostring(err), vim.log.levels.ERROR)
			end
		end
	end
	Netrw.refresh()
end
function Netrw.rename_entry()
	local old_path = Netrw.get_fullpath_under_cursor(nil, false)
	if not old_path or is_protected_path(old_path) then
		vim.notify("Cannot rename tree root or parent directory.", vim.log.levels.WARN)
		return
	end
	local old_name = vim.fs.basename(old_path)
	local directory = Helpers.norm_path(vim.fs.dirname(old_path))
	vim.cmd("echohl Question")
	local new_name = vim.fn.input("Rename to: ", old_name, "file")
	vim.cmd("echohl None")
	if not new_name or new_name:match("^%s*$") or new_name == old_name then return end
	local valid, v_err = validate_relative_subpath(new_name)
	if not valid then
		vim.notify(v_err, vim.log.levels.WARN)
		return
	end
	local new_path = Helpers.join_path(directory, new_name)
	if Helpers.exists(new_path) then
		vim.notify("Target already exists: " .. new_name, vim.log.levels.WARN)
		return
	end
	local new_parent = Helpers.norm_path(vim.fs.dirname(new_path))
	if new_parent ~= "" and not Helpers.is_dir(new_parent) then
		Helpers.mkdir_p(new_parent)
	end
	local ok, err = vim.uv.fs_rename(old_path, new_path)
	if not ok then
		vim.notify("Rename failed: " .. tostring(err), vim.log.levels.ERROR)
		return
	end
	Netrw.refresh()
end
function Netrw.cd_to_current_file()
	if vim.bo.buftype ~= "" or vim.bo.filetype == "netrw" or vim.fn.win_gettype() ~= "" then return end
	local file_name = vim.api.nvim_buf_get_name(0)
	if file_name == "" or Helpers.is_dir(file_name) or not Helpers.exists(file_name) then return end
	local dir = Helpers.resolve_path(vim.fs.dirname(file_name))
	if dir ~= "" and Helpers.is_dir(dir) then
		pcall(vim.api.nvim_set_current_dir, dir)
	end
end
local netrw_maps_augroup = vim.api.nvim_create_augroup("NetrwMaps", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
	group = netrw_maps_augroup,
	pattern = "netrw",
	callback = function(ev)
		vim.cmd([[cnoreabbrev <buffer> <expr> w (getcmdtype() ==# ':' && getcmdline() ==# 'w') ? '' : 'w']])
		if Netrw.cr_orig == nil then
			Netrw.cr_orig = vim.fn.maparg("<CR>", "n", false, true)
		end
		vim.api.nvim_set_hl(0, "Question", { fg = "#BB9AF7", bold = true })
		vim.opt_local.colorcolumn = "0"
		vim.opt_local.statusline = "%!v:lua.StatusLineRender(2)"
		local opts = { buffer = ev.buf, silent = true }
		local unmap_keys = { "<CR>", "<Space>", "<C-l>", "<C-h>", "<C-k>", "<C-j>", "%", "o", "d", "D", "R", "v", "i", "I", "s" }
		for _, lhs in ipairs(unmap_keys) do
			pcall(vim.keymap.del, "n", lhs, opts)
		end
		vim.keymap.set("n", "s", function()
			local sort_modes = { name = "time", time = "size", size = "exten", exten = "name" }
			local current = vim.b.netrw_sort_by or vim.g.netrw_sort_by or "name"
			local next_mode = sort_modes[current] or "name"
			vim.g.netrw_sort_by = next_mode
			vim.b.netrw_sort_by = next_mode
			Netrw.refresh()
		end, opts)
		vim.keymap.set("n", "<CR>", Netrw.open_under_cursor_split, opts)
		vim.keymap.set("n", "<Leader><CR>", Netrw.open_under_cursor_only, opts)
		vim.keymap.set("n", "<Leader>s<CR>", Netrw.open_under_cursor_vsplit, opts)
		vim.keymap.set("n", "%", Netrw.create_entry, { buffer = ev.buf, silent = true, nowait = true })
		vim.keymap.set("n", "r", Netrw.rename_entry, opts)
		vim.keymap.set("n", "<C-l>", "<C-w>l", opts)
		vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
		vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
		vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
		vim.keymap.set("n", "i", Netrw.toggle_hidden_files, opts)
		vim.keymap.set("n", "d", Netrw.delete_under_cursor, opts)
		vim.keymap.set("v", "d", Netrw.delete_selected, opts)
	end,
})
local cd_to_file_augroup = vim.api.nvim_create_augroup("CdToFile", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
	group = cd_to_file_augroup,
	pattern = "*",
	callback = Netrw.cd_to_current_file,
})
vim.api.nvim_create_autocmd({ "WinResized", "VimResized" }, {
	group = netrw_maps_augroup,
	callback = function()
		Netrw.lock_width()
	end,
})
vim.keymap.set("n", "<Leader>ft", Netrw.open_file_tree, { silent = true })


-- Terminal
local is_list = vim.islist or vim.tbl_islist
local Terminal = {
	defaults = {
		width = 0.8,
		height = 0.8,
		border = {
			{ "╭", "FloatBorder" },
			{ "─", "FloatBorder" },
			{ "╮", "FloatBorder" },
			{ "│", "FloatBorder" },
			{ "╯", "FloatBorder" },
			{ "─", "FloatBorder" },
			{ "╰", "FloatBorder" },
			{ "│", "FloatBorder" },
		},
		winblend = 0,
		winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
		shell = nil,
		toggle_keymap = "<Leader>ter",
		kill_keymap = "<Leader>q",
		terminal_mappings = true,
		title = "Floating Terminal",
		title_pos = "center",
	},
	config = {},
	registry = {},
	oneshot = {},
	_deferred_ops = {},
	_active_toggle_keymap = nil,
}
function Terminal.sanitize_title(title)
	local raw = (title ~= nil and title ~= "") and tostring(title) or tostring(Terminal.config.title or "Floating Terminal")
	return (raw:gsub("[%z\1-\31\127]+", " "))
end
function Terminal.valid_title_pos()
	local pos = Terminal.config.title_pos
	if pos == "left" or pos == "center" or pos == "right" then
		return pos
	end
	return "center"
end
function Terminal.is_valid_cmd(cmd)
	if type(cmd) == "string" then
		return vim.trim(cmd) ~= ""
	end
	if type(cmd) == "table" and is_list(cmd) and #cmd > 0 then
		for i = 1, #cmd do
			if type(rawget(cmd, i)) ~= "string" then
				return false
			end
		end
		local exe = rawget(cmd, 1)
		return type(exe) == "string" and vim.trim(exe) ~= ""
	end
	return false
end
function Terminal.is_job_alive(job_id)
	if not job_id or job_id <= 0 then
		return false
	end
	local ok, status = pcall(vim.fn.jobwait, { job_id }, 0)
	if not ok or type(status) ~= "table" then
		return false
	end
	return rawget(status, 1) == -1
end
function Terminal.run_when_safe(fn)
	if vim.fn.getcmdwintype() == "" then
		fn()
		return
	end
	Terminal._deferred_ops[#Terminal._deferred_ops + 1] = fn
end
function Terminal.flush_deferred_ops()
	if #Terminal._deferred_ops == 0 or vim.fn.getcmdwintype() ~= "" then
		return
	end
	local ops = Terminal._deferred_ops
	Terminal._deferred_ops = {}
	for _, fn in ipairs(ops) do
		pcall(fn)
	end
end
function Terminal.get_restore_win()
	local cur = vim.api.nvim_get_current_win()
	if vim.api.nvim_win_is_valid(cur) and vim.api.nvim_win_get_config(cur).relative == "" then
		return cur
	end
	for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		if vim.api.nvim_win_is_valid(w) and vim.api.nvim_win_get_config(w).relative == "" then
			return w
		end
	end
	return cur
end
function Terminal.get_key()
	local cur = vim.api.nvim_get_current_buf()
	if not vim.api.nvim_buf_is_valid(cur) then
		return cur
	end
	if vim.bo[cur].buftype == "terminal" then
		local src = vim.b[cur].source_buf
		if src and vim.api.nvim_buf_is_valid(src) then
			return src
		end
	end
	return cur
end
function Terminal.resolve_cwd(source_buf)
	if source_buf and vim.api.nvim_buf_is_valid(source_buf) then
		local name = vim.api.nvim_buf_get_name(source_buf)
		if name ~= "" and not name:match("^[a-zA-Z][a-zA-Z0-9+.-]*://") then
			local norm = Helpers.norm_path(name)
			if norm ~= "" and norm ~= "." then
				if Helpers.is_dir(norm) then
					return Helpers.resolve_path(vim.fn.fnamemodify(norm, ":p"))
				end
				local dir = Helpers.norm_path(vim.fs.dirname(norm))
				if dir ~= "" and dir ~= "." and Helpers.is_dir(dir) then
					return Helpers.resolve_path(vim.fn.fnamemodify(dir, ":p"))
				end
			end
		end
	end
	local cwd = Helpers.norm_path(vim.uv.cwd() or vim.fn.getcwd())
	if cwd ~= "" and Helpers.is_dir(cwd) then
		return cwd
	end
	return Helpers.norm_path(vim.uv.os_homedir() or vim.fn.expand("~"))
end
function Terminal.resolve_shell()
	local sh = Terminal.config.shell
	if type(sh) == "function" then
		local ok, res = pcall(sh)
		sh = ok and res or nil
	end
	if type(sh) == "string" then
		sh = vim.trim(sh)
	end
	if Terminal.is_valid_cmd(sh) then
		if type(sh) == "table" then
			local copy = vim.deepcopy(sh)
			rawset(copy, 1, vim.trim(rawget(copy, 1)))
			return copy
		end
		return sh
	end
	if Helpers.get_os() == "Windows" then
		for _, ps in ipairs({ "pwsh", "pwsh.exe" }) do
			if vim.fn.executable(ps) == 1 then
				local resolved = vim.fn.exepath(ps)
				return { resolved ~= "" and resolved or ps, "-NoLogo" }
			end
		end
		for _, ps in ipairs({ "powershell", "powershell.exe" }) do
			if vim.fn.executable(ps) == 1 then
				local resolved = vim.fn.exepath(ps)
				return { resolved ~= "" and resolved or ps, "-NoLogo" }
			end
		end
		local comspec = vim.trim(vim.env.COMSPEC or "")
		if comspec ~= "" and vim.fn.executable(comspec) == 1 then
			return comspec
		end
		return "cmd.exe"
	end
	local env_sh = vim.trim(vim.env.SHELL or "")
	if #env_sh >= 2 and ((env_sh:sub(1, 1) == '"' and env_sh:sub(-1) == '"') or (env_sh:sub(1, 1) == "'" and env_sh:sub(-1) == "'")) then
		env_sh = vim.trim(env_sh:sub(2, -2))
	end
	if env_sh ~= "" then
		if env_sh:sub(1, 1) == "~" then
			env_sh = vim.fn.expand(env_sh)
		end
		if vim.fn.executable(env_sh) == 1 and not env_sh:match("[/\\]nologin$") and not env_sh:match("[/\\]false$") then
			local resolved = vim.fn.exepath(env_sh)
			return resolved ~= "" and resolved or env_sh
		end
	end
	for _, candidate in ipairs({ "zsh", "bash", "sh" }) do
		if vim.fn.executable(candidate) == 1 then
			local resolved = vim.fn.exepath(candidate)
			return resolved ~= "" and resolved or candidate
		end
	end
	return "/bin/sh"
end
function Terminal.compute_geometry()
	local columns = math.max(1, vim.o.columns)
	local tab_offset = (vim.o.showtabline == 2 or (vim.o.showtabline == 1 and #vim.api.nvim_list_tabpages() > 1)) and 1 or 0
	local avail_lines = math.max(1, vim.o.lines - vim.o.cmdheight - tab_offset)
	local b = Terminal.config.border
	local pad = 2
	if b == nil or b == "none" or b == "" or (type(b) == "table" and #b == 0) then
		pad = 0
	elseif b == "shadow" then
		pad = 1
	end
	if columns <= pad or avail_lines <= pad then
		b = "none"
		pad = 0
	end
	local w_ratio = tonumber(Terminal.config.width)
	if not w_ratio or w_ratio ~= w_ratio then
		w_ratio = 0.8
	end
	w_ratio = math.min(1.0, math.max(0.05, w_ratio))
	local h_ratio = tonumber(Terminal.config.height)
	if not h_ratio or h_ratio ~= h_ratio then
		h_ratio = 0.8
	end
	h_ratio = math.min(1.0, math.max(0.05, h_ratio))
	local max_w = math.max(1, columns - pad)
	local max_h = math.max(1, avail_lines - pad)
	local width = math.min(max_w, math.max(1, math.floor(columns * w_ratio)))
	local height = math.min(max_h, math.max(1, math.floor(avail_lines * h_ratio)))
	local row = tab_offset + math.max(0, math.floor((avail_lines - height - pad) / 2))
	local col = math.max(0, math.floor((columns - width - pad) / 2))
	return {
		width = width,
		height = height,
		row = row,
		col = col,
		pad = pad,
		border = b,
	}
end
function Terminal.close_window(win, prev_win)
	Terminal.run_when_safe(function()
		local was_focused = win and vim.api.nvim_win_is_valid(win) and vim.api.nvim_get_current_win() == win
		if win and vim.api.nvim_win_is_valid(win) then
			pcall(vim.api.nvim_win_close, win, true)
		end
		if was_focused and prev_win and prev_win ~= win and vim.api.nvim_win_is_valid(prev_win) then
			if vim.api.nvim_win_get_tabpage(prev_win) == vim.api.nvim_get_current_tabpage() then
				pcall(vim.api.nvim_set_current_win, prev_win)
			end
		end
	end)
end
function Terminal.delete_buffer(buf)
	Terminal.run_when_safe(function()
		if buf and vim.api.nvim_buf_is_valid(buf) then
			pcall(vim.api.nvim_buf_delete, buf, { force = true })
		end
	end)
end
function Terminal.spawn_pty(buf, cmd, cwd, on_exit)
	local opts = {
		cwd = cwd,
		on_exit = on_exit,
	}
	if vim.fn.has("nvim-0.11") == 1 then
		opts.term = true
		local ok, job_id = pcall(vim.fn.jobstart, cmd, opts)
		return ok and job_id or -1
	end
	local ok, job_id = pcall(vim.api.nvim_buf_call, buf, function()
		return vim.fn.termopen(cmd, opts)
	end)
	return ok and job_id or -1
end
function Terminal.create_floating_window(buf, custom_title)
	local geom = Terminal.compute_geometry()
	local clean_title = Terminal.sanitize_title(custom_title)
	if vim.api.nvim_buf_is_valid(buf) then
		vim.b[buf]._term_custom_title = custom_title and clean_title or nil
	end
	local win_opts = {
		relative = "editor",
		row = geom.row,
		col = geom.col,
		width = geom.width,
		height = geom.height,
		style = "minimal",
		border = geom.border,
	}
	if geom.pad > 0 and geom.border ~= "shadow" and geom.width >= 4 then
		win_opts.title = clean_title
		win_opts.title_pos = Terminal.valid_title_pos()
	end
	local ok, win = pcall(vim.api.nvim_open_win, buf, true, win_opts)
	if not ok or not win or not vim.api.nvim_win_is_valid(win) then
		ok, win = pcall(vim.api.nvim_open_win, buf, true, {
			relative = "editor",
			row = geom.row,
			col = geom.col,
			width = geom.width,
			height = geom.height,
			style = "minimal",
			border = geom.pad > 0 and "single" or "none",
		})
	end
	if not ok or not win or not vim.api.nvim_win_is_valid(win) then
		ok, win = pcall(vim.api.nvim_open_win, buf, true, {
			relative = "editor",
			row = 0,
			col = 0,
			width = 1,
			height = 1,
			style = "minimal",
			border = "none",
		})
		if not ok or not win or not vim.api.nvim_win_is_valid(win) then
			return nil
		end
	end
	vim.wo[win].winblend = math.min(100, math.max(0, tonumber(Terminal.config.winblend) or 0))
	vim.wo[win].cursorline = true
	vim.wo[win].number = false
	vim.wo[win].relativenumber = false
	vim.wo[win].signcolumn = "no"
	vim.wo[win].foldcolumn = "0"
	vim.wo[win].winhighlight = Terminal.config.winhighlight
	return win
end
function Terminal.bind_buffer_keymaps(buf, persistent)
	if not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	local prev = vim.b[buf]._term_keys
	if prev then
		if prev.toggle then
			pcall(vim.keymap.del, "t", prev.toggle, { buffer = buf })
			pcall(vim.keymap.del, "n", prev.toggle, { buffer = buf })
		end
		if prev.kill then
			pcall(vim.keymap.del, "t", prev.kill, { buffer = buf })
			pcall(vim.keymap.del, "n", prev.kill, { buffer = buf })
		end
		if prev.esc then
			pcall(vim.keymap.del, "t", "<Esc>", { buffer = buf })
		end
		if prev.quit then
			pcall(vim.keymap.del, "n", "q", { buffer = buf })
		end
		vim.b[buf]._term_keys = nil
	end
	if not Terminal.config.terminal_mappings then
		return
	end
	local opts = { buffer = buf, noremap = true, silent = true }
	vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)
	if persistent then
		local tk = Terminal.config.toggle_keymap
		local kk = Terminal.config.kill_keymap
		local mapped_toggle = nil
		local mapped_kill = nil
		if type(tk) == "string" and tk ~= "" then
			vim.keymap.set({ "t", "n" }, tk, function()
				Terminal.toggle()
			end, opts)
			mapped_toggle = tk
		end
		if type(kk) == "string" and kk ~= "" then
			vim.keymap.set({ "t", "n" }, kk, function()
				Terminal.kill()
			end, opts)
			mapped_kill = kk
		end
		vim.b[buf]._term_keys = {
			esc = true,
			toggle = mapped_toggle,
			kill = mapped_kill,
		}
	else
		vim.keymap.set("n", "q", function()
			for w, item in pairs(Terminal.oneshot) do
				if item.buf == buf then
					Terminal.cleanup_oneshot(w, false, false)
					return
				end
			end
			Terminal.delete_buffer(buf)
		end, opts)
		vim.b[buf]._term_keys = { esc = true, quit = true }
	end
end
function Terminal.cleanup_oneshot(win, defer_buf_delete, skip_ui)
	local item = Terminal.oneshot[win]
	if not item then
		return
	end
	Terminal.oneshot[win] = nil
	if not item.exited and item.job_id and item.job_id > 0 then
		pcall(vim.fn.jobstop, item.job_id)
	end
	if skip_ui then
		return
	end
	if defer_buf_delete then
		vim.schedule(function()
			Terminal.close_window(win, item.prev_win)
			Terminal.delete_buffer(item.buf)
		end)
	else
		Terminal.close_window(win, item.prev_win)
		Terminal.delete_buffer(item.buf)
	end
end
function Terminal.close_all_floats()
	for _, w in ipairs(vim.tbl_keys(Terminal.oneshot)) do
		Terminal.cleanup_oneshot(w, false, false)
	end
	local cur_tab = vim.api.nvim_get_current_tabpage()
	for _, e in pairs(Terminal.registry) do
		if e.win and vim.api.nvim_win_is_valid(e.win) then
			local w = e.win
			local win_tab = vim.api.nvim_win_get_tabpage(w)
			local restore = e.prev_win
			Terminal.close_window(w, win_tab == cur_tab and restore or nil)
			if not vim.api.nvim_win_is_valid(w) then
				e.win = nil
				e.prev_win = nil
			end
		end
	end
end
function Terminal.toggle(cmd, close_on_exit)
	if vim.fn.getcmdwintype() ~= "" then
		vim.notify("Cannot toggle terminal from command-line window", vim.log.levels.WARN)
		return
	end
	if cmd ~= nil then
		if not Terminal.is_valid_cmd(cmd) then
			vim.notify("Terminal command must be a non-empty string or list of strings", vim.log.levels.WARN)
			return
		end
		local key = Terminal.get_key()
		Terminal.close_all_floats()
		local prev_win = Terminal.get_restore_win()
		local cwd = Terminal.resolve_cwd(key)
		local buf = vim.api.nvim_create_buf(false, true)
		vim.bo[buf].buflisted = false
		vim.b[buf].source_buf = key
		local raw_title = type(cmd) == "table" and vim.trim(table.concat(cmd, " ")) or vim.trim(cmd)
		local title = Terminal.sanitize_title(raw_title)
		local win = Terminal.create_floating_window(buf, title)
		if not win then
			Terminal.delete_buffer(buf)
			vim.notify("Failed to open terminal window", vim.log.levels.ERROR)
			return
		end
		local job_id = Terminal.spawn_pty(buf, cmd, cwd, function(_, exit_code)
			vim.schedule(function()
				local item = Terminal.oneshot[win]
				if not item or item.buf ~= buf then
					return
				end
				item.exited = true
				if close_on_exit then
					Terminal.cleanup_oneshot(win, false, false)
					return
				end
				if win and vim.api.nvim_win_is_valid(win) then
					local done_title = Terminal.sanitize_title(string.format("[%d] %s", exit_code or 0, title))
					if vim.api.nvim_buf_is_valid(buf) then
						vim.b[buf]._term_custom_title = done_title
					end
					Terminal.run_when_safe(function()
						local cur = Terminal.oneshot[win]
						if not cur or cur.buf ~= buf or not vim.api.nvim_win_is_valid(win) then
							return
						end
						local geom = Terminal.compute_geometry()
						if geom.pad > 0 and geom.border ~= "shadow" and geom.width >= 4 then
							pcall(vim.api.nvim_win_set_config, win, {
								border = geom.border,
								title = done_title,
								title_pos = Terminal.valid_title_pos(),
							})
						end
					end)
					if vim.api.nvim_get_current_win() == win then
						pcall(vim.cmd, "stopinsert")
					end
				end
			end)
		end)
		if job_id <= 0 then
			Terminal.close_window(win, prev_win)
			Terminal.delete_buffer(buf)
			vim.notify("Failed to run command: " .. title, vim.log.levels.ERROR)
			return
		end
		Terminal.oneshot[win] = { buf = buf, job_id = job_id, prev_win = prev_win, exited = false }
		Terminal.bind_buffer_keymaps(buf, false)
		pcall(vim.cmd, "startinsert")
		return
	end
	local key = Terminal.get_key()
	local entry = Terminal.registry[key]
	local cur_tab = vim.api.nvim_get_current_tabpage()
	if entry and entry.win and vim.api.nvim_win_is_valid(entry.win) then
		local w = entry.win
		local win_tab = vim.api.nvim_win_get_tabpage(w)
		local restore = entry.prev_win
		Terminal.close_window(w, win_tab == cur_tab and restore or nil)
		if not vim.api.nvim_win_is_valid(w) then
			entry.win = nil
			entry.prev_win = nil
		end
		if win_tab == cur_tab then
			return
		end
	end
	Terminal.close_all_floats()
	local prev_win = Terminal.get_restore_win()
	if entry
		and entry.buf
		and vim.api.nvim_buf_is_valid(entry.buf)
		and vim.api.nvim_buf_is_loaded(entry.buf)
		and Terminal.is_job_alive(entry.job_id)
	then
		local existing_win = vim.fn.bufwinid(entry.buf)
		if existing_win ~= -1 and vim.api.nvim_win_is_valid(existing_win) then
			if vim.api.nvim_win_get_config(existing_win).relative ~= "" then
				entry.prev_win = (prev_win ~= existing_win) and prev_win or nil
				entry.win = existing_win
			else
				entry.prev_win = nil
				entry.win = nil
			end
			pcall(vim.api.nvim_set_current_win, existing_win)
			pcall(vim.cmd, "startinsert")
			return
		end
		local win = Terminal.create_floating_window(entry.buf, vim.b[entry.buf]._term_custom_title)
		if not win then
			vim.notify("Failed to open terminal window", vim.log.levels.ERROR)
			return
		end
		entry.prev_win = (prev_win ~= win) and prev_win or nil
		entry.win = win
		pcall(vim.cmd, "startinsert")
		return
	end
	if entry then
		Terminal.kill_by_key(key, false, false)
	end
	local cwd = Terminal.resolve_cwd(key)
	local buf = vim.api.nvim_create_buf(false, true)
	vim.bo[buf].buflisted = false
	vim.b[buf].source_buf = key
	local win = Terminal.create_floating_window(buf)
	if not win then
		Terminal.delete_buffer(buf)
		vim.notify("Failed to open terminal window", vim.log.levels.ERROR)
		return
	end
	local job_id = Terminal.spawn_pty(buf, Terminal.resolve_shell(), cwd, function()
		vim.schedule(function()
			local current = Terminal.registry[key]
			local restore = nil
			local open_win = nil
			if current and current.buf == buf then
				restore = current.prev_win
				open_win = current.win
				Terminal.registry[key] = nil
			end
			Terminal.close_window(open_win, restore)
			Terminal.delete_buffer(buf)
		end)
	end)
	if job_id <= 0 then
		Terminal.close_window(win, prev_win)
		Terminal.delete_buffer(buf)
		vim.notify("Failed to start terminal shell", vim.log.levels.ERROR)
		return
	end
	Terminal.bind_buffer_keymaps(buf, true)
	Terminal.registry[key] = {
		buf = buf,
		win = win,
		prev_win = (prev_win ~= win) and prev_win or nil,
		job_id = job_id,
	}
	pcall(vim.cmd, "startinsert")
end
function Terminal.kill_by_key(key, defer_teardown, skip_ui)
	local entry = Terminal.registry[key]
	if not entry then
		return
	end
	Terminal.registry[key] = nil
	if entry.job_id and entry.job_id > 0 then
		pcall(vim.fn.jobstop, entry.job_id)
	end
	if skip_ui then
		return
	end
	if defer_teardown then
		vim.schedule(function()
			Terminal.close_window(entry.win, entry.prev_win)
			Terminal.delete_buffer(entry.buf)
		end)
	else
		Terminal.close_window(entry.win, entry.prev_win)
		Terminal.delete_buffer(entry.buf)
	end
end
function Terminal.kill()
	local cur_win = vim.api.nvim_get_current_win()
	if Terminal.oneshot[cur_win] then
		Terminal.cleanup_oneshot(cur_win, false, false)
		return
	end
	Terminal.kill_by_key(Terminal.get_key(), false, false)
end
function Terminal.reposition_open_windows()
	Terminal.run_when_safe(function()
		local geom = Terminal.compute_geometry()
		local blend = math.min(100, math.max(0, tonumber(Terminal.config.winblend) or 0))
		local function apply_resize(win, buf)
			if not (win and vim.api.nvim_win_is_valid(win)) then
				return
			end
			local cfg = {
				relative = "editor",
				row = geom.row,
				col = geom.col,
				width = geom.width,
				height = geom.height,
				border = geom.border,
			}
			if geom.pad > 0 and geom.border ~= "shadow" then
				if geom.width >= 4 and buf and vim.api.nvim_buf_is_valid(buf) then
					cfg.title = vim.b[buf]._term_custom_title or Terminal.sanitize_title(nil)
					cfg.title_pos = Terminal.valid_title_pos()
				else
					cfg.title = ""
				end
			end
			pcall(vim.api.nvim_win_set_config, win, cfg)
			vim.wo[win].winblend = blend
			vim.wo[win].winhighlight = Terminal.config.winhighlight
		end
		for _, e in pairs(Terminal.registry) do
			apply_resize(e.win, e.buf)
		end
		for w, item in pairs(Terminal.oneshot) do
			apply_resize(w, item.buf)
		end
	end)
end
function Terminal.setup(opts)
	Terminal.config = vim.tbl_deep_extend("force", {}, Terminal.defaults, opts or {})
	if opts and opts.border ~= nil then
		Terminal.config.border = vim.deepcopy(opts.border)
	end
	local augroup = vim.api.nvim_create_augroup("TermOps", { clear = true })
	vim.api.nvim_create_autocmd("CmdwinLeave", {
		group = augroup,
		pattern = "*",
		callback = function()
			vim.schedule(Terminal.flush_deferred_ops)
		end,
	})
	vim.api.nvim_create_autocmd("WinEnter", {
		group = augroup,
		pattern = "*",
		callback = function()
			if next(Terminal.oneshot) == nil then
				return
			end
			local cur_win = vim.api.nvim_get_current_win()
			local item = Terminal.oneshot[cur_win]
			if item and item.exited then
				pcall(vim.cmd, "stopinsert")
			end
		end,
	})
	vim.api.nvim_create_autocmd("WinClosed", {
		group = augroup,
		pattern = "*",
		callback = function(ev)
			local closed_win = tonumber(ev.match)
			if not closed_win then
				return
			end
			if Terminal.oneshot[closed_win] then
				Terminal.cleanup_oneshot(closed_win, true, false)
			end
			for _, e in pairs(Terminal.registry) do
				if e.win == closed_win then
					e.win = nil
				end
				if e.prev_win == closed_win then
					e.prev_win = nil
				end
			end
		end,
	})
	vim.api.nvim_create_autocmd("VimResized", {
		group = augroup,
		pattern = "*",
		callback = function()
			Terminal.reposition_open_windows()
		end,
	})
	vim.api.nvim_create_autocmd("BufWipeout", {
		group = augroup,
		pattern = "*",
		callback = function(ev)
			if Terminal.registry[ev.buf] then
				Terminal.kill_by_key(ev.buf, true, false)
			end
			local stale_keys = {}
			for k, e in pairs(Terminal.registry) do
				if e.buf == ev.buf then
					stale_keys[#stale_keys + 1] = k
				end
			end
			for _, k in ipairs(stale_keys) do
				Terminal.kill_by_key(k, true, false)
			end
			local stale_wins = {}
			for w, item in pairs(Terminal.oneshot) do
				if item.buf == ev.buf then
					stale_wins[#stale_wins + 1] = w
				end
			end
			for _, w in ipairs(stale_wins) do
				Terminal.cleanup_oneshot(w, true, false)
			end
		end,
	})
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = augroup,
		pattern = "*",
		callback = function()
			Terminal._deferred_ops = {}
			for _, k in ipairs(vim.tbl_keys(Terminal.registry)) do
				Terminal.kill_by_key(k, false, true)
			end
			for _, w in ipairs(vim.tbl_keys(Terminal.oneshot)) do
				Terminal.cleanup_oneshot(w, false, true)
			end
		end,
	})
	if Terminal._active_toggle_keymap and Terminal._active_toggle_keymap ~= Terminal.config.toggle_keymap then
		pcall(vim.keymap.del, "n", Terminal._active_toggle_keymap)
	end
	Terminal._active_toggle_keymap = nil
	if type(Terminal.config.toggle_keymap) == "string" and Terminal.config.toggle_keymap ~= "" then
		Terminal._active_toggle_keymap = Terminal.config.toggle_keymap
		vim.keymap.set("n", Terminal.config.toggle_keymap, function()
			Terminal.toggle(nil)
		end, { noremap = true, silent = true, desc = "Toggle floating terminal" })
	end
	for _, e in pairs(Terminal.registry) do
		if e.buf and vim.api.nvim_buf_is_valid(e.buf) then
			Terminal.bind_buffer_keymaps(e.buf, true)
		end
	end
	for _, item in pairs(Terminal.oneshot) do
		if item.buf and vim.api.nvim_buf_is_valid(item.buf) then
			Terminal.bind_buffer_keymaps(item.buf, false)
		end
	end
	Terminal.reposition_open_windows()
end
Terminal.setup()


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
	if handle == nil then return end
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
	handle = io.popen("echo | "..compiler.." -v -x c - 2>&1")
	if handle == nil then return end
	if not handle then
		return
	end
	local raw = handle:read("*a")
	handle:close()
	local include_dirs = {}
	local in_includes = false
	for _, line in ipairs(Helpers.split(raw, "\n")) do
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
	if handle == nil then return end
	local ctags = vim.trim(handle:read("*a"))
	handle:close()
	if vim.fn.executable(ctags) == 0 then
		print("Ctags doesn't exist on your machine!!")
		return
	end
	handle = io.popen("which python3")
	if handle == nil then return end
	local python3 = vim.trim(handle:read("*a"))
	handle:close()
	if vim.fn.executable(python3) == 0 then
		print("Python3 doesn't exist on your machine!!")
		return
	end
	local file_path = vim.fn.expand("%:p:h")
	handle = io.popen('python3 -c "import sys; print(\"\n\".join(sys.path))"')
	if handle == nil then return end
	if not handle then
		return
	end
	local raw = handle:read("*a")
	handle:close()
	local include_dirs = {}
	for _, line in ipairs(Helpers.split(raw, "\n")) do
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


-- Markdown syntax highlighting
local function apply_conceal(buf)
	if not vim.api.nvim_buf_is_valid(buf) then return end
	local ok, parser = pcall(vim.treesitter.get_parser, buf, "markdown")
	if not ok or not parser then return end
	parser:parse(true)
	local ns = vim.api.nvim_create_namespace("mdview_conceal")
	vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
	local block_query = vim.treesitter.query.parse("markdown", [[
		(atx_heading (atx_h1_marker) @h)
		(atx_heading (atx_h2_marker) @h)
		(atx_heading (atx_h3_marker) @h)
		(atx_heading (atx_h4_marker) @h)
		(atx_heading (atx_h5_marker) @h)
		(atx_heading (atx_h6_marker) @h)
		(thematic_break) @line
		(fenced_code_block (fenced_code_block_delimiter) @code_fence)
	]])
	local inline_query = vim.treesitter.query.parse("markdown_inline", [[
		(strong_emphasis) @strong
		(emphasis) @em
		(code_span) @code
	]])
	parser:for_each_tree(function(tree, ltree)
		local lang = ltree:lang()
		if lang == "markdown" then
			for id, node in block_query:iter_captures(tree:root(), buf) do
				local name = block_query.captures[id]
				local sr, sc, _, ec = node:range()
				if name == "h" then
					vim.api.nvim_buf_set_extmark(buf, ns, sr, sc, { end_col = ec + 1, conceal = "" })
				elseif name == "code_fence" then
					local line_text = vim.api.nvim_buf_get_lines(buf, sr, sr + 1, false)[1] or ""
					local backticks_end = sc
					while line_text:sub(backticks_end + 1, backticks_end + 1) == "`" do
						backticks_end = backticks_end + 1
					end
					vim.api.nvim_buf_set_extmark(buf, ns, sr, sc, { end_col = backticks_end, conceal = "" })
				elseif name == "line" then
					local line_text = vim.api.nvim_buf_get_lines(buf, sr, sr + 1, false)[1] or ""
					local actual_ec = string.len(line_text:gsub("%s+$", ""))
					local win_width = vim.api.nvim_win_get_width(0)
					local line_width = math.max(1, win_width - 6)
					local dynamic_line = string.rep("─", line_width)
					vim.api.nvim_buf_set_extmark(buf, ns, sr, sc, {
						end_col = actual_ec,
						conceal = "",
						virt_text = { { dynamic_line, "Comment" } },
						virt_text_pos = "inline",
					})
				end
			end
		elseif lang == "markdown_inline" then
			for id, node in inline_query:iter_captures(tree:root(), buf) do
				local name = inline_query.captures[id]
				local sr, sc, er, ec = node:range()
				if name == "strong" or name == "em" then
					local delim = (name == "strong") and 2 or 1
					vim.api.nvim_buf_set_extmark(buf, ns, sr, sc, { end_col = sc + delim, conceal = "" })
					vim.api.nvim_buf_set_extmark(buf, ns, er, ec - delim, { end_col = ec, conceal = "" })
				end
			end
		end
	end)
end
local MDSyntaxGI = vim.api.nvim_create_augroup("MDSyntax", { clear = true })
vim.api.nvim_create_autocmd({"FileType"}, {
	group = MDSyntaxGI,
	pattern = "markdown",
	callback = function(args)
		vim.opt_local.textwidth = 100
		vim.opt_local.wrap = true
		vim.opt_local.linebreak = true
		vim.opt_local.conceallevel = 2
		vim.opt_local.concealcursor = "nc"
		vim.opt_local.list = false
		vim.opt_local.colorcolumn = ""
		vim.opt_local.spelllang = "en"
		local dir = vim.fn.stdpath("config")
		local md_parser = dir.."/markdown.so"
		local mdi_parser = dir.."/markdown_inline.so"
		pcall(vim.treesitter.language.add, "markdown", { path = md_parser })
		pcall(vim.treesitter.language.add, "markdown_inline", { path = mdi_parser })
	if vim.fn.filereadable(md_parser) == 0 or vim.fn.filereadable(mdi_parser) == 0 then
			print("[Bootstrap] Building tree-sitter-markdown directly in config folder...")
			local clone_dir = dir.."/tmp_clone_md"
			local compile_cmd = string.format(
				"rm -rf '%s' && " ..
				"git clone --depth=1 https://github.com/tree-sitter-grammars/tree-sitter-markdown.git '%s' && " ..
				"cc -o '%s' -shared -fPIC -O2 '%s/tree-sitter-markdown/src/parser.c' '%s/tree-sitter-markdown/src/scanner.c' -I'%s/tree-sitter-markdown/src' && " ..
				"cc -o '%s' -shared -fPIC -O2 '%s/tree-sitter-markdown-inline/src/parser.c' '%s/tree-sitter-markdown-inline/src/scanner.c' -I'%s/tree-sitter-markdown-inline/src' && " ..
				"rm -rf '%s'",
				clone_dir, clone_dir,
				md_parser, clone_dir, clone_dir, clone_dir,
				mdi_parser, clone_dir, clone_dir, clone_dir,
				clone_dir
			)
			vim.fn.jobstart(compile_cmd, {
				on_exit = function(_, exit_code)
					if exit_code == 0 then
						print("[Bootstrap] Markdown parsers successfully compiled! Reopen the file.")
						pcall(vim.treesitter.language.add, "markdown", { path = md_parser })
						pcall(vim.treesitter.language.add, "markdown_inline", { path = mdi_parser })
						pcall(vim.treesitter.start, args.buf, "markdown")
					else
						print("[Bootstrap] Markdown parser build failed (exit "..exit_code..")")
					end
				end
			})
		end
		vim.treesitter.query.set("markdown", "highlights", [[
			(atx_heading (atx_h1_marker)) @markup.heading.1
			(atx_heading (atx_h2_marker)) @markup.heading.2
			(atx_heading (atx_h3_marker)) @markup.heading.3
			(atx_heading (atx_h4_marker)) @markup.heading.4
			(atx_heading (atx_h5_marker)) @markup.heading.5
			(atx_heading (atx_h6_marker)) @markup.heading.6
			(fenced_code_block) @markup.raw.block
			(block_quote) @markup.quote
			(thematic_break) @punctuation.special
			(list_marker_minus) @punctuation.special
			(list_marker_plus) @punctuation.special
			(list_marker_star) @punctuation.special
		]])
		vim.treesitter.query.set("markdown", "injections", [[
			[(inline) (pipe_table_cell)] @injection.content
			(#set! injection.language "markdown_inline")
		]])
		vim.treesitter.query.set("markdown_inline", "highlights", [[
			(strong_emphasis) @markup.strong
			(emphasis) @markup.italic
			(strikethrough) @markup.strikethrough
			(code_span) @markup.raw
			(link_text) @markup.link.label
			(link_destination) @markup.link.url
			(uri_autolink) @markup.link.url
		]])
		local highlight = vim.api.nvim_set_hl
		local colors = {
			red = "#F7768E", green = "#9ECE6A", yellow = "#E0AF68",
			blue = "#7AA2F7", magenta = "#BB9AF7", cyan = "#7DCFFF",
			orange = "#FFB86C", grey = "#3B4261", bg_alt = "#171B26",
			pink = "#F5C2E7",
		}
		highlight(0, "@markup.heading.1", { fg = colors.red,     bold = true })
		highlight(0, "@markup.heading.2", { fg = colors.magenta,  bold = true })
		highlight(0, "@markup.heading.3", { fg = colors.pink,  bold = true })
		highlight(0, "@markup.heading.4", { fg = colors.green,   bold = true })
		highlight(0, "@markup.heading.5", { fg = colors.cyan,    bold = true })
		highlight(0, "@markup.heading.6", { fg = colors.orange, bold = true })
		highlight(0, "@markup.strong", { fg = colors.orange, bold = true })
		highlight(0, "@markup.italic", { fg = colors.yellow, italic = true })
		highlight(0, "@markup.raw", { fg = colors.green, bg = colors.bg_alt })
		highlight(0, "@markup.raw.block", { fg = colors.green, bg = colors.bg_alt })
		highlight(0, "@markup.quote", { fg = colors.grey, italic = true })
		highlight(0, "@markup.link.label", { fg = colors.blue, underline = true })
		highlight(0, "@markup.link.url", { fg = colors.grey })
		pcall(vim.treesitter.start, args.buf, "markdown")
		apply_conceal(args.buf)
	end
})
vim.api.nvim_create_autocmd({ "BufEnter" }, {
	group = MDSyntaxGI,
	pattern = "*",
	callback = function()
		if vim.bo.filetype == "markdown" then
			apply_conceal(0)
		end
	end,
})
vim.api.nvim_create_autocmd({ "WinResized", "VimResized" }, {
	group = MDSyntaxGI,
	pattern = "*",
	callback = function()
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "markdown" then
				apply_conceal(buf)
			end
		end
	end,
})
vim.api.nvim_create_autocmd({ "TextChanged", "InsertLeave" }, {
	group = MDSyntaxGI,
	pattern = { "*.md", "*.markdown" },
	callback = function(ev)
		if vim.bo[ev.buf].filetype == "markdown" then
			apply_conceal(ev.buf)
		end
	end,
})


-- Netrw rendering
local NetrwUI = {
	ns = vim.api.nvim_create_namespace("netrw_connectors"),
	has_inline = vim.fn.has("nvim-0.10") == 1,
}
local function read_netrw_var(buf, key)
	local bval = vim.b[buf][key]
	if bval ~= nil and bval ~= vim.NIL then
		return bval
	end
	local gval = vim.g[key]
	if gval ~= nil and gval ~= vim.NIL then
		return gval
	end
	return nil
end
local function set_netrw_hl()
	vim.api.nvim_set_hl(0, "NetrwSize", { fg = "#E0AF68" })
	vim.api.nvim_set_hl(0, "NetrwConnector", { link = "Comment", default = true })
end
local function parse_netrw_line(line, depth_str)
	local depth = 0
	local rest = line
	local step = #depth_str
	while step > 0 and rest:sub(1, step) == depth_str do
		depth = depth + 1
		rest = rest:sub(step + 1)
	end
	local name = rest:gsub("^%d+/?%s*", "")
	name = name:gsub("%s*%->.*$", "")
	local classify = vim.g.netrw_classify
	if classify == nil or classify == vim.NIL or classify ~= 0 then
		name = name:gsub("[/@%*=|]+%s*$", "")
	else
		name = name:gsub("/%s*$", "")
	end
	return depth, name
end
local function is_netrw_banner(line)
	return line:match('^"[ =]') ~= nil
end
local function format_size(bytes)
	local n = tonumber(bytes)
	if not n or n < 0 then return "" end
	local units = { "B", "K", "M", "G", "T" }
	local i = 1
	while n >= 1024 and i < #units do
		n = n / 1024
		i = i + 1
	end
	if i == 1 then
		return string.format("%d%s", n, units[i])
	end
	return string.format("%.1f%s", n, units[i])
end
local function format_time(epoch)
	if not epoch or epoch < 0 then return "" end
	local ok, formatted = pcall(os.date, "%Y-%m-%d %H:%M", epoch)
	return (ok and type(formatted) == "string") and formatted or ""
end
local function get_buf_base_dir(buf, is_tree)
	if is_tree then
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			if vim.api.nvim_win_get_buf(win) == buf and vim.w[win] then
				local treetop = vim.w[win].netrw_treetop
				if treetop ~= nil and treetop ~= vim.NIL and treetop ~= "" then
					return treetop
				end
			end
		end
	end
	local curdir = vim.b[buf].netrw_curdir
	if curdir ~= nil and curdir ~= vim.NIL and curdir ~= "" then
		return curdir
	end
	return nil
end
local function ensure_window_conceal(buf)
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == buf then
			vim.wo[win].conceallevel = 2
			vim.wo[win].concealcursor = "nvc"
		end
	end
end
function NetrwUI.render(buf)
	if not vim.api.nvim_buf_is_valid(buf) then return end
	if vim.bo[buf].filetype ~= "netrw" then return end
	vim.api.nvim_buf_clear_namespace(buf, NetrwUI.ns, 0, -1)
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local count = #lines
	if count == 0 then return end
	local raw_depth = read_netrw_var(buf, "netrw_treedepthstring")
	local depth_str = (type(raw_depth) == "string" and raw_depth ~= "") and raw_depth or "| "
	local depth_step = #depth_str
	local depths = {}
	local names = {}
	local has_tree_lines = false
	for i = 1, count do
		local d, name = parse_netrw_line(lines[i], depth_str)
		depths[i] = d
		names[i] = name
		if d > 0 then has_tree_lines = true end
	end
	local is_last = {}
	local active_depth = {}
	for i = count, 1, -1 do
		local d = depths[i]
		for k, _ in pairs(active_depth) do
			if k > d then
				active_depth[k] = nil
			end
		end
		if d > 0 then
			is_last[i] = not active_depth[d]
			active_depth[d] = true
		end
	end
	local sort_mode = tostring(read_netrw_var(buf, "netrw_sort_by") or "name"):lower()
	local is_size = sort_mode:sub(1, 1) == "s"
	local is_time = sort_mode:sub(1, 1) == "t"
	local liststyle = tonumber(read_netrw_var(buf, "netrw_liststyle")) or 0
	local is_tree = (liststyle == 3) or has_tree_lines
	local base_dir = get_buf_base_dir(buf, is_tree)
	local show_meta = (is_size or is_time)
		and base_dir ~= nil
		and (liststyle == 0 or liststyle == 3)
	local branch_stack = {}
	local dir_stack = {}
	local slice_unpack = table.unpack or unpack
	local uv = vim.uv or vim.loop
	local virt_pos = NetrwUI.has_inline and "inline" or "overlay"
	local conceal_val = NetrwUI.has_inline and "" or nil
	local leaf_last = NetrwUI.has_inline and "╰▸ " or "╰─"
	local leaf_mid = NetrwUI.has_inline and "├▸ " or "├─"
	for i = 1, count do
		local line = lines[i]
		local d = depths[i]
		local name = names[i]
		if d > 0 then
			local prefix_parts = {}
			for k = 1, d - 1 do
				prefix_parts[k] = branch_stack[k] and "│ " or "  "
			end
			prefix_parts[d] = is_last[i] and leaf_last or leaf_mid
			branch_stack[d] = not is_last[i]
			vim.api.nvim_buf_set_extmark(buf, NetrwUI.ns, i - 1, 0, {
				end_col = math.min(d * depth_step, #line),
				conceal = conceal_val,
				virt_text = { { table.concat(prefix_parts), "NetrwConnector" } },
				virt_text_pos = virt_pos,
				strict = false,
			})
			for k = 1, d - 1 do
				if dir_stack[k] == nil then
					dir_stack[k] = ""
				end
			end
			dir_stack[d] = name
			for k = d + 1, #dir_stack do
				dir_stack[k] = nil
			end
		else
			branch_stack = {}
			dir_stack = {}
		end
		if show_meta and not is_netrw_banner(line) and name ~= "" and name ~= "." and name ~= ".." then
			local full_path = nil
			if d > 0 then
				full_path = Helpers.join_path(base_dir, slice_unpack(dir_stack, 1, d))
			elseif is_tree then
				full_path = Helpers.norm_path(base_dir)
			else
				full_path = Helpers.join_path(base_dir, name)
			end
			if full_path and full_path ~= "" then
				local st = Helpers.stat(full_path) or (uv and uv.fs_lstat and uv.fs_lstat(full_path))
				if st then
					local formatted = ""
					if is_size and st.type == "file" then
						formatted = "  " .. format_size(st.size)
					elseif is_time and st.mtime then
						formatted = "  " .. format_time(st.mtime.sec)
					end
					if formatted ~= "" then
						vim.api.nvim_buf_set_extmark(buf, NetrwUI.ns, i - 1, 0, {
							virt_text = { { formatted, "NetrwSize" } },
							virt_text_pos = "eol",
							strict = false,
						})
					end
				end
			end
		end
	end
end
function NetrwUI.render_all()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "netrw" then
			NetrwUI.render(buf)
		end
	end
end
function NetrwUI.setup()
	local group = vim.api.nvim_create_augroup("NetrwSyntax", { clear = true })
	set_netrw_hl()
	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		pattern = "*",
		callback = set_netrw_hl,
	})
	vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "BufEnter", "TextChanged" }, {
		group = group,
		pattern = "*",
		callback = function(args)
			if vim.bo[args.buf].filetype == "netrw" then
				ensure_window_conceal(args.buf)
				NetrwUI.render(args.buf)
			end
		end,
	})
	vim.api.nvim_create_autocmd({ "FocusGained", "WinResized", "VimResized" }, {
		group = group,
		pattern = "*",
		callback = NetrwUI.render_all,
	})
end
NetrwUI.setup()
_G.NetrwUI = NetrwUI


-- Auto-pairs
PairsV = vim.api.nvim_create_augroup("Pairs", { clear = true })
vim.api.nvim_create_autocmd({"FileType"}, {
	group = PairsV,
	pattern = { "c", "python", "lua", "vim", "rust", "go" },
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

vim.api.nvim_create_autocmd({"BufEnter"}, {
	pattern = "*",
	callback = function()
		local file_type = vim.bo[0].filetype
		if Helpers.in_list(file_type, { "c", "python", "lua", "vim", "rust", "go" }) then
			vim.opt.colorcolumn = "80"
		end
	end
})


-- LSP bootstrap
LSPBootstrapV = vim.api.nvim_create_augroup("LSPBootstrap", { clear = true })
vim.fn.mkdir(BinDir, "p")
vim.env.PATH = BinDir..":"..vim.env.PATH
local node_name = "node-v26.13.1-linux-x64"
local node_path = BinDir.."/"..node_name
local node_url = "https://nodejs.org/dist/v26.13.1/"..node_name..".tar.xz"
local luals_url = "https://github.com/LuaLS/lua-language-server"
local cmd_dump_path = vim.fn.stdpath("config").."/.cmd_dumps"
vim.fn.mkdir(cmd_dump_path, "p")


local luals_install_cmd = table.concat({
	"rm -rf '"..BinDir.."/tmp_lualsp' '"..BinDir.."/lua-language-server-dist' && ",
	"git clone --depth=1 --recurse-submodules '"..luals_url.."' '"..BinDir.."/tmp_lualsp' && ",
	"cd '"..BinDir.."/tmp_lualsp' && ",
	"./make.sh && ",
	"mv '"..BinDir.."/tmp_lualsp' '"..BinDir.."/lua-language-server-dist'",
})

local gopls_install_cmd = "GOBIN="..BinDir.." go install golang.org/x/tools/gopls@latest"

local pyright_install_cmd = table.concat({
				"curl -L -o '"..node_path..".tar.xz' "..node_url.." && ",
				"tar -xf "..node_path..".tar.xz && ",
				node_path.."/bin/npm install --prefix '"..BinDir .."' pyright && ",
				"ln -sf '"..BinDir.."/node_modules/.bin/pyright-langserver' '"..BinDir.."/pyright-langserver' && ",
				"rm -rf "..node_path..".tar.xz "..node_path
			})

local rust_analyzer_install_cmd = table.concat({
			"rm '"..BinDir.."/rust-analyzer_dist' '"..BinDir.."/rust-analyzer_tmp.gz' && ",
			"mkdir -p '"..BinDir.."/rust-analyzer_dist' && ",
			"URL=$(curl -s https://api.github.com/repos/rust-lang/rust-analyzer/releases/latest ",
			"| grep -o '\"browser_download_url\": *\"[^\"]*rust-analyzer-x86_64-unknown-linux-gnu\\.gz\"' ",
			"| grep -o 'https://[^\"]*') && ",
			"echo \"Resolved URL: $URL\" && ",
			"curl -L -o '"..BinDir.."/rust-analyzer_tmp.gz' \"$URL\" && ",
			"gunzip -c '"..BinDir.."/rust-analyzer_tmp.gz' > '"..BinDir.."/rust-analyzer_dist/rust-analyzer' && ",
			"chmod +x '"..BinDir.."/rust-analyzer_dist/rust-analyzer' && ",
			"rm -f '"..BinDir.."/rust-analyzer_tmp.gz'",
		})

local clangd_install_cmd = table.concat({
			"rm -rf '"..BinDir.."/clangd_dist' '".. BinDir.."/clangd_tmp.zip' && ",
			"URL=$(curl -s https://api.github.com/repos/clangd/clangd/releases/latest ",
			"| grep -o '\"browser_download_url\": *\"[^\"]*clangd-linux-[0-9.]*\\.zip\"' ",
			"| grep -o 'https://[^\"]*') && ",
			"echo \"Resolved URL: $URL\" && ",
			"curl -L -o '"..BinDir.."/clangd_tmp.zip' \"$URL\" && ",
			"unzip -q '"..BinDir.."/clangd_tmp.zip' -d '"..BinDir.."' && ",
			"rm -f '"..BinDir.."/clangd_tmp.zip' && ",
			"mv '"..BinDir.."'/clangd_* '"..BinDir.."/clangd_dist'",
		})

SERVERS = {
	python = {
		name = "pyright",
		cmd_name = "pyright-langserver",
		check = function()
			return vim.fn.executable("pyright-langserver") == 1
		end,
		install_cmd = pyright_install_cmd,
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
		install_cmd = rust_analyzer_install_cmd,
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
		install_cmd = clangd_install_cmd,
		lsp_cmd = { BinDir.."/clangd_dist/bin/clangd" },
		filetypes = { "c", "cpp" },
		root_markers = { "compile_commands.json", ".git" }
	},
	go = {
		name = "gopls",
		cmd_name = "gopls",
		check = function()
			return vim.fn.executable(BinDir.."/gopls") == 1
		end,
		install_cmd = gopls_install_cmd,
		lsp_cmd = { BinDir.."/gopls" },
		filetypes = { "go" },
		root_markers = { ".git" }
	},
	lua = {
		name = "lua_ls",
		cmd_name = "lua-language-server",
		check = function()
			return vim.fn.executable(BinDir.."/lua-language-server-dist/bin/lua-language-server") == 1
		end,
		install_cmd = luals_install_cmd,
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
	local current_date = Helpers.replace_char(os.date(), " :", "_", "g")
	local install_cmd = Helpers.substitute(server.install_cmd, " && ", "\\\n\t", "g")
	local content = "Install cmd for server '"..server.name.."'\n\t"..install_cmd.."\n"
	local file_handle = io.open(cmd_dump_path.."/"..server.name.."InstallCmd"..current_date, "w")
	if file_handle then
		file_handle:write(content)
		file_handle:close()
	end
	Helpers.with_job_progress("[Bootstrap] Installing "..server.name, function(done)
		vim.fn.jobstart(server.install_cmd, {
			cwd = BinDir,
			on_exit = function(_, code)
			  if code == 0 then
				done("[Bootstrap] "..server.name.." installed")
				vim.lsp.start({
					name = server.name,
					cmd = server.lsp_cmd,
					filetypes = server.filetypes,
					root_dir = vim.fs.root(bufnr, server.root_markers),
				})
			  else
				done("[Bootstrap] failed to install "..server.name, vim.log.levels.ERROR)
			  end
			end,
		})
	end)
end
vim.api.nvim_create_autocmd("FileType", {
	group = LSPBootstrapV,
	pattern = { "python", "c", "cpp", "lua", "rust", "go" },
	callback = function(args)
		local ft = vim.bo[args.buf].filetype
		local key = (ft == "cpp") and "c" or ft
		local server = SERVERS[key]
		if server then
			BootstrapAndStart(server, args.buf)
		end
	end,
})


-- Completions
vim.api.nvim_create_autocmd("LspAttach", {
	group = LSPBootstrapV,
	pattern = "*",
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client:supports_method("textDocument/completion") then
			vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = false })
		end
	end,
})
vim.keymap.set("i", "<C-n>", function()
	if vim.fn.pumvisible() == 1 then
		return "<C-n>"
	else
		vim.lsp.completion.get()
	end
end, { expr = true })
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
vim.g.c_syntax_for_h = 1
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
	hl(0, "MyNetrwSort", { bg = colors.pink, fg = colors.bg, bold = true })
	vim.o.laststatus = 2
end
function StatusLineRender(flag)
	local sort_modes = {
		name = "\u{f15d} ",
		time = "\u{f017} ",
		size = "\u{f0a0} ",
		exten = "\u{f1c9} ",
		default = "\u{f0dc} ",
	}
	if flag == 2 then
		local name = vim.fn.expand("%:t")
		local focused = vim.g.statusline_winid == vim.api.nvim_get_current_win()
		if not focused then
			return "  "..name
	end
		local netrw_line = string.format("%%#%s# 󰙅 Netrw %%*", "MyStlReplace")
		local prompt = string.format("%%#%s# Sorted by:%%*", "MyNetrwSort")
		local current_sort = vim.g.netrw_sort_by
		local sort = string.format("%%#%s# "..current_sort.." %s %%*", "MyStlVisual", sort_modes[current_sort])
		return table.concat({
			netrw_line,
			"%=",
			prompt,
			sort,
		})
	end
	local mode_names = {
	  n = "NORMAL", i = "INSERT", v = "VISUAL", V = "V-LINE", ic = "I-COMPLETION",
	  ["\22"] = "V-BLOCK", c = "COMMAND", R = "REPLACE", t = "TERMINAL" , nt = "N-TERMINAL" }
	local mode_hl = {
	  n = "MyStlNormal", i = "MyStlInsert", v = "MyStlVisual", V = "MyStlVisual", ic = "MyStlICompletion",
	  ["\22"] = "MyStlVisual", c = "MyStlCommand", R = "MyStlReplace", t = "MyStlTerminal", nt = "MyStlTerminal" }
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
	  c  = "", r  = "󰑕", R  = "󰑕", nt = "", t  = "", ic = "" }
	local m = vim.api.nvim_get_mode().mode
	local mode_comp = string.format("%%#%s#  %s %%*", mode_hl[m] or "MyStlNormal", mode_names[m] or m)..string.format("%%#%s#%s  %%*", mode_hl[m] or "MyStlNormal", mode_icons[m])
	local name = vim.fn.expand("%:t")
	if name == "" then name = "[No Name]" end
	local file_comp = vim.bo.modified and (name.." [+]") or name
	local file_type = string.format("%%#%s#  %s %s  %%*", "MyStlFileType", file_types[vim.bo.filetype] or file_types.default, vim.bo.filetype)
	local file_lines = string.format("%%#%s#  %s %%*", "MyStlFileLines", vim.fn.line(".")..":"..vim.fn.col(".").." ")
	local focused = vim.g.statusline_winid == vim.api.nvim_get_current_win()
	if not focused then
		return "  "..file_comp
	end
	return table.concat({
		mode_comp, " ", file_comp,
		"%=",
		file_type,
		file_lines
	})
end
StatusLineGI = vim.api.nvim_create_augroup("StatusLine", { clear = true })
vim.api.nvim_create_autocmd({"BufEnter"}, {
	group = StatusLineGI,
	pattern = "*",
	callback = function()
		local file_type = vim.bo[0].filetype
		if file_type == "netrw" then
			vim.o.statusline = "%!v:lua.StatusLineRender(2)"
		else
			vim.o.statusline = "%!v:lua.StatusLineRender(1)"
		end
	end
})


-- File_preview
local preview_on = false
local preview_win = nil
function CreatePreviewWindow(buf)
	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local opts = {
		relative = "editor",
		row = math.floor((vim.o.lines - vim.o.cmdheight - height)/2),
		col = math.floor((vim.o.columns - width)/2),
		width = width,
		height = height,
		style = "minimal",
		border = {
			{ "╭", "FloatBorder" },
			{ "─", "FloatBorder" },
			{ "╮", "FloatBorder" },
			{ "│", "FloatBorder" },
			{ "╯", "FloatBorder" },
			{ "─", "FloatBorder" },
			{ "╰", "FloatBorder" },
			{ "│", "FloatBorder" },
		},
		title = "File Preview",
		title_pos = "center",
		focusable = false,
	}
	local win = vim.api.nvim_open_win(buf, false, opts)
	vim.wo[win].winblend = Config.winblend
	vim.wo[win].winhighlight = "Normal:Normal,FloatBorder:FloatBorder"
	return win
end
local function preview()
	if preview_win and vim.api.nvim_win_is_valid(preview_win) then
		vim.api.nvim_win_close(preview_win, true)
		preview_win = nil
	end
	local cwin = vim.api.nvim_get_current_win()
	local cbuf = vim.api.nvim_get_current_buf()
	local filetype = vim.bo[cbuf].filetype
	if vim.api.nvim_win_is_valid(cwin) then
		local filename = Netrw.get_fullpath_under_cursor()
		if filename ~= nil and string.sub(filename, -1) ~= '/' and vim.fn.filereadable(filename) and filetype == "netrw" then
			local buf = vim.api.nvim_create_buf(false, true)
			local file_type = vim.filetype.match({ filename = filename })
			local content = vim.fn.readfile(filename)
			local success, _ = pcall(vim.api.nvim_buf_set_lines, buf, 0, -1, false, content)
			if not success then return end
			vim.bo[buf].filetype = file_type
			preview_win = CreatePreviewWindow(buf)
		end
	end
end
vim.api.nvim_create_autocmd("CursorMoved", {
	pattern = "*",
	callback = function()
		if preview_on then
			preview()
		end
	end
})
vim.keymap.set("n", "<Leader>pr", function()
	preview_on = not preview_on
	if preview_on then
		preview()
	end
	if not preview_on and preview_win and vim.api.nvim_win_is_valid(preview_win) then
		vim.api.nvim_win_close(preview_win, true)
		preview_win = nil
	end
end, { silent = true })



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
	pattern = "*",
	callback = function()
		-- CursorAnimate()
	end
})


-- Search highlight
vim.opt.hlsearch = false
function Toggle_hlsearch()
	vim.opt.hlsearch = not vim.opt.hlsearch:get()  ---@diagnostic disable-line: undefined-field
end


-- Markdown LOAD_IMAGE → Kitty unicode placeholders
vim.fn.mkdir(BinDir, "p")
vim.env.PATH = BinDir..":"..vim.env.PATH
local function ensure_imagemagick()
	if vim.fn.executable("magick") == 1 or vim.fn.executable(BinDir.."/magick") == 1 then
		return true
	end
	vim.notify("[Bootstrap] Downloading portable ImageMagick AppImage...")
	local out = BinDir.."/magick"
	local cmd = string.format(
		"curl -L -o '%s' 'https://github.com/ImageMagick/ImageMagick/releases/download/7.1.2-35/ImageMagick-7.1.2-35-gcc-x86_64.AppImage' && chmod +x '%s'",
		out, out
	)
	vim.fn.jobstart(cmd, {
		on_exit = function(_, code)
			if code == 0 then
				vim.notify("[Bootstrap] ImageMagick installed successfully!")
			else
				vim.notify("[Bootstrap] ImageMagick download failed", vim.log.levels.ERROR)
			end
		end,
	})
	return false
end
vim.schedule(function()
	ensure_imagemagick()
end)
local is_kitty = vim.env.KITTY_WINDOW_ID ~= nil or (vim.env.TERM or ""):lower():find("kitty") ~= nil
if is_kitty then
	local ns = vim.api.nvim_create_namespace("load_image_kitty")
	local tty_file = nil
	local uv = vim.uv or vim.loop
	local function write(data)
		if not data or data == "" then return end
		vim.fn.chansend(2, data)
	end
	local image_ids = {}
	local next_id = 1
	local transmitted = {}
	local function ensure_hl(id)
		local name = "KittyImg"..id
		if vim.fn.hlexists(name) == 0 then
			local r = math.floor(id / 65536) % 256
			local g = math.floor(id / 256) % 256
			local b = id % 256
			vim.api.nvim_set_hl(0, name, {
				fg = string.format("#%02x%02x%02x", r, g, b),
				bg = "NONE",
			})
		end
		return name
	end
	local function fetch_remote_image(url)
		if not url or url == "" then return nil end
		local ext = url:match("%.([%w]+)$")
		if not ext or #ext > 4 then ext = "png" end
		local hash = vim.fn.sha256(url)
		local cache_dir = vim.fn.stdpath("cache").."/markdown_images"
		vim.fn.mkdir(cache_dir, "p")
		local local_path = string.format("%s/%s.%s", cache_dir, hash, ext)
		if vim.fn.filereadable(local_path) == 1 then
			return local_path
		end
		local download_cmd = ""
		if vim.fn.executable("curl") == 1 then
			download_cmd = string.format("curl -s -L %s -o %s", vim.fn.shellescape(url), vim.fn.shellescape(local_path))
		elseif vim.fn.executable("wget") == 1 then
			download_cmd = string.format("wget -q %s -O %s", vim.fn.shellescape(url), vim.fn.shellescape(local_path))
		else
			return nil
		end
		local success = os.execute(download_cmd)
		if success == 0 or success == true then
			return local_path
		end
		return nil
	end
	local function prepare_image(path)
		local ext = path:sub(-4):lower()
		if ext == ".png" then return path end
		local tmp_path = "/tmp/kitty_"..vim.fn.sha256(path)..".png"
		if vim.fn.filereadable(tmp_path) == 0 then
			local magick = vim.fn.executable("magick") == 1 and "magick" or "convert"
			if vim.fn.executable(magick) == 1 then
				vim.fn.system(string.format("%s %s %s",
					magick, vim.fn.shellescape(path), vim.fn.shellescape(tmp_path)))
			else
				return nil
			end
		end
		return tmp_path
	end
	local ROWCOL_DIACRITICS = {
		0x0305, 0x030D, 0x030E, 0x0310, 0x0312, 0x033D, 0x033E, 0x033F, 0x0346, 0x034A, 0x034B, 0x034C,
		0x0350, 0x0351, 0x0352, 0x0357, 0x035B, 0x0363, 0x0364, 0x0365, 0x0366, 0x0367, 0x0368, 0x0369,
		0x036A, 0x036B, 0x036C, 0x036D, 0x036E, 0x036F, 0x0483, 0x0484, 0x0485, 0x0486, 0x0487, 0x0592,
		0x0593, 0x0594, 0x0595, 0x0597, 0x0598, 0x0599, 0x059C, 0x059D, 0x059E, 0x059F, 0x05A0, 0x05A1,
		0x05A8, 0x05A9, 0x05AB, 0x05AC, 0x05AF, 0x05C4, 0x0610, 0x0611, 0x0612, 0x0613, 0x0614, 0x0615,
		0x0616, 0x0617, 0x0657, 0x0658, 0x0659, 0x065A, 0x065B, 0x065D, 0x065E, 0x06D6, 0x06D7, 0x06D8,
		0x06D9, 0x06DA, 0x06DB, 0x06DC, 0x06DF, 0x06E0, 0x06E1, 0x06E2, 0x06E4, 0x06E7, 0x06E8, 0x06EB,
		0x06EC, 0x0730, 0x0732, 0x0733, 0x0735, 0x0736, 0x073A, 0x073D, 0x073F, 0x0740, 0x0741, 0x0743,
		0x0745, 0x0747, 0x0749, 0x074A, 0x07EB, 0x07EC, 0x07ED, 0x07EE, 0x07EF, 0x07F0, 0x07F1, 0x07F3,
		0x0816, 0x0817, 0x0818, 0x0819, 0x081B, 0x081C, 0x081D, 0x081E, 0x081F, 0x0820, 0x0821, 0x0822,
		0x0823, 0x0825, 0x0826, 0x0827, 0x0829, 0x082A, 0x082B, 0x082C, 0x082D, 0x0951, 0x0953, 0x0954,
		0x0F82, 0x0F83, 0x0F86, 0x0F87, 0x135D, 0x135E, 0x135F, 0x17DD, 0x193A, 0x1A17, 0x1A75, 0x1A76,
		0x1A77, 0x1A78, 0x1A79, 0x1A7A, 0x1A7B, 0x1A7C, 0x1B6B, 0x1B6D, 0x1B6E, 0x1B6F, 0x1B70, 0x1B71,
		0x1B72, 0x1B73, 0x1CD0, 0x1CD1, 0x1CD2, 0x1CDA, 0x1CDB, 0x1CE0, 0x1DC0, 0x1DC1, 0x1DC3, 0x1DC4,
		0x1DC5, 0x1DC6, 0x1DC7, 0x1DC8, 0x1DC9, 0x1DCB, 0x1DCC, 0x1DD1, 0x1DD2, 0x1DD3, 0x1DD4, 0x1DD5,
		0x1DD6, 0x1DD7, 0x1DD8, 0x1DD9, 0x1DDA, 0x1DDB, 0x1DDC, 0x1DDD, 0x1DDE, 0x1DDF, 0x1DE0, 0x1DE1,
		0x1DE2, 0x1DE3, 0x1DE4, 0x1DE5, 0x1DE6, 0x1DFE, 0x20D0, 0x20D1, 0x20D4, 0x20D5, 0x20D6, 0x20D7,
		0x20DB, 0x20DC, 0x20E1, 0x20E7, 0x20E9, 0x20F0, 0x2CEF, 0x2CF0, 0x2CF1, 0x2DE0, 0x2DE1, 0x2DE2,
		0x2DE3, 0x2DE4, 0x2DE5, 0x2DE6, 0x2DE7, 0x2DE8, 0x2DE9, 0x2DEA, 0x2DEB, 0x2DEC, 0x2DED, 0x2DEE,
		0x2DEF, 0x2DF0, 0x2DF1, 0x2DF2, 0x2DF3, 0x2DF4, 0x2DF5, 0x2DF6, 0x2DF7, 0x2DF8, 0x2DF9, 0x2DFA,
		0x2DFB, 0x2DFC, 0x2DFD, 0x2DFE, 0x2DFF, 0xA66F, 0xA67C, 0xA67D, 0xA6F0, 0xA6F1, 0xA8E0, 0xA8E1,
		0xA8E2, 0xA8E3, 0xA8E4, 0xA8E5, 0xA8E6, 0xA8E7, 0xA8E8, 0xA8E9, 0xA8EA, 0xA8EB, 0xA8EC, 0xA8ED,
		0xA8EE, 0xA8EF, 0xA8F0, 0xA8F1, 0xAAB0, 0xAAB2, 0xAAB3, 0xAAB7, 0xAAB8, 0xAABE, 0xAABF, 0xAAC1,
		0xFE20, 0xFE21, 0xFE22, 0xFE23, 0xFE24, 0xFE25, 0xFE26, 0x10A0F, 0x10A38, 0x1D185, 0x1D186, 0x1D187,
		0x1D188, 0x1D189, 0x1D1AA, 0x1D1AB, 0x1D1AC, 0x1D1AD, 0x1D242, 0x1D243, 0x1D244,
	}
	local function diacritic(n)
		return vim.fn.nr2char(ROWCOL_DIACRITICS[(n % #ROWCOL_DIACRITICS) + 1], true)
	end
	local PH = "\xF4\x8E\xBB\xAE"
	local function get_image_dimensions(path)
		local f = io.open(path, "rb")
		if not f then return nil, nil end
		local header = f:read(24)
		if not header then f:close(); return nil, nil end
		if header:sub(2, 4) == "PNG" then
			f:close()
			local w = string.byte(header, 17) * 16777216 + string.byte(header, 18) * 65536 + string.byte(header, 19) * 256 + string.byte(header, 20)
			local h = string.byte(header, 21) * 16777216 + string.byte(header, 22) * 65536 + string.byte(header, 23) * 256 + string.byte(header, 24)
			return w, h
		end
		if string.byte(header, 1) == 0xFF and string.byte(header, 2) == 0xD8 then
			f:seek("set", 2)
			local data = f:read("*a")
			f:close()
			local i = 1
			while i < #data do
				if string.byte(data, i) ~= 0xFF then
					i = i + 1
				else
					local marker = string.byte(data, i + 1)
					if marker == 0xC0 or marker == 0xC1 or marker == 0xC2 or marker == 0xC3 then
						local h = string.byte(data, i + 5) * 256 + string.byte(data, i + 6)
						local w = string.byte(data, i + 7) * 256 + string.byte(data, i + 8)
						return w, h
					elseif marker == 0xD9 or marker == 0xDA then
						break
					else
						local len = string.byte(data, i + 2) * 256 + string.byte(data, i + 3)
						i = i + 2 + len
					end
				end
			end
		end
		f:close()
		return nil, nil
	end
	local function transmit(id, path, cols, rows)
		local key = id..":"..cols.."x"..rows
		if transmitted[key] then return end
		local b64 = vim.base64.encode(vim.fn.fnamemodify(path, ":p")):gsub("%-", "/")
		local chunks = {}
		for i = 1, #b64, 4096 do
			table.insert(chunks, b64:sub(i, i + 4095))
		end
		for i, chunk in ipairs(chunks) do
			local ctrl
			if i == 1 then
				ctrl = string.format("a=t,f=100,t=f,i=%d,q=2,U=1,C=1,m=%d", id, (#chunks > 1 and 1 or 0))
			else
				ctrl = string.format("m=%d", (i == #chunks) and 0 or 1)
			end
			write("\x1b_G"..ctrl..";"..chunk.."\x1b\\")
			uv.sleep(1)
		end
		transmitted[key] = true
		local control_p = string.format("a=p,i=%d,p=%d,c=%d,r=%d,q=2,U=1,C=1", id, id, cols, rows)
		write("\x1b_G"..control_p.."\x1b\\")
	end
	local function refresh(buf)
		if not vim.api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= "markdown" then return end
		vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
		local win = vim.fn.bufwinid(buf)
		if win == -1 then return end
		local win_info = vim.fn.getwininfo(win)[1]
		if not win_info then return end
		local available_width = win_info.width - win_info.textoff
		local max_cols = math.max(10, available_width - 2)
		local max_rows = 20
		local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
		local total_lines = #lines
		for i, line in ipairs(lines) do
			local target_path = nil
			local local_p = line:match('%-%-%s*LOAD_IMAGE%s*=%s*"([^"]+)"%s*%-%-')
			if local_p then
				if local_p:match("^https?://") then
					target_path = fetch_remote_image(local_p)
				else
					target_path = vim.fn.expand(local_p)
				end
			end
			if target_path and vim.fn.filereadable(target_path) == 1 then
				local id = image_ids[target_path]
				if not id then
					id = next_id
					next_id = next_id + 1
					image_ids[target_path] = id
				end
				local hl = ensure_hl(id)
				local w, h = get_image_dimensions(target_path)
				local cols, rows
				if w and h and w > 0 and h > 0 then
					local aspect = w / h
					rows = math.floor(max_cols / (aspect * 2))
					if rows > max_rows then rows = max_rows end
					cols = math.floor(rows * aspect * 2)
					if cols > max_cols then
						cols = max_cols
						rows = math.floor(cols / (aspect * 2))
					end
				else
					cols = max_cols
					rows = max_rows
				end
				cols, rows = math.max(1, cols), math.max(1, rows)
				local png_path = prepare_image(target_path)
				if png_path and vim.fn.filereadable(png_path) == 1 then
					transmit(id, png_path, cols, rows)
					local virt = {}
					for r = 0, rows - 1 do
						local row_d = diacritic(r)
						local cells = {}
						for c = 0, cols - 1 do
							cells[#cells + 1] = PH..row_d..diacritic(c)
						end
						virt[#virt + 1] = { { table.concat(cells), hl } }
					end
					vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, { end_col = #line, conceal = "" })
					local draw_above = (i >= total_lines)
					vim.api.nvim_buf_set_extmark(buf, ns, i - 1, 0, {
						virt_lines = virt,
						virt_lines_above = draw_above
					})
				end
			end
		end
	end
	local group = vim.api.nvim_create_augroup("LoadImageKitty", { clear = true })
	vim.api.nvim_create_autocmd(
		{ "BufReadPost", "BufEnter", "BufWritePost", "TextChanged", "InsertLeave" }, {
		group = group,
		pattern = { "*.md", "*.markdown" },
		callback = function(ev)
			vim.schedule(function() pcall(refresh, ev.buf) end)
		end,
	})
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = function() if tty_file then pcall(function() tty_file:close() end) end end,
	})
end


-- Keymaps
vim.keymap.set("n", "<C-l>", "<C-w>l", { silent = true })
vim.keymap.set("n", "<C-h>", "<C-w>h", { silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { silent = true })
vim.keymap.set("n", "<Leader>h", Toggle_hlsearch, { silent = true })
vim.keymap.set("n", "<Leader>n", ":next<CR>", { silent = true })
vim.keymap.set("n", "<Leader>p", ":prev<CR>", { silent = true })
vim.keymap.set("n", "<Leader>bf", ":let g:netrw_banner = 1<CR>:Ex<CR>", { silent = true })
vim.keymap.set("n", "<Leader>sc", ":so ~/.config/nvim/init.lua <CR>", { silent = true })
vim.keymap.set("n", "<Leader>o", ":only<CR>", { silent = true })


vim.keymap.set("n", "<Leader>man", function()
	local cword = vim.fn.expand('<cword>')
	if cword == "" then return end
	vim.fn.jobstart("man -w "..cword, {
		on_exit = function(_, exit_code)
			if exit_code == 0 then
				vim.schedule(function()
					ToggleTerminal("man "..cword)
				end)
			else
				vim.schedule(function()
					vim.api.nvim_echo({{ "No manual entry for "..cword, "ErrorMsg" }}, true, {})
				end)
			end
		end
	})
end, { noremap = true, silent = true })
vim.keymap.set("n", "<Leader>help", function()
	local cword = vim.fn.expand('<cword>')
	if cword == "" then return end
	local check_cmd = string.format("python3 -c \"import pydoc; pydoc.render_doc('%s')\"", cword)
	vim.fn.jobstart(check_cmd, {
		on_exit = function(_, exit_code)
			if exit_code == 0 then
				vim.schedule(function()
					ToggleTerminal("python3 -c \"help("..cword..")\"")
				end)
			else
				vim.schedule(function()
					vim.api.nvim_echo({{ "No Python help found for ".. cword, "ErrorMsg" }}, true, {})
				end)
			end
		end
	})
end, { noremap = true, silent = true })
vim.keymap.set("n", "<Leader>q", "<C-\\><C-n>:q!<CR>", { silent = true })
vim.keymap.set({ "n", "v" }, "<Leader>y", '"+y', { silent = true })
vim.keymap.set("n", "<CR>", "za", { silent = true })
vim.keymap.set({ "n", "v" }, "<Leader>qa", ":qa!<CR>", { silent = true })
vim.keymap.set("t", "<Leader>qa", "<C-\\><C-n>:qa!<CR>", { silent = true })


vim.keymap.set("n", "<Leader>s", ":%s/\\<<C-r><C-w>\\>//gI<Left><Left><Left>", { silent = true })
vim.keymap.set("x", "<leader>s", [["vy:%s/\V<C-r>=escape(@v, '/\')<CR>//g<Left><Left>]], { silent = true })
vim.keymap.set("n", "<Leader>S", ":s/\\<<C-r><C-w>\\>//gI<Left><Left><Left>", { silent = true })
vim.keymap.set("x", "<leader>S", [["vy:s/\V<C-r>=escape(@v, '/\')<CR>//<Left><Left>]], { silent = true })

local function visual_wrap(left, right)
	return function()
		local m = vim.api.nvim_get_mode().mode
		local map = {
			v = "c"..left..'<C-r>"'..right.."<Esc>",
			V = [[:s/\%V.*\%V/]]..left.."&"..right..[[/g<CR>]],
			["\22"] = "c"..left..'<C-r>"'..right.."<Esc>",
		}
		return map[m]
	end
end

vim.keymap.set("n", '<Leader>"', ':s/\\<<C-r><C-w>\\>/"<C-r><C-w>"/ <CR>')
vim.keymap.set("x", '<leader>"', visual_wrap('"', '"'), { expr = true, silent = true })

vim.keymap.set("n", "<Leader>'", ":s/\\<<C-r><C-w>\\>/'<C-r><C-w>'/ <CR>")
vim.keymap.set("x", "<leader>'", visual_wrap("'", "'"), { expr = true, silent = true })

vim.keymap.set("n", "<Leader>{", ":s/\\<<C-r><C-w>\\>/{<C-r><C-w>}/ <CR>")
vim.keymap.set("x", "<leader>{", visual_wrap("{", "}"), { expr = true, silent = true })
vim.keymap.set("n", "<Leader>}", ":s/\\<<C-r><C-w>\\>/{<C-r><C-w>}/ <CR>")
vim.keymap.set("x", "<leader>}", visual_wrap("{", "}"), { expr = true, silent = true })

vim.keymap.set("n", "<Leader>(", ":s/\\<<C-r><C-w>\\>/(<C-r><C-w>)/ <CR>")
vim.keymap.set("x", "<leader>(", visual_wrap("(", ")"), { expr = true, silent = true })
vim.keymap.set("n", "<Leader>)", ":s/\\<<C-r><C-w>\\>/(<C-r><C-w>)/ <CR>")
vim.keymap.set("x", "<leader>)", visual_wrap("(", ")"), { expr = true, silent = true })

vim.keymap.set("n", "<Leader>[", ":s/\\<<C-r><C-w>\\>/[<C-r><C-w>]/ <CR>")
vim.keymap.set("x", "<leader>[", visual_wrap("[", "]"), { expr = true, silent = true })
vim.keymap.set("n", "<Leader>]", ":s/\\<<C-r><C-w>\\>/[<C-r><C-w>]/ <CR>")
vim.keymap.set("x", "<leader>]", visual_wrap("[", "]"), { expr = true, silent = true })



-- Always keep at the bottom
MidnightNexus()
StatusLineSetup()
