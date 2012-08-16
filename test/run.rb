test "output of successful run" do
  expected = ".\n"

  out = %x{./bin/cutest test/fixtures/success.rb}

  assert_equal(expected, out)
end

test "output of failed run" do
  expected = "  line: assert false\n" +
             "  file: test/fixtures/failure.rb +2\n\n" +
             "Cutest::AssertionFailed: expression returned false\n\n"

  out = %x{./bin/cutest test/fixtures/failure.rb}

  assert_equal(expected, out)
end

test "output of failed run" do
  expected = "  line: raise \"Oops\"\n" +
             "  file: test/fixtures/exception.rb +2\n\n" +
             "RuntimeError: Oops\n\n"

  out = %x{./bin/cutest test/fixtures/exception.rb}

  assert_equal(expected, out)
end

test "output of custom assertion" do
  expected = "  line: assert_empty \"foo\"\n" +
             "  file: test/fixtures/fail_custom_assertion.rb +7\n\n" +
             "Cutest::AssertionFailed: not empty\n\n"

  out = %x{./bin/cutest test/fixtures/fail_custom_assertion.rb}

  assert_equal(expected, out)
end

test "output of failure in nested file" do
  expected = "  line: assert false\n" +
             "  file: test/fixtures/failure.rb +2\n\n" +
             "Cutest::AssertionFailed: expression returned false\n\n"

  out = %x{./bin/cutest test/fixtures/failure_in_loaded_file.rb}

  assert_equal(expected, out)
end
