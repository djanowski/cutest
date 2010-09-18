test "succeeds if the value is true" do
  assert true
end

test "raises if the assertion fails" do
  assert_raise(Cutest::AssertionFailed) do
    assert false
  end
end
