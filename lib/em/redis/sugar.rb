class EM::Redis::Client
  COMMANDS = {
    string:  %w(get strlen getset setnx setex setbit getbit mset msetnx mget incr incrby decr decrby
                append setrange getrange),
    boolean: %w(exists del type keys randomkey rename renamenx dbsize expire persist ttl select move
                flushdb flushall),
  }.freeze

  COMMANDS[:string].each  {|c| send(:define_method, c) {|*args| command(c, *args) }}
  COMMANDS[:boolean].each {|c| send(:define_method, c) {|*args|
    defer = EM::DefaultDeferrable.new
    req   = command(c, *args)
    req.callback {|r| defer.succeed(r == '1') }
    req.errback  {|e| defer.fail(e) }
    defer
  }}

  # set here is special since it combines :set and optional :expire
  def set key, value, ttl = nil
    if ttl
      defer = EM::DefaultDeferrable.new
      req   = command(:set, key, value)
      req.callback do
        req = command(:expire, key, ttl)
        req.callback {|r| defer.succeed(r == '1') }
        req.errback  {|e| defer.fail(e) }
      end
      req.errback {|e| defer.fail(e) }
      defer
    else
      command(:set, key, value)
    end
  end
end
