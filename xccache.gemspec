lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "xccache"
  spec.version       = File.read("VERSION").strip
  spec.authors       = ["Thuyen Trinh"]
  spec.email         = ["trinhngocthuyen@gmail.com"]
  spec.description   = "A Ruby gem"
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/trinhngocthuyen/xccache"
  spec.license       = "MIT"

  spec.files         = Dir["{lib,bin}/**/*"]
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "claide"
  spec.add_dependency "parallel"
  spec.add_dependency "tty-cursor"
  spec.add_dependency "tty-screen"
  spec.add_dependency "xcodeproj", ">= 1.26.0"
end
