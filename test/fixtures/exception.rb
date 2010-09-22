def foo
  raise "Oops"
end

test "some unhandled exception" do
  foo
end
