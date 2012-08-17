class Cutest
  VERSION = "1.2.0.rc2"
  FILTER = %r[/(ruby|jruby|rbx)[-/]([0-9\.])+]
  CACHE = Hash.new { |h, k| h[k] = File.readlines(k) }

  def self.run(files)
    exceptions = files.flat_map { |file| run_file(file) }

    exceptions.each do |exc, file|
      display_trace(exc, file)
      display_error(exc)
    end
  end

  def self.run_file(file)
    reader, writer = IO.pipe

    fork do
      reader.close

      begin
        print "#{file}: ["
        load(file)
        print "]\n"
        Marshal.dump(cutest[:exceptions], writer)
      rescue LoadError, SyntaxError
        display_error($!)
        exit 1
      end
    end

    Process.wait
    exit unless $?.success?

    writer.close
    exceptions = Marshal.load(reader.read)
    exceptions.map { |e| [e, file] }
  end

  def self.code(fn, ln)
    begin
      CACHE[fn][ln.to_i - 1].strip
    rescue
      "(Can't display line)"
    end
  end

  def self.display_error(exception)
    print "#{exception.class}: "
    print "#{exception.message}\n"
  end

  def self.display_trace(exception, file)
    trace = exception.backtrace
    pivot = trace.index { |line| line.match(file) }

    if pivot
      other = trace[0..pivot].select { |line| line !~ FILTER }
      other.reverse.each { |trace| display_trace_location(trace) }
    else
      display_trace_location(trace.first)
    end
  end

  def self.display_trace_location(line)
    fn, ln = line.split(":")

    puts
    puts "file: #{fn} +#{ln}"
    puts "line: #{code(fn, ln)}"
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
  Thread.current[:cutest] ||= { :prepare => [], :exceptions => [] }

  # Shortcut to access Thread.current[:cutest].
  def cutest
    Thread.current[:cutest]
  end

  # Create a class where the block will be evaluated. Recommended to improve
  # isolation between tests.
  def scope(&block)
    Cutest::Scope.new(&block).call
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

    prepare.each { |blk| blk.call }
    block.call(setup && setup.call)
    success
  rescue StandardError => exception
    cutest[:exceptions] << exception
    exception.kind_of?(Cutest::AssertionFailed) ? failure : other_exception
  end

  # Assert that value is not nil or false.
  def assert(value)
    flunk("expression returned #{value.inspect}") unless value
  end

  # Assert that two values are equal.
  def assert_equal(value, other)
    flunk("#{value.inspect} != #{other.inspect}") unless value == other
  end

  # Assert that the block doesn't raise the expected exception.
  def assert_raise(expected = Exception)
    yield
  rescue => exception
    flunk("got #{exception.inspect} instead") unless exception.kind_of?(expected)
  end

  # Raise an error where the message is the last line
  # executed before flunking.
  def flunk(message = nil)
    exception = Cutest::AssertionFailed.new(message)
    exception.set_backtrace([caller[1]])

    raise exception
  end

  # Executed when an assertion succeeds.
  def success
    print "."
  end

  # Executed when a cutest assertion fails.
  def failure
    print "F"
  end

  # Executed when a non-cutest exception is raised
  def other_exception
    print "E"
  end
end
