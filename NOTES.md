## parse_tree vs ruby_parser:

parse_tree uses a native extension and thus is faster, but isn't compatible with Ruby1.9.
ruby_parser is pure ruby, so slower but compatible with both rubies.

## Similar Tools

### [Flay](http://blog.zenspider.com/releases/2008/11/flay-version-1-0-0-has-been-released.html)

Flay analyzes ruby code for structural similarities. Tells you which bits are ripe for refactoring.

### [Flog](http://blog.zenspider.com/releases/2008/10/flog-version-1-2-0-has-been-released.html)

Informs you about poorly written code (too many dependencies, etc)

### [Roodi](http://roodi.rubyforge.org/)

Like a lint for Ruby. Performs checks like:

- AssignmentInConditionalCheck - Check for an assignment inside a conditional. It‘s probably a mistaken equality comparison.
- MethodLineCountCheck - Check that the number of lines in a method is below the threshold.

### [Diamondback Ruby](http://www.cs.umd.edu/projects/PL/druby/index.html)

Does:

Type inference: DRuby uses inference to model most of Ruby’s idioms as precisely as possible without any need for programmer intervention.
Type annotations: Methods may be given explicit type annotations with an easy to use syntax inspired by RDoc.
Dynamic checking: When necessary, methods can be type checked at runtime, using contracts to isolate and properly blame any errant code, similar to gradual typing.
Metaprogramming support: DRuby includes a combined static and dynamic analysis to precisely model dynamic meta-programming constructs, such as eval and method_missing.

[druby docs](http://www.cs.umd.edu/projects/PL/druby/manual/manual.html).

## [Laser](https://github.com/michaeledgar/laser)

[Youtube talk](http://www.youtube.com/watch?v=Uadw9fmig_k)

## Typed Scheme
This has been done years ago with Scheme. See [here](http://www.ccs.neu.edu/home/samth/typed-scheme/).
Also google for "soft typing".

Here's what [this guy](http://www.ccs.neu.edu/home/matthias/) had to say about it:

> We started with inference in 1988 (Soft Scheme) and explored it for 22 years before I gave up and moved on to explicitly and statically typed languages as a "target". Inference is way too brittle. 

## Still want to write smartcheck? Then you might want to check out druby's notes:

    http://www.cs.umd.edu/projects/PL/druby/manual/manual.html

And they have written a bunch of papers too.
