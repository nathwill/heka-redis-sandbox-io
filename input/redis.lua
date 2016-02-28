-- This Source Code Form is subject to the terms of the Mozilla Public
-- License, v. 2.0. If a copy of the MPL was not distributed with this
-- file, You can obtain one at http://mozilla.org/MPL/2.0/.

--[[
Plugin for consuming messages from a Redis list.

Config:

- server (string, optional, default "127.0.0.1")
  Specify Redis host to connect to.

- port (uint, optional, default 6379)
  Specify port Redis is listening on.

- channel (string, optional, default "heka")
  Specify the list key to BLPOP messages from.

- timeout (uint, optional, default 5)
  Specify the BLPOP timeout.

- encoding (string, optional, default "raw")
  Specify either "json" or "raw" message encoding.
  If "json", plugin will json decode the message
  and assign the resulting table to the Fields
  variable of the heka message.

- payload_keep(bool, optional, default true)
  Whether to preserve the original message payload.

*Example Heka Configuration*

.. code-block:: ini

    [RedisInput]
    type = "SandboxInput"
    filename = "lua_inputs/redis.lua"
    module_directory = "/usr/share/heka/lua_modules;/usr/share/heka/lua_io_modules"

    [RedisInput.config]
    server = "10.0.0.29"
    channel = "my-channel"
--]]

_PRESERVATION_VERSION = read_config("preservation_version") or 0

local string = require "string"
local table = require "table"
local cjson = require "cjson"
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
    Encoding  = read_config("encoding") or "raw",
    Keep      = read_config("payload_keep") or true,
}

assert(cfg.Port > 0, "port must be greater than zero")
assert(cfg.Timeout >= 0, "timeout must be >= zero")

function process_message()
    -- establish redis connection
    local ok, client = pcall(function()
      return redis.connect(cfg.Server, cfg.Port)
    end)

    if not ok then
        return -1, "Redis connection failed."
    end

    if not client:ping() then
        return -1, "Redis not responding."
    end

    -- begin processing
    while true do
        local ok, retval = pcall(function()
            return client:blpop(cfg.Channel, cfg.Timeout)
        end)

        if not ok then return -1, "BLPOP returned error." end

        if type(retval) == 'table' then
            msg.Logger = "redis."..retval[1]

            if cfg.Encoding == "json" then
                local ok, json = pcall(cjson.decode, retval[2])
                if not ok then
                    return -1, "Failed to decode message."
                end

                msg.Fields = json
            end

            if cfg.Keep then msg.Payload = retval[2] end

            if not pcall(inject_message, msg) then
                return -1, "Failed to inject message."
            end

            msg.Payload = ""; msg.Fields = nil
        else
            if not client:ping() then
                return -1, "Redis not responding."
            end
        end
    end

    return 0
end
