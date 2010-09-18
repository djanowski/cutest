require "batch"

class Cutest < Batch
  VERSION = "0.0.5"

  def report_errors
    return if @errors.empty?

    $stderr.puts "\nSome errors occured:\n\n"

    @errors.each do |item, error|
      $stderr.puts error, "\n"
    end
  end

  def self.run(files, anonymous = false)
    each(files) do |file|
      read, write = IO.pipe

      fork do
        read.close

        begin
          load(file, anonymous)
        rescue => e
          error = [e.message] + e.backtrace.take_while { |line| !line.start_with?(__FILE__) }
          write.write error.join("\n")
          write.write "\n"
          write.close
        end
      end

      write.close

      Process.wait

      output = read.read
      raise Cutest::AssertionFailed.new(output) unless output.empty?
      read.close
    end
  end

  class AssertionFailed < StandardError; end

  class Scope
    def initialize(&scope)
      @scope = scope
    end

    def call
      instance_eval(&@scope)
    end
  end
end

# Use Thread.current[:cutest] to store information about test preparation and
# setup.
Thread.current[:cutest] ||= { :prepare => [] }

# Shortcut to access Thread.current[:cutest].
def cutest
  Thread.current[:cutest]
end

# Create a class where the block will be evaluated. Recomended to improve
# isolation between tests.
def scope(name = nil, &blk)
  Cutest::Scope.new(&blk).call
end

# Prepare the environment in order to run the tests. This method can be called
# many times, and each new block is appened to a list of preparation blocks.
# When a test is executed, all the preparation blocks are ran in the order they
# were declared. If called without a block, it returns the array of preparation
# blocks.
def prepare(&block)
  cutest[:prepare] << block if block_given?
  cutest[:prepare]
end

# Setup parameters for the tests. The block passed to setup is evaluated before
# running each test, and the result of the setup block is passed to the test as
# a parameter. If the setup and the tests are declared at the same level (in
# the global scope or in a sub scope), it is possible to use instance
# variables, but the parameter passing pattern is recommended to ensure there
# are no side effects.
#
# If the setup blocks are declared in the global scope and the tests are
# declared in sub scopes, the parameter passing usage is required.
#
# Setup blocks can be defined many times, but each new definition overrides the
# previous one. It is recommended to split the tests in many different files
# (the report is per file, not per assertion). Usually one setup block per file
# is enough, but nothing forbids having different scopes with different setup
# blocks.
def setup(&block)
  cutest[:setup] = block if block_given?
  cutest[:setup]
end

# Call all the prepare blocks and setup blocks before executing the test. Even
# though the assertions can live anywhere (it's not mandatory to put them
# inside test blocks), it is necessary to wrap them in test blocks in order to
# execute preparation and setup blocks.
def test(name = nil, &block)
  @_test = name

  prepare.each { |block| block.call }
  block.call(setup && setup.call)
end

# Assert that value is not nil or false.
def assert(value)
  flunk unless value
end

# Assert that the block doesn't raise the expected exception.
def assert_raise(expected = Exception)
  begin
    yield
  rescue => exception
  ensure
    flunk unless exception.kind_of?(expected)
  end
end

# Stop the tests and raise an error where the message is the last line executed
# before flunking.
def flunk(caller = caller[1])
  ex = Cutest::AssertionFailed.new(@_test)
  ex.set_backtrace(caller)

  file, line = ex.backtrace.shift.split(":")
  code = File.readlines(file)[line.to_i - 1]

  ex.message.replace(">> #{@_test}\n=> #{code.strip}\n   #{file} +#{line}")

  raise ex
end
