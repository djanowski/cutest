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
  expected = "  0% .\n100% \n"

  stdout, stderr = capture do
    Cutest.run(Dir["test/fixtures/success.rb"])
  end

  assert stdout == expected
end

test "output of failed run" do
  stdout, stderr = capture do
    Cutest.run(Dir["test/fixtures/failure.rb"])
  end

  assert stdout == "  0% E\n100% \n"
  assert stderr["\nSome errors occured:\n\n>> failed assertion\n=> assert false\n"]
  assert stderr["test/fixtures/failure.rb +2\n\n"]
end

test "output of failed run on a custom assertion" do

  stdout, stderr = capture do
    Cutest.run(Dir["test/fixtures/fail_custom_assertion.rb"])
  end

  assert stdout == "  0% E\n100% \n"
  assert stderr["\nSome errors occured:\n\n>> failed custom assertion\n=> assert_empty \"foo\"\n"]
  assert stderr["test/fixtures/fail_custom_assertion.rb +6\n\n"]
end

test "output of failed run on an exception" do
  stdout, stderr = capture do
    Cutest.run(Dir["test/fixtures/exception.rb"])
  end

  assert stdout == "  0% E\n100% \n"
  assert stderr["\nSome errors occured:\n\nOops\n"]
  assert stderr["test/fixtures/exception.rb:2:in `foo'\n"]
  assert stderr["test/fixtures/exception.rb:6:in `block in <top (required)>'\n\n"]
end
