# Masonry

Functions for reading, writing, and processing files, also known as asset pipelines.

```coffeescript
import * as m from "@dashkite/masonry"
import {coffee} from "@dashkite/masonry/coffee"

do m.start [
  m.glob [ "{src,test}/**/*.coffee" ], "."
  m.read
  m.tr coffee
  m.extension ".js"
  m.write "build"
]
```

Use with [Genie][] to run build functions using a task runner command-line interface.

[Genie]://github.com/dashkite/genie#genie

## Quick Reference

Masonry is based on composing _reactors_, also known as asynchronous iterators. The `start` function takes a list of functions that, together, yield a reactor, and waits on each value in turn. What this means is that we never iterate through a list of files more than once within a given function, even though it may appear otherwise. For all intents and purposes, you can imagine the reactors, like `read` and `write` as simply operating on a single file.

### Reactors

| Name      | Arguments          | Description                                                  |
| --------- | ------------------ | ------------------------------------------------------------ |
| glob      | pattern, directory | Given a list of glob patterns and a base directory, returns a reactor that produces paths that match the patterns. |
| read      | -                  | Reads each file. Typically used after `glob`.                |
| tr        | function or array  | Given a function that takes a context object, invokes the processor for each file. Typically used after `read` to compile or translate a file. If given an array, will call each function in turn with the output from the previous function. |
| extension | text               | Sets the extension of the context, which is used by `write` to determine the extension for the output file. |
| write     | directory          | Given a directory, writes each file out based on the relative path. |
| copy      | directory          | May be used in place of `read` and `write` when you simply want to copy a file from one directory to another using a stream. |

### Utilities

Masonry provides standalone utility functions for convenience

| Name   | Arguments          | Description                                                  |
| ------ | ------------------ | ------------------------------------------------------------ |
| rm     | directory          | Removes a directory. Useful for cleaning files from the previous build. |
| watch  | path, handler      | Watch a directory or file and call a handler in response to changes. |
| server | directory, options | Starts a static Web Server serving files from the given directory. See below for options. |
| exec   | command, arguments | Spawn a child process to run the given command, with the given array of arguments. |
| node   | script, arguments  | Spawn a child process to run a given Node script, with the given arguments. |

#### Server Options

The `server` function takes any of the following options:

- `fallback`: Path to file to serve if no file is found.
- `files`: Options to pass to [serve-static][]
- `port`: Which port to run the server on

[serve-static]: http://expressjs.com/en/resources/middleware/serve-static.html

### Extensions

Extensions are typically used with `tr` to compile an asset.

| Name        | Arguments | Description                                                  |
| ----------- | --------- | ------------------------------------------------------------ |
| coffee      | preset    | Compiles CoffeeScript into JavaScript. See below for a description of the presets. |
| pug.render  | -         | Renders Pug into HTML. Will use `data` if set by a previous reactor function. |
| pug.compile | -         | Compiles Pug into a JavaScript module file exporting a template. |
| stylus      | -         | Renders Stylus into CSS.                                     |
| yaml        | -         | Renders YAML into JSON.                                      |
| markdown    | -         | Renders Markdown into HTML.                                  |
| text        | -         | Compiles text into a JavaScript module that returns the given input. |

#### CoffeeScript Presets

The  `coffee` extension takes a _preset_, which must be one of `browser` or `node`, corresponding to Babel `preset-env` targets:

- `import`, which sets `targets` to `esmodules: true`
- `node`, which sets `targets` to `node: "current"`

We no longer need to target specific browsers, since we're relying on [support for ES Modules](https://caniuse.com/mdn-javascript_statements_import).

#### Composing Extensions

Extensions may be composed by passing them as an array to the `tr` reactor function. For example, to make a Stylus file accessible as an ES Module, we might write:

```coffeescript
do m.start [
  m.glob [ "src/**/*.styl" ], "."
  m.read
  m.tr [ stylus, text ]
  m.extension ".js"
  m.write "build"
]
```
