# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "em-redislite"
  s.version = "0.2.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Bharanee Rathna"]
  s.date = "2012-04-08"
  s.description = "EventMachine based Redis client"
  s.email = ["deepfryed@gmail.com"]
  s.files = ["test/test_connection.rb", "test/test_commands.rb", "test/helper.rb", "test/test_command_expire.rb", "lib/em/redis.rb", "lib/em-redislite.rb", "lib/em-synchrony/em-redislite.rb", "README.md", "CHANGELOG"]
  s.homepage = "http://github.com/deepfryed/em-redislite"
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.21"
  s.summary = "A lite version of EM::Redis"

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<eventmachine>, [">= 0"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<eventmachine>, [">= 0"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<eventmachine>, [">= 0"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
