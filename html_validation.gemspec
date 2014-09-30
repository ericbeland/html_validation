# -*- encoding: utf-8 -*-
require File.expand_path('../lib/html_validation/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Eric Beland"]
  gem.email         = ["ebeland@gmail.com"]
  gem.description   = %q{HTML Validation lets you validate html locally. Lets you build html validation into your test suite, but break the rules if you must.}
  gem.summary       = %q{Local HTML validation for tests and RSpec. }
  gem.homepage      = "https://github.com/ericbeland/html_validation"

  gem.files         = `git ls-files lib`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "html_validation"
  gem.require_paths = ["lib"]
  gem.executables   = ['html_validation']
  gem.version       = PageValidations::HTML_VALIDATOR_VERSION
  gem.license = 'MIT'
end
