require 'eventmachine'

module EM
  module Redis

    VERSION  = '0.2.1'
    DEFAULTS = { host: '127.0.0.1', port: 6379 }

    class Error < StandardError; end

    def self.connect options = {}
      options = DEFAULTS.merge(options)
      begin
        EM.connect options[:host], options[:port], Client, { host: options[:host], port: options[:port] }
      rescue ConnectionError => e
        client = Client.new(nil)
        client.fail(Error.new(e.message))
        client
      end
    end

    class Client < Connection
      include Deferrable

      def initialize options = {}
        @options = options
      end

      def post_init
        @buffer     = ''
        @want_bytes = 0
        @want_lines = 0
        @pool       = []
        @lines      = []
      end

      def error?
        signature ? super : true
      end

      def command name, *args
        defer = DefaultDeferrable.new
        @pool << defer
        send_data "*#{args.length + 1}\r\n" +
                  "$#{name.length}\r\n#{name}\r\n" +
                  args.map(&:to_s).inject('') {|a,v| a + "$#{v.bytesize}\r\n#{v}\r\n"}
        defer
      end

      def on_error msg, dns_error = false
        unbind(msg)
      end

      def reset_errback &block
        @errbacks = [ block ]
      end

      def reconnect!
        EM.reconnect @options[:host], @options[:port], self
      end

      def unbind msg = 'lost db connection'
        error = Error.new(msg)
        @pool.each {|r| r.fail(error) }
        @pool = []
        fail error
      end

      def receive_data data
        @buffer << data
        while index = @buffer.index("\r\n")
          if @want_bytes > 0
            break unless @buffer.bytesize >= @want_bytes + 2
            data = @buffer.slice!(0, @want_bytes + 2)
            process_bytes(data[0..@want_bytes-1])
          else
            process_response @buffer.slice!(0, index+2).strip
          end
        end
      end

      def process_bytes data
        @want_bytes = 0
        if @want_lines > 0
          @lines.push(data)
          if @lines.length == @want_lines
            @pool.shift.succeed(@lines)
            @lines, @want_lines = [], 0
          end
        else
          @pool.shift.succeed(data)
        end
      end

      def process_response data
        case data[0]
          when '+' then @pool.shift.succeed(data[1..-1])
          when '-' then @pool.shift.fail(Error.new(data[1..-1]))
          when ':' then @pool.shift.succeed(data[1..-1])
          when '$' then @want_bytes = data[1..-1].to_i
          when '*' then @want_lines = data[1..-1].to_i
          else     fail Error.new("Unknown data format: #{data}")
        end

        process_bytes(nil) if @want_bytes < 0
      end

      COMMANDS = %w(
        APPEND AUTH BLPOP BRPOP BRPOPLPUSH DECR DECRBY DEL DISCARD DUMP ECHO EXEC EXISTS EXPIRE EXPIREAT
        GET GETBIT GETRANGE GETSET HDEL HEXISTS HGET HGETALL HINCRBY HINCRBYFLOAT HKEYS HLEN HMGET HMSET
        HSET HSETNX HVALS INCR INCRBY INCRBYFLOAT KEYS LINDEX LINSERT LLEN LPOP LPUSH LPUSHX LRANGE LREM
        LSET LTRIM MGET MIGRATE MOVE MSET MSETNX MULTI OBJECT PERSIST PEXPIRE PEXPIREAT PING PSETEX PTTL
        QUIT RANDOMKEY RENAME RENAMENX RESTORE RPOP RPOPLPUSH RPUSH RPUSHX SADD SCARD SDIFF SDIFFSTORE
        SELECT SET SETBIT SETEX SETNX SETRANGE SINTER SINTERSTORE SISMEMBER SMEMBERS SMOVE SORT SPOP
        SRANDMEMBER SREM STRLEN SUNION SUNIONSTORE TTL TYPE UNWATCH WATCH ZADD ZCARD ZCOUNT ZINCRBY
        ZINTERSTORE ZRANGE ZRANGEBYSCORE ZRANK ZREM ZREMRANGEBYRANK ZREMRANGEBYSCORE ZREVRANGE
        ZREVRANGEBYSCORE ZREVRANK ZSCORE ZUNIONSTORE
      ).freeze

      COMMANDS.each {|name| send(:define_method, name.downcase) {|*args| command(name, *args) }}
    end # Client
  end # Redis
end # EM
