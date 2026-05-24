// =========================================================================
// PARAMETRIC SLIDING BAG CLIP (CHIP CLIP)
// =========================================================================
// A highly durable, springless, two-piece sliding bag sealer.
// Fully parameterized and optimized for 3D printing flat on the bed.
// No supports required!
// =========================================================================

/* [General Settings] */
// Total length of the bag clip (mm)
clip_length = 150; // [50:1:300]

// Diameter of the inner rod (mm). A thicker rod is stiffer and stronger.
rod_diameter = 5.5; // [3:0.1:10]

// The gap/clearance between the inner rod and the outer shell (mm).
// Adjust this based on the thickness of the bags you want to seal:
// - 0.8mm to 1.0mm: Thin plastic bags (e.g., bread bags, single-layer chip bags)
// - 1.1mm to 1.3mm: Medium bags (e.g., standard thick potato chip bags)
// - 1.4mm to 1.8mm: Thick bags (e.g., coffee bags with foil lining, pet food bags)
gap_size = 1.2; // [0.5:0.05:3.0]

// Width of the slot in the outer shell (mm).
// This must be wide enough for the folded bag to slide through.
// Typically slightly less than the rod_diameter so the rod stays captured.
slot_width = 3.5; // [2:0.1:8]

// Wall thickness of the outer shell (mm).
shell_wall_thickness = 2.4; // [1.5:0.1:4]

/* [Snap Joint Settings] */
// Length of the solid connection block at the back of the clip (mm).
back_length = 12; // [8:1:25]

// Fit clearance between the snap pin and the socket (mm).
// Lower values = tighter snap (harder to push in but very secure).
// Higher values = looser snap (easier to assemble).
snap_clearance = 0.15; // [0.05:0.05:0.5]

/* [Advanced / Detail Settings] */
// Length of the entry taper at the front (mm) to guide the bag in easily.
front_taper_length = 15; // [5:1:30]

// Rendering resolution (number of fragments for cylinders/spheres)
$fn = 60; // [20:10:120]

/* [Display Mode] */
// Which part to render?
// - "print_layout": Both parts positioned flat on the print bed (Recommended for exporting STL)
// - "assembled": Assembled view (For visual inspection of the fit)
// - "shell_only": Outer shell only
// - "rod_only": Inner rod only
part = "print_layout"; // [print_layout, assembled, shell_only, rod_only]


// =========================================================================
// INTERNAL DERIVED CALCULATIONS
// =========================================================================

// Inner bore radius of the outer shell
bore_radius = (rod_diameter / 2) + gap_size;

// Outer flat-to-flat radius of the hexagonal shell
shell_r_in = bore_radius + shell_wall_thickness;

// Outer vertex-to-vertex radius of the hexagonal shell
shell_r_out = shell_r_in / cos(30);

// Radius of the inner rod
rod_radius = rod_diameter / 2;

// Cap radius of the rod (designed to fit flush inside the outer shell recess)
cap_radius = shell_r_in - 0.5;

// Depth of the cap and the matching recess
cap_depth = 4.0;

// Rod length (slightly shorter than clip to prevent protruding at the front)
rod_length = clip_length - 1.0;


// =========================================================================
// MAIN ENTRY POINT
// =========================================================================

if (part == "print_layout") {
    // Render both parts flat on the print bed side-by-side
    outer_shell();
    
    // Position the rod parallel to the shell with some breathing room
    translate([0, shell_r_in * 2.5 + 5, 0])
    inner_rod();
}
else if (part == "assembled") {
    // Render them assembled for inspection
    // The outer shell is in its default position
    %outer_shell(); // Translucent outer shell
    
    // Slide the rod in from the back (X=0)
    inner_rod();
}
else if (part == "shell_only") {
    outer_shell();
}
else if (part == "rod_only") {
    inner_rod();
}


// =========================================================================
// COMPONENT MODULES
// =========================================================================

// --- OUTER SHELL MODULE ---
module outer_shell() {
    difference() {
        union() {
            // 1. Main Hexagonal Body (Straight Section)
            translate([0, 0, shell_r_in])
            rotate([0, 90, 0])
            rotate([0, 0, 30])
            cylinder(r = shell_r_out, h = clip_length - 5, $fn = 6);
            
            // 2. Tapered Front Nose (Chamfered Hexagon for premium look/feel)
            translate([clip_length - 5, 0, shell_r_in])
            rotate([0, 90, 0])
            rotate([0, 0, 30])
            cylinder(r1 = shell_r_out, r2 = shell_r_out - 1.2, h = 5, $fn = 6);
        }
        
        // 3. Central Bore (Hollow cavity for the rod)
        // Starts after the solid back block and goes all the way out the front
        translate([back_length, 0, shell_r_in])
        rotate([0, 90, 0])
        cylinder(r = bore_radius, h = clip_length - back_length + 1, $fn = $fn);
        
        // 4. Rod Entry Tunnel (Through the back block to let the rod slide in)
        // Has a small clearance so the rod slides smoothly
        translate([-1, 0, shell_r_in])
        rotate([0, 90, 0])
        cylinder(r = rod_radius + snap_clearance, h = back_length + 2, $fn = $fn);
        
        // 5. Cap Recess (Half-moon socket at the very back)
        // The rod cap snaps into this recess to sit flush
        translate([-0.1, 0, shell_r_in])
        rotate([0, 90, 0])
        difference() {
            cylinder(r = cap_radius + snap_clearance, h = cap_depth + 0.1, $fn = $fn);
            
            // Flatten the bottom of the recess to match the flat bottom of the shell/cap
            translate([-cap_radius - 1, -cap_radius - 1, -shell_r_in - 0.1])
            cube([(cap_radius + 1) * 2, (cap_radius + 1) * 2, shell_r_in]);
        }
        
        // 6. Longitudinal Entry Slot (At the top of the shell)
        // Allows the folded bag to slide into the bore
        translate([back_length, -slot_width / 2, shell_r_in])
        cube([clip_length - back_length + 1, slot_width, shell_r_out * 2]);
        
        // 7. Internal Entry Taper (Conical flare at the front of the bore)
        // Makes it incredibly easy to guide the bag crease into the clip
        translate([clip_length - front_taper_length, 0, shell_r_in])
        rotate([0, 90, 0])
        cylinder(r1 = bore_radius, r2 = bore_radius + 1.8, h = front_taper_length + 0.1, $fn = $fn);
        
        // 8. Snap Lock Dimple (Small recess at the top of the cap socket)
        // Catches the snap bump on the rod to provide a solid "click" feedback
        translate([cap_depth / 2, 0, shell_r_in + (cap_radius + snap_clearance)])
        sphere(r = 0.7, $fn = 20);
        
        // 9. Decorative Grip Grooves
        // Three stylish, recessed bands near the back for tactile grip
        for (i = [0 : 2]) {
            translate([back_length + 5 + i * 7, 0, shell_r_in])
            rotate([0, 90, 0])
            rotate([0, 0, 30])
            difference() {
                cylinder(r = shell_r_out + 0.5, h = 1.6, center = true, $fn = 6);
                cylinder(r = shell_r_out - 0.4, h = 2, center = true, $fn = 6);
            }
        }
    }
}

// --- INNER ROD MODULE ---
module inner_rod() {
    union() {
        // 1. Main Rod Cylinder
        // Positioned concentrically with the shell (centered at Z = shell_r_in when assembled)
        translate([cap_depth, 0, shell_r_in])
        rotate([0, 90, 0])
        cylinder(r = rod_radius, h = rod_length - cap_depth - front_taper_length, $fn = $fn);
        
        // 2. Smooth Tapered Front Nose
        // Guides the bag smoothly into the bore
        translate([rod_length - front_taper_length, 0, shell_r_in])
        rotate([0, 90, 0])
        cylinder(r1 = rod_radius, r2 = 1.0, h = front_taper_length, $fn = $fn);
        
        // 3. Spherical Safety Tip (No sharp edges to tear bags or scratch fingers)
        translate([rod_length, 0, shell_r_in])
        sphere(r = 1.0, $fn = $fn);
        
        // 4. Rod Cap (Half-moon shaped to fit flush into the shell's back recess)
        difference() {
            translate([0, 0, shell_r_in])
            rotate([0, 90, 0])
            cylinder(r = cap_radius, h = cap_depth, $fn = $fn);
            
            // Flatten the bottom at Z = 0 so it prints flat on the bed without supports
            translate([-1, -cap_radius - 1, -0.1])
            cube([cap_depth + 2, (cap_radius + 1) * 2, shell_r_in]);
        }
        
        // 5. Snap Lock Protrusion (Small tactile snap bump on top of the cap)
        translate([cap_depth / 2, 0, shell_r_in + cap_radius - 0.15])
        sphere(r = 0.55, $fn = 20);
        
        // 6. Integrated Hanging Loop (Premium feature to hang clips or seal bags on a hook)
        translate([-7.5, 0, shell_r_in])
        rotate([0, 0, 0])
        difference() {
            // Outer loop body
            cylinder(r = 7.5, h = rod_radius * 2, center = true, $fn = $fn);
            
            // Inner cutout hole
            cylinder(r = 4.5, h = rod_radius * 2 + 1, center = true, $fn = $fn);
            
            // Flatten the bottom of the loop to match the bed at Z = 0
            translate([-8, -8, -shell_r_in - 0.1])
            cube([16, 16, shell_r_in - rod_radius + 0.1]);
        }
    }
}
