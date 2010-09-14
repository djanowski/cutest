require "batch"

class AssertionFailed < StandardError; end

def assert(value)
  flunk unless value
end

def assert_raise(expected = Exception)
  begin
    yield
  rescue => exception
  ensure
    flunk unless exception.kind_of?(expected)
  end
end

def flunk(caller = caller[1])
  ex = AssertionFailed.new(@_test)
  ex.set_backtrace(caller)

  file, line = ex.backtrace.shift.split(":")
  code = File.readlines(file)[line.to_i - 1]

  ex.message.replace(">> #{@_test}\n=> #{code.strip}\n   #{file} +#{line}")

  raise ex
end

@_setup = nil

def setup(&block)
  @_setup = block if block_given?
  @_setup
end

def test(name = nil, &block)
  @_test = name

  block.call(setup && setup.call)
end

class Cutest < Batch
  VERSION = "0.0.3"

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
      raise AssertionFailed.new(output) unless output.empty?
      read.close
    end
  end
end
