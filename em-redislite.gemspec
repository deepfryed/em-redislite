# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
	s.name          = %q{em-redislite}
	s.version       = '0.1'
	s.summary       = 'A lightweight EM based Redis adapter'
	s.description   = 'A very simple EventMachine based adapter that talks Redis protocol'
	s.authors       = [ 'Bharanee Rathna' ]
	s.email         = %q{deepfryed@gmail.com}
	s.homepage      = %q{http://github.com/deepfryed/em-redislite}
	s.files         = %w(README.rdoc em-redislite.gemspec) + Dir.glob("{lib}/**/*")
	s.require_paths = %w(lib)
	s.platform      = Gem::Platform::RUBY

	s.add_dependency('eventmachine')
end
