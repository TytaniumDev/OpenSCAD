# Parametric Sliding Bag Sealer (OpenSCAD)

A highly durable, springless, two-piece sliding bag sealer (chip clip) designed in OpenSCAD. It is fully parameterized, optimized for 3D printing flat on the bed, and requires **no supports**.

## 🛠️ Key Design & Engineering Features

* **No Supports Required:** Both the hexagonal outer shell and the inner rod sit perfectly flat on the print bed.
* **Maximum Bending Strength:** By printing flat horizontally, the filament layer lines run along the length of the clip, ensuring it won't snap under stress from thick bags.
* **Triangular Stick Profile:** The inserting rod is designed as a triangular prism, providing excellent structural rigidity and a wide flat bottom base for printing flat on the bed with 100% success.
* **Large Spherical Guide Tip:** Inspired by the original model, the front tip of the rod features a large sphere of radius `sphere_radius = bore_radius - snap_clearance` (3.8mm). This serves as a smooth guide-in ball to slide onto bags easily, and sits perfectly flat on the bed via our global flat-bottom cut.
* **Double-Wedge Snap Lock (One-Way Permanent Fit):** Bypasses weak point dimples! The sides of the rod cap feature two sturdy, double-sided wedge barbs that ramp up during insertion and lock into matching rectangular grooves in the sleeve recess, creating an incredibly secure one-way structural lock.
* **Entry Guide Funnel:** A generous `15mm` flared conical entry taper on the sleeve allows bag folds to slide in smoothly.

---

## 🖼️ Visual Renders

### 1. Assembled Fit
When inserted, the large guide sphere at the tip plugs the front opening of the sleeve beautifully, and the half-moon cap sits flush at the back, permanently locked:
![Assembled View](docs/assembled.png)

### 2. Print Bed Layout
Both parts lie flat on the bed, ready to export and print with no supports and high strength:
![Print Bed Layout](docs/print_layout.png)

---

## ⚙️ Customization

You can open `bag_clip.scad` in OpenSCAD and adjust these primary variables directly in the Editor or using the **Customizer Panel**:

```openscad
// Total length of the bag clip (mm)
clip_length = 150; 

// Diameter of the inner rod (mm)
rod_diameter = 5.5; 

// Clearance gap between the rod and the shell (Crucial for bag thickness)
gap_size = 1.2; 

// Width of the slot in the outer shell (mm)
slot_width = 3.5; 

// Fit clearance tolerance for the snap joint (mm)
snap_clearance = 0.15; 
```

### 💡 Recommended Gap Sizes:
* **Thin Bags** (e.g., bread bags, thin single-layer plastic): `gap_size = 0.8` to `1.0`
* **Medium Bags** (e.g., standard thick potato chip/snack bags): `gap_size = 1.1` to `1.3`
* **Thick Bags** (e.g., foil-lined coffee bags, pet food bags): `gap_size = 1.4` to `1.8`

---

## 🖨️ Recommended Print Settings (e.g., Bambu Lab X1C)

* **Material:** PLA or PETG (PETG is ideal for maximum springiness; PLA is perfect and rigid)
* **Layer Height:** `0.20mm` (Standard)
* **Wall Loops (Perimeters):** Set to **3 or 4 walls** (Highly recommended to make the shell robust and springy)
* **Infill:** `15%` to `20%` (Gyroid or Grid pattern)
* **Supports:** **Disabled** (Not required)
