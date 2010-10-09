test "catches the right exception" do
  assert_raise(RuntimeError) do
    raise RuntimeError
  end
end

test "raises if the expectation is not met" do
  assert_raise(Cutest::AssertionFailed) do
    assert_raise(RuntimeError) do
      raise ArgumentError
    end
  end
end
