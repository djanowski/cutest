__END__
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
  expected = "\e[01;36m\n\nCutest::AssertionFailed: \e[1;33mexpression retur" +
             "ned false\n\n\e[00m- assert false\e[01;30m test/fixtures/failu" +
             "re.rb +2\n\e[00m\n"

  stdout, stderr = capture do
    Cutest.run(Dir["test/fixtures/failure.rb"])
  end

  assert_equal(stdout, expected)
end

test "output of failed run" do
  expected = "\e[01;36m\n\nRuntimeError: \e[1;33mOops\n\n\e[00m- raise \"Oop" +
             "s\"\e[01;30m test/fixtures/exception.rb +2\n\e[00m\n"

  stdout, stderr = capture do
    Cutest.run(Dir["test/fixtures/exception.rb"])
  end

  assert_equal(stdout, expected)
end

test "output of custom assertion" do
  expected = "\e[01;36m\n\nCutest::AssertionFailed: \e[1;33mnot empty\n\n\e[" +
             "00m- assert_empty \"foo\"\e[01;30m test/fixtures/fail_custom_a" +
             "ssertion.rb +7\n\e[00m\n"

  stdout, stderr = capture do
    Cutest.run(Dir["test/fixtures/fail_custom_assertion.rb"])
  end

  assert_equal(stdout, expected)
end
