class Cutest
  VERSION = "1.1.1"
  REQUIREMENTS = []
  FILTER = %r[/(ruby|jruby|rbx)[-/]([0-9\.])+]
  CACHE = Hash.new { |h, k| h[k] = File.readlines(k) }

  module Color
    def self.title(str)
      "\033[01;36m#{str}"
    end

    def self.exception(str)
      "\033[1;33m#{str}"
    end

    def self.code(str)
      "\033[00m#{str}"
    end

    def self.location(str)
      "\033[01;30m#{str}"
    end

    def self.reset
      "\033[00m"
    end
  end

  def self.flags
    "-r #{REQUIREMENTS.join(" ")}" if REQUIREMENTS.any?
  end

  def self.run(files)
    files.each do |file|
      %x{cutest #{flags} #{file}}.chomp.display

      break unless $?.success?
    end

    puts
  end

  def self.run_file(file)
    begin
      REQUIREMENTS.each { |r| require r }

      load(file)

    rescue LoadError, SyntaxError
      display_error
      exit 1

    rescue Exception
      display_error

      trace = $!.backtrace
      pivot = trace.index { |line| line.match(file) }
      other = trace[0..pivot].select { |line| line !~ FILTER }
      other.reverse.each { |trace| display_trace(trace) }
      exit 1
    end
  end

  def self.code(fn, ln)
    CACHE[fn][ln.to_i - 1].strip
  end

  def self.display_error
    print Color.title("\n\n#{$!.class}: ")
    print Color.exception("#{$!.message}\n\n")
  end

  def self.display_trace(line)
    fn, ln = line.split(":")

    print Color.code("- #{code(fn, ln)}")
    print Color.location(" #{fn} +#{ln}\n")
    print Color.reset
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
  end

  # Assert that value is not nil or false.
  def assert(value)
    flunk("expression returned #{value.inspect}") unless value
    success
  end

  # Assert that two values are equal.
  def assert_equal(value, other)
    flunk("#{value.inspect} != #{other.inspect}") unless value == other
    success
  end

  # Assert that the block doesn't raise the expected exception.
  def assert_raise(expected = Exception)
    begin
      yield
    rescue => exception
    ensure
      flunk("got #{exception.inspect} instead") unless exception.kind_of?(expected)
      success
    end
  end

  # Stop the tests and raise an error where the message is the last line
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
end
