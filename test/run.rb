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
  expected = ".\n"

  stdout, stderr = capture do
    Cutest.run(Dir["test/fixtures/success.rb"])
  end

  assert_equal(stdout, expected)
end

test "output of failed run" do
  expected = "\n\e[01;36mException: \e[01;33massert false\e[00m # assertion failed\ntest/fixtures/failure.rb +2\n\n"

  stdout, stderr = capture do
    Cutest.run(Dir["test/fixtures/failure.rb"])
  end

  assert_equal(stdout, expected)
end

test "output of failed run" do
  expected = "\n\e[01;36mException: \e[01;33mraise \"Oops\"\e[00m # Oops\ntest/fixtures/exception.rb +2\n\n"

  stdout, stderr = capture do
    Cutest.run(Dir["test/fixtures/exception.rb"])
  end

  assert_equal(stdout, expected)
end

test "output of custom assertion" do
  expected = "\n\e[01;36mException: \e[01;33massert_empty \"foo\"\e[00m # not empty\ntest/fixtures/fail_custom_assertion.rb +7\n\n"

  stdout, stderr = capture do
    Cutest.run(Dir["test/fixtures/fail_custom_assertion.rb"])
  end

  assert_equal(stdout, expected)
end
