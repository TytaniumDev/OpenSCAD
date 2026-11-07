// =========================================================================
// PHOTOSYNTHESIS SEED TOKEN BOX
// =========================================================================
// A tiny box for the seed tokens from the board game Photosynthesis.
// The lid is a flat cap that covers the whole top, with a dovetail
// tongue underneath that slides along grooves in the walls. It clicks
// shut over a small detent bump. A sprouting seed is engraved in the cap.
//
// Because the cap covers the walls too, the closed top is one smooth
// surface; the only seam runs around the outside edge.
//
// Prints as two parts, both flat on the bed with no supports:
//   - Box: open side up.
//   - Lid: upside down, seed side on the bed.
// =========================================================================

/* [Interior] */
// Inside size across the box, left to right (mm)
interior_width = 28; // [10:0.5:80]

// Inside size front to back, along the lid's sliding direction (mm)
interior_length = 28; // [10:0.5:80]

// Inside height, floor to underside of the lid (mm)
interior_height = 15; // [5:0.5:60]

// Radius of the inside vertical corners (mm). The tokens are round, so
// rounded corners cost no usable space.
interior_corner_radius = 2; // [0.5:0.1:6]

// Radius of the fillet where the inside walls meet the floor (mm).
// Makes it easier to scoop the last token out.
interior_floor_fillet = 1.5; // [0.5:0.1:4]

/* [Walls] */
// Thickness of the side walls (mm)
wall_thickness = 2; // [1.2:0.1:4]

// Thickness of the floor (mm)
floor_thickness = 1.2; // [0.6:0.1:3]

// Rounding of the outside top and bottom edges (mm)
outer_edge_radius = 1; // [0.2:0.1:2]

/* [Lid] */
// Thickness of the flat cap that forms the top of the box (mm)
lid_cap_thickness = 1.2; // [0.8:0.1:3]

// Thickness of the dovetail tongue under the cap (mm)
lid_tongue_thickness = 1; // [0.6:0.1:3]

// How far the dovetail groove cuts into each wall, at its deepest (mm).
// Deeper holds the lid more firmly but leaves the wall thinner.
dovetail_depth = 0.8; // [0.4:0.1:2]

/* [Seed Engraving] */
// Overall height of the seed design on the lid (mm)
seed_size = 18; // [8:0.5:26]

// How deep the seed is cut into the cap (mm)
seed_depth = 0.6; // [0.2:0.1:1.5]

/* [Fit] */
// Gap between the lid and its dovetail groove (mm).
// Raise it if the lid binds; lower it if the lid rattles.
slide_clearance = 0.2; // [0.05:0.05:0.5]

// Height of the bump on the front wall that holds the lid shut (mm).
// Set to 0 to turn the click off.
detent_height = 0.25; // [0:0.05:0.5]

// Radius of the sphere the detent bump is cut from (mm)
detent_radius = 1; // [0.6:0.1:2]

/* [Advanced] */
// Rendering resolution (number of fragments for round shapes)
$fn = 48; // [20:4:120]

/* [Display Mode] */
// Which part to render?
// - "print_layout": Box and lid side by side, ready to print (recommended for exporting STL)
// - "assembled": Lid slid into the box, to check the fit
// - "box": Box only
// - "lid": Lid only, seed side up
part = "print_layout"; // [print_layout, assembled, box, lid]

// How far the lid is slid open in the assembled view (mm)
assembled_lid_open = 0; // [0:1:40]


// =========================================================================
// INTERNAL DERIVED CALCULATIONS
// =========================================================================
// The box is centred on the origin in x and y, with its bottom at z = 0.
// The lid slides in from the front (-y) toward the back (+y).

outer_width = interior_width + 2 * wall_thickness;
outer_length = interior_length + 2 * wall_thickness;

// Outside corners follow the inside ones, so the wall stays even all round.
outer_corner_radius = interior_corner_radius + wall_thickness;

// Heights, bottom to top:
//   ledge_z:    top of the interior. The dovetail groove starts here, and
//               the front wall stops here so the tongue can slide over it.
//   wall_top_z: top of the side and back walls. The cap rests on these.
//   box_height: top of the cap, the very top of the closed box.
ledge_z = floor_thickness + interior_height;
wall_top_z = ledge_z + lid_tongue_thickness;
box_height = wall_top_z + lid_cap_thickness;

// The cap rests on the wall tops, so the tongue is made slide_clearance
// shorter than its groove. That keeps the tongue off the groove floor
// and leaves the cap as the only thing setting the lid's height, which
// is what keeps the top flush.
tongue_bottom_z = ledge_z + slide_clearance;

// Thinnest bit of wall, behind the deepest part of the dovetail groove.
wall_behind_groove = wall_thickness - dovetail_depth;

// The dovetail's 45-degree slope pulls the groove back in by one
// lid_tongue_thickness from bottom to top. This is how far the top of
// the groove reaches past the inside face of the wall (negative =
// overhangs the interior).
groove_top_offset = dovetail_depth - lid_tongue_thickness;

// Centre of the detent bump: on top of the front wall, halfway through it.
detent_y = -(interior_length / 2 + wall_thickness / 2);

// Radius of the dimple where it meets the tongue's underside. The dimple
// is the bump's sphere lifted by slide_clearance; this must stay inside
// the front wall or it would notch the lid's front edge.
dimple_drop = detent_radius - detent_height - slide_clearance;
dimple_footprint_radius = sqrt(detent_radius * detent_radius
    - max(dimple_drop, 0) * max(dimple_drop, 0));

// Seed artwork is drawn 18 mm tall, then scaled to seed_size.
seed_drawn_size = 18;

// Sanity checks for impossible parameter combinations
assert(wall_behind_groove >= 0.8,
    "dovetail_depth leaves less than 0.8 mm of wall behind the groove. Make the walls thicker or the groove shallower.");
assert(interior_corner_radius + groove_top_offset > 0,
    "lid_tongue_thickness is too large for interior_corner_radius and dovetail_depth: the top of the dovetail would lose its rounded corners.");
assert(slide_clearance < lid_tongue_thickness,
    "slide_clearance must be smaller than lid_tongue_thickness.");
assert(outer_edge_radius < lid_cap_thickness,
    "outer_edge_radius must be smaller than lid_cap_thickness so the rounding stays on the cap, above the seam.");
assert(seed_depth < lid_cap_thickness,
    "seed_depth must be smaller than lid_cap_thickness or the seed cuts through the cap.");
assert(outer_edge_radius < outer_corner_radius,
    "outer_edge_radius must be smaller than the outside corner radius.");
assert(interior_floor_fillet < interior_corner_radius,
    "interior_floor_fillet must be smaller than interior_corner_radius.");
assert(detent_height < detent_radius,
    "detent_height must be smaller than detent_radius.");
assert(detent_height == 0 || dimple_footprint_radius < wall_thickness / 2,
    "The detent is too big for the front wall: lower detent_radius or detent_height.");
assert(seed_size <= min(interior_width, interior_length) - 2,
    "seed_size is too big to fit on the lid.");


// =========================================================================
// MAIN ENTRY POINT
// =========================================================================

if (part == "print_layout") {
    box();
    translate([outer_width + 5, 0, 0])
    lid_print_orientation();
}
else if (part == "assembled") {
    color("Peru") box();
    color("ForestGreen")
    translate([0, -assembled_lid_open, 0])
    lid();
}
else if (part == "box") {
    box();
}
else if (part == "lid") {
    lid_print_orientation();
}


// =========================================================================
// COMPONENT MODULES
// =========================================================================

// --- BOX ---
// The closed shape below the cap, hollowed out, with the lid's groove
// cut into the top and the detent bump added on the front wall.
module box() {
    difference() {
        // intersection() keeps only what's inside both shapes: here, the
        // part of the shell below the wall tops.
        intersection() {
            closed_shape();
            below_z(wall_top_z);
        }
        cavity();
        lid_slot(grow = 0, bottom_z = ledge_z, top_z = wall_top_z + 0.1);
    }
    detent_bump();
}

// --- LID (closed position) ---
// The cap is the top slice of the same closed shape the box is cut
// from, so the two meet in a flush seam all round. The tongue is the
// dovetail groove shrunk by slide_clearance on every side, clipped to
// the closed shape so its front picks up the box's rounded corners.
module lid() {
    difference() {
        union() {
            difference() {
                closed_shape();
                below_z(wall_top_z);
            }
            intersection() {
                closed_shape();
                lid_slot(grow = -slide_clearance,
                    bottom_z = tongue_bottom_z, top_z = wall_top_z + 0.1);
            }
        }
        detent_dimple();
        seed_engraving();
    }
}

// --- LID, AS PRINTED ---
// Flipped upside down (rotate 180 degrees about x) so the cap lies flat
// on the bed and the tongue's 45-degree sides lean outward as they rise,
// which prints without supports. Then lowered so the cap's top is at z = 0.
module lid_print_orientation() {
    translate([0, 0, box_height])
    rotate([180, 0, 0])
    lid();
}

// --- CLOSED SHAPE ---
// The rounded outer shape of the whole closed box. The box and the lid
// are both cut from it, so they line up exactly.
module closed_shape() {
    rounded_box([outer_width, outer_length, box_height],
        outer_corner_radius, outer_edge_radius);
}

// --- BELOW Z ---
// A big block filling everything below height z, used to split the
// closed shape into box and cap.
module below_z(z) {
    size = 4 * max(outer_width, outer_length, box_height);
    translate([-size / 2, -size / 2, z - size])
    cube(size);
}

// --- CAVITY ---
// The inside of the box. It runs up past the top so only its bottom
// edges get rounded, which gives the floor fillet.
module cavity() {
    translate([0, 0, floor_thickness])
    rounded_box([interior_width, interior_length, box_height],
        interior_corner_radius, interior_floor_fillet);
}

// --- LID SLOT ---
// The dovetail-shaped space the tongue slides along. At the ledge it
// reaches dovetail_depth into the walls, then leans in at 45 degrees as
// it rises, so the walls overhang the tongue's edges and hold it down.
// A 45-degree overhang prints cleanly without supports.
//
// hull() of a thin slice at the bottom and a narrower one at the top
// fills in the sloped sides between them.
//   grow:     widens (or with a negative value, shrinks) the slot on every
//             side. The box cuts with 0; the tongue is made with
//             -slide_clearance.
//   bottom_z: where the slot starts.
//   top_z:    where the slot stops.
module lid_slot(grow, bottom_z, top_z) {
    slice = 0.01;
    hull() {
        translate([0, 0, bottom_z])
        linear_extrude(height = slice)
        lid_slot_outline(lid_slot_reach(grow, bottom_z));

        translate([0, 0, top_z - slice])
        linear_extrude(height = slice)
        lid_slot_outline(lid_slot_reach(grow, top_z));
    }
}

// How far the slot reaches past the inside face of the wall at height z.
// The 45-degree slope means it loses 1 mm of reach for every 1 mm of rise.
function lid_slot_reach(grow, z) = dovetail_depth + grow - (z - ledge_z);

// --- LID SLOT OUTLINE (2D) ---
// The interior's rounded rectangle, pushed outward by `reach`, and
// stretched forward past the front wall so the lid can slide in.
module lid_slot_outline(reach) {
    hull() {
        rounded_rect([interior_width + 2 * reach, interior_length + 2 * reach],
            interior_corner_radius + reach);
        translate([0, -outer_length])
        rounded_rect([interior_width + 2 * reach, interior_length + 2 * reach],
            interior_corner_radius + reach);
    }
}

// --- DETENT BUMP ---
// A low dome on top of the front wall. The lid flexes over it and drops
// into a matching dimple when fully closed. It's the top slice of a
// sphere: intersection() with a block keeps only the part above the ledge.
module detent_bump() {
    if (detent_height > 0) {
        intersection() {
            detent_sphere(lift = 0);
            translate([-detent_radius, detent_y - detent_radius, ledge_z - 0.01])
            cube([detent_radius * 2, detent_radius * 2, detent_radius]);
        }
    }
}

// --- DETENT DIMPLE ---
// The matching hollow under the lid: the bump's sphere lifted by
// slide_clearance, so the dimple is a little deeper than the bump is tall.
module detent_dimple() {
    if (detent_height > 0) {
        detent_sphere(lift = slide_clearance);
    }
}

// --- DETENT SPHERE ---
// Sphere positioned so its top pokes detent_height (plus `lift`) above
// the underside of the tongue.
module detent_sphere(lift) {
    translate([0, detent_y, tongue_bottom_z + detent_height + lift - detent_radius])
    sphere(r = detent_radius);
}

// --- SEED ENGRAVING ---
// The seed artwork, cut seed_depth into the top of the cap. It starts
// 0.1 mm above the top so the cut doesn't leave a coincident face.
module seed_engraving() {
    translate([0, 0, box_height - seed_depth])
    linear_extrude(height = seed_depth + 0.1)
    scale(seed_size / seed_drawn_size)
    seed_2d();
}

// --- SEED ARTWORK (2D) ---
// A teardrop seed with a stem and two leaves sprouting from its tip.
// Drawn about 18 mm tall, centred on the origin.
module seed_2d() {
    stem_width = 1.2;
    stem_top = 5;
    translate([0, -1]) {
        // Seed body: hull() of a big and a small circle makes a teardrop.
        hull() {
            translate([0, -4]) circle(r = 4);
            translate([0, 1.5]) circle(r = 1);
        }
        // Stem
        translate([-stem_width / 2, 1])
        square([stem_width, stem_top - 1]);
        // Leaves, angled up and out from the top of the stem
        for (angle = [35, 145]) {
            translate([0, stem_top])
            rotate(angle)
            leaf_2d(length = 7, width = 3.4);
        }
    }
}

// --- LEAF (2D) ---
// A pointed leaf lying along +x, with its base at the origin.
// It's the overlap of two big circles (a "vesca" shape). For a lens of
// a given length and width, the circles' radius r and offset d satisfy
// r - d = width / 2 and (r + d)(r - d) = (length / 2)^2.
module leaf_2d(length, width) {
    half_w = width / 2;
    sum = (length / 2) * (length / 2) / half_w;
    r = (sum + half_w) / 2;
    d = (sum - half_w) / 2;
    translate([length / 2, 0])
    intersection() {
        translate([0, -d]) circle(r = r, $fn = $fn * 2);
        translate([0, d]) circle(r = r, $fn = $fn * 2);
    }
}


// =========================================================================
// SHAPE HELPERS
// =========================================================================
// Generic shapes with every size passed in. Candidates for lib/ once a
// second project needs them.

// --- ROUNDED RECTANGLE (2D) ---
// size: [x, y], centred on the origin. r: corner radius.
// offset(r = ...) grows a shape and rounds its corners, so growing a
// smaller square by r gives exactly `size` with round corners.
module rounded_rect(size, r) {
    offset(r = r)
    square([size[0] - 2 * r, size[1] - 2 * r], center = true);
}

// --- ROUNDED BOX ---
// size: [x, y, z], centred in x and y, bottom at z = 0.
// corner_r: radius of the vertical corners.
// edge_r:   radius of the top and bottom edges (must be < corner_r).
// Each corner is a little donut (rotate_extrude spins a 2D shape around
// the z axis); hull() of the eight donuts wraps them in a smooth box.
// rotate_extrude() refuses shapes that cross the axis, so the circle is
// trimmed to x >= 0 first. Only its outer side matters to the hull.
module rounded_box(size, corner_r, edge_r) {
    hull() {
        for (x = [-1, 1], y = [-1, 1], z = [edge_r, size[2] - edge_r]) {
            translate([x * (size[0] / 2 - corner_r), y * (size[1] / 2 - corner_r), z])
            rotate_extrude()
            intersection() {
                translate([corner_r - edge_r, 0]) circle(r = edge_r);
                translate([0, -edge_r]) square([corner_r, 2 * edge_r]);
            }
        }
    }
}
