@bar = true

prepare { $foo = false }

scope do
  @foo = true

  test "something" do
    assert !$foo
    assert defined?(@foo)
    assert !defined?(@bar)
  end
end

scope do
  test "something" do
    assert !$foo
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
