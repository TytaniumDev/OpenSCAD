# CLAUDE.md

This repo is a collection of Tyler's parametric OpenSCAD models. Tyler is learning OpenSCAD (background is Flutter), so explain non-obvious OpenSCAD techniques briefly in comments and PR descriptions.

## Structure

- `projects/<name>/` is one model. `<name>` is `snake_case` and the main file is `projects/<name>/<name>.scad`.
- Each project has a `README.md` (what it is, key parameters, print settings) and, optionally, `docs/` with render images.
- `lib/` holds modules shared by more than one project. See `lib/README.md`. Import with `use <../../lib/<file>.scad>`.
- `scripts/render.sh` exports STLs; `scripts/preview.sh` renders PNGs. Run either with `--help`.

## Conventions for .scad files

Follow the layout of `projects/bag_clip/bag_clip.scad`:

1. Header comment: what the model is and how it prints.
2. Customizer parameters, grouped with `/* [Section] */` headers. Each has a comment and a range hint like `// [min:step:max]`. Units are millimetres.
3. A `part` parameter selecting what to render (`print_layout`, `assembled`, and one option per part). Default to `print_layout` so exporting gives a print-ready STL.
4. Derived values in an "internal calculations" section, followed by `assert()`s that catch impossible parameter combinations.
5. Main entry point (the `if (part == ...)` block).
6. Component modules: small, single-purpose, named for what they make (`outer_shell()`, `inner_rod()`).

Other rules:

- Design for printing flat on the bed with no supports where possible; note any print orientation in the README.
- Add `0.1`–`0.2` mm overlap on cutting shapes in `difference()` to avoid coincident faces.
- Name fit tolerances explicitly (e.g. `snap_clearance`) instead of burying magic numbers.
- Keep `$fn` as a single top-level parameter.

## Verifying changes

OpenSCAD is installed in cloud sessions by `.claude/hooks/session-start.sh`.

- Always run `scripts/render.sh --check` before committing. It uses `--hardwarnings`, so warnings fail the build.
- Use `scripts/preview.sh <name> <out.png> -D 'part="assembled"'` and look at the image to check geometry. Note it renders with CGAL, so `%` (background) parts are not drawn.
- After changing a model, re-export its STL with `scripts/render.sh <name>` and commit it, so the repo always has a print-ready file.
- If render images in `docs/` are out of date after a visible change, regenerate them with `scripts/preview.sh`.

## Workflow

- Work on a branch and open a PR. CI runs the render check.
- Once CI is green, merge the PR without asking (Tyler has approved auto-merge for this repo).

## Adding a new project

1. `mkdir projects/<name>` and create `<name>.scad` following the conventions above.
2. Add a `README.md` in the project folder.
3. Add a row to the Projects table in the root `README.md`.
4. Export the STL with `scripts/render.sh <name>`.
