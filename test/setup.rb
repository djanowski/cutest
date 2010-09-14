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
  assert 23 == params[:a]
end
