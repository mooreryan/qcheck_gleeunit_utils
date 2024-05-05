<!-- TOC --><a name="qcheck_gleeunit_utils"></a>
# qcheck_gleeunit_utils

[![Package Version](https://img.shields.io/hexpm/v/qcheck_gleeunit_utils)](https://hex.pm/packages/qcheck_gleeunit_utils)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/qcheck_gleeunit_utils/)


This package provides utility functions for working with Gleam's [gleeunit](https://github.com/lpil/gleeunit) test framework.

While it may be more broadly useful, this library is mainly developed for internal use in the [qcheck](https://github.com/mooreryan/gleam_qcheck) library.  As such, no guarantees about API stability will be made until qcheck itself is more stable.

## Contents

<!-- TOC start (generated with https://github.com/derlin/bitdowntoc) -->

- [qcheck_gleeunit_utils](#qcheck_gleeunit_utils)
   * [Compilation target](#compilation-target)
   * [Usage](#usage)
      + [Run all tests in parallel](#run-all-tests-in-parallel)
      + [Run tests with long timeouts](#run-tests-with-long-timeouts)
      + [Run parallel test groups](#run-parallel-test-groups)
         - [Gotchas](#gotchas)
      + [Run in-order tests in a parallel context](#run-in-order-tests-in-a-parallel-context)
   * [License](#license)

<!-- TOC end -->

<!-- TOC --><a name="compilation-target"></a>
## Compilation target

The functions provided in this package only work properly on the Erlang target.  They will not manage your tests properly on the JavaScript target.

<!-- TOC --><a name="usage"></a>
## Usage

The following sections show some common use cases.  More info can be found in the docs.

(Click the tiny arrows to expand the sections containing example code.)

<!-- TOC --><a name="run-all-tests-in-parallel"></a>
### Run all tests in parallel

If you want to keep things as simple as possible and simply run all your tests in parallel, you may replace the call to `gleeunit.main` with `run.run_gleeunit`.

<details>

<summary style="color:#D900B8;">
  <span style="text-decoration:underline;">
    Click to expand the example code!
  </span>
</summary>

```gleam
import gleeunit/should
import qcheck_gleeunit_utils/run

pub fn main() {
  run.run_gleeunit()
}

pub fn example_1_should_pass__test() {
  do_work()
  should.equal(1, 1)
}

pub fn example_2_should_fail__test() {
  do_work()
  should.equal(1, 2)
}

pub fn example_3_should_pass__test() {
  do_work()
  should.equal(1, 1)
}

pub fn example_4_should_fail__test() {
  do_work()
  should.equal(100, 200)
}

import gleam/list

// A small function simulating some CPU bound work.
fn do_work() {
  let _l = list.range(0, 10_000_000)

  Nil
}
```

</details>

Be aware that any individual test that takes longer than 5 seconds (the default EUnit timeout), will cause the whole test suite to come crashing down.

<!-- TOC --><a name="run-tests-with-long-timeouts"></a>
### Run tests with long timeouts

Here is an example of a test that will timeout (...at least, it will timeout on my laptop).

<details>

<summary style="color:#D900B8;">
  <span style="text-decoration:underline;">
    Click to expand the example code!
  </span>
</summary>


```gleam
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn hello__test() {
  do_work(25)
  should.equal(1, 1)
}

import gleam/list

// A small function simulating some CPU bound work.
fn do_work(i) {
  case i >= 0 {
    True -> {
      let _l = list.range(0, 10_000_000)
      do_work(i - 1)
    }
    False -> Nil
  }
}
```

</details>

If you run that with `gleam test`, (and you're computer isn't too much faster than mine), then you should get a timeout error that looks sort of like this:

```
Pending:
  qcheck_gleeunit_utils_test.hello__test: module 'qcheck_gleeunit_utils_test'
    %% Unknown error: {timeout,

... lots more stack trace ...
```
Okay, so that test is taking too long, so it crashes with the timeout error.

We can avoid that by using a test generating function along with the `test_spec.make` function.

<details>

<summary style="color:#D900B8;">
  <span style="text-decoration:underline;">
    Click to expand the example code!
  </span>
</summary>


```gleam
import gleeunit
import gleeunit/should

// Add this import statement.
import qcheck_gleeunit_utils/test_spec

pub fn main() {
  gleeunit.main()
}

// Add a trailing `_` (underscore) character to the test name to specify that it
// is a function for generating rather than a test itself.
pub fn hello__test_() {
  // And use the `test_spec.make` function here.
  test_spec.make(fn() {
    do_work(25)
    should.equal(1, 1)
  })
}

import gleam/list

// A small function simulating some CPU bound work.
fn do_work(i) {
  case i >= 0 {
    True -> {
      let _l = list.range(0, 10_000_000)
      do_work(i - 1)
    }
    False -> Nil
  }
}
```

You could also write the `hello__test_()` function with the `use` syntax if you prefer.

```gleam
pub fn hello__test_() {
  // And use the `test_spec.make` function here.
  use <- test_spec.make
  do_work(25)
  should.equal(1, 1)
}
```

</details>

Now, run that with `gleam test` and you will get a passing test. (On my computer, it takes about 7 seconds.)

*Note that this example can also be used with the `run.run_gleeunit` as opposed to the `gleeunit.main` if you want to parallelize all the tests.

<!-- TOC --><a name="run-parallel-test-groups"></a>
### Run parallel test groups

Sometimes, you may want only certain tests to be run in parallel, perhaps because you have some tests that interact with some external state or involve some other tricky setup or teardown that may interact poorly with other tests running in parallel.

For this, we use the `TestGroup`s, which are created with the `test_spec.run_in_parallel` and `test_spec.run_in_order` functions.  For this use case, we will use `test_spec.run_in_parallel` to create a `TestGroup` that will specify tests to be run in parallel.

<details>

<summary style="color:#D900B8;">
  <span style="text-decoration:underline;">
    Click to expand the example code!
  </span>
</summary>


```gleam
import gleam/list
import gleeunit
import gleeunit/should
import qcheck_gleeunit_utils/test_spec

pub fn main() {
  gleeunit.main()
}

pub fn in_order_1__test() {
  do_work(5)
  should.equal(1, 1)
}

pub fn in_order_2__test() {
  do_work(5)
  should.equal(1, 1)
}

pub fn in_order_3__should_fail__test() {
  do_work(5)
  should.equal(1, 3)
}

fn in_parallel_1() {
  do_work(5)
  should.equal(1, 1)
}

fn in_parallel_2() {
  do_work(5)
  should.equal(1, 1)
}

fn in_parallel_3__should_fail() {
  do_work(5)
  should.equal(1, 11)
}

pub fn in_parallel__test_() {
  [in_parallel_1, in_parallel_2, in_parallel_3__should_fail]
  // Note the use of `test_spec.make` here.
  |> list.map(test_spec.make)
  |> test_spec.run_in_parallel
}

// A small function simulating some CPU bound work.
fn do_work(i) {
  case i >= 0 {
    True -> {
      let _l = list.range(0, 10_000_000)
      do_work(i - 1)
    }
    False -> Nil
  }
}
```

</details>

<!-- TOC --><a name="gotchas"></a>
#### Gotchas

There is a tricky gotcha that you need to be aware of with test groups.  It occurs when you give different timeouts for functions in a test group.

<details>

<summary style="color:#D900B8;">
  <span style="text-decoration:underline;">
    Click to expand the example code!
  </span>
</summary>

```gleam
import gleam/list
import gleeunit
import gleeunit/should
import qcheck_gleeunit_utils/test_spec

pub fn main() {
  gleeunit.main()
}

// All of these tests should fail, and they are all too long for the default
// timeout.

fn in_parallel_1__should_fail() {
  do_work(25)
  should.equal(1, 1)
}

fn in_parallel_2__should_fail() {
  do_work(25)
  should.equal(1, 10)
}

fn in_parallel_3__should_fail() {
  do_work(25)
  should.equal(1, 100)
}

pub fn in_parallel__test_() {
  [
    // The `make` calls by default use a really long timeout.
    test_spec.make(in_parallel_1__should_fail),
    // For this one, we set a timeout of 1 second.
    test_spec.make_with_timeout(1, in_parallel_2__should_fail),
    test_spec.make(in_parallel_3__should_fail),
  ]
  |> test_spec.run_in_parallel
}

// A small function simulating some CPU bound work.
fn do_work(i) {
  case i >= 0 {
    True -> {
      let _l = list.range(0, 10_000_000)
      do_work(i - 1)
    }
    False -> Nil
  }
}
```

</details>

If you run that with `gleam test`, while you should see three test failures, you will only see the first test failure.  I suspect this is because the timeout error triggered by the second test silently brings down the whole test group.  

If you change the timeout to `100` seconds (or really any long enough value), and rerun `gleam test`, you will see all three tests failing as expected.

To summarize, be careful with test groups when one or more of the tests may timeout--it will silently crash the whole test group, swallowing any failures (or passes) for some (or all) of the tests.

<!-- TOC --><a name="run-in-order-tests-in-a-parallel-context"></a>
### Run in-order tests in a parallel context

If what you really want is *all* tests to be run in parallel, it can be a real drag to specify all your tests in parallel test groups.  So it is easy enough to use the `run.run_gleeunit` parallel helper.  However, what if you need some of the tests to be run in order?

You can do that by creating a `TestGroup` with the `test_spec.run_in_order` function.

<details>

<summary style="color:#D900B8;">
  <span style="text-decoration:underline;">
    Click to expand the example code!
  </span>
</summary>

```gleam
import gleam/list
import gleeunit/should
import qcheck_gleeunit_utils/run
import qcheck_gleeunit_utils/test_spec

pub fn main() {
  run.run_gleeunit()
}

pub fn in_parallel_1__test() {
  do_work(5)
  should.equal(1, 1)
}

pub fn in_parallel_2__test() {
  do_work(5)
  should.equal(1, 1)
}

pub fn in_parallel_3__should_fail__test() {
  do_work(5)
  should.equal(1, 3)
}

pub fn in_parallel_4__test() {
  do_work(5)
  should.equal(1, 1)
}

pub fn in_parallel_5__test() {
  do_work(5)
  should.equal(1, 1)
}

pub fn in_parallel_6__test() {
  do_work(5)
  should.equal(1, 1)
}

fn in_order_1() {
  do_work(5)
  should.equal(1, 1)
}

fn in_order_2() {
  do_work(5)
  should.equal(1, 1)
}

fn in_order_3__should_fail() {
  do_work(5)
  should.equal(1, 11)
}

fn in_order_4() {
  do_work(5)
  should.equal(1, 1)
}

fn in_order_5() {
  do_work(5)
  should.equal(1, 1)
}

fn in_order_6() {
  do_work(5)
  should.equal(1, 1)
}

pub fn in_parallel__test_() {
  [
    in_order_1,
    in_order_2,
    in_order_3__should_fail,
    in_order_4,
    in_order_5,
    in_order_6,
  ]
  |> list.map(test_spec.make)
  |> test_spec.run_in_order
}

// A small function simulating some CPU bound work.
fn do_work(i) {
  case i >= 0 {
    True -> {
      let _l = list.range(0, 10_000_000)
      do_work(i - 1)
    }
    False -> Nil
  }
}
```

</details>

If you run that with `gleam test`, you will see the first 6 test complete more or less all at once, then the following six tests complete one-by-one.

<!-- TOC --><a name="license"></a>
## License

[![license MIT or Apache
2.0](https://img.shields.io/badge/license-MIT%20or%20Apache%202.0-blue)](https://github.com/mooreryan/gleam_qcheck)

Copyright (c) 2024 Ryan M. Moore

Licensed under the Apache License, Version 2.0 or the MIT license, at your option. This program may not be copied, modified, or distributed except according to those terms.

See `licenses/gleeunit_license.txt` for the original gleeunit license.
