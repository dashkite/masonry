# Technical Notes

### Asynchronous Iterators

Masonry is built on the concept of composing reactors, which are essentially asynchronous iterators. This architecture ensures that we process a stream of files efficiently, rather than looping over an entire collection of files repeatedly.

### Transform Composition

The `tr` (or `transform`) function allows for both single and multiple transform functions. When an array of functions is provided, Masonry automatically pipelines the output of one function to the input of the next.
