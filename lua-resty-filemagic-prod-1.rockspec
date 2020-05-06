package = "lua-resty-filemagic"
version = "prod-1"
source = {
    url = "git@github.com:slzhu/lua-resty-filemagic.git"
}
description = {
    summary = "LuaJIT FFI bindings to libmagic, magic number recognition library - tries to determine file types.",
    detailed = "lua-resty-filemagic is a file information library implementing LuaJIT bindings to libmagic.",
    homepage = "https://github.com/slzhu/lua-resty-filemagic",
    maintainer = "Joney Zhu <joney.zhu12@gmail.com>",
    license = "BSD"
}
dependencies = {
    "luajit" >= "2.1.0"
}
build = {
    type = "builtin",
    modules = {
        ["resty.filemagic"] = "lib/resty/filemagic.lua"
    }
}
