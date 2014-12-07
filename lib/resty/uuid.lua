-- uuid.lua --- uuid generator based on libuuid1. It uses the LuaJIT
-- FFI. The UUID generated is a type 4 according to RFC 4122.
-- http://www.ietf.org/rfc/rfc4122.txt

-- Copyright (C) 2014 António P. P. Almeida <appa@perusio.net>

-- Author: António P. P. Almeida <appa@perusio.net>

-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the "Software"),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.

-- Except as contained in this notice, the name(s) of the above copyright
-- holders shall not be used in advertising or otherwise to promote the sale,
-- use or other dealings in this Software without prior written authorization.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
-- THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.
local ffi = require 'ffi'
local ffi_new = ffi.new
local ffi_str = ffi.string
local ffi_load = ffi.load
local ffi_cdef = ffi.cdef
local C = ffi.C
local os = ffi.os
local tonumber = tonumber
local setmetatable = setmetatable

-- Avoid polluting the global environment.
-- If we are in Lua 5.1 this function exists.
if _G.setfenv then
   setfenv(1, {})
else -- Lua 5.2.
   _ENV = nil
end

ffi_cdef[[typedef unsigned char uuid_t[16];
          typedef long time_t;
          typedef struct timeval {
             time_t tv_sec;
             time_t tv_usec;
                                 } timeval;
          void uuid_generate(uuid_t out);
          void uuid_generate_random(uuid_t out);
          void uuid_generate_time(uuid_t out);
          int uuid_generate_time_safe(uuid_t out);
          int uuid_parse(const char *in, uuid_t uu);
          void uuid_unparse(const uuid_t uu, char *out);
          int uuid_type(const uuid_t uu);
          int uuid_variant(const uuid_t uu);
          time_t uuid_time(const uuid_t uu, struct timeval *ret_tv);
         ]]

-- The buffer length.
local buffer_length = 36
-- Load the library for debian: libuuid1.so.1.
local lib = os == 'OSX' and C or ffi_load('uuid.so.1')
-- UUID data type: unsigned char 16 length vector.
local uuid = ffi_new('uuid_t')
-- Parametrized type: buf is a 36 character long string.
local buf = ffi_new('char[?]', buffer_length)
-- timeval data type declaration.
local time_val = ffi_new('timeval')

-- The module table.
local M = {}

--- Convert the binary representation of the UUID to a string.
--
-- @param bin_uuid binary UUID.
--
-- @return string being the binary representation of the
--
local function unparse(bin_uuid)
   lib.uuid_unparse(bin_uuid, buf)
   return ffi_str(buf, buffer_length)
end

--- Converts a string representation of an UUID to binary.
--
-- @param str_uuid string representation of an UUID.
--
-- @return binary representation of an uuid.
--
local function parse(str_uuid)
   return lib.uuid_parse(str_uuid, uuid) == 0 and uuid or nil
end

--- Generate an UUID.
--
-- @return a string representation of an UUID.
--
function M.generate()
   lib.uuid_generate(uuid)
   return unparse(uuid)
end

--- Generate a random number based M. It uses /dev/urandom as an
--  entropy source.
--
-- @return string representation of the random number generator M.
--
function M.generate_random()
   -- Generate a random number based M.
   lib.uuid_generate_random(uuid)
   return unparse(uuid)
end

--- Generate a time based UUID.
--
--
-- @return string representing a time based UUID.
--
function M.generate_time()
   lib.uuid_generate_time(uuid)
   return unparse(uuid)
end

--- Generate a time based UUID in safe way.
--
-- @return string representing a time based UUID and true or false
--         depending if the UUID time base generated is safe.
--
function M.generate_time_safe()
   -- Generate a safe time based UUID.
   local safe = lib.uuid_generate_time_safe(uuid) == 0
   return unparse(uuid), safe
end

--- Get the type of UUID.
--
-- @param str_uuid string representation of UUID.
--
-- @return integer representing the type of UUID.
--
function M.type(str_uuid)
   return lib.uuid_type(parse(str_uuid))
end

--- Get the UUID variant.
--
-- @param str_uuid string representation of UUID.
--
-- @return integer representing the type of UUID.
--
function M.variant(str_uuid)
   return lib.uuid_variant(parse(str_uuid))
end

--- Get the time representation seconds, microseconds of a given UUID.
--
-- @param str_uuid string representation of an UUID.
--
-- @return the time in seconds and microseconds when the UUID was
--         created.
--
function M.time(str_uuid)
   local secs = lib.uuid_time(parse(str_uuid), time_val)
   return tonumber(secs), tonumber(time_val.tv_usec)
end

-- Return the module table.
return setmetatable(M, { __call = M.generate })
