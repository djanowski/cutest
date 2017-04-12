test "test can be run without fork" do
  expected = ".\n"

  out = %x{NO_FORK=true ./bin/cutest -r ./test/keep_pid.rb test/fixtures/check_pid.rb}

  assert_equal(expected, out)
end

test "running tests works the same" do

  %x{NO_FORK=true ./bin/cutest test/run.rb}

  assert_equal 0, $?.to_i

end
