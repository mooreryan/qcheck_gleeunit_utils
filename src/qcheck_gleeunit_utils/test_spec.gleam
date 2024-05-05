//// Utility functions for representing tests and test groups in Gleeunit, 
//// allowing users to control the timeout length of individual tests as well as 
//// to create groups of tests that will be run in parallel or in order.
//// 
//// - [TestSpec](#TestSpec) values are created by [make](#make) and 
////   [make_with_timeout](#make_with_timeout).
//// - [TestGroup](#TestGroup) values are created by 
////   [run_in_parallel](#run_in_parallel) and [run_in_order](#run_in_order).
////
//// Both `TestSpec`s and `TestGroup`s represent tests as data, which, when 
//// targeting Erlang, will be executed by the test runner *if* they are 
//// returned by a test generating function (that is, a function whose name is 
//// prefixed by `_test_`).
//// 
//// **Note:** The functions in this module will *NOT* work correclty on the 
//// JavaScript target.
//// 
//// 

/// `TestSpec(a)` represents a specification for a test.
/// 
/// 
pub opaque type TestSpec(a) {
  Timeout(Int, fn() -> a)
}

/// `TestGroup(a)`represents a group of test specifications.
/// 
/// 
pub opaque type TestGroup(a) {
  Inparallel(List(TestSpec(a)))
  Inorder(List(TestSpec(a)))
}

/// `make(f)` creates a test specification that specifies how to run the
/// function `f` with a very long timeout.
/// 
/// While the function `f` can technically return a value of any type, it is
/// likely that the return type will be `Nil`.  For example, when using 
/// functions from the `gleeunit/should` module.
/// 
/// ```gleam
/// make(fn() {
///   should.equal(1 + 2, 3)
/// })
/// ```
/// 
/// You may prefer the `use` syntax:
/// 
/// ```gleam
/// use <- make
/// should.equal(1 + 2, 3)
/// ```
/// 
/// Named functions of the correct signature may also be used.
/// 
/// ```gleam
/// fn addition_is_commutative() {
///   should.equal(1 + 2, 2 + 1)
/// }
/// 
/// // ... later inside some other function ...
/// make(addition_is_commutative)
/// ```
/// 
/// 
pub fn make(f: fn() -> a) -> TestSpec(a) {
  Timeout(2_147_483_647, f)
}

/// `make_with_timeout(timeout, f)` creates a test specification that specifies
/// how to run the function `f` with a custom `timeout` in given in seconds.
/// 
/// See [make](#make) for examples.
/// 
/// 
pub fn make_with_timeout(timeout: Int, f: fn() -> a) -> TestSpec(a) {
  Timeout(timeout, f)
}

/// `run_in_parallel(test_specs)` creates a test group that specifies that the
/// given `test_specs` should be run in parallel.
/// 
/// The `run_in_parallel` function is generally used in the context of a 
/// [test generating function](https://www.erlang.org/doc/apps/eunit/chapter#writing-test-generating-functions).
/// You write a function that returns a representation of the set of tests to be
/// executed.  
/// 
/// The names of these functions **must** end with `_test_` (note the trailing 
/// underscore).
/// 
/// ```gleam
/// pub fn a_lengthy_nice_math_test_() {
///   [
///     make(fn() {
///       let result = some_lengthy_calculation(1, 2)
///       should.equal(1, result)
///     }),
///     make(fn() {
///       let result = another_lengthy_calculation(10, 20)
///       should.equal(100, result)
///     }),
///   ]
///   |> run_in_parallel
/// }
/// ```
/// 
/// 
pub fn run_in_parallel(test_specs: List(TestSpec(a))) -> TestGroup(a) {
  Inparallel(test_specs)
}

/// `run_in_order(test_specs)` creates a test group that specifies that the
/// given `test_specs` should be run in order.
/// 
/// See `run_in_parallel` for examples.
/// 
/// 
pub fn run_in_order(test_specs: List(TestSpec(a))) -> TestGroup(a) {
  Inorder(test_specs)
}
