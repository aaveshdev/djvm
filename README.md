# DJVM - a JVM written in Dragon

DJVM is a Java Virtual Machine implemented in the Dragon language. It reads
real `.class` files and executes their bytecode directly - no OpenJDK, no
external JVM, just Dragon interpreting (or, once compiled with `--native`,
running as a native binary that emulates) the JVM's own instruction set.

It is not a complete JVM. It covers enough of the class file format, the
bytecode instruction set, and the standard library to run ordinary
single-threaded console programs - the kind of thing you'd write while
learning Java or scripting a small utility.

Organized as 16 files: classfile parser / class loader / runtime types /
bytecode interpreter / native method library, split by `java.*` package -
similar to how a real JVM's source tree is laid out.

## Features

**Class loading**
- Parses real `.class` files: constant pool (all standard tag types),
  fields, methods, `Code` attributes, exception tables, `BootstrapMethods`
  (for lambda support)
- Loads and links application classes from disk, with bootstrap stubs for
  common `java.*` classes so programs don't need the real JDK present
- Class caching so each class is parsed once

**Bytecode interpreter**
- Executes the JVM instruction set: arithmetic and bitwise ops (int/long/
  float/double), stack manipulation, local variable load/store, control
  flow (branches, loops, `switch`/`tableswitch`/`lookupswitch`), object and
  array creation, field access, `invokevirtual`/`invokestatic`/
  `invokespecial`/`invokeinterface`, `invokedynamic` for lambdas
- Exception handling with proper stack unwinding to matching `catch`
  blocks, including uncaught-exception termination
- A small cooperative thread scheduler (`JavaThread` + a round-robin
  instruction budget per tick) - enough to run `Thread`-using code, not a
  real concurrent scheduler

**Native standard library** (implemented as Dragon functions registered
against JVM method signatures, not real Java bytecode)
- `String`, `StringBuilder`
- `Object`, `Class` (basic reflection), `System`, `Thread`, `Enum`
- `Integer`, `Long`, `Float`, `Double`, `Boolean`, `Character`
- `Math`, `Random`
- `ArrayList`, `LinkedList`, `Stack`, `PriorityQueue`, `Arrays`
- `HashMap`, `HashSet`, `TreeMap`, `TreeSet`, `Collections`, `Optional`
- `PrintStream` (`System.out`/`System.err`), `Scanner` (stdin)
- The standard exception hierarchy (`NullPointerException`,
  `ArrayIndexOutOfBoundsException`, `ArithmeticException`, etc.)
- Basic dispatch for functional interfaces (`Runnable`, `Comparator`,
  `Function`, `Supplier`, `Consumer`, `Predicate`) used by lambdas

**Two run modes**
- Interpreted directly by `dragon`
- Compiled to a standalone native binary with `dragon -c ... --native`

## What it doesn't do

No JIT, no real bytecode verifier, no classfile hierarchy/security
checking, no true OS-level threading or synchronization, no networking or
filesystem-heavy `java.io`/`java.nio`, and reflection is limited to the
stubs listed above. It's built for correctness on ordinary programs, not
spec compliance.

## Files

| File | What it is |
|---|---|
| `djvm_helpers.dgn` | Heap allocation, GC helpers, object/string construction, constant-pool & bytecode utility functions |
| `djvm_classfile_parser.dgn` | `ClassLoaderParser` - reads `.class` bytes into constant pool / fields / methods |
| `djvm_classloader.dgn` | `ClassManager` - loads, caches, links classes; bootstrap stubs for `java.*` |
| `djvm_runtime_types.dgn` | `Frame` and `JavaThread` - call frame and thread state |
| `djvm_natives_strings.dgn` | `String` / `StringBuilder` native methods |
| `djvm_natives_lang_core.dgn` | `Object`, `Class`, `System`, `Thread`, `Enum`, basic reflection |
| `djvm_natives_io.dgn` | `PrintStream`, `Scanner` |
| `djvm_natives_numbers.dgn` | `Integer`, `Long`, `Float`, `Double`, `Boolean`, `Character` |
| `djvm_natives_math.dgn` | `Math`, `Random` |
| `djvm_natives_collections_list.dgn` | `ArrayList`, `LinkedList`, `Stack`, `PriorityQueue`, `Arrays` |
| `djvm_natives_collections_map.dgn` | `HashMap`, `HashSet`, `TreeMap`, `TreeSet`, `Collections`, `Optional` |
| `djvm_natives_exceptions.dgn` | Exception type natives |
| `djvm_natives_lambda.dgn` | Functional-interface (lambda) dispatch |
| `djvm_core.dgn` | `class DragonJVM` - fields, construction, native-registration dispatch, method invocation, exception unwinding |
| `djvm_interpreter.dgn` | **Continues** the `DragonJVM` class opened in `djvm_core.dgn` - the `executeInstruction` bytecode dispatch loop |
| `djvm_main.dgn` | Entry point (`main`) |

One structural note: `djvm_core.dgn` and `djvm_interpreter.dgn` together
form a single `class DragonJVM { ... }` - Dragon has no way to reopen or
split a class across files, so `djvm_core.dgn` deliberately doesn't close
the class brace; `djvm_interpreter.dgn` closes it. They must stay adjacent
in `build.sh`'s concatenation order. Every other file is a fully
independent, self-contained class or set of top-level functions.

The natives-registration functions (`registerStringNatives`, etc.) are
plain top-level functions taking `jvm` as an explicit parameter, called in
turn from `DragonJVM.registerStandardNatives()`. This keeps each native
library file self-contained without needing cross-file class access -
Dragon's own `import` doesn't reliably support that (`extends
module.Class` isn't parseable at all, and `new module.Class(...)` produces
broken objects under `--native`), so `build.sh` combines the files at
build time instead of relying on it.

**Edit the individual files, then always run `./build.sh` before
compiling** - don't hand-edit the generated `djvm.dgn`, it gets overwritten.

## Build & run

```sh
./build.sh                              # writes djvm.dgn
dragon djvm.dgn YourClass                # interpreted
dragon -c djvm.dgn -o djvm.exe --native  # compile native
djvm.exe YourClass
```