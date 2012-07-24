test "output of successful run" do
  expected = ".\n"

  out = %x{./bin/cutest test/fixtures/success.rb}

  assert_equal(expected, out)
end

test "output of failed run" do
  expected = "\n\nCutest::AssertionFailed: expression returned false" +
             "\n\n- assert false test/fixtures/failure.rb +2\n\n"

  out = %x{./bin/cutest test/fixtures/failure.rb}

  assert_equal(expected, out)
end

test "output of failed run" do
  expected = "\n\nRuntimeError: Oops\n\n- raise \"Oop" +
             "s\" test/fixtures/exception.rb +2\n\n"

  out = %x{./bin/cutest test/fixtures/exception.rb}

  assert_equal(expected, out)
end

test "output of custom assertion" do
  expected = "\n\nCutest::AssertionFailed: not empty\n\n" +
             "- assert_empty \"foo\" test/fixtures/fail_custom_a" +
             "ssertion.rb +7\n\n"

  out = %x{./bin/cutest test/fixtures/fail_custom_assertion.rb}

  assert_equal(expected, out)
end
