Cutest
=======

Forking tests.

Description
-----------

Each test file is run in a forked process to avoid shared state. Once a failure
is found, you get a report detailing what failed and how to locate the error
and the rest of the file is skipped.

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

Three assertions are available: `assert`, that accepts a value and raises
if it's false or nil; `assert_equal`, that raises if its arguments are not
equal; and `assert_raise`, that executes a passed block and compares the raised
exception to the expected one. In all cases, if the expectation is no met, an
`AssertionFailed` exception is raised.

Usage
-----

In your terminal:

    $ cutest test/*.rb

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
running them.

Handling errors
---------------

If you get an error when running the tests, this is what you will see:

    Exception: assert_equal 24, params[:a] # 24 != 23
    test/setup.rb +14

Running the build
-----------------

Using Rake:

    task :test do
      exec "cutest test/*.rb"
    end

    task :default => :test

Using Make:

    .PHONY: test

    test:
      cutest test/*.rb

Command-line interface
----------------------

The tool `cutest` accepts a list of files and sends them to `Cutest.run`. If
you need to require a file or library before running the tests, as is the case
with test helpers, use the `-r` flag:

    $ cutest -r ./test/helper.rb ./test/*_test.rb

If you want to check which version you are running, try the `-v` flag.

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
