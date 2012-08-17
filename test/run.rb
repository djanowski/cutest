test "output of successful run" do
  expected = <<-EXP.gsub(/^[ ]{4}/, '')
    test/fixtures/success.rb: [.]
  EXP

  out = %x{./bin/cutest test/fixtures/success.rb}

  assert_equal(expected, out)
end

test "output of failed run" do
  expected = <<-EXP.gsub(/^[ ]{4}/, '')
    test/fixtures/failure.rb: [F]

    file: test/fixtures/failure.rb +2
    line: assert false
    Cutest::AssertionFailed: expression returned false
  EXP

  out = %x{./bin/cutest test/fixtures/failure.rb}

  assert_equal(expected, out)
end

test "output of non-assertion exception" do
  expected = <<-EXP.gsub(/^[ ]{4}/, '')
    test/fixtures/exception.rb: [E]

    file: test/fixtures/exception.rb +2
    line: raise "Oops"
    RuntimeError: Oops
  EXP

  out = %x{./bin/cutest test/fixtures/exception.rb}

  assert_equal(expected, out)
end

test "output of custom assertion" do
  expected = <<-EXP.gsub(/^[ ]{4}/, '')
    test/fixtures/fail_custom_assertion.rb: [F]

    file: test/fixtures/fail_custom_assertion.rb +6
    line: assert_empty "foo"
    Cutest::AssertionFailed: not empty
  EXP

  out = %x{./bin/cutest test/fixtures/fail_custom_assertion.rb}

  assert_equal(expected, out)
end

test "output of failure in nested file" do
  expected = <<-EXP.gsub(/^[ ]{4}/, '')
    test/fixtures/failure_in_loaded_file.rb: [F]

    file: test/fixtures/failure.rb +2
    line: assert false
    Cutest::AssertionFailed: expression returned false
  EXP

  out = %x{./bin/cutest test/fixtures/failure_in_loaded_file.rb}

  assert_equal(expected, out)
end
