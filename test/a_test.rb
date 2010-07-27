setup do
  {a: 23, b: 42}
end

test "should be 23" do
  assert 24 == 24
end

test "should return 43" do |params|
  assert params[:b] == 43
end
