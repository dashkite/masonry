# Reference

## $start$

$start: (fx: iterable<function>) \rightarrow function$

Takes a list of functions that, together, yield a reactor, and waits on each value in turn.

## $concurrently$

$concurrently: (fx: iterable<function>) \rightarrow function$

Takes a list of functions and executes them concurrently.

## $glob$

$glob: (patterns: array<string>, options: object) \rightarrow function$

Returns a reactor that produces paths matching the given glob patterns.

## $read$

$read: (context: object) \rightarrow promise$

Reads each file as text.

## $readText$

$readText: (context: object) \rightarrow promise$

Reads each file as text. Alias for `read`.

## $readBytes$

$readBytes: (context: object) \rightarrow promise$

Reads each file as a buffer.

## $tr$

$tr: (transform: function | array<function>) \rightarrow function$

Invokes the processor for each file. If given an array, calls each function in turn with the output from the previous function.

## $transform$

$transform: (transform: function | array<function>) \rightarrow function$

Alias for `tr`.

## $attempt$

$attempt: (transform: function) \rightarrow function$

Safely executes a transform, returning the original input if the transform fails and logging a warning.

## $extension$

$extension: (extension: string) \rightarrow function$

Sets the extension of the context.

## $write$

$write: (target: string) \rightarrow function$

Writes each file out based on the relative path to the provided target directory.

## $copy$

$copy: (target: string) \rightarrow function$

Copies a file from one directory to another using a stream.

## $changed$

$changed: (target: string, fx: iterable<function>) \rightarrow function$

Executes the given functions only if the source file has been modified more recently than the target file.

## $clean$

$clean: (target: string) \rightarrow function$

Removes a directory. Useful for cleaning files from the previous build.
