def assert_empty(string)
  assert(string.empty?, "not empty")
end

test "failed custom assertion" do
  assert_empty "foo"
end
