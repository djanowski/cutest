Cutest
=======

Forking tests.

Description
-----------

Run tests in separate processes to avoid shared state.

Each test file is loaded in a forked process and inside an anonymous
module. Once a failure is found in a file, the rest of the file is
skipped and the error is reported. This way, running your test suite
feels faster.

There are no nested contexts, just the `setup` and `test` methods.
Unlike other testing tools, the result of evaluating the setup is
passed as a parameter to each test. Even if you can still use instance
variables, the code in the examples is the suggested way to keep tests
from sharing information.

Usage
-----

In your Rakefile:

    require "cutest"

    task :test do
      Cutest.run(Dir["test/*"])
    end

    task :default => :test

In your tests:

    setup do
      {:a => 23, :b => 43}
    end

    test "should receive the result of the setup block as a parameter" do |params|
      assert params == {:a => 23, :b => 43}
    end

    test "should evaluate the setup block before each test" do |params|
      params[:a] = nil
    end

    test "should preserve the original values from the setup" do |params|
      assert 23 == params[:a]
    end

To run the tests:

    $ rake

If you get an error, the report will look like this:

    => assert 24 == params[:a]
    test/a_test.rb:14

Instead of a description of the error, you get to see the assertion
that failed along with the file and line number. Adding a debugger and
fixing the bug is left as an exercise for the reader.

Installation
------------

    $ gem install cutest

License
-------

Copyright (c) 2009 Damian Janowski and Michel Martens

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
