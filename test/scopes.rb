@bar = true

scope do
  @foo = true

  test "something" do
    assert defined?(@foo)
    assert !defined?(@bar)
  end
end

scope do
  test "something" do
    assert !defined?(@foo)
    assert !defined?(@bar)
  end
end

scope do
  @baz = true

  scope do
    test "something" do
      assert !defined?(@baz)
    end
  end
end
