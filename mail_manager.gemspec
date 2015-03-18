# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mail_manager/version'

Gem::Specification.new do |gem|
  gem.name          = "mail_manager"
  gem.version       = MailManager::VERSION
  gem.authors       = ["Lone Star Internet"]
  gem.email         = ["biz@lone-star.net"]
  gem.licenses      = ["MIT"]
  gem.description   = %q{Manages the delivery of mailable items. Handles bounces, unsubscribe, opt-in, etc.}
  gem.summary       = %q{Mailing list management tool}
  gem.homepage      = "http://ireach.com"

  gem.add_dependency "rails", "~>3.2"
  gem.add_dependency "daemons", "~>1.1"
  gem.add_dependency "with_lock", "~>0.1"
  gem.add_dependency "mini_magick", "~>4.1"
  gem.add_dependency "will_paginate", "~>3.0"
  gem.add_dependency 'unix_utils', "~>0.0"
  gem.add_dependency "delayed_job", "~>4"
  gem.add_dependency 'delayed_job_active_record', "~>4"
  gem.add_dependency "dynamic_form", "~>1.1"
  gem.add_dependency 'cancancan', "~>1.9"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
end
