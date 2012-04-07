require_relative 'helper'

describe 'Connection' do
  it 'should connect and return a client' do
    EM.run {
      client = EM::Redis.connect
      assert_kind_of EM::Redis::Client, client
      EM.stop
    }
  end

  it 'should defer fail on failed connection' do
    EM.run {
      failed = false
      client = EM::Redis.connect host: 'tardis', port: 0
      assert_kind_of EM::Redis::Client, client
      client.errback { failed = true }
      assert failed
      EM.stop
    }
  end
end
