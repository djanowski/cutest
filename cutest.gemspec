Gem::Specification.new do |s|
  s.name              = "cutest"
  s.version           = "1.1.0"
  s.summary           = "Forking tests."
  s.description       = "Run tests in separate processes to avoid shared state."
  s.authors           = ["Damian Janowski", "Michel Martens"]
  s.email             = ["djanowski@dimaion.com", "michel@soveran.com"]
  s.homepage          = "http://github.com/djanowski/cutest"
  s.files = ["LICENSE", "README.markdown", "Rakefile", "lib/cutest.rb", "cutest.gemspec", "test/assert.rb", "test/assert_equal.rb", "test/assert_raise.rb", "test/prepare.rb", "test/run.rb", "test/scopes.rb", "test/setup.rb"]
  s.executables.push "cutest"
end
