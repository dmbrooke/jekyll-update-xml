lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jekyll/update/xml/version"

Gem::Specification.new do |spec|
  spec.name          = "jekyll-update-xml"
  spec.version       = "0.2.0"
  spec.authors       = ["dbrooke"]
  spec.email         = ["dbrooke@coveo.com"]

  spec.summary       = "Generate RSS feed"
  spec.description   = "A simple XML builder for a Jekyll site RSS feed."
  spec.homepage      = "https://github.com/dmbrooke/jekyll-update-xml"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/dmbrooke/jekyll-update-xml"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_runtime_dependency 'builder', '~> 3.2', '>= 3.2.3'
  spec.add_runtime_dependency 'commonmarker', '~> 0.20.1'
  spec.add_runtime_dependency 'jekyll', '>= 3.7', '< 5.0'
end
