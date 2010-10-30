setup do
  {:a => 23, :b => 43}
end

test "should receive the result of the setup block as a parameter" do |params|
  assert params == {:a => 23, :b => 43}
end

test "if the params are modified..." do |params|
  params[:a] = nil
end

test "...it should preserve the original values from the setup" do |params|
  assert_equal 23, params[:a]
end

setup do
  "Hello world!"
end

test "only the most recently defined setup block is executed" do |value|
  assert "Hello world!" == value
end

scope do
  test "works inside scopes too" do |value|
    assert "Hello world!" == value
  end
end
