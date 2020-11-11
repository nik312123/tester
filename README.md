# tester

Used to test packages.

In folder in which you plan to use Tester, include a `dune` file with something like the following, replacing `hwk_05_test` with the name of the `.ml` file in which you plan to add your tests.

```dune
(tests
    (names hwk_05_test)
    (libraries tester))
```

In the `.ml` file in which your tests will be contained, put the following at the top:

```ocaml
open Tester
```

Then, use 
