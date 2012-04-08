# Redis Lite 

Eventmachine based adapter that talks redis 2.0 protocol

## Installation

  gem install em-redislite

## Dependencies

* Ruby >= 1.9.1
* eventmachine
* em-synchrony (optional)

## Unsupported commands

* Pub/Sub
* Scripting
* Server

## Example

### Using callbacks

```ruby
  require 'em-redislite'

  EM.run do
    # defaults to { host: '127.0.0.1', port: 6379 }
    client = EM::Redis.connect
    client.errback {|error| $stderr.puts "Redis Error: #{error}"; EM.stop }

    r = client.set "mykey", "myvalue"
    r.callback {|value| p value }
    r.errback  {|error| p error }

    r = client.get "mykey"
    r.callback {|value| p value }
    r.errback  {|error| p error }
  end
```
### Using em-synchrony

```ruby
  require 'em-redislite'
  require 'em-synchrony/em-redislite'

  EM.run do
    EM.synchrony do
      client = EM::Redis.connect
      client.errback {|error| $stderr.puts "Redis Error: #{error}"; EM.stop }
      
       p client.set "mykey", "myvalue"
       p client.get "mykey"
       EM.stop
    end
  end
```

## License
[Creative Commons Attribution - CC BY](http://creativecommons.org/licenses/by/3.0)
