require 'em-synchrony'
require 'em-redislite'

module EM
  module Redis
    class Client < Connection
      def command name, *args
        EM::Synchrony.sync send_command(name, *args)
      end
    end
  end
end
