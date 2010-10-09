require "stringio"

def capture
  stdout, $stdout = $stdout, StringIO.new
  stderr, $stderr = $stderr, StringIO.new
  yield
  [$stdout.string, $stderr.string]
ensure
  $stdout = stdout
  $stderr = stderr
end

test "output of successful run" do
  expected = "\n"

  stdout, stderr = capture do
    Cutest.run(Dir["test/fixtures/success.rb"])
  end

  assert stdout == expected
end
