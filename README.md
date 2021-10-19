# `visibility`

This package is a reproduction of an issue with GHC's instance visibility.

## Expected Behavior

The module `Cls` defines a type class `Cls` with no methods.
The module `B` creates a datatype and provides an instance of `Cls`.

The module `A` does an empty import of `B`, and also defines a datatype and provides a `Cls` instance.
Finally, the module `C` does an import of `A`, and also defines a datatype `C` with a `Cls` instance.

The module `Lib` ties everything together - we call `reifyInstances` and print the instances out at compile-time.
This module only does an `import C ()`, and yet it is able to see `A`, `B`, and `C` as visible instances.

## What's the problem?

The problem occurs when we do the exact same thing in our test suite.
`test/Main.hs` has nearly exactly the same code as `Lib`, and yet it only sees the `Cls C` instance.

Based on everything I can find, I'd expect that *all* of these instances are visible, despite the module boundary.

## Other notes

GHC has a note on what instance visibility means:

```
Note [Instance lookup and orphan instances]
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Suppose we are compiling a module M, and we have a zillion packages
loaded, and we are looking up an instance for C (T W).  If we find a
match in module 'X' from package 'p', should be "in scope"; that is,

  is p:X in the transitive closure of modules imported from M?

The difficulty is that the "zillion packages" might include ones loaded
through earlier invocations of the GHC API, or earlier module loads in GHCi.
They might not be in the dependencies of M itself; and if not, the instances
in them should not be visible.  #2182, #8427.

There are two cases:
  * If the instance is *not an orphan*, then module X defines C, T, or W.
    And in order for those types to be involved in typechecking M, it
    must be that X is in the transitive closure of M's imports.  So we
    can use the instance.

  * If the instance *is an orphan*, the above reasoning does not apply.
    So we keep track of the set of orphan modules transitively below M;
    this is the ie_visible field of InstEnvs, of type VisibleOrphanModules.

    If module p:X is in this set, then we can use the instance, otherwise
    we can't.
```


