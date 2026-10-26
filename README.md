# OpenSCAD Models

A collection of my parametric 3D models, written in [OpenSCAD](https://openscad.org/).

## Projects

| Project | Description |
| --- | --- |
| [Bag clip](projects/bag_clip/) | Springless two-piece sliding bag sealer (chip clip) that prints flat with no supports. |
| [Cat feeder funnel](projects/cat_feeder_funnel/) | Wide, anti-jam funnel that sits in the top of a PetLibro automatic feeder. Prints without supports. |
| [Mosaic stand](projects/mosaic_stand/) | Desk stand that shows a square framed mosaic on its corner as a diamond, leaning back for stability. Prints without supports. |

## Layout

```
projects/<name>/       One folder per model
  <name>.scad          Main, parametric source (open this in OpenSCAD)
  <name>.stl           Exported, print-ready mesh
  README.md            What it is, parameters, print settings
  docs/                Render images used by the README
lib/                   Reusable modules shared across projects
scripts/               Render helpers (STL export, PNG previews)
```

## Rendering

Open any `projects/<name>/<name>.scad` file in OpenSCAD and use the Customizer panel to tweak parameters.

From the command line:

```sh
scripts/render.sh              # re-export every project's STL
scripts/render.sh bag_clip     # re-export one project
scripts/render.sh --check      # make sure everything renders, without writing files
scripts/preview.sh bag_clip    # write a PNG preview to build/bag_clip.png
```

Every pull request runs `scripts/render.sh --check` in GitHub Actions, so a model that fails to render can't be merged unnoticed.

## License

[MIT](LICENSE)
