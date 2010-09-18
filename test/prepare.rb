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

module Foo
  test "and run inside modules" do
    assert $foo = [true, false]
  end
end
