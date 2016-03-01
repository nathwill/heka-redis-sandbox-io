lua Sandbox{Input,Output} redis plugins for Mozilla Heka
========================================================

heka plugins using the excellent [redis-lua](https://github.com/nrk/redis-lua) plugin.

note that this plugin intentionally uses list-key paradigms instead of PUB/SUB,
as most queue workers in the ruby world tend to work this way.

Usage Instructions
------------------
Copy plugins to the appropriate directory: `inputs/redis.lua` to `${SHARE_PATH}/lua_inputs`,
`outputs/redis.lua` to `${SHARE_PATH}/lua_outputs`, and `modules/redis.lua` to 
`${SHARE_PATH}/lua_modules`. 

Read the in-plugin documentation for configuration options. In particular, note the need
to adjust the `module_path` Sandbox directive, in order for the redis module to be able to
locate the `socket` module in the load_path.
