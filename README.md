# Masonry
*Functions for composing asset pipelines*

[![Hippocratic License HL3-CORE](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-CORE&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/core.html)

Masonry is a toolkit for reading, writing, and processing files. It relies on composing reactors—asynchronous iterators—to handle files efficiently.

## Features

* Compose asset pipelines using asynchronous iterators.
* Process files efficiently without iterating through them multiple times.
* Support building and transforming files via robust utilities.
* Integrate easily with task runners like [Genie](https://github.com/dashkite/genie#genie).

## Installation

```bash
pnpm install @dashkite/masonry
```

## Usage

Here is a common scenario compiling CoffeeScript files:

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

## Other Resources

- [Recipes](docs/recipes.md)
- [Reference](docs/reference.md)
- [Technical Notes](docs/technical-notes.md)
- [Testing](docs/testing.md)
