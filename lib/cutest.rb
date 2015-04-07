class Cutest
  unless defined?(VERSION)
    VERSION = "1.2.2"
    FILTER = %r[/(ruby|jruby|rbx)[-/]([0-9\.])+]
    CACHE = Hash.new { |h, k| h[k] = File.readlines(k) }
  end

  def self.run(files)
    status = files.all? do |file|
      run_file(file)

      Process.wait2.last.success?
    end

    puts

    status
  end

  def self.run_file(file)
    fork do
      begin
        load(file)

      rescue LoadError, SyntaxError
        display_error
        exit 1

      rescue StandardError
        trace = $!.backtrace
        pivot = trace.index { |line| line.match(file) }

        puts "\n  test: %s" % cutest[:test]

        if pivot
          other = trace[0..pivot].select { |line| line !~ FILTER }
          other.reverse.each { |line| display_trace(line) }
        else
          display_trace(trace.first)
        end

        display_error

        exit 1
      end
    end
  end

  def self.code(fn, ln)
    begin
      CACHE[fn][ln.to_i - 1].strip
    rescue
      "(Can't display line)"
    end
  end

  def self.display_error
    print "\n#{$!.class}: "
    print "#{$!.message}\n"
  end

  def self.display_trace(line)
    fn, ln = line.split(":")

    puts "  line: #{code(fn, ln)}"
    puts "  file: #{fn} +#{ln}"
  end

  class AssertionFailed < StandardError
  end

  class Scope
    def initialize(&scope)
      @scope = scope
    end

    def call
      instance_eval(&@scope)
    end
  end
end

module Kernel
private

  # Use Thread.current[:cutest] to store information about test preparation
  # and setup.
  Thread.current[:cutest] ||= { :prepare => [] }

  # Shortcut to access Thread.current[:cutest].
  def cutest
    Thread.current[:cutest]
  end

  # Create an instance where the block will be evaluated. Recommended to improve
  # isolation between tests.
  def scope(name = nil, &block)
    if !cutest[:scope] || cutest[:scope] == name
      Cutest::Scope.new(&block).call
    end
  end

  # Prepare the environment in order to run the tests. This method can be
  # called many times, and each new block is appended to a list of
  # preparation blocks. When a test is executed, all the preparation blocks
  # are ran in the order they were declared. If called without a block, it
  # returns the array of preparation blocks.
  def prepare(&block)
    cutest[:prepare] << block if block_given?
    cutest[:prepare]
  end

  # Setup parameters for the tests. The block passed to setup is evaluated
  # before running each test, and the result of the setup block is passed to
  # the test as a parameter. If the setup and the tests are declared at the
  # same level (in the global scope or in a sub scope), it is possible to use
  # instance variables, but the parameter passing pattern is recommended to
  # ensure there are no side effects.
  #
  # If the setup blocks are declared in the global scope and the tests are
  # declared in sub scopes, the parameter passing usage is required.
  #
  # Setup blocks can be defined many times, but each new definition overrides
  # the previous one. It is recommended to split the tests in many different
  # files (the report is per file, not per assertion). Usually one setup
  # block per file is enough, but nothing forbids having different scopes
  # with different setup blocks.
  def setup(&block)
    cutest[:setup] = block if block_given?
    cutest[:setup]
  end

  # Kernel includes a test method for performing tests on files.
  undef test if defined? test

  # Call the prepare and setup blocks before executing the test. Even
  # though the assertions can live anywhere (it's not mandatory to put them
  # inside test blocks), it is necessary to wrap them in test blocks in order
  # to execute preparation and setup blocks.
  def test(name = nil, &block)
    cutest[:test] = name

    if !cutest[:only] || cutest[:only] == name
      prepare.each { |blk| blk.call }
      block.call(setup && setup.call)
    end

    cutest[:test] = nil
  end

  # Assert that value is not nil or false.
  def assert(value, msg = "expression returned #{value.inspect}")
    flunk(msg) unless value
    success
  end

  # Assert that actual and expected values are equal.
  def assert_equal(actual, expected)
    assert(actual == expected, "#{actual.inspect} != #{expected.inspect}")
  end

  # Assert that the block doesn't raise the expected exception.
  def assert_raise(expected = Exception)
    begin
      yield
    rescue expected => exception
      exception
    ensure
      assert(exception.kind_of?(expected), "got #{exception.inspect} instead")
    end
  end

  # Stop the tests and raise an error where the message is the last line
  # executed before flunking.
  def flunk(message = nil)
    backtrace = caller.find { |line| line.include? 'top (required)' }
    exception = Cutest::AssertionFailed.new(message)
    exception.set_backtrace(backtrace)

    raise exception
  end

  # Executed when an assertion succeeds.
  def success
    print "."
  end
end
