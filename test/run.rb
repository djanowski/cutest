test "output of successful run" do
  expected = ".\n"

  out = %x{./bin/cutest test/fixtures/success.rb}

  assert_equal(expected, out)
end

test "exit code of successful run" do
  %x{./bin/cutest test/fixtures/success.rb}
  assert_equal 0, $?.to_i
end

test "output of failed run" do
  file = File.realpath('test/fixtures/failure.rb')
  expected = "\n" +
             "  test: failed assertion\n" +
             "  line: assert false\n" +
             "  file: #{file} +2\n\n" +
             "Cutest::AssertionFailed: expression returned false\n\n"

  out = %x{./bin/cutest #{file}}

  assert_equal(expected, out)
end

test "output of failed run" do
  file = File.realpath('test/fixtures/exception.rb')
  expected = "\n" +
             "  test: some unhandled exception\n" +
             "  line: raise \"Oops\"\n" +
             "  file: #{file} +2\n\n" +
             "RuntimeError: Oops\n\n"

  out = %x{./bin/cutest #{file}}

  assert_equal(expected, out)
end

test "exit code of failed run" do
  %x{./bin/cutest test/fixtures/failure.rb}

  assert $?.to_i != 0
end

test "output of custom assertion" do
  file = File.realpath('test/fixtures/fail_custom_assertion.rb')
  expected = "\n" +
             "  test: failed custom assertion\n" +
             "  line: assert_empty \"foo\"\n" +
             "  file: #{file} +7\n\n" +
             "Cutest::AssertionFailed: not empty\n\n"

  out = %x{./bin/cutest #{file}}

  assert_equal(expected, out)
end

test "output of failure in nested file" do
  test_file = File.realpath('test/fixtures/failure.rb')
  nested_file = File.realpath('test/fixtures/failure_in_loaded_file.rb')
  expected = "\n" +
             "  test: failed assertion\n" +
             "  line: assert false\n" +
             "  file: #{test_file} +2\n\n" +
             "Cutest::AssertionFailed: expression returned false\n\n"

  out = %x{./bin/cutest #{nested_file}}

  assert_equal(expected, out)
end

test "output of failure outside block" do
  expected = ".\n" +
  "  test: \n" +
  "  line: assert false\n" +
  "  file: test/fixtures/outside_block.rb +5\n\n" +
  "Cutest::AssertionFailed: expression returned false\n\n"

  out = %x{./bin/cutest test/fixtures/outside_block.rb}

  assert_equal(expected, out)
end
