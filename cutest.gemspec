Gem::Specification.new do |s|
  s.name              = "cutest"
  s.version           = "0.0.4"
  s.summary           = "Forking tests."
  s.description       = "Run tests in separate processes to avoid shared state."
  s.authors           = ["Damian Janowski", "Michel Martens"]
  s.email             = ["djanowski@dimaion.com", "michel@soveran.com"]
  s.homepage          = "http://github.com/djanowski/cutest"
  s.files = ["LICENSE", "README.markdown", "Rakefile", "lib/cutest.rb", "cutest.gemspec", "test/assert.rb", "test/assert_raise.rb", "test/setup.rb"]
  s.add_dependency "batch", "~> 0.0.1"
end
