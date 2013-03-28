# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mail_manager/version'

Gem::Specification.new do |gem|
  gem.name          = "mail_manager"
  gem.version       = MailManager::VERSION
  gem.authors       = ["Lone Star Internet"]
  gem.email         = ["biz@lone-star.net"]
  gem.description   = %q{Manages the delivery of mailable items. Handles bounces, unsubscribe, opt-in, etc.}
  gem.summary       = %q{Mailing list management tool}
  gem.homepage      = "http://lone-star.net"

  gem.add_development_dependency "rspec"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
