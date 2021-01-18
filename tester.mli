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
    actual_result_lazy: 'a lazy_t;
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
val test: ('a -> 'a -> bool) -> ('a -> string) -> string -> 'a -> 'a lazy_t -> 'a t

(**
    [test_eq] creates an instance of the {!t} record type with the given parameters and (=) as {!pass_pred}
    @param string_of_result   A function to parse the output of the function
    @param input              The string representing the input to the function
    @param expected_result    The expected output of the function
    @param actual_result_lazy The lazily-evaluated result of actually executing the function
    @return The {!t} instance with the given values
*)
val test_eq: ('a -> string) -> string -> 'a -> 'a lazy_t -> 'a t

(**
    [run_test_res_t] includes the possible results of running {!run_test_res}:
    
    – [Pass] if the result of evaluating {!t.actual_result_lazy} is equivalent to {!t.expected_result} as determined by
    {!t.pass_pred}
    
    – [FailureResult] if the result of evaluating {!t.actual_result_lazy} is not equivalent to {!t.expected_result} as
    determined by {!t.pass_pred}
    
    – [FailureExcept] if evaluating {!t.actual_result_lazy} causes an exception to be raised
*)
type 'a run_test_res_t =
    | Pass of 'a
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
