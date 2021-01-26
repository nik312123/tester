(**
    [Tester] is a unit test framework for OCaml. It allows the easy creation of unit tests for OCaml code. It is
    somewhat based on {{:https://tinyurl.com/OUnit2} OUnit2}, another unit testing framework for OCaml. However, its
    output can be customized per test case, and it is easier to see whether a case has passed or failed.
    
    Copyright (C) 2020 Nikunj Chawla
    
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.
    
    You should have received a copy of the GNU Lesser General Public License
    along with this program.  If not, see {:https://www.gnu.org/licenses/}.
*)

(**
    The record type that is associated with a test
*)
type 'a t

(**
    [test] creates an instance of the {!t} record type with the given parameters
    @param pass_pred          A function to compare the expected and actual results of the computationally-delayed
                              expression
    @param string_of_result   A function to parse the output of the computationally-delayed expression
    @param input              The string representing the input for the test
    @param expected_result    The expected output of the computationally-delayed expression
    @param actual_result_lazy The lazily-evaluated result of actually executing the computationally-delayed expression
    @return The {!t} instance with the given values
*)
val test: ('a -> 'a -> bool) -> ('a -> string) -> string -> 'a -> 'a lazy_t -> 'a t

(**
    [test_eq] creates an instance of the {!t} record type with the given parameters and (=) as [pass_pred] from {!test}
    @param string_of_result   A function to parse the output of the computationally-delayed expression
    @param input              The string representing the input for the test
    @param expected_result    The expected output of the computationally-delayed expression
    @param actual_result_lazy The lazily-evaluated result of actually executing the computationally-delayed expression
    @return The {!t} instance with the given values
*)
val test_eq: ('a -> string) -> string -> 'a -> 'a lazy_t -> 'a t

(**
    [test_exn] creates an instance of the {!t} record type with the given parameters
    @param pass_pred          A function to compare the expected and actual exceptions for the computationally-delayed
                              expression
    @param string_of_exn      A function to parse the exception raised by the computationally-delayed expression
    @param input              The string representing the input for the test
    @param except_cond_str    The string to print as what was expected if [pass_pred] fails
    @param actual_result_lazy The lazily-evaluated result of actually executing the computationally-delayed expression
    @return The {!t} instance with the given values
*)
val test_exn: (exn -> bool) -> (exn -> string) -> string -> string -> 'a lazy_t -> 'a t

(**
    [run_test_res_t] includes the possible results of running {!run_test_res}:
    
    – [PassResult] if the result of executing the provided expression is equivalent to the expected result as determined
    by [pass_pred] from the function that created {!t}
    
    - [PassExcept] if the exception raised when executing the provided expression is equivalent to the expected
    exception as determined by [pass_pred] from the function that created {!t}
    
    – [FailureResult] if the result of evaluating the provided expression is not equivalent to the expected outcome as
    determined by [pass_pred] from the function that created {!t}
    
    – [FailureExcept] if evaluating the provided expression causes an exception to be raised
*)
type 'a run_test_res_t =
    | PassResult of 'a
    | PassExcept of exn
    | FailureResult of 'a
    | FailureExcept of exn

(**
    [result_passed] returns [true] if the provided {!run_test_res_t} has the type constructor [Pass] and [false]
    otherwise
    @param r The {!run_test_res_t} instance to test
    @return [true] if the provided {!run_test_res_t} has the type constructor [Pass] and [false] otherwise
*)
val result_passed: 'a run_test_res_t -> bool

(**
    [run_test_res] executes a given test case and returns the appropriate {!run_test_res_t} depending on the test
    succeeding or the multiple ways in which it can fail
    @param name       The printed name that is associated with this test case
    @param show_input [true] if the input string for the test should be printed
    @param show_pass  [true] if something should be printed if a test passes
    @param test       The instance of {!t} to be run
    @return The appropriate {!run_test_res_t} depending on the test succeeding or the multiple ways in which it can fail
*)
val run_test_res: string -> bool -> bool -> 'a t -> 'a run_test_res_t

(**
    [run_test] executes a given test case
    @param name       The printed name that is associated with this test case
    @param show_input [true] if the input string for the test should be printed
    @param show_pass  [true] if something should be printed if a test passes
    @param test       The instance of {!t} to be run
    @return Unit
*)
val run_test: string -> bool -> bool -> 'a t -> unit

(**
    [run_tests_res] runs a [list] of {!t}s using {!run_test_res} and returns a tuple containing the number of tests that
    passed, the number of tests that failed due to differing results, and the number of tests that failed due to an
    exception being thrown
    @param name        The name that is associated with the given [t list]
    @param show_inputs [true] if the input string for each test in the [t list] should be printed
    @param show_passes [true] if something should be printed if a test passes for the individual test
    @param show_num    [true] if the number of tests passed should be shown
    @param tests       The [list] of {!t}s to run
    @return A tuple containing the number of tests that passed, the number of tests that failed due to differing
    results, and the number of tests that failed due to an exception being thrown
*)
val run_tests_res: string -> bool -> bool -> bool -> 'a t list -> int * int * int

(**
    [run_tests] runs a [list] of {!t}s using {!run_test}
    @param name        The name that is associated with the given [test list]
    @param show_inputs [true] if the input string for each test in the [test list] should be printed
    @param show_passes [true] if something should be printed if a test passes for the individual test
    @param show_num    [true] if the number of tests passed should be shown
    @param tests       The [list] of {!t}s to run
    @return Unit
*)
val run_tests: string -> bool -> bool -> bool -> 'a t list -> unit
