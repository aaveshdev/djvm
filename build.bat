@echo off
REM DJVM build script (Windows): concatenates the split .dgn source files
REM into a single djvm.dgn for compilation. Dragon has no working cross-file
REM import for classes, so the split files are combined at build time rather
REM than at Dragon's own module-load time.

setlocal

set OUT=%1
if "%OUT%"=="" set OUT=djvm.dgn

if exist "%OUT%" del "%OUT%"

copy /b djvm_helpers.dgn ^
      + djvm_classfile_parser.dgn ^
      + djvm_classloader.dgn ^
      + djvm_runtime_types.dgn ^
      + djvm_natives_strings.dgn ^
      + djvm_natives_lang_core.dgn ^
      + djvm_natives_io.dgn ^
      + djvm_natives_numbers.dgn ^
      + djvm_natives_math.dgn ^
      + djvm_natives_collections_list.dgn ^
      + djvm_natives_collections_map.dgn ^
      + djvm_natives_exceptions.dgn ^
      + djvm_natives_lambda.dgn ^
      + djvm_core.dgn ^
      + djvm_interpreter.dgn ^
      + djvm_main.dgn ^
      "%OUT%"

echo Built %OUT%

endlocal