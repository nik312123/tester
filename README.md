# tester

## Short Description

Used to unit test functions and code.

## Documentation

The documentation for the `Tester` module is present here: [Tester documentation](https://nik312123.github.io/ocamlLibDocs/tester/Tester/)

## Installation

There are a few ways in which you can use this package.

### Using it only in your local project

Clone this repository in your workspace directory where the workspace path is `[workspace_path]`:

```bash
cd [workspace_path]
git clone https://github.com/nik312123/tester.git
```

**1\. If your project is a dune project:**

Ensure that your workspace has a structure that matches something like one of the below structures:

Outer-most possible structure:

```
workspace_dir/
    dune
    dune-project
    example.ml
    example2.ml
    ...
```

The `.ml` files in which you need to use the library can be nested as far as you would like as in the following:

```
workspace_dir/
    dune
    dune-project
    project_subdir/
        dune
        example.ml
        example2.ml
```

Then, in the `dune` file corresponding to the `.ml` file(s) in question, you can add `tester` in the libraries section like in the following:

```
(executable
    (name example)
    (libraries tester))
```

**2\. If your project is built using `ocamlbuild`**

### Installing it in your `opam` switch and using it in a project

Clone the repository wherever you would like:

```bash
git clone https://github.com/nik312123/tester.git
```

Go into the directory you just cloned:

```bash
cd tester
```

Install the library using `opam`:

```bash
opam install .
```

**1\. If your project is a dune project:**

Then, in the `dune` file corresponding to the `.ml` file(s) in question, you can add `tester` in the libraries section like in the following:

```
(executable
    (name example)
    (libraries tester))
```

**2\. If your project is built using `ocamlbuild`**

When building using `ocamlbuild`, include the library in your packages

Example:

If `[example_path]` is the path for `example.ml` and `[tester_path]` is the path for `tester.ml` where both paths are subdirectories of the workspace directory, then the following would be the command to build `example.byte` using the `Tester` module:

```bash
ocamlbuild -use-ocamlfind -I [example_path] -I [tester_path] example.byte
```
