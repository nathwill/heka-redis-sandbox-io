-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

--[[
Example Redis database input.

Config:

- server (string)
- port (uint)
- channel (string)
- timeout (uint)

*Example Heka Configuration*

.. code-block:: ini

    [RedisInput]
    type = "SandboxInput"
    filename = "lua_inputs/redis.lua"

    [RedisInput.config]
    server = "127.0.0.1"
    port = 6379
    channel = "heka-input"
--]]

local string = require "string"
local table = require "table"
local redis = require "redis"

local msg = {
    Type    = "redis",
    Payload = "",
}

local cfg = {
    Server    = read_config("server") or "127.0.0.1",
    Port      = read_config("port") or 6379,
    Channel   = read_config("channel") or "heka",
    Timeout   = read_config("timeout") or 5,
}

assert(cfg.Port > 0, "port must be greater than zero")
assert(cfg.Timeout >= 0, "port must be >= zero")

local client = redis.connect(cfg.Server, cfg.Port)
if not client:ping() then
    return 1, "Redis connection failed."
end

function process_message()
    repeat
        local elem = client:blpop(cfg.Channel, cfg.Timeout)

        if elem then
            msg.Payload = elem[2]
            if not pcall(inject_message, msg) then
                return -1, "Failed to inject message."
            end
        else
            if not client:ping() then
                return 1, "Redis connection failed."
            end
        end
    until false

    return 0
end
