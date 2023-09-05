# Masonry

Functions for reading, writing, and processing files, also known as asset pipelines.

```coffeescript
import * as M from "@dashkite/masonry"
import {coffee} from "@dashkite/masonry-coffee"

do M.start [
  M.glob [ "{src,test}/**/*.coffee" ]
  M.read
  M.tr coffee
  M.extension ".js"
  M.write "build"
]
```

Use with [Genie][] to run build functions using a task runner command-line interface.

[Genie]://github.com/dashkite/genie#genie

## Quick Reference

Masonry is based on composing _reactors_, also known as asynchronous iterators. The `start` function takes a list of functions that, together, yield a reactor, and waits on each value in turn. What this means is that we never iterate through a list of files more than once within a given function, even though it may appear otherwise. For all intents and purposes, you can imagine the reactors, like `read` and `write` as simply operating on a single file.

### Reactors

| Name      | Arguments         | Description                                                  |
| --------- | ----------------- | ------------------------------------------------------------ |
| glob      | pattern           | Given a list of glob patterns and a base directory, returns a reactor that produces paths that match the patterns. |
| read      | -                 | Reads each file. Typically used after `glob`.                |
| tr        | function or array | Given a function that takes a context object, invokes the processor for each file. Typically used after `read` to compile or translate a file. If given an array, will call each function in turn with the output from the previous function. |
| extension | text              | Sets the extension of the context, which is used by `write` to determine the extension for the output file. |
| write     | directory         | Given a directory, writes each file out based on the relative path. |
| copy      | directory         | May be used in place of `read` and `write` when you simply want to copy a file from one directory to another using a stream. |
| set       | name, setter      | Sets the property _name_ on the build context using the given function, which accepts the build context as an argument. |

### Utilities

Masonry provides standalone utility functions for convenience

| Name  | Arguments     | Description                                                  |
| ----- | ------------- | ------------------------------------------------------------ |
| rm    | directory     | Removes a directory. Useful for cleaning files from the previous build. |
| watch | path, handler | Watch a directory or file and call a handler in response to changes. |
