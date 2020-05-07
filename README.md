
Name
====

`lua-resty-filemagic` is a file information library implementing LuaJIT bindings to `libmagic`.

Table of Contents
=================
* [Name](#name)
* [Status](#status)
* [Synopsis](#synopsis)
* [Description](#description)
  * [Fields](#fields)
  * [Lua API](#lua-api)
* [TODO](#todo)
* [Installation](#installation)
* [License](#license)
* [See Also](#see-also)

Status
======
Producty ready.

Synopsis
========

```lua
-- Quick call using __call meta-method
local filemagic = require "resty.filemagic"
local flags = filemagic.flags

local info, err = filemagic("path to file")
if info then
    print(info)
end

-- Another usage by create new context
local init_flags = {flags.error}
local ins = filemagic.new(init_flags)

local default_flags = nil
local flags1 = {flags.mime, flags.extension}

local info, err = ins:file("path to file", default_flags)
local info, err = ins:buffer("all or part of the file content", flags1)
```
Description
===========

Fields
------

* [FileMagic.version](#filemagicversion)
* [FileMagic.flags.*](#filemagicflags)
* [FileMagic.params.*](#filemagicparams)

### FileMagic.version
---------------------

Get the version number of this library
     which is compiled into the	shared library using the constant
     `MAGIC_VERSION` from	`<magic.h>`.  This can be	used by	client programs	to
     verify that the version they compile against is the same as the version
     that they run against.

### FileMagic.flags.*
---------------------

| Flag              | Description                                              |
|:------------------|:---------------------------------------------------------|
| none              | No flags                                                 |
| debug             | Turn on debugging                                        |
| symlink           | Follow symlinks                                          |
| compress          | Check inside compressed files                            |
| devices           | Look at the contents of devices                          |
| mime_type         | Return the MIME type                                     |
| continue          | Return all matches                                       |
| check             | Print warnings to stderr                                 |
| preserve_atime    | Restore access time on exit                              |
| raw               | Don't convert unprintable chars                          |
| error             | Handle ENOENT etc as real errors                         |
| mime_encoding     | Return the MIME encoding                                 |
| mime              | A shorthand for mime_type \| mime_encoding.              |
| apple             | Return the Apple creator/type                            |
| extension         | Return a /-separated list of extensions                  |
| compress_transp   | Check inside compressed files but not report compression |
| nodesc            | A shorthand for extension \| mime \| apple               |
| no_check_compress | Don't check for compressed files                         |
| no_check_tar      | Don't check for tar files                                |
| no_check_soft     | Don't check magic entries                                |
| no_check_apptype  | Don't check application type                             |
| no_check_elf      | Don't check for elf details                              |
| no_check_text     | Don't check for text files                               |
| no_check_cdf      | Don't check for cdf files                                |
| no_check_tokens   | Don't check tokens                                       |
| no_check_encoding | Don't check text encodings                               |
| no_check_json     | Don't check for JSON files                               |
| no_check_ascii    | Same as `no_check_text`                                  |

### FileMagic.params.*
----------------------

| Parameter                 | Description                                                | Default |
|:--------------------------|:-----------------------------------------------------------|:--------|
| magic_param_indir_max     |                                                            | 15      |
| magic_param_name_max      | controls the maximum number of calls for name/use.         | 30      |
| magic_param_elf_phnum_max | controls how many ELF program sections will  be processed. | 128     |
| magic_param_elf_shnum_max | controls how many ELF sections will be processed.          | 32768   |
| magic_param_elf_notes_max | controls how many ELF notes will be processed.             | 256     |
| magic_param_regex_max     |                                                            | 8192    |
| magic_param_bytes_max     |                                                            | 1048576 |

Lua API
-------
* [FileMagic()](#filemagic)
* [FileMagic.new](#filemagicnew)
* [FileMagic:error](#filemagicerror)
* [FileMagic:errno](#filemagicerrno)
* [FileMagic:descriptor](#filemagicdescriptor)
* [FileMagic:file](#filemagicfile)
* [FileMagic:buffer](#filemagicbuffer)
* [FileMagic:getflags](#filemagicgetflags)
* [FileMagic:setflags](#filemagicsetflags)
* [FileMagic:check](#filemagiccheck)
* [FileMagic:compile](#filemagiccompile)
* [FileMagic:list](#filemagiclist)
* [FileMagic:load](#filemagicload)

### FileMagic()
---------------
```lua
---@param path string
---@param flags number | number[] @@ optional, 0 by default
---@param magic string @@ optional 
---@return LuaFileMagic
```
**syntax:** *info, err = FileMagic(path, flags, magic)*

Call this function to quickly recognize the file specified in `path` argument.

### FileMagic.new
-----------------
```lua
---@param flags number | number[] @@ optional, 0 by default
---@param magic string @@ optional
---@return LuaFileMagic
```
**syntax:** *instance = FileMagic.new(flags, magic)*

The function creates a magic cookie pointer wrapper and returns it.
It returns nil if there was an error allocating the magic cookie. The
flags argument specifies how the other magic functions should behave.

### FileMagic:error
---------------
```lua
---@return string | nil
```
**syntax:** *err = FileMagic:error()*

The function returns a textual explanation of the last error, or NULL if there was no error.

### FileMagic:errno
---------------
```lua
---@return number
```
**syntax:** *errno = FileMagic:errno()*

The function returns the last operating system error number that was encountered by a system call.

### FileMagic:descriptor
----------
```lua
---@param fd cdata
---@param flags number | number[] @@ optional
---@return string | nil, string
```
**syntax:** *info, err = FileMagic:descriptor(fd, flags)*

The function returns a textual description of the contents of the `fd` argument, or nil if an error occurred.

### FileMagic:file
--------------
```lua
---@param path string 
---@param flags number | number[] @@ optional
---@return string | nil, string
```
**syntax:** *info, err = FileMagic:file(path, flags)*

The function returns a textual description of the contents of the `path` argument, or nil if an error occurred.

### FileMagic:buffer
----------------
```lua
---@param buffer string
---@param flags number | number[] @@ optional
---@return string | nil, string
```
**syntax:** *info, err = FileMagic:buffer(buffer, flags)*

The function returns a textual description of the contents of the `buffer` argument.

### FileMagic:getflags
----------------
```lua
---@return number | '>=0' | '-1', string
```
**syntax:** *flags, err = FileMagic:getflags()*

The function returns a value representing current `flags` set.

### FileMagic:setflags
----------------
```lua
---@param flags number | number[]
---@return boolean, string
```
**syntax:** *ok, err = FileMagic:setflags(flags)*

The function sets the flags described above. Note that using both MIME flags together can also return extra information on the charset.

### FileMagic:check
---------------
```lua
---@param path string @@ optional
---@return boolean, string
```
**syntax:** *ok, err = FileMagic:check(path)*

The function	can be used to check the validity of entries
in	the colon separated database files passed in as	`path`, or `nil` for
the default database.

### FileMagic:compile
---------------
```lua
---@param path string @@ optional
---@return boolean, string
```
**syntax:** *ok, err = FileMagic:compile(path)*

The function can be used to compile the colon separated
list of database files passed in as `path`, or `nil` for the default
database.  The	compiled files
created are named from the	`basename(1)` of each file argument with ".mgc"
appended to it.

### FileMagic:list
---------------
```lua
---@param path string @@ optional
---@return boolean, string
```
**syntax:** *ok, err = FileMagic:list(path)*

The function dumps all magic entries in a human readable
     format, dumping first the entries that are	matched	against	binary files
     and then the ones that match text files.  It takes	and optional `path`
     argument which is a colon separated list of database files, or `nil` for
     the default database.

### FileMagic:load
---------------
```lua
---@param path string @@ optional
---@return boolean, string
```
**syntax:** *ok, err = FileMagic:load(path)*

The function must be u sed to load the	colon separated	list
     of	database files passed in as `path`, or `nil` for the default database
     file before any magic queries can performed.

TODO
====

* load_buffers
* getparam
* setparam

Installation
============

Just place [`filemagic.lua`](https://github.com/slzhu/lua-resty-filemagic/blob/master/lib/resty/filemagic.lua) somewhere in your `package.path`, preferably under `resty` directory. If you are using OpenResty, the default location would be `/usr/local/openresty/lualib/resty`.

Compiling and Installing libmagic C-library
-------------------------------------------

Consult your operating system or package management about installing this (usually it is already installed in most systems).

License
=======

`lua-resty-filemagic` uses two clause BSD license.

```
Copyright (c) 2020, Joney Zhu
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this
  list of conditions and the following disclaimer in the documentation and/or
  other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```

See Also
========

* [FreeBSD Manual Pages](https://www.freebsd.org/cgi/man.cgi?query=libmagic&sektion=3&apropos=0&manpath=FreeBSD+12.1-RELEASE+and+Ports)
* [magic.h](https://github.com/file/file/blob/FILE5_37/src/magic.h.in)
