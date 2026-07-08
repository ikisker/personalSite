// p-orbital.scad — CC BY 4.0, Isaac Kisker (isaackisker.com/molecules)
//
// 2p orbital: two lobes as one body — the union of two Ø16 spheres.
//   lobes   — spheres R8, centers 14.8 apart on the lobe (x) axis
//   waist   — a raised, chamfered riser collar on the saddle for the +z socket
//   sockets — 2 axial into the lobe tips, 1 into the waist riser (+z)

// --- Customizer parameters ---
preset = 0;          // [0:Standard]
hole_diameter = 5.0; // [2.0:0.01:7.0]

/* [Hidden] */
$fa = 3;
$fs = 0.4;

// --- Shape constants ---
R_SPH = 8;          // lobe sphere radius (Ø16)
CX    = 7.4;        // lobe sphere center offset on x (half of the 14.8 spacing)
POLE  = CX + R_SPH; // lobe tip on x = 15.4
WAIST_MOUTH = 7;    // raised waist insertion point (centered z; ~1 below the
                    // lobe crown R_SPH=8) — how proud the riser collar stands

// --- Shared build constants (common to every orbital file — see test/style-guide.scad) ---
FLAT_CUT  = 0;    // trimmed off each lobe underside for a stable print face
BOSS_WALL = 1.2;  // material kept around a socket when its boss is enabled
EPS       = 0.01; // overshoot so cut faces clear the surface cleanly
PEG_DEPTH = 5;    // socket hole depth — one peg length for every socket
BOSS_CHAM = 1.2;  // 45° taper at the riser base — no flat downward print overhang

// --- Derived geometry ---
FLAT_Z = -(R_SPH - FLAT_CUT);   // underside flat plane in the centered frame = −6
ZLIFT  =   R_SPH - FLAT_CUT;    // lift so the flat lands on z=0 = 6

// --- Sockets --- (a socket is [position, direction, depth, boss, clear])
// clear (optional, default false): also cut any body geometry overhanging the
// insertion path — the coaxial channel past the boss out to open air.
PRESETS = [
    // preset 0 "Standard": a socket in each lobe tip (axial) + one in the waist (+z).
    [
        [[-POLE, 0, 0], [ 1, 0, 0], PEG_DEPTH, false],
        [[ POLE, 0, 0], [-1, 0, 0], PEG_DEPTH, false],
        // waist: hole bored from the raised riser top (riser in body() is the
        // collar, so boss off); clear still trims lobe overhang at large holes.
        [[0, 0, WAIST_MOUTH - PEG_DEPTH], [ 0, 0, 1], PEG_DEPTH, false, true],
    ]
];
sockets = PRESETS[preset];

// --- Modules ---
// Rotate children so their +z axis points along dir.
module orient(dir) {
    n = dir / norm(dir);
    rotate([0, acos(n[2]), atan2(n[1], n[0])]) children();
}

module socket_hole(s) {
    translate(s[0]) orient(s[1])
        translate([0, 0, -EPS]) cylinder(h = s[2] + EPS, d = hole_diameter);
}

module socket_boss(s) {
    translate(s[0]) orient(s[1])
        cylinder(h = s[2], d = hole_diameter + 2 * BOSS_WALL);
}

// Clear the insertion corridor: continue the boss-width channel past the boss,
// out to open air, so nothing overhangs the peg's straight path in.
module socket_clear(s) {
    translate(s[0]) orient(s[1])
        translate([0, 0, s[2]]) cylinder(h = 100, d = hole_diameter + 2 * BOSS_WALL);
}

// Raised collar on the waist saddle: a 45° base cone (merges into the lobes with
// no flat overhang) topped by the cylinder the waist hole is bored through.
module waist_riser() {
    cylinder(h = BOSS_CHAM, d1 = hole_diameter, d2 = hole_diameter + 2 * BOSS_WALL);
    translate([0, 0, BOSS_CHAM])
        cylinder(h = WAIST_MOUTH - BOSS_CHAM, d = hole_diameter + 2 * BOSS_WALL);
}

module body() {
    intersection() {
        union() {
            translate([-CX, 0, 0]) sphere(R_SPH);
            translate([ CX, 0, 0]) sphere(R_SPH);
            waist_riser();
        }
        translate([0, 0, FLAT_Z + 100]) cube([200, 200, 200], center = true);
    }
}

// --- Assembly ---
translate([0, 0, ZLIFT])   // lift the centered body so its flat sits on z=0
difference() {
    union() {
        body();
        for (s = sockets) if (s[3]) socket_boss(s);
    }
    for (s = sockets) socket_hole(s);
    for (s = sockets) if (s[4]) socket_clear(s);
}
