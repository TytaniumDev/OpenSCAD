# Shared library

Reusable OpenSCAD modules and functions used by more than one project.

## Adding a module

- One topic per file, e.g. `lib/fasteners.scad`, `lib/shapes.scad`.
- Files here only define `module`s and `function`s. No top-level geometry, so they're safe to `use`.
- Every module takes its sizes as parameters (in millimetres) and has a short comment describing them.
- Move code here when a second project needs it, not before.

## Using it from a project

Projects live two levels down, so pull a library file in with a relative path:

```openscad
use <../../lib/shapes.scad>
```

Prefer `use` over `include`: `use` imports modules and functions without running any top-level code or leaking variables into your file.
