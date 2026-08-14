#!/bin/sh
# DJVM build script: concatenates the split .dgn source files into a single
# djvm.dgn for compilation. Dragon has no working cross-file import for
# classes, so the split files are combined at build time rather than at
# Dragon's own module-load time.
set -e
OUT="${1:-djvm.dgn}"

cat \
  djvm_helpers.dgn \
  djvm_classfile_parser.dgn \
  djvm_classloader.dgn \
  djvm_runtime_types.dgn \
  djvm_natives_strings.dgn \
  djvm_natives_lang_core.dgn \
  djvm_natives_io.dgn \
  djvm_natives_numbers.dgn \
  djvm_natives_math.dgn \
  djvm_natives_collections_list.dgn \
  djvm_natives_collections_map.dgn \
  djvm_natives_exceptions.dgn \
  djvm_natives_lambda.dgn \
  djvm_core.dgn \
  djvm_interpreter.dgn \
  djvm_main.dgn \
  > "$OUT"

echo "Built $OUT"
