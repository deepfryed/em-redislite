require 'minitest/spec'
require_relative '../lib/em-redislite'

class MiniTest::Unit::TestCase
  def em_run &block
    EM.run do
      client = EM::Redis.connect
      r      = client.command :flushdb
      r.callback {|value| block.yield(client) }
      r.errback  {|error| $stderr.puts error.inspect; Kernel.exit(1) }
    end
  end
end

MiniTest::Unit.autorun
