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
    The record type that is associated with a test; it consists of [pass_pred] a function to test if the expected result
    and actual result match, [string_of_result] a function to convert the output of the function to a [string], [input]
    the [string] representing the input to the function, [expected_result] the expected output of the function, and
    [actual_result_lazy] the lazily-evaluated result of actually executing the function
*)
type 'a t = {
    pass_pred: 'a -> 'a -> bool;
    string_of_result: 'a -> string;
    input: string;
    expected_result: 'a;
    actual_result_lazy: 'a lazy_t
}

(**
    [test] creates an instance of the {!t} record type with the given parameters
    @param pass_pred          A function to compare the expected and actual results of the function
    @param string_of_result   A function to parse the output of the function
    @param input              The string representing the input to the function
    @param expected_result    The expected output of the function
    @param actual_result_lazy The lazily-evaluated result of actually executing the function
    @return The {!t} instance with the given values
*)
let test (pass_pred: 'a -> 'a -> bool) (string_of_result: 'a -> string) (input: string) (expected_result: 'a)
(actual_result_lazy: 'a lazy_t): 'a t =
    {pass_pred; string_of_result; input; expected_result; actual_result_lazy}

(**
    [test_eq] creates an instance of the {!t} record type with the given parameters and (=) as {!pass_pred}
    @param string_of_result   A function to parse the output of the function
    @param input              The string representing the input to the function
    @param expected_result    The expected output of the function
    @param actual_result_lazy The lazily-evaluated result of actually executing the function
    @return The {!t} instance with the given values
*)
let test_eq (string_of_result: 'a -> string) (input: string) (expected_result: 'a) (actual_result_lazy: 'a lazy_t):
'a t = test (=) string_of_result input expected_result actual_result_lazy

(**
    [run_test_res] executes a given test case and returns [true] if the test passed and [false] otherwise
    @param name       The printed name that is associated with this test case
    @param show_input [true] if the input string for the test should be printed
    @param show_pass  [true] if something should be printed if a test passes
    @param test       The instance of {!t} to be run
    @return [true] if the test passed and [false] if it did not
*)
type 'a fn_res_t =
    | Res of 'a
    | Except of exn

let fn_res_get_res: 'a fn_res_t -> 'a = function
    | Res r -> r
    | _ -> failwith "fn_res_t is not Res"

let fn_res_get_exn: 'a fn_res_t -> exn = function
    | Except e -> e
    | _ -> failwith "fn_res_t is not Except"

type 'a run_test_res_t =
    | Pass of 'a
    | FailureResult of 'a
    | FailureExcept of exn

let result_passed: 'a run_test_res_t -> bool = function
    | Pass _ -> true
    | _ -> false

let run_test_res (name: string) (show_input: bool) (show_pass: bool) (test: 'a t): 'a run_test_res_t =
    let show_failure (fail_str: string): unit =
        Printf.printf "\n    Expected: %s\n      Actual: %s\n"
            (test.string_of_result test.expected_result)
            fail_str
    (* Retrieve the result of comparing the expected result with the actual result *)
    in let fn_res =
        try Res (Lazy.force test.actual_result_lazy)
        with e -> Except e
    in let passed =
        match fn_res with
            | Res actual_result -> test.pass_pred test.expected_result actual_result
            | Except _ -> false
    (* Print PASS if passed and FAIL if failed along with the name associated with the test case *)
    in if not passed || show_pass then
        let () = print_string (if passed then "PASS" else "FAIL") in
        Printf.printf " – %s" name
    else ();
    (* Print the input string associated with the test if show_input is true *)
    if show_input && (not passed || show_pass) then Printf.printf " <- %s" test.input else ();
    (* If passed, then simply print OK; otherwise, print the expected and actual values *)
    if passed then
        let () = if show_pass then
            print_endline " OK"
        else ()
        in Pass (fn_res |> fn_res_get_res)
    else
        match fn_res with
            | Res actual_result ->
                let () = show_failure (test.string_of_result actual_result) in
                FailureResult (fn_res |> fn_res_get_res)
            | Except e ->
                let () = show_failure ("Exception occurred: " ^ (Printexc.to_string e)) in
                FailureExcept (fn_res |> fn_res_get_exn)

(**
    [run_test] executes a given test case
    @param name       The printed name that is associated with this test case
    @param show_input [true] if the input string for the test should be printed
    @param show_pass  [true] if something should be printed if a test passes
    @param test       The instance of {!t} to be run
    @return unit
*)
let run_test (name: string) (show_input: bool) (show_pass: bool) (test: 'a t): unit =
    let _ = run_test_res name show_input show_pass test in ()

(**
    [run_tests_res] runs a [list] of {!t}s using {!run_test_res} and returns a tuple containing the number of tests that
    passed and the total number of tests
    @param name        The name that is associated with the given [t list]
    @param show_inputs [true] if the input string for each test in the [t list] should be printed
    @param show_passes [true] if something should be printed if a test passes for the individual test
    @param show_num    [true] if the number of tests passed should be shown
    @param tests       The [list] of {!t}s to run
    @return A tuple containing the number of tests that passed and the total number of tests
*)
let run_tests_res (name: string) (show_inputs: bool) (show_passes: bool) (show_num: bool) (tests: 'a t list):
int * int * int =
    Printf.printf "Running tests for %s:\n" name;
    (* Fold function to accumulate the results of each test *)
    let run_test_part ((num_passed, num_failed, num_err): int * int * int) (test: 'a t): int * int * int =
        match run_test_res name show_inputs show_passes test with
            | Pass _ -> (num_passed + 1, num_failed, num_err)
            | FailureResult _ -> (num_passed, num_failed + 1, num_err)
            | FailureExcept _ -> (num_passed, num_failed, num_err + 1)
    in let (num_passed, num_failed, num_err) = List.fold_left run_test_part (0, 0, 0) tests
    in if show_num then Printf.printf "%d/%d tests passed for %s\n" num_passed (num_failed + num_err) name
    else ();
    print_endline "";
    (num_passed, num_failed, num_err)

(**
    [run_tests] runs a [list] of {!t}s using {!run_test}
    @param name        The name that is associated with the given [test list]
    @param show_inputs [true] if the input string for each test in the [test list] should be printed
    @param show_passes [true] if something should be printed if a test passes for the individual test
    @param show_num    [true] if the number of tests passed should be shown
    @param tests       The [list] of {!t}s to run
    @return unit
*)
let run_tests (name: string) (show_inputs: bool) (show_passes: bool) (show_num: bool) (tests: 'a t list): unit =
    let _ = run_tests_res name show_inputs show_passes show_num tests in ()
