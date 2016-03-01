Running the example configuration included here produces the following output:

Plugins starting up:

```bash
[nathwill@wyrdish ~]$ hekad -config=heka.toml
2016/02/29 23:57:50 Pre-loading: [redis_input]
2016/02/29 23:57:50 Pre-loading: [RstEncoder]
2016/02/29 23:57:50 Pre-loading: [LogOutput]
2016/02/29 23:57:50 Pre-loading: [redis_output]
2016/02/29 23:57:50 Pre-loading: [TokenSplitter]
2016/02/29 23:57:50 Loading: [TokenSplitter]
2016/02/29 23:57:50 Pre-loading: [HekaFramingSplitter]
2016/02/29 23:57:50 Loading: [HekaFramingSplitter]
2016/02/29 23:57:50 Pre-loading: [NullSplitter]
2016/02/29 23:57:50 Loading: [NullSplitter]
2016/02/29 23:57:50 Pre-loading: [ProtobufDecoder]
2016/02/29 23:57:50 Loading: [ProtobufDecoder]
2016/02/29 23:57:50 Pre-loading: [ProtobufEncoder]
2016/02/29 23:57:50 Loading: [ProtobufEncoder]
2016/02/29 23:57:50 Loading: [RstEncoder]
2016/02/29 23:57:50 Loading: [redis_input]
2016/02/29 23:57:50 Loading: [LogOutput]
2016/02/29 23:57:50 Loading: [redis_output]
2016/02/29 23:57:50 Starting hekad...
2016/02/29 23:57:50 Output started: LogOutput
2016/02/29 23:57:50 Output started: redis_output
2016/02/29 23:57:50 MessageRouter started.
2016/02/29 23:57:50 Input started: redis_input
```

Example message input/output:

```bash
127.0.0.1:6379> rpush 'heka-input' 'buttz'
(integer) 1
127.0.0.1:6379> lpop heka-output
"{\"Logger\":\"redis.heka-input\",\"Type\":\"redis\",\"Payload\":\"buttz\",\"Timestamp\":1.456819097e+18,\"Uuid\":\"8!\\u0001NpHJj\xad3\xffV\xcf\\u000b\\/\xf2\"}"
```

Equivalent message rst-encoded for stdout logging:

```bash
2016/02/29 23:58:17 
:Timestamp: 2016-03-01 07:58:17 +0000 UTC
:Type: redis
:Hostname: 
:Pid: 0
:Uuid: 3821014e-7048-4a6a-ad33-ff56cf0b2ff2
:Logger: redis.heka-input
:Payload: buttz
:EnvVersion: 
:Severity: 7
```
