(**
    [Tester] is a unit test framework for OCaml. It allows the easy creation of unit tests for OCaml code. It is
    somewhat based on {{:https://tinyurl.com/OUnit2}OUnit2}, another unit testing framework for OCaml. However, its
    output can be customized per test case, and it is easier to see whether a case has passed or failed.
*)

(**
    The record type that is associated with a test; it consists of [compare_fun] a function to compare the expected and
    actual results of the function, [string_of_result] a function to parse the output of the function, [input] the
    string representing the input to the function, [expected_result] the expected output of the function, and
    [actual_result_lazy] the lazily-evaluated result of actually executing the function
*)
type 'a t = {
    compare_fun: 'a -> 'a -> bool;
    string_of_result: 'a -> string;
    input: string;
    expected_result: 'a;
    actual_result_lazy: 'a lazy_t
}

(**
    [test] creates an instance of the {!t} record type with the given parameters
    @param compare_fun        A function to compare the expected and actual results of the function
    @param string_of_result   A function to parse the output of the function
    @param input              The string representing the input to the function
    @param expected_result    The expected output of the function
    @param actual_result_lazy The lazily-evaluated result of actually executing the function
    @return The {!t} instance with the given values
*)
let test (compare_fun: 'a -> 'a -> bool) (string_of_result: 'a -> string) (input: string) (expected_result: 'a)
(actual_result_lazy: 'a lazy_t): 'a t =
    {compare_fun; string_of_result; input; expected_result; actual_result_lazy}

(**
    [test_eq] creates an instance of the {!t} record type with the given parameters and (=) as {!compare_fun}
    @param string_of_result   A function to parse the output of the function
    @param input              The string representing the input to the function
    @param expected_result    The expected output of the function
    @param actual_result_lazy The lazily-evaluated result of actually executing the function
    @return The {!t} instance with the given values
*)
let test_eq (string_of_result: 'a -> string) (input: string) (expected_result: 'a) (actual_result_lazy: 'a lazy_t):
'a t = test (=) string_of_result input expected_result actual_result_lazy

(**
    [run_test_output] executes a given test case and returns true if the test passed and false otherwise
    @param name       The printed name that is associated with this test case
    @param show_input True if the input string for the test should be printed
    @param show_pass  True if something should be printed if a test passes
    @param test       The instance of {!t} to be run
    @return True if the test passed and false if it did not
*)
let run_test_output (name: string) (show_input: bool) (show_pass: bool) (test: 'a t): bool =
    (* Retrieve the result of comparing the expected result with the actual result *)
    let passed = test.compare_fun test.expected_result (Lazy.force test.actual_result_lazy) in
    (* Print PASS if passed and FAIL if failed along with the name associated with the test case *)
    if not passed || show_pass then
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
        in true
    else
        let () = Printf.printf "\n    Expected: %s\n      Actual: %s\n"
                               (test.string_of_result test.expected_result)
                               (test.string_of_result (Lazy.force test.actual_result_lazy))
        in false

(**
    [run_test] executes a given test case
    @param name       The printed name that is associated with this test case
    @param show_input True if the input string for the test should be printed
    @param show_pass  True if something should be printed if a test passes
    @param test       The instance of {!t} to be run
    @return unit
*)
let run_test (name: string) (show_input: bool) (show_pass: bool) (test: 'a t): unit =
    let _ = run_test_output name show_input show_pass test in ()

(**
    [run_tests_output] runs a [list] of {!t}s using {!run_test} and returns a tuple containing the number of tests that
    passed and the total number of tests
    @param name        The name that is associated with the given [t list]
    @param show_inputs True if the input string for each test in the [t list] should be printed
    @param show_passes True if something should be printed if a test passes for the individual test
    @param show_num    True if the number of tests passed should be shown
    @param tests       The [list] of {!t}s to run
    @return A tuple containing the number of tests that passed and the total number of tests
*)
let run_tests_output (name: string) (show_inputs: bool) (show_passes: bool) (show_num: bool) (tests: 'a t list):
int * int =
    Printf.printf "Running tests for %s:\n" name;
    let run_test_part ((num_passed, num_tests): int * int) (test: 'a t): int * int =
        let passed = run_test_output name show_inputs show_passes test in
        (num_passed + (if passed then 1 else 0), num_tests + 1)
    in let (num_passed, num_tests) = List.fold_left run_test_part (0, 0) tests
    in if show_num then Printf.printf "%d/%d tests passed for %s\n" num_passed num_tests name
    else ();
    print_endline "";
    (num_passed, num_tests)

(**
    [run_tests] runs a [list] of {!t}s using {!run_test}
    @param name        The name that is associated with the given [test list]
    @param show_inputs True if the input string for each test in the [test list] should be printed
    @param show_passes True if something should be printed if a test passes for the individual test
    @param show_num    True if the number of tests passed should be shown
    @param tests       The [list] of {!t}s to run
    @return unit
*)
let run_tests (name: string) (show_inputs: bool) (show_passes: bool) (show_num: bool) (tests: 'a t list): unit =
    let _ = run_tests_output name show_inputs show_passes show_num tests in ()
