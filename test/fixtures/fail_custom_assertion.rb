def assert_empty(string)
  flunk("not empty") unless string.empty?
  success
end

test "failed custom assertion" do
  assert_empty "foo"
end
