test "catches the right exception" do
  assert_raise(RuntimeError) do
    raise RuntimeError
  end
end

test "catches exceptions lower than StandardError" do
  assert_raise(NotImplementedError) do
    raise NotImplementedError
  end
end

test "raises if the expectation is not met" do
  assert_raise(Cutest::AssertionFailed) do
    assert_raise(RuntimeError) do
      raise ArgumentError
    end
  end
end

test "returns the exception" do
  exception = assert_raise(RuntimeError) do
    raise RuntimeError, "error"
  end

  assert_equal "error", exception.message
end

test "catches a custom exception" do
  assert_raise do
    raise Class.new(Exception)
  end
end
