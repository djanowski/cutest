test  do
  assert_equal 1, 1
end

test "returns true" do
  assert_equal assert_equal(1, 1), true
end

test "raises if the assertion fails" do
  assert_raise(Cutest::AssertionFailed) do
    assert_equal 1, 2
  end
end
