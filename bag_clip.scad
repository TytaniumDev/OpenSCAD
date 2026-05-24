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

// The flat cut height (relative to Z=0 bed height of the concentric center).
// Slices the bottom of the rod and cap to create a flat print base of 0.8mm thick.
flat_cut_z = shell_r_in - rod_radius + 0.8;


// =========================================================================
// MAIN ENTRY POINT
// =========================================================================

if (part == "print_layout") {
    // Render both parts flat on the print bed side-by-side
    outer_shell();
    
    // Position the rod parallel to the shell with its flat bottom sitting perfectly on Z=0
    translate([0, shell_r_in * 2.5 + 5, -flat_cut_z])
    inner_rod();
}
else if (part == "assembled") {
    // Render them assembled for inspection
    %outer_shell(); // Translucent outer shell
    inner_rod();
}
else if (part == "shell_only") {
    outer_shell();
}
else if (part == "rod_only") {
    // Center it on the bed for printing alone
    translate([0, 0, -flat_cut_z])
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
        
        // 3. Central Bore (Hollow cavity for the rod) with a flat floor
        // Starts after the solid back block, runs forward, tapers down, and ends in a tight matching front socket
        difference() {
            union() {
                // Main wide bore (clamping section)
                translate([back_length, 0, shell_r_in])
                rotate([0, 90, 0])
                cylinder(r = bore_radius, h = clip_length - back_length - 8, $fn = $fn);
                
                // Transition taper (funnels down to the snug front socket)
                translate([clip_length - 8, 0, shell_r_in])
                rotate([0, 90, 0])
                cylinder(r1 = bore_radius, r2 = rod_radius + snap_clearance, h = 4, $fn = $fn);
                
                // Narrow front socket (fits the rod's hemispherical tip snugly)
                translate([clip_length - 4, 0, shell_r_in])
                rotate([0, 90, 0])
                cylinder(r = rod_radius + snap_clearance, h = 5.1, $fn = $fn);
            }
            
            // Flatten the bottom of the entire bore cavity to match the flat bottom of the rod
            translate([back_length - 1, -bore_radius - 2, -0.1])
            cube([clip_length - back_length + 3, (bore_radius + 2) * 2, flat_cut_z - gap_size + 0.1]);
        }
        
        // 4. Rod Entry Tunnel (Through the back block to let the rod slide in)
        // Has a matching flat bottom
        difference() {
            translate([-1, 0, shell_r_in])
            rotate([0, 90, 0])
            cylinder(r = rod_radius + snap_clearance, h = back_length + 2, $fn = $fn);
            
            // Flatten the bottom of the entry tunnel
            translate([-2, -rod_radius - 2, -0.1])
            cube([back_length + 4, (rod_radius + 2) * 2, flat_cut_z - snap_clearance + 0.1]);
        }
        
        // 5. Cap Recess (Half-moon socket at the very back)
        // The rod cap snaps into this recess to sit flush
        translate([-0.1, 0, shell_r_in])
        rotate([0, 90, 0])
        difference() {
            cylinder(r = cap_radius + snap_clearance, h = cap_depth + 0.1, $fn = $fn);
            
            // Flatten the bottom of the recess to match the flat bottom of the cap
            translate([-cap_radius - 2, -cap_radius - 2, -shell_r_in - 0.1])
            cube([(cap_radius + 2) * 2, (cap_radius + 2) * 2, flat_cut_z - snap_clearance + 0.1]);
        }
        
        // 6. Longitudinal Entry Slot (At the top of the shell)
        // Allows the folded bag to slide into the bore
        translate([back_length, -slot_width / 2, shell_r_in])
        cube([clip_length - back_length + 1, slot_width, shell_r_out * 2]);
        
        // 7. Snap Lock Dimple (Small recess at the top of the cap socket)
        // Catches the snap bump on the rod to provide a solid "click" feedback
        translate([cap_depth / 2, 0, shell_r_in + (cap_radius + snap_clearance)])
        sphere(r = 0.7, $fn = 20);
        
        // 8. Decorative Grip Grooves
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
    difference() {
        union() {
            // 1. Main Rod Cylinder (Constant diameter all the way to the front nose)
            // Positioned concentrically with the shell (centered at Z = shell_r_in when assembled)
            translate([cap_depth, 0, shell_r_in])
            rotate([0, 90, 0])
            cylinder(r = rod_radius, h = rod_length - cap_depth - rod_radius, $fn = $fn);
            
            // 2. Hemispherical Front Tip (Saves material, removes sharp corners, and matches the sleeve socket)
            translate([rod_length - rod_radius, 0, shell_r_in])
            sphere(r = rod_radius, $fn = $fn);
            
            // 3. Rod Cap (Half-moon shaped to fit flush into the shell's back recess)
            translate([0, 0, shell_r_in])
            rotate([0, 90, 0])
            cylinder(r = cap_radius, h = cap_depth, $fn = $fn);
            
            // 4. Snap Lock Protrusion (Small tactile snap bump on top of the cap)
            translate([cap_depth / 2, 0, shell_r_in + cap_radius - 0.15])
            sphere(r = 0.55, $fn = 20);
        }
        
        // 5. Global Flat Bottom Cut (Slices off the bottom of the entire rod, tip, and cap!)
        // Slices exactly at Z = flat_cut_z to create a perfect, co-planar printing surface
        translate([-10, -cap_radius - 5, -0.1])
        cube([clip_length + 20, (cap_radius + 5) * 2, flat_cut_z + 0.1]);
    }
}
