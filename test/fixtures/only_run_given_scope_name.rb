scope "another scope" do
  test do
    raise "This is not raised"
  end
end

scope "scope" do
  test "test" do
    assert true
  end

  test do
    raise "This is raised"
  end
end
