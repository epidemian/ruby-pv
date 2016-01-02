$LOAD_PATH << File.join(__dir__, 'lib')

Gem::Specification.new do |spec|
  spec.name          = 'ruby-pv'
  spec.version       = '0.0.1'
  spec.license       = 'Public Domain'
  spec.authors       = ['Demian Ferreiro']
  spec.email         = 'epidemian@gmail.com'

  spec.summary       = 'A handy progress monitor for long-running tasks'
  spec.homepage      = 'https://github.com/epidemian/ruby-pv'

  spec.files         = `git ls-files`.split("\n").reject { |f| f =~ %r{^spec/} }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
end
