require 'eventmachine'
module EM
  module Redis
    class Error < StandardError; end

    DEFAULTS = { host: '127.0.0.1', port: 6379 }

    def self.connect options = {}
      options = DEFAULTS.merge(options)
      begin
        EM.connect options[:host], options[:port], Client, { host: options[:host], port: options[:port] }
      rescue ConnectionError => e
        client = Client.new ''
        client.fail(Error.new(e.message))
        client
      end
    end

    class Client < Connection
      include Deferrable

      def initialize options
        @options = options
      end

      def post_init
        @buffer     = ''
        @want_bytes = 0
        @want_lines = 0
        @pool       = []
        @lines      = []
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

      def unbind msg = 'lost connection'
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
    end # Client
  end # Redis
end # EM
