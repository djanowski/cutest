Cutest
=======

Forking tests.

Description
-----------

Run tests in separate processes to avoid shared state.

Each test file is run in a forked process and, if the second parameter to
`Cutest.run` is true, it is also loaded inside an anonymous module. Once a
failure is found in a file, the rest of the file is skipped and the error is
reported. This way, running your test suite feels faster.

You can use the `scope` command around tests: it guarantees that no instance
variables are shared between tests.

There are two commands very similar in nature, but with a subtle difference that
makes them easy to combine in order to satisfy different needs: `prepare` and
`setup`.

The `prepare` blocks are executed before each test. If you call `prepare` many
times, each passed block is appended to an array. When the test is run, all
those prepare blocks are executed in order. The result of the block is
discarded, so it is only useful for preparing the environment (flushing the
database, removing a directory, etc.).

The `setup` block is executed before each test and the result is passed as a
parameter to the `test` block. Unlike `prepare`, each definition of `setup`
overrides the previous one. Even if you can declare instance variables and
share them between tests, the recommended usage is to pass the result of the
block as a parameter to the `test` blocks.

The `test` method executes the passed block after running `prepare` and
`setup`. This is where assertions must be declared.

Two assertions are available: `assert` and `assert_raise`. The first accepts a
value and raises an `AssertionFailed` exception if it's false or nil, and the
later receives an expected exception and a block: the block is executed and
the raised exception is compared with the expected one. An `AssertionFailed`
exception is raised if the block runs fine or if the raised exception doesn't
match the expectation.

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

An example working with a prepare block:

    prepare do
      Ohm.flush
    end

    setup do
      Ohm.redis.get("foo")
    end

    test do |foo|
      assert foo.nil?
    end

And working with scopes:

    setup do
      @foo = true
    end

    @bar = true

    scope do
      test "should not share instance variables" do |foo|
        assert !defined?(@foo)
        assert !defined?(@bar)
        assert foo == true
      end
    end

The tests in these two examples will pass.

Unlike other testing frameworks, Cutest does not compile all the tests before
running them. Another shift in design is that one dot is shown after a file is
examined, and not the usual one-dot-per-assertion. And finally, the execution
of a file stops one the first failure is found.

Installation
------------

    $ gem install cutest

License
-------

Copyright (c) 2010 Damian Janowski and Michel Martens

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
