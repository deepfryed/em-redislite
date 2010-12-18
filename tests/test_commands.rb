require_relative 'helper'

describe 'Commands' do
  it 'should support set' do
    @success = false
    em_run do |client|
      r = client.set 'mykey', 'foobar'
      r.callback {|value| @success = assert_equal 'OK', value;  EM.stop }
      r.errback  {|error| EM.stop }
    end
    assert @success
  end

  it 'should support get' do
    @success = false
    em_run do |client|
      r = client.set 'mykey', 'foo1234'
      r = client.get 'mykey'
      r.callback {|value| @success = assert_equal 'foo1234', value; EM.stop }
      r.errback  {|error| EM.stop }
    end
    assert @success
  end

  it 'should support get with nil' do
    @success = false
    em_run do |client|
      r = client.get 'mykey1234'
      r.callback {|value| @success = assert_nil value; EM.stop }
      r.errback  {|error| EM.stop }
    end
    assert @success
  end

  it 'should support mget' do
    @success = false
    em_run do |client|
      r = client.set  'mykey1', 'foo1234'
      r = client.set  'mykey2', 'bar1234'
      r = client.mget 'mykey1', 'mykey2'

      r.callback {|value| @success = assert_equal %w(foo1234 bar1234), value; EM.stop }
      r.errback  {|error| EM.stop }
    end
    assert @success
  end

  it 'should support incr and incrby' do
    @success = false
    em_run do |client|
      client.incr   'mykey'
      client.incrby 'mykey', 2

      r = client.get  'mykey'
      r.callback {|value| @success = assert_equal '3', value; EM.stop }
      r.errback  {|error| EM.stop }
    end
    assert @success
  end

  it 'should support decr and decrby' do
    @success = false
    em_run do |client|
      client.set    'mykey', 5
      client.decr   'mykey'
      client.decrby 'mykey', 2

      r = client.get  'mykey'
      r.callback {|value| @success = assert_equal '2', value; EM.stop }
      r.errback  {|error| EM.stop }
    end
    assert @success
  end
end
