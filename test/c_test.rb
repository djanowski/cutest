def foo
  raise ArgumentError
end

def bar
  foo
end

bar
