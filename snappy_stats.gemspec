# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'snappy_stats/version'

Gem::Specification.new do |spec|
  spec.name          = "snappy_stats"
  spec.version       = SnappyStats::VERSION
  spec.authors       = ["Tim Williams"]
  spec.email         = ["tim@teachmatic.com"]
  spec.description   = %q{Metrics storage and retrieval library for time series data.}  
  spec.summary       = %q{Redis backed simple time series statistics gem}
  spec.homepage      = "https://github.com/timrwilliams/snappy_stats"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "active_support"
  spec.add_dependency "redis"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "fakeredis"
  spec.add_development_dependency "timecop"
end
