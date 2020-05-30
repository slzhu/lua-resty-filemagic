local bit          = require "bit"
local ffi          = require "ffi"

local ffi_load     = ffi.load
local ffi_gc       = ffi.gc
local ffi_str      = ffi.string
local ffi_cdef     = ffi.cdef
local bor          = bit.bor

local type         = type
local ipairs       = ipairs
local assert       = assert
local setmetatable = setmetatable

local cdata_null   = ffi.new("const char *")

ffi_cdef [[
typedef struct magic_set *magic_t;
magic_t magic_open(int);
void magic_close(magic_t);

const char *magic_getpath(const char *, int);
const char *magic_file(magic_t, const char *);
const char *magic_descriptor(magic_t, int);
const char *magic_buffer(magic_t, const void *, size_t);

const char *magic_error(magic_t);
int magic_getflags(magic_t);
int magic_setflags(magic_t, int);

//int magic_version(void);
int magic_load(magic_t, const char *);
int magic_load_buffers(magic_t, void **, size_t *, size_t);

int magic_compile(magic_t, const char *);
int magic_check(magic_t, const char *);
int magic_list(magic_t, const char *);
int magic_errno(magic_t);
]]

local flgs                       = {}

flgs.none                        = 0x0000000 -- /* No flags */
flgs.debug                       = 0x0000001 -- /* Turn on debugging */
flgs.symlink                     = 0x0000002 -- /* Follow symlinks */
flgs.compress                    = 0x0000004 -- /* Check inside compressed files */
flgs.devices                     = 0x0000008 -- /* Look at the contents of devices */
flgs.mime_type                   = 0x0000010 -- /* Return the MIME type */
flgs.continue                    = 0x0000020 -- /* Return all matches */
flgs.check                       = 0x0000040 -- /* Print warnings to stderr */
flgs.preserve_atime              = 0x0000080 -- /* Restore access time on exit */
flgs.raw                         = 0x0000100 -- /* Don't convert unprintable chars */
flgs.error                       = 0x0000200 -- /* Handle ENOENT etc as real errors */
flgs.mime_encoding               = 0x0000400 -- /* Return the MIME encoding */
flgs.mime                        = bor(flgs.mime_type, flgs.mime_encoding)
flgs.apple                       = 0x0000800 -- /* Return the Apple creator/type */
flgs.extension                   = 0x1000000 -- /* Return a /-separated list of extensions */
flgs.compress_transp             = 0x2000000 -- /* Check inside compressed files but not report compression */
flgs.nodesc                      = bor(flgs.extension, flgs.mime, flgs.apple)
flgs.no_check_compress           = 0x0001000 -- /* Don't check for compressed files */
flgs.no_check_tar                = 0x0002000 -- /* Don't check for tar files */
flgs.no_check_soft               = 0x0004000 -- /* Don't check magic entries */
flgs.no_check_apptype            = 0x0008000 -- /* Don't check application type */
flgs.no_check_elf                = 0x0010000 -- /* Don't check for elf details */
flgs.no_check_text               = 0x0020000 -- /* Don't check for text files */
flgs.no_check_cdf                = 0x0040000 -- /* Don't check for cdf files */
flgs.no_check_tokens             = 0x0100000 -- /* Don't check tokens */
flgs.no_check_encoding           = 0x0200000 -- /* Don't check text encodings */
flgs.no_check_json               = 0x0400000 -- /* Don't check for JSON files */

--/* Defined for backwards compatibility (renamed) */
flgs.no_check_ascii              = flgs.no_check_text

--/* Defined for backwards compatibility; do nothing */
flgs.no_check_fortran            = 0x000000 -- /* Don't check ascii/fortran */
flgs.no_check_troff              = 0x000000 -- /* Don't check ascii/troff */

local params                     = {}

--         Parameter                     Type      Default
params.magic_param_indir_max     = 0  -- size_t    15           
params.magic_param_name_max      = 1  -- size_t    30           controls the maximum number of calls for name/use.
params.magic_param_elf_phnum_max = 2  -- size_t    128          controls how many ELF program sections will	be processed.
params.magic_param_elf_shnum_max = 3  -- size_t    32768        controls how many ELF sections will be processed.
params.magic_param_elf_notes_max = 4  -- size_t    256          controls how many ELF notes will be processed.
params.magic_param_regex_max     = 5  -- size_t    8192
params.magic_param_bytes_max     = 6  -- size_t    1048576

local lib                        = ffi_load "magic"

local function flags_tonumber(flags)
    local t = type(flags)
    local f = 0

    if t == "number" then
        f = flags
    elseif t == "table" then
        for _, v in ipairs(flags) do
            if type(v) == "number" then
                f = bor(v, f)
            else
                f = bor(flags[v] or 0, f)
            end
        end
    end

    return f
end

---@param self LuaFileMagic
local function __call(self, path, flags, magic)
    if self.context then
        return self:file(path, flags)
    else
        local ins = self.new(flags, magic)
        return ins:file(path)
    end
end

---@class LuaFileMagic
---@field version number
---@field context cdata
local FileMagic   = setmetatable({ }, { __call = __call })

--FileMagic.version = lib.magic_version()
FileMagic.flags   = flgs
FileMagic.params  = params

local mt          = { __index = FileMagic, __call = __call }

---@param flags number | number[] @@ optional, 0 by default
---@param magic string @@ optional
---@return LuaFileMagic
function FileMagic.new(flags, magic)
    local context = ffi_gc(lib.magic_open(flags_tonumber(flags)), lib.magic_close)

    ---@type LuaFileMagic
    local this    = setmetatable({ context = context }, mt)
    assert(this:load(magic))

    return this
end

---@return string
function FileMagic:error()
    local err = lib.magic_error(self.context)
    if err ~= cdata_null then
        return ffi_str(err)
    end
end

---@return number
function FileMagic:errno()
    return lib.magic_errno(self.context)
end

---@param fd cdata
---@param flags number | number[] @@ optional
---@return string, string info, error
function FileMagic:descriptor(fd, flags)
    if flags then
        self:setflags(flags)
    end

    local value = lib.magic_descriptor(self.context, fd)
    return value and ffi_str(value) or nil, not value and self:error() or nil
end

---@param path string
---@param flags number | number[] @@ optional
---@return string, string info, error
function FileMagic:file(path, flags)
    if flags then
        self:setflags(flags)
    end

    local value = lib.magic_file(self.context, path)
    return value and ffi_str(value) or nil, not value and self:error() or nil
end

---@param buffer string
---@param flags number | number [] @@ optional
---@return string, string info, error
function FileMagic:buffer(buffer, flags)
    if flags then
        self:setflags(flags)
    end

    local value = lib.magic_buffer(self.context, buffer, #buffer)
    return value and ffi_str(value) or nil, not value and self:error() or nil
end

---@return number | '"-1"', string
function FileMagic:getflags()
    return lib.magic_getflags(self.context), self:error()
end

---@param flags number | number[]
---@return boolean, string
function FileMagic:setflags(flags)
    return lib.magic_setflags(self.context, flags_tonumber(flags)) == 0, self:error()
end

---@param path string @@ optional
---@return boolean, string
function FileMagic:check(path)
    return lib.magic_check(self.context, path) == 0, self:error()
end

---@param path string @@ optional
---@return boolean, string
function FileMagic:compile(path)
    return lib.magic_compile(self.context, path) == 0, self:error()
end

---@param path string @@ optional
---@return boolean, string
function FileMagic:list(path)
    return lib.magic_list(self.context, path) == 0, self:error()
end

---@param path string @@ optional
---@return boolean, string
function FileMagic:load(path)
    return lib.magic_load(self.context, path) == 0, self:error()
end

--function fileinfo:load_buffers(buffers, sizes, nbuffers)
--TODO
--end

--function fileinfo:getparam(param, value)
--TODO
--end

--function fileinfo:setparam(param, value)
--TODO
--end

return FileMagic
