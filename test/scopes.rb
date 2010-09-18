@bar = true

prepare { $foo = false }

scope "Foo" do
  @foo = true

  test "something" do
    assert !$foo
    assert defined?(@foo)
    assert !defined?(@bar)
  end
end

scope "Bar" do
  test "something" do
    assert !$foo
    assert !defined?(@foo)
    assert !defined?(@bar)
  end
end

scope "Outer" do
  @baz = true

  scope "Inner" do
    test "something" do
      assert !defined?(@baz)
    end
  end
end
