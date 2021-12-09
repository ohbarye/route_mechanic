require_relative 'lib/route_mechanic/version'

Gem::Specification.new do |spec|
  spec.name          = "route_mechanic"
  spec.version       = RouteMechanic::VERSION
  spec.authors       = ["ohbarye"]
  spec.email         = ["over.rye@gmail.com"]

  spec.summary       = %q{RouteMechanic detects broken routes with ease}
  spec.description   = %q{No need to maintain Rails' routing tests manually. RouteMechanic automatically detects broken routes and missing action methods in controller once you've finished installation.}
  spec.homepage      = "https://github.com/ohbarye/route_mechanic"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.6.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/ohbarye/route_mechanic"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "actionpack", ">= 4.2", "< 6.2"
  spec.add_runtime_dependency "regexp-examples", ">= 1.5", "< 2"
end
