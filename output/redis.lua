require "os"
require "string"
require "table"
require "cjson"

local redis = require "redis"

local cfg = {
    Server  = read_config("server") or "127.0.0.1",
    Port    = read_config("port") or 6379,
    Queue   = read_config("queue") or "heka",
    Timeout = read_config("timeout") or 5,
    MaxMsgs = read_config("max_messages") or 0,
    MaxTime = read_config("flush_interval") or 5,
}

local client = redis.connect(cfg.Server, cfg.Port)

local msg = {}
local count = 0
local last_flush = 0

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

    count = count + 1
    msg = {}

    if cfg.MaxMsgs > 0 then
        if count >= cfg.MaxMsgs then return bulk_load() end
    else
        bulk_load()
    end

    return 0
end

function timer_event(ns)
    if ns - last_flush >= cfg.MaxTime then
        bulk_load()
    end
end
