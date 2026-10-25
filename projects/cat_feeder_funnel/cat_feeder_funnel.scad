// =========================================================================
// CAT FEEDER FUNNEL (PETLIBRO AUTOMATIC FEEDER)
// =========================================================================
// A wide funnel for pouring kibble into the top of a PetLibro feeder.
// The narrow neck slides snugly into the feeder's food container and is
// extra deep so the funnel stays put while you pour.
//
// Prints upright (neck on the bed, wide end up) with no supports: every
// surface leans out at most `wall_angle` degrees from vertical.
//
// Anti-jam features:
// - Steep walls (default 40 degrees from vertical), well past the angle at
//   which kibble stops sliding.
// - A smooth, rounded throat where the cone meets the neck, so there is no
//   ledge for kibble to bridge across.
// - A straight (never narrowing) neck, so kibble isn't squeezed on the way out.
//
// Every edge is rounded: the wall is drawn as a "stroke" of circles along
// a centreline, so its ends are naturally half-round.
// =========================================================================

/* [Feeder Fit] */
// Diameter of the opening at the top of the feeder's food container (mm)
container_opening = 110; // [60:0.5:200]

// Gap between the neck and the opening, across the diameter (mm).
// Smaller = snugger. Increase if the neck won't go in.
neck_clearance = 0.6; // [0:0.1:3]

// How far the neck reaches down into the container (mm)
neck_depth = 30; // [10:1:80]

/* [Funnel Shape] */
// Outer diameter of the wide top (mm). The Bambu Lab X1C bed is 256 mm,
// so 250 mm is the largest that leaves a small margin.
top_diameter = 250; // [120:1:256]

// Wall lean from vertical (degrees). Must be 45 or less to print without
// supports. Lower = steeper walls, less jamming, but a taller funnel.
wall_angle = 40; // [20:1:45]

// Wall thickness (mm). Also sets how round the top rim and neck edge are.
wall_thickness = 2.4; // [1.2:0.1:5]

// Radius of the rounded throat where the cone meets the neck (mm),
// measured to the middle of the wall. Bigger = smoother flow.
throat_radius = 25; // [5:1:60]

/* [Printer] */
// Printer bed size (mm), used to check the funnel fits
bed_size = 256; // [150:1:400]

// Thickness shaved off the round neck edge so it sits flat on the bed (mm)
bed_flat = 0.4; // [0:0.1:1]

/* [Display] */
// What to render.
// - "print_layout": the funnel as printed (export this as the STL)
// - "cross_section": cut in half to show the wall profile
part = "print_layout"; // [print_layout, cross_section]

// Rendering resolution (number of fragments for circles)
$fn = 180; // [30:10:360]


// =========================================================================
// INTERNAL CALCULATIONS
// =========================================================================

half_wall = wall_thickness / 2;

// The wall is built around a centreline in the (radius, height) plane.
// Neck centreline radius: outer neck surface is (opening - clearance) / 2.
neck_od = container_opening - neck_clearance;
neck_center_r = neck_od / 2 - half_wall;

// Top end of the centreline: the rounded rim adds half a wall all round.
top_center_r = top_diameter / 2 - half_wall;

// Throat arc: turns the centreline from vertical to `wall_angle`.
// Its centre sits outside the neck, at the top of the straight neck.
neck_top_z = neck_depth;
arc_center = [neck_center_r + throat_radius, neck_top_z];
arc_end = arc_center + throat_radius * [-cos(wall_angle), sin(wall_angle)];

// Straight cone section from the arc end up to the rim.
cone_run = top_center_r - arc_end[0];
cone_rise = cone_run / tan(wall_angle);
top_z = arc_end[1] + cone_rise;

// Shift everything up so the flattened neck edge sits on z = 0.
z_offset = half_wall - bed_flat;
total_height = top_z + half_wall + z_offset;

echo(str("Funnel: ", top_diameter, " mm wide, ", total_height, " mm tall, neck OD ", neck_od, " mm"));

assert(wall_angle <= 45, "wall_angle above 45 degrees needs supports");
assert(top_diameter <= bed_size - 4, "top_diameter must leave at least 2 mm margin on the bed");
assert(top_diameter > neck_od + 2 * throat_radius, "top_diameter too small for the neck and throat");
assert(throat_radius > half_wall, "throat_radius must be larger than half the wall thickness");
assert(cone_run > 0, "throat_radius too large for this top_diameter");
assert(bed_flat < half_wall, "bed_flat must be less than half the wall thickness");


// =========================================================================
// MAIN ENTRY POINT
// =========================================================================

if (part == "print_layout") {
    funnel();
} else if (part == "cross_section") {
    difference() {
        funnel();
        translate([-top_diameter, -top_diameter, -1])
            cube([2 * top_diameter, top_diameter, total_height + 2]);
    }
}


// =========================================================================
// COMPONENT MODULES
// =========================================================================

// The complete funnel, sitting on the bed.
module funnel() {
    difference() {
        translate([0, 0, z_offset]) rotate_extrude() wall_profile();
        // Flatten the rounded neck edge so it sticks to the bed.
        translate([0, 0, -wall_thickness]) cylinder(h = wall_thickness, r = top_diameter);
    }
}

// 2D cross-section of the wall (x = radius, y = height), for rotate_extrude.
module wall_profile() {
    stroke(wall_centerline(), wall_thickness);
}

// Points along the middle of the wall: straight neck, throat arc, cone.
function wall_centerline() =
    let(arc_steps = max(4, ceil(wall_angle / 360 * $fn * 2)))
    concat(
        [[neck_center_r, 0]],
        [for (i = [0 : arc_steps])
            let(a = 180 - wall_angle * i / arc_steps)
            arc_center + throat_radius * [cos(a), sin(a)]],
        [[top_center_r, top_z]]
    );

// Draws a path of points as a line of the given width with round ends.
// Each pair of neighbouring points becomes the hull of two circles.
module stroke(points, width) {
    for (i = [0 : len(points) - 2])
        hull() {
            translate(points[i]) circle(d = width);
            translate(points[i + 1]) circle(d = width);
        }
}
