# lua-resty-filemagic

`lua-resty-filemagic` is a file information library implementing LuaJIT bindings to `libmagic`.

## Hello World with lua-resty-filemagic

```lua
local fileinfo = require "resty.filemagic"
fileinfo"plain-text.txt"
```

This will return string containing `ASCII text`. But there are other information available as well.

## Installation

Just place [`filemagic.lua`](https://github.com/slzhu/lua-resty-filemagic/blob/master/lib/resty/filemagic.lua) somewhere in your `package.path`, preferably under `resty` directory. If you are using OpenResty, the default location would be `/usr/local/openresty/lualib/resty`.

### Compiling and Installing libmagic C-library

Consult your operating system or package management about installing this (usually it is already installed in most systems).

## Lua API

TBD

## License

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
