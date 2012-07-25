test "output of successful run" do
  expected = ".\n"

  out = %x{./bin/cutest test/fixtures/success.rb}

  assert_equal(expected, out)
end

test "output of failed run" do
  expected = "\n\nCutest::AssertionFailed: expression returned false\n\n" +
             "  line: assert false\n" +
             "  file: test/fixtures/failure.rb +2\n\n"

  out = %x{./bin/cutest test/fixtures/failure.rb}

  assert_equal(expected, out)
end

test "output of failed run" do
  expected = "\n\nRuntimeError: Oops\n\n" +
             "  line: raise \"Oops\"\n" +
             "  file: test/fixtures/exception.rb +2\n\n"

  out = %x{./bin/cutest test/fixtures/exception.rb}

  assert_equal(expected, out)
end

test "output of custom assertion" do
  expected = "\n\nCutest::AssertionFailed: not empty\n\n" +
             "  line: assert_empty \"foo\"\n" +
             "  file: test/fixtures/fail_custom_assertion.rb +7\n\n"

  out = %x{./bin/cutest test/fixtures/fail_custom_assertion.rb}

  assert_equal(expected, out)
end

test "output of failure in nested file" do
  expected = "\n\nCutest::AssertionFailed: expression returned false\n\n" +
             "  line: assert false\n" +
             "  file: test/fixtures/failure.rb +2\n\n"

  out = %x{./bin/cutest test/fixtures/failure_in_loaded_file.rb}

  assert_equal(expected, out)
end
