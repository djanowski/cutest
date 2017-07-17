test "catches default exception" do
  assert_raise do
    raise
  end
end

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

test "raises if nothing raised" do
  assert_raise(Cutest::AssertionFailed) do
    assert_raise {}
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

test "provides a helpful error message" do
  exception = assert_raise(Cutest::AssertionFailed) do
    assert_raise(RuntimeError) do
      raise ArgumentError
    end
  end

  assert_equal "got #<ArgumentError: ArgumentError> instead", exception.message

  exception = assert_raise(Cutest::AssertionFailed) do
    assert_raise { "foo" }
  end

  assert_equal "got \"foo\" instead", exception.message
end

test "considers an exception as return value a failure" do
  assert_raise(Cutest::AssertionFailed) do
    assert_raise(RuntimeError) do
      RuntimeError.new
    end
  end
end

test "catches a custom exception" do
  assert_raise do
    raise Class.new(Exception)
  end
end
