require_relative 'helper'

describe 'Command Expire' do
  it 'should support set with expiry' do
    @success = false
    em_run do |client|
      r = client.setex 'mykey', 1, 'foobar'
      r = client.get   'mykey'
      r.callback do |value|
        EM.stop unless value == 'foobar'
        EM.add_timer(2) do
          r = client.get 'mykey'
          r.callback {|value| @success = assert_nil value; EM.stop }
          r.errback  {|error| EM.stop }
        end
      end
      r.errback  {|error| EM.stop }
    end
    assert @success
  end
end
