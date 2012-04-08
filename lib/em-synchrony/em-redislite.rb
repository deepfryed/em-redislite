require 'em-synchrony'
require 'em-redislite'

module EM
  module Redis
    class Client < Connection
      def command name, *args
        EM::Synchrony.sync send_command(name, *args)
      end

      def send_command name, *args
        defer = DefaultDeferrable.new
        @pool << defer
        send_data "*#{args.length + 1}\r\n" +
                  "$#{name.length}\r\n#{name}\r\n" +
                  args.map(&:to_s).inject('') {|a,v| a + "$#{v.bytesize}\r\n#{v}\r\n"}
        defer
      end
    end
  end
end
