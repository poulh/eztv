# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "p3-eztv"
  spec.version       = "0.0.9"
  spec.authors       = ["Damir Svrtan", "Poul Hornsleth"]
  spec.email         = ["poulh@umich.edu"]
  spec.summary       = "EZTV Search API"
  spec.description   = "Parses EZTV.ag's HTML as they do not have a clean REST API"
  spec.homepage      = "https://github.com/poulh/p3-eztv"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "nokogiri", "~> 1.6"
  spec.add_runtime_dependency "httparty", "~> 0.13"

end
