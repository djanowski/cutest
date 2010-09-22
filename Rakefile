require File.expand_path("../lib/cutest", __FILE__)

$VERBOSE = true

task :test do
  Cutest.run(Dir["test/*.rb"])
end

task :default => :test
