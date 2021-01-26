(**
    [pass_pred_t] is the type of predicate that the test is using depending on whether testing for output or testing for
    exceptions
*)
type 'a pass_pred_t =
    | PredRes of ('a -> 'a -> bool)
    | PredExn of (exn -> bool)

(**
    The record type that is associated with a test; it consists of [pass_pred] a function to test if the expected result
    and actual result match, [string_of_result] a function to convert the output of the computationally-delayed
    expression to a [string] if not testing for an exception, [string_of_exn] a function to convert the exception raised
    by the computationally-delayed expression if not testing for the output, [input] the [string] representing the input
    to the function, [expected_result] the expected output of the function if testing for function output,
    [except_cond_str] the [string] to print as what was expected if the test is an exception test and if [pass_pred]
    fails, and [actual_result_lazy] the lazily-evaluated result of actually executing the function
*)
type 'a t = {
    pass_pred: 'a pass_pred_t;
    string_of_result: 'a -> string;
    string_of_exn: exn -> string;
    input: string;
    expected_result: 'a option;
    except_cond_str: string;
    actual_result_lazy: 'a lazy_t
}

let test (pass_pred: 'a -> 'a -> bool) (string_of_result: 'a -> string) (input: string) (expected_result: 'a)
(actual_result_lazy: 'a lazy_t): 'a t =
    {
        pass_pred = PredRes pass_pred;
        string_of_result;
        string_of_exn = Fun.const "";
        input;
        expected_result = Some expected_result;
        except_cond_str = "";
        actual_result_lazy
    }

let test_eq (string_of_result: 'a -> string) (input: string) (expected_result: 'a) (actual_result_lazy: 'a lazy_t):
'a t = test (=) string_of_result input expected_result actual_result_lazy

let test_exn (pass_pred: exn -> bool) (string_of_exn: exn -> string) (input: string) (except_cond_str: string)
(actual_result_lazy: 'a lazy_t):
'a t =
    {
        pass_pred = PredExn pass_pred;
        string_of_result = Fun.const "";
        string_of_exn;
        input;
        expected_result = None;
        except_cond_str;
        actual_result_lazy
    }

type 'a run_test_res_t =
    | PassResult of 'a
    | PassExcept of exn
    | FailureResult of 'a
    | FailureExcept of exn

let result_passed: 'a run_test_res_t -> bool = function
    | PassResult _ | PassExcept _ -> true
    | _ -> false

let run_test_res (name: string) (show_input: bool) (show_pass: bool) (test: 'a t): 'a run_test_res_t =
    let string_of_expected: string =
        (match test.pass_pred with
            | PredRes _ -> test.string_of_result (Option.get test.expected_result)
            | PredExn _ -> test.except_cond_str
        )
    in let show_failure (fail_str: string): unit =
        Printf.printf "\n    Expected: %s\n      Actual: %s"
            string_of_expected
            fail_str;
        print_newline ()
    (* Retrieve the result of comparing the expected result with the actual result *)
    in let fn_res =
        try Ok (Lazy.force test.actual_result_lazy)
        with e -> Error e
    in let passed =
        match fn_res with
            | Ok actual_result -> (match test.pass_pred with
                | PredRes pass_pred -> pass_pred (Option.get test.expected_result) actual_result
                | PredExn _ -> false
            )
            | Error e -> (match test.pass_pred with
                | PredRes _ -> false
                | PredExn pass_pred -> pass_pred e
            )
    (* Print PASS if passed and FAIL if failed along with the name associated with the test case *)
    in if not passed || show_pass then
        let () = print_string (if passed then "PASS" else "FAIL") in
        Printf.printf " – %s" name
    else ();
    (* Print the input string associated with the test if show_input is true *)
    if show_input && (not passed || show_pass) then Printf.printf " <- %s" test.input else ();
    (* If passed, then simply print OK; otherwise, print the expected and actual values *)
    if passed then
        let () =
            if show_pass
            then let () = print_string " OK" in print_newline ()
            else ()
        in (match fn_res with
            | Ok res -> PassResult res
            | Error e -> PassExcept e
        )
    else
        match fn_res with
            | Ok actual_result ->
                let () = show_failure (test.string_of_result actual_result) in
                FailureResult (Result.get_ok fn_res)
            | Error e ->
                (match test.pass_pred with
                    | PredRes _ -> show_failure ("Exception occurred – " ^ Printexc.to_string e)
                    | PredExn _ -> show_failure (test.string_of_exn e)
                );
                FailureExcept (Result.get_error fn_res)

let run_test (name: string) (show_input: bool) (show_pass: bool) (test: 'a t): unit =
    let _ = run_test_res name show_input show_pass test in ()

let run_tests_res (name: string) (show_inputs: bool) (show_passes: bool) (show_num: bool) (tests: 'a t list):
int * int * int =
    Printf.printf "Running tests for %s:" name; print_newline ();
    (* Fold function to accumulate the results of each test *)
    let run_test_part ((num_passed, num_failed, num_err): int * int * int) (test: 'a t): int * int * int =
        match run_test_res name show_inputs show_passes test with
            | PassResult _ | PassExcept _ -> (num_passed + 1, num_failed, num_err)
            | FailureResult _ -> (num_passed, num_failed + 1, num_err)
            | FailureExcept _ -> (num_passed, num_failed, num_err + 1)
    in let (num_passed, num_failed, num_err) = List.fold_left run_test_part (0, 0, 0) tests
    in if show_num then Printf.printf "%d/%d tests passed for %s\n" num_passed (num_passed + num_failed + num_err) name;
    print_newline ();
    (num_passed, num_failed, num_err)

let run_tests (name: string) (show_inputs: bool) (show_passes: bool) (show_num: bool) (tests: 'a t list): unit =
    let _ = run_tests_res name show_inputs show_passes show_num tests in ()
