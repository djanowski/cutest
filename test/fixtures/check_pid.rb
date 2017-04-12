test 'this process is the same as the parent' do
  assert_equal Process.pid, PID
end
