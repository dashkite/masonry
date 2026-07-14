# Recipes

## Compiling CoffeeScript Files

This guide explains how to set up a pipeline to read CoffeeScript files, compile them, and write the output to a build directory.

Masonry enables this task by composing reactors. You provide a list of patterns to match files, read them, transform them, and write them out.

```coffeescript
import * as M from "@dashkite/masonry"
# import external processor
import {coffee} from "@dashkite/masonry-coffee"

do M.start [
  M.glob [ "{src,test}/**/*.coffee" ]
  M.read
  M.tr coffee
  M.extension ".js"
  M.write "build"
]
```

1. Utilize `M.glob` to find the source files.
2. Fetch the file contents using the `M.read` reactor.
3. Apply the compilation transformation via `M.tr`.
4. Update the output extension using `M.extension`.
5. Write the final result to the build directory using `M.write`.

## Performing Incremental Builds

This guide explains how to process only the files that have changed since the last build, saving time on large projects.

Masonry enables incremental builds through the `M.changed` function, which wraps your processing steps. It compares the source file's modification time against the target file.

```coffeescript
import * as M from "@dashkite/masonry"
# import external processor
import {coffee} from "@dashkite/masonry-coffee"

do M.start [
  M.glob [ "{src,test}/**/*.coffee" ]
  M.changed "build", [
    M.read
    M.tr coffee
    M.extension ".js"
    M.write "build"
  ]
]
```

1. Utilize `M.glob` to find the source files.
2. Wrap the processing steps with `M.changed`, providing the target build directory.
3. Masonry checks if the source file is newer than the target file.
4. If changed, Masonry proceeds to read, transform, and write the file.

## Copying Static Assets

This guide details how to move static assets from a source directory to a target directory without applying any transformations.

Masonry provides the `M.copy` reactor as a direct path to copy files, bypassing the read and write stages.

```coffeescript
import * as M from "@dashkite/masonry"

do M.start [
  M.glob [ "public/**/*" ]
  M.copy "build/public"
]
```

1. Locate the static files using `M.glob`.
2. Copy the files directly to the destination using `M.copy`.

## Cleaning the Build Directory

This guide demonstrates how to remove old artifacts from an output directory before initiating a fresh pipeline.

Masonry handles directory deletion natively via `M.clean`. You can execute this as a standalone operation before your main pipelines run.

```coffeescript
import * as M from "@dashkite/masonry"

do M.clean "build"
```

1. Invoke `M.clean` with the target directory path.
2. Wait for the operation to complete to ensure the directory is empty.

## Running Multiple Pipelines Concurrently

This guide illustrates how to execute several independent build pipelines at the same time.

Masonry enables parallel execution through `M.concurrently`, which accepts an array of initialized pipelines and resolves when all have completed.

```coffeescript
import * as M from "@dashkite/masonry"
# import external processor
import {coffee} from "@dashkite/masonry-coffee"

do M.concurrently [
  M.start [
    M.glob [ "{src,test}/**/*.coffee" ]
    M.read
    M.tr coffee
    M.extension ".js"
    M.write "build"
  ]
  M.start [
    M.glob [ "public/**/*" ]
    M.copy "build/public"
  ]
]
```

1. Define each individual pipeline using `M.start`.
2. Group the pipelines within an array.
3. Pass the array to `M.concurrently` to execute them in parallel.

## Composing Multiple Transforms

This guide explains how to pass a single file through multiple processing stages sequentially.

Masonry allows the `M.tr` reactor to accept an array of transform functions. It automatically pipes the output of one transform as the input to the next.

```coffeescript
import * as M from "@dashkite/masonry"
# import external processors
import {coffee} from "@dashkite/masonry-coffee"
import {minify} from "@dashkite/masonry-minify"

do M.start [
  M.glob [ "src/**/*.coffee" ]
  M.read
  M.tr [
    coffee
    minify
  ]
  M.extension ".js"
  M.write "build"
]
```

1. Find and read the source files.
2. Pass an array of functions to `M.tr`.
3. Masonry executes each function in turn, chaining the outputs.
4. Update the extension and write the final output.

## Handling Safe Transformations

This guide details how to prevent a pipeline from crashing when a specific transform encounters an error.

Masonry provides `M.attempt`, which wraps a single transform. If the transform throws an error, it logs the error and returns the original input, allowing the pipeline to continue.

```coffeescript
import * as M from "@dashkite/masonry"
# import external processor
import {riskyTransform} from "@dashkite/masonry-risky"

do M.start [
  M.glob [ "src/**/*.txt" ]
  M.read
  M.attempt riskyTransform
  M.write "build"
]
```

1. Find and read the source files.
2. Wrap the error-prone transform with `M.attempt`.
3. If an error occurs, the original input is preserved and a warning is logged.
4. Write the resulting output to the target directory.
