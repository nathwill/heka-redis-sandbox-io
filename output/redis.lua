-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

--[[
Example Redis database message loader.

Config:

- server (string)
- port (uint)
- queue (string)
- max_messages (uint)
- flush_interval (uint)

*Example Heka Configuration*

.. code-block:: ini

    [RedisOutput]
    type = "SandboxOutput"
    filename = "lua_outputs/redis.lua"
    message_matcher = "Type == 'logfile'"
    ticker_interval = 5

    [RedisOutput.config]
    server = "127.0.0.1"
    port = 6379
    queue = "my-queue"
    max_messages = 20
    flush_interval = 10
--]]

-- load modules
local os = require "os"
local string = require "string"
local table = require "table"
local cjson = require "cjson"
local redis = require "redis"

-- set up configuration
local cfg = {
    Server  = read_config("server") or "127.0.0.1",
    Port    = read_config("port") or 6379,
    Queue   = read_config("queue") or "heka",
    MaxMsgs = read_config("max_messages") or 1,
    MaxTime = read_config("flush_interval") or 5,
}

-- validate configuration
assert(cfg.MaxMsgs > 0, "max_messages must be greater than zero")
assert(cfg.MaxTime > 0, "flush_interval must be greater than zero")

-- normalize time to ns
cfg.MaxTime = cfg.MaxTime * 1e9

-- set up connection to redis
local client = redis.connect(cfg.Server, cfg.Port)

if not client:ping() then
    return 1, "Redis connection failed."
end

-- track state
local msg = {}
local count = 0
local last_flush = 0

-- persist msg buffer
msgs = {}


function bulk_load()
    if unpack(msgs) then
        local res = client:rpush(cfg.Queue, unpack(msgs))
        if res then
            msgs = {}; count = 0; last_flush = os.time() * 1e9
        else
            return 1, "Failed to push messages."
        end
    end

    return 0
end

function process_message()
    local msg = decode_message(read_message("raw"))
    table.insert(msgs, cjson.encode(msg))

    count = count + 1; msg = {}

    if count >= cfg.MaxMsgs then
        return bulk_load()
    end

    return 0
end

function timer_event(ns)
    if ns - last_flush >= cfg.MaxTime then
        bulk_load()
    end
end
