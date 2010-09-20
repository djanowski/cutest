prepare do
  $foo = []
end

prepare do
  $foo << true
end

test "all the prepare blocks are called" do
  assert $foo == [true]
end

prepare do
  $foo << false
end

test "and are cumulative" do
  assert $foo == [true, false]
end

scope do
  test "and run inside scopes" do
    assert $foo = [true, false]
  end
end
