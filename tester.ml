(**
    [Tester] is the module associated with simple test cases with better output then OUnit2 as desired
*)

(**
    The record type that is associated with a test; it consists of [compare_fun] a function to compare the expected and actual results of
    the function, [string_of_result] a function to parse the output of the function, [input] the string representing the input to the
    function, [expected_result] the expected output of the function, and [actual_result] the value that the function actually returned
*)
type 'a test = {compare_fun: 'a -> 'a -> bool; string_of_result: 'a -> string; input: string; expected_result: 'a; actual_result: 'a}

(**
    [create_test] creates an instance of the [test] record type with the given parameters
    @param compare_fun      A function to compare the expected and actual results of the function
    @param string_of_result A function to parse the output of the function
    @param input            The string representing the input to the function
    @param expected_result  The expected output of the function
    @param actual_result    The value that the function actually returned
    @return The [test] instance with the given values
*)
let create_test (compare_fun: 'a -> 'a -> bool) (string_of_result: 'a -> string) (input: string) (expected_result: 'a) (actual_result: 'a): 'a test =
    {compare_fun = compare_fun; string_of_result = string_of_result; input = input; expected_result = expected_result; actual_result = actual_result}

(**
    [create_test_eq] creates an instance of the [test] record type with the given parameters and (=) as [compare_fun]
    @param string_of_result A function to parse the output of the function
    @param input            The string representing the input to the function
    @param expected_result  The expected output of the function
    @param actual_result    The value that the function actually returned
    @return The [test] instance with the given values
*)
let create_test_eq (string_of_result: 'a -> string) (input: string) (expected_result: 'a) (actual_result: 'a): 'a test =
    create_test (=) string_of_result input expected_result actual_result

(**
    [run_test] executes a given test case
    @param name                                                                   The printed name that is associated with this test case
    @param show_input                                                             True if the input string for the test should be printed
    @param {compare_fun; string_of_result; input; expected_result; actual_result} The [test] to run
    @return unit
*)
let run_test (name: string) (show_input: bool) ({compare_fun; string_of_result; input; expected_result; actual_result}: 'a test): unit =
    (* Retrieve the result of comparing the expected result with the actual result *)
    let passed = compare_fun expected_result actual_result in
    (* Print PASS if passed and FAIL if failed along with the name associated with the test case *)
    print_string (if passed then "PASS" else "FAIL");
    Printf.printf " – %s" name;
    (* Print the input string associated with the test if show_input is true *)
    let () = if show_input then Printf.printf " <- %s" input else () in
    (* If passed, then simply print OK; otherwise, print the expected and actual values *)
    if passed then print_endline " OK"
    else Printf.printf "\n    Expected: %s\n      Actual: %s\n" (string_of_result expected_result) (string_of_result actual_result)

(**
    [run_tests] runs a [list] of [test]s using [run_test]
    @param name        The name that is associated with the given [test list]
    @param show_inputs True if the input string for each test in the [test list] should be printed
    @param tests       The [list] of [test]s to run
    @return unit
*)
let run_tests (name: string) (show_inputs: bool) (tests: 'a test list): unit =
    Printf.printf "Running tests for %s:\n" name;
    List.iter (run_test name show_inputs) tests;
    print_endline ""
