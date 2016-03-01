Mozilla Heka Sandbox{Input,Output} Redis plugins
================================================

heka plugins using the excellent [redis-lua](https://github.com/nrk/redis-lua) module.

note that this plugin intentionally uses list-key paradigms instead of PUB/SUB,
as most queue workers in the ruby world tend to work this way.

Usage Instructions
------------------
Copy plugins to the appropriate directory: `input/redis.lua` to `${SHARE_PATH}/lua_inputs`,
`output/redis.lua` to `${SHARE_PATH}/lua_outputs`, and `modules/redis.lua` to 
`${SHARE_PATH}/lua_modules`. 

Read the in-plugin documentation for configuration options. In particular, note the need
to adjust the `module_path` Sandbox directive, which is needed for the redis module to be
able to locate the `socket` module in the lua load_path.
