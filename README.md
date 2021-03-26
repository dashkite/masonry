# Brick

Functions for reading, writing, and processing files, also known as asset pipelines.

```coffeescript
import * as b from "@dashkite/masonry"
import {coffee} from "@dashkite/masonry-coffee"

do b.start [
  b.glob [ "{src,test}/**/*.coffee" ], "."
  b.read
  b.tr coffee
  b.extension ".js"
  b.write "build"
]
```

Use with [Genie][] to run build functions using a task runner command-line interface.

[Genie]://github.com/dashkite/genie#genie

## API

Brick’s composition is based on the use of _reactors_, also known as asynchronous iterators. The `start` function takes a list of functions that, together, yield a reactor, and waits on each value in turn. What this means is that we never iterate through a list of files more than once within a given function, even though it may appear otherwise. For all intents and purposes, you can imagine the reactors, like `read` and `write` as simply operating on a single file.

### Start

#### start steps

Given a list of (possibly asynchronous) functions, composes them and returns an asynchronous function.

#### glob patterns, directory

Given a list of glob patterns and a base directory, returns a reactor that produces paths that match the patterns.

### Reactors

Each of the following functions technically takes a reactor as an argument, but we’ve omitted that, since they’re intended to be composed together, in which case, the reactor argument is passed via composition.

#### read

Reads each file. Typically used after `glob`.

#### tr processor

Given a processor function that takes a path specification and text, invokes the processor for each file. Typically used after `read` to compile or translate a file.

#### extension text

Sets the extension to be used by `write`.

#### write directory

Given a directory, writes each file out based on the relative path.

#### copy directory

May be used in place of `read` and `write` when you simply want to copy a file from one directory to another using a stream.

### Convenience Functions

These functions are intended to be used by themeslves and are included for convenience.

#### rm directory

Removes a directory. Useful for cleaning files from the previous build.

#### watch path, handler

Watch a directory or file and call a handler in response to changes.

#### server directory, options

Starts a static Web Server serving files from the given directory. Options may include:

- `fallback`: Path to file to serve if no file is found.
- `files`: Options to pass to [serve-static][]
- `port`: Which port to run the server on

[serve-static]: http://expressjs.com/en/resources/middleware/serve-static.html

#### exec command, arguments

Spawn a child process to run the given command, with the given arguments.

#### node script,  arguments

Spawn a child process to run a given Node script, with the given arguments.
