//// This module provides an alternative to the 
//// [gleeunit.main](https://hexdocs.pm/gleeunit/gleeunit.html#main) function 
//// that will run tests in parallel when targeting Erlang.  When targeting 
//// JavaScript, it will use Gleeunit's default runner.
//// 
//// 

// Note: This module is a modified version of the `gleeunit` module from the
// `gleeunit` package.  See bottom of module for original copyright notice.

@target(javascript)
import gleeunit

@target(javascript)
pub fn run_gleeunit() -> Nil {
  gleeunit.main()
}

@target(erlang)
/// Find and run all test functions for the current project using Erlang's EUnit
/// test framework.
///
/// Any Erlang or Gleam function in the `test` directory with a name ending in
/// `_test` is considered a test function and will be run.
///
/// When targeting Erlang, any Erlang or Gleam function in the `test` directory 
/// with a name ending in `_test_` is considered a test generating function that 
/// should return a representation of a set of tests to be run.  (See 
/// `test_spec.make`, for more information.)
///
/// - If running on Erlang, tests will be run in parallel.
/// - If running on JavaScript, tests will be run with Gleeunit's default runner.
///
/// 
pub fn run_gleeunit() -> Nil {
  do_run_in_parallel()
}

@target(erlang)
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
@target(erlang)
import gleam/list
@target(erlang)
import gleam/result
@target(erlang)
import gleam/string

const halt_success = 0

const halt_failure = 0

@target(erlang)
fn do_run_in_parallel() -> Nil {
  let options = [Verbose, NoTty, Report(#(GleeunitProgress, [Colored(True)]))]

  find_files(matching: "**/*.{erl,gleam}", in: "test")
  |> list.map(gleam_to_erlang_module_name)
  |> list.map(dangerously_convert_string_to_atom(_, Utf8))
  |> Inparallel
  |> run_eunit(options)
  |> decode.run(result_decoder())
  |> result.unwrap(halt_failure)
  |> halt
}

@target(erlang)
fn result_decoder() {
  {
    use tag <- decode.field("type", decode.string)
    let result = case tag {
      "ok" -> halt_success
      _ -> halt_failure
    }
    decode.success(result)
  }
}

@target(erlang)
@external(erlang, "erlang", "halt")
fn halt(a: Int) -> Nil

@target(erlang)
fn gleam_to_erlang_module_name(path: String) -> String {
  path
  |> string.replace(".gleam", "")
  |> string.replace(".erl", "")
  |> string.replace("/", "@")
}

@target(erlang)
@external(erlang, "gleeunit_ffi", "find_files")
fn find_files(matching matching: String, in in: String) -> List(String)

@target(erlang)
type Atom

@target(erlang)
type Encoding {
  Utf8
}

@target(erlang)
@external(erlang, "erlang", "binary_to_atom")
fn dangerously_convert_string_to_atom(a: String, b: Encoding) -> Atom

@target(erlang)
type ReportModuleName {
  GleeunitProgress
}

@target(erlang)
type GleeunitProgressOption {
  Colored(Bool)
}

@target(erlang)
type EunitOption {
  Verbose
  NoTty
  Report(#(ReportModuleName, List(GleeunitProgressOption)))
}

@target(erlang)
type TestRepr {
  // Do not change this to PascalCase. It must be like this for the FFI.
  Inparallel(List(Atom))
}

@target(erlang)
@external(erlang, "eunit", "test")
fn run_eunit(a: TestRepr, b: List(EunitOption)) -> Dynamic
//
//
// Original copyright notice:
//
//
// Copyright 2021, Louis Pilfold <louis@lpil.uk>.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
