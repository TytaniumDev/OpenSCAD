// =========================================================================
// DIAMOND MOSAIC DISPLAY STAND
// =========================================================================
// Holds a square, framed mosaic on one corner so it reads as a diamond.
// The bottom corner drops into a V-shaped cradle that leans the mosaic
// back a few degrees, and a base plate reaches out behind it so the
// leaning weight can't tip it over.
//
// Prints in one piece, base down, exactly as exported. No supports.
// =========================================================================

/* [Mosaic] */
// Side length of the square mosaic (mm)
mosaic_size = 150; // [50:1:300]

// Total thickness of the mosaic, tiles plus wood frame (mm)
mosaic_thickness = 15; // [3:0.5:40]

// Width of the wood frame border on the back of the mosaic (mm).
// The back support stays inside this so it rests on wood, not the panel.
frame_border = 15; // [5:0.5:40]

/* [Stand Shape] */
// How far the mosaic leans back from vertical (degrees).
// More tilt is more stable but shows the mosaic at more of an angle.
tilt_angle = 12; // [0:1:25]

// Length of each cradle arm, measured along the mosaic's edge (mm)
arm_length = 50; // [20:1:120]

// Height of the front lip, measured square to the mosaic's edge (mm).
// Keep it small: it covers this much of the mosaic's front face.
front_lip_height = 5; // [2:0.5:20]

// Height of the back support, measured square to the mosaic's edge (mm).
// Should be no more than frame_border so it only touches the wood.
back_support_height = 12; // [4:0.5:40]

// Thickness of the front lip (mm)
front_lip_thickness = 3; // [1.5:0.1:8]

// Thickness of the back support (mm)
back_support_thickness = 5; // [2:0.1:12]

/* [Base] */
// How far the base plate reaches behind the bottom corner (mm).
// Must be well past the mosaic's centre of gravity; an assert checks it.
base_depth_behind = 70; // [30:1:150]

// Thickness of the base plate (mm)
base_thickness = 4; // [2:0.5:10]

// Material under the lowest point of the V seat (mm)
seat_thickness = 4; // [2:0.5:10]

// Corner rounding of the base plate outline (mm)
base_corner_radius = 8; // [0:0.5:20]

/* [Fit] */
// Extra room in the slot beyond the mosaic's thickness (mm).
// Raise it if the mosaic is a tight fit; lower it if it wobbles.
slot_clearance = 1.0; // [0.2:0.1:3]

// Radius of the groove along the bottom of the V. A printed V can't be
// perfectly sharp, so this keeps the mosaic's corner from riding up on it.
corner_relief_radius = 1.5; // [0:0.1:4]

/* [Advanced] */
// Rendering resolution (number of fragments for round shapes)
$fn = 48; // [20:4:120]

/* [Display Mode] */
// Which part to render?
// - "print_layout": The stand alone, base on the bed (recommended for exporting STL)
// - "assembled": The stand with a stand-in mosaic, to check the fit
part = "print_layout"; // [print_layout, assembled]


// =========================================================================
// INTERNAL DERIVED CALCULATIONS
// =========================================================================
// "Mosaic space" is the frame the cradle is drawn in, before tilting:
//   x runs across the mosaic, y runs through its thickness (front face
//   at y = 0, viewer on the -y side), z runs up the diamond. The bottom
//   corner of the mosaic sits at the origin.

// Half the width of the cradle. The arms run at 45 degrees, so an arm of
// length L along the edge spans L / sqrt(2) sideways and upward.
arm_reach = arm_length / sqrt(2);

// Heights measured square to an edge become vertical rises in mosaic
// space by dividing by cos(45).
front_lip_rise = front_lip_height / cos(45);
back_support_rise = back_support_height / cos(45);

// Slot through the thickness, centred on the mosaic
slot_front_y = -slot_clearance / 2;
slot_back_y = mosaic_thickness + slot_clearance / 2;

// Front and back faces of the whole cradle
cradle_front_y = slot_front_y - front_lip_thickness;
cradle_back_y = slot_back_y + back_support_thickness;

// Tilting back lowers the back of the seat by depth * sin(tilt).
// Lift the cradle so even that lowest point keeps seat_thickness under it.
cradle_lift = seat_thickness + corner_relief_radius
    + cradle_back_y * sin(tilt_angle);

// How far the cradle profile reaches downward in mosaic space. Anything
// below the bed is trimmed off, so this only has to be deep enough.
cradle_depth_below = cradle_lift / cos(tilt_angle) + cradle_back_y + 1;

// Mosaic's centre of gravity, horizontally behind the bottom corner.
// It sits half a diagonal up the mosaic and half its thickness in.
mosaic_diagonal = mosaic_size * sqrt(2);
centre_of_gravity_y = (mosaic_thickness / 2) * cos(tilt_angle)
    + (mosaic_diagonal / 2) * sin(tilt_angle);

// Keep the base this much farther back than the centre of gravity, so a
// light bump from the front doesn't push it over the back edge.
stability_margin = 15;

// Sanity checks for impossible or unstable parameter combinations
assert(back_support_height <= frame_border,
    "back_support_height is taller than frame_border, so it would press on the recessed back panel instead of the wood frame.");
assert(arm_length < mosaic_size,
    "arm_length must be shorter than the mosaic's edge.");
assert(base_depth_behind >= centre_of_gravity_y + stability_margin,
    str("base_depth_behind is too short to keep the mosaic from tipping backwards. Use at least ",
        ceil(centre_of_gravity_y + stability_margin), " mm."));
assert(base_corner_radius < arm_reach,
    "base_corner_radius is too large for the base plate.");


// =========================================================================
// MAIN ENTRY POINT
// =========================================================================

if (part == "print_layout") {
    stand();
}
else if (part == "assembled") {
    stand();
    // Drawn as a solid (not with %) so it shows up in PNG previews, which
    // render with CGAL and skip background parts.
    color("SteelBlue")
    place_tilted()
    mosaic_stand_in();
}


// =========================================================================
// COMPONENT MODULES
// =========================================================================

// --- WHOLE STAND ---
// Tilted cradle plus base plate, trimmed flat at the bed (z = 0).
module stand() {
    // intersection() keeps only what's inside both shapes; here it slices
    // off everything below the bed so the bottom is perfectly flat.
    intersection() {
        union() {
            place_tilted() cradle();
            base_plate();
        }
        bed_slab();
    }
}

// --- TILT AND LIFT ---
// Moves anything drawn in mosaic space into its displayed position.
// Rotating about x by -tilt_angle tips the top of the mosaic back (+y).
module place_tilted() {
    translate([0, 0, cradle_lift])
    rotate([-tilt_angle, 0, 0])
    children();
}

// --- CRADLE (mosaic space) ---
// A V-shaped seat with a short lip in front and a taller support behind,
// minus the slot the mosaic drops into and a relief groove at the V.
module cradle() {
    difference() {
        union() {
            // Seat under the mosaic, across the full depth
            translate([0, cradle_back_y, 0])
            cradle_slice(rise = 0, thickness = cradle_back_y - cradle_front_y);

            // Front lip
            translate([0, slot_front_y, 0])
            cradle_slice(rise = front_lip_rise, thickness = front_lip_thickness);

            // Back support
            translate([0, cradle_back_y, 0])
            cradle_slice(rise = back_support_rise, thickness = back_support_thickness);
        }
        corner_relief();
    }
}

// --- ONE SLICE OF THE CRADLE (mosaic space) ---
// Extrudes cradle_profile() through the thickness, ending at y = 0.
// linear_extrude() grows along +z, so rotate([90, 0, 0]) turns that
// into growing along -y; translate the result to place it.
module cradle_slice(rise, thickness) {
    rotate([90, 0, 0])
    linear_extrude(height = thickness)
    cradle_profile(rise);
}

// --- CRADLE PROFILE (2D) ---
// A block with a 90-degree V cut into its top. The V's sides follow the
// mosaic's two bottom edges; `rise` raises the V to make a lip.
module cradle_profile(rise) {
    polygon([
        [-arm_reach, arm_reach + rise],
        [0, rise],
        [arm_reach, arm_reach + rise],
        [arm_reach, -cradle_depth_below],
        [-arm_reach, -cradle_depth_below]
    ]);
}

// --- CORNER RELIEF (mosaic space) ---
// A rod along the bottom of the V, only as long as the slot so it doesn't
// tunnel through the lip or the back support. rotate([-90, 0, 0]) turns
// the cylinder from pointing up (+z) to pointing back (+y).
module corner_relief() {
    if (corner_relief_radius > 0) {
        translate([0, slot_front_y, 0])
        rotate([-90, 0, 0])
        cylinder(r = corner_relief_radius, h = slot_back_y - slot_front_y);
    }
}

// --- BASE PLATE ---
// The cradle's footprint stretched back to base_depth_behind, with
// rounded corners. projection() flattens a 3D shape to its 2D shadow on
// the bed; hull() wraps that and the back rectangle in one outline.
// offset(delta = -r) then offset(r = +r) rounds the convex corners
// without changing the overall size.
module base_plate() {
    linear_extrude(height = base_thickness)
    offset(r = base_corner_radius)
    offset(delta = -base_corner_radius)
    hull() {
        projection() place_tilted() cradle();
        translate([-arm_reach, 0])
        square([arm_reach * 2, base_depth_behind]);
    }
}

// --- BED SLAB ---
// A big block sitting on z = 0, used to trim the stand flat.
module bed_slab() {
    slab_size = (mosaic_size + base_depth_behind) * 4;
    translate([-slab_size / 2, -slab_size / 2, 0])
    cube(slab_size);
}

// --- MOSAIC STAND-IN (mosaic space) ---
// The square mosaic turned 45 degrees onto its corner, for the assembled view.
module mosaic_stand_in() {
    translate([0, mosaic_thickness, 0])
    rotate([90, 0, 0])
    linear_extrude(height = mosaic_thickness)
    rotate(45)
    square(mosaic_size);
}
