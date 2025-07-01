import gleam/list
import gleeunit/should
import qcheck_gleeunit_utils/run
import qcheck_gleeunit_utils/test_spec

pub fn main() {
  run.run_gleeunit()
}

const test_iterations: Int = 1

pub fn use_syntax__test_() {
  use <- test_spec.make
  let _ = do_work(test_iterations)
  should.equal(1, 1)
}

pub fn in_parallel_1__test() {
  let _ = do_work(test_iterations)
  should.equal(1, 1)
}

pub fn in_parallel_2__test() {
  let _ = do_work(test_iterations)
  should.equal(1, 1)
}

pub fn in_parallel_3__test() {
  let _ = do_work(test_iterations)
  should.equal(1, 1)
}

fn in_order_1() {
  let _ = do_work(test_iterations)
  should.equal(1, 1)
}

fn in_order_2() {
  let _ = do_work(test_iterations)
  should.equal(1, 1)
}

fn in_order_3() {
  let _ = do_work(test_iterations)
  should.equal(1, 1)
}

pub fn in_parallel__test_() {
  [in_order_1, in_order_2, in_order_3]
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
