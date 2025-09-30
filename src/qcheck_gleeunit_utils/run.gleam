//// This module provides an alternative to the
//// [gleeunit.main](https://hexdocs.pm/gleeunit/gleeunit.html#main) function
//// that will run tests in parallel when targeting Erlang.  When targeting
//// JavaScript, it will use Gleeunit's default runner.
////
////

// Based on gleeunit commit 28993019b465e0d5872d67a890b3ec5ba7e42283

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

@target(erlang)
import gleam/list
@target(erlang)
import gleam/result
@target(erlang)
import gleam/string

/// Find and run all test functions for the current project using Erlang's EUnit
/// test framework, or a custom JavaScript test runner.
///
/// Any Erlang or Gleam function in the `test` directory with a name ending in
/// `_test` is considered a test function and will be run.
///
/// A test that panics is considered a failure.
///
pub fn run_gleeunit() -> Nil {
  do_run_gleeunit()
}

@target(javascript)
import gleeunit

@target(javascript)
fn do_run_gleeunit() -> Nil {
  gleeunit.main()
}

@target(erlang)
fn do_run_gleeunit() -> Nil {
  let options = [Verbose, NoTty, Report(#(GleeunitProgress, [Colored(True)]))]

  let result =
    find_files(matching: "**/*.{erl,gleam}", in: "test")
    |> list.map(gleam_to_erlang_module_name)
    |> list.map(dangerously_convert_string_to_atom(_, Utf8))
    |> Inparallel
    |> run_eunit(options)

  let code = case result {
    Ok(_) -> 0
    Error(_) -> 1
  }
  halt(code)
}

@target(erlang)
@external(erlang, "erlang", "halt")
fn halt(a: Int) -> Nil

@target(erlang)
fn gleam_to_erlang_module_name(path: String) -> String {
  case string.ends_with(path, ".gleam") {
    True ->
      path
      |> string.replace(".gleam", "")
      |> string.replace("/", "@")

    False ->
      path
      |> string.split("/")
      |> list.last
      |> result.unwrap(path)
      |> string.replace(".erl", "")
  }
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
  Inparallel(List(Atom))
}

@target(erlang)
@external(erlang, "qcheck_gleeunit_utils_ffi", "run_eunit")
fn run_eunit(a: TestRepr, b: List(EunitOption)) -> Result(Nil, a)
