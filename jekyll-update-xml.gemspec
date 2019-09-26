Gem::Specification.new do |s|
    s.name        = 'jekyll-update-xml'
    s.version     = '0.0.0'
    s.date        = '2019-09-23'
    s.summary     = "Simple XML Builder"
    s.description = "A simple XML builder for a Jekyll site RSS feed."
    s.authors     = ["David Brooke"]
    s.email       = 'dbrooke@coveo.com'
    s.files       = ["lib/jekyll-update-xml.rb"]
    s.require_paths = ["lib"]
    s.homepage = 'https://github.com/dmbrooke/jekyll-update-xml'

    s.add_runtime_dependency 'builder', '~> 3.2', '>= 3.2.3'
    s.add_runtime_dependency 'uuid', '~> 2.3', '>= 2.3.9'
    s.add_runtime_dependency "jekyll", ">= 3.7", "< 5.0"
end