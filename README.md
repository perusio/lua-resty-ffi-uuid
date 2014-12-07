# Lua UUID generating library relying on LuaJIT's FFI bindings to luibuuid

## Introduction

This is a [LuaJIT FFI](http://luajit.org/ext_ffi.html) binding to the
[libuuid](http://linux.die.net/man/3/libuuid) library. It generates
[type 4 UUIDs](https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_4_.28random.29).
The source of the UUID can be a time based or random.

The library is compatible with
[Distributed Computing Environment](https://en.wikipedia.org/wiki/Distributed_Computing_Environment) (DCE).

## Available functions

The module/library makes available the folllowing functions.

 + `generate()`: generate a type 4 UUID. By default the UUID is random
   number based.

 + `generate_random()`: generate a type 4 UUID based on `/dev/urandom`.
   
 + `generate_time()`: generate a type 4 UUID based on time and the
    Ethernet MAC
    address if available.

 + `generate_time_safe()`: generates a type 4 UUID making sure that
   the generated UUID is unique by checking thqt the qccess to the
   system clock is successful. 

 + `type(<str UUID>)`: Returns the type of UUID generated from a given
   UUIID in string format.

 + `variant(<str UUID>)`: Returns the variant of UUID generated from a
   given UUIID in string format.

 + `time(<str UUID>)`: Returns the time in seconds and microseconds
   in the fraction of the second from a given UUIID in string format. 
        
## Example usage

```lua
u = require 'resty.uuid'

-- Get an UUID.
local my_uuid = u()
-- Print it.
print(u)
-> 46dd2f12-06b1-4286-81ba-62050d483fcd
-- Get the type.
print(u.type(my_uuid))
-> 4
-- Get the variant.
print(u.variant(my_uuid))
-> 1
-- Get a time based UUID.
local uuid1 = u.generate_time_safe()
-- Print the time in seconds and the microseconds fraction of the second.
print(u.time(uuid1))
1417912708      745140

```

## Requirements

`libuuid` must be installed for the library to be used. In
[Debian](http://debian.org) the package is called
[`libuuid1`](https://packages.debian.org/search?keywords=libuuid1).

## License

 Permission is hereby granted, free of charge, to any person obtaining a
 copy of this software and associated documentation files (the "Software"),
 to deal in the Software without restriction, including without limitation
 the rights to use, copy, modify, merge, publish, distribute, sublicense,
 and/or sell copies of the Software, and to permit persons to whom the
 Software is furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 Except as contained in this notice, the name(s) of the above copyright
 holders shall not be used in advertising or otherwise to promote the sale,
 use or other dealings in this Software without prior written authorization.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 DEALINGS IN THE SOFTWARE.
