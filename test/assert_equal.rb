test  do
  assert_equal 1, 1
end

test "raises if the assertion fails" do
  assert_raise(Cutest::AssertionFailed) do
    assert_equal 1, 2
  end
end

test "provides a helpful error message" do
  exception = assert_raise(Cutest::AssertionFailed) do
    assert_equal 1, 2
  end

  assert_equal "1 != 2", exception.message
end
