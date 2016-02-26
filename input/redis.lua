require "string"
require "table"

local redis = require "redis"

local msg = {
    Type    = "redis",
    Payload = "",
}

local cfg = {
    Server  = read_config("server") or "127.0.0.1",
    Port    = read_config("port") or 6379,
    Queue   = read_config("queue") or "heka",
    Timeout = read_config("timeout") or 5,
}

local client = redis.connect(cfg.Server, cfg.Port)

function process_message()
    local connected = client:ping()

    if connected then
        while true do
            local elem = client:blpop(cfg.Queue, cfg.Timeout)

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
        end
    else
        return 1, "Redis connection failed."
    end

    client:quit()
    return 0
end
