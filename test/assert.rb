test "succeeds if the value is true" do
  assert true
end

test "raises if the assertion fails" do
  assert_raise(Cutest::AssertionFailed) do
    assert false
  end
end

test "provides a helpful message" do
  exception = assert_raise(Cutest::AssertionFailed) do
    assert false
  end

  assert_equal "expression returned false", exception.message
end
