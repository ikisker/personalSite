// d-xy-center.scad — CC BY 4.0, Isaac Kisker (isaackisker.com/molecules)
//
// The centre hub of the d_xy orbital, split off for easier printing.
//   shape   — the parent centre sphere, truncated by a flat facet on each of the
//             four lobe axes (+-x/+-y) where a lobe mates
//   joint   — a 5x5x5 square socket in each facet takes the peg on a d-xy-lobe
//   sockets — every parent socket EXCEPT the four lobe tips (which live on the
//             lobe parts now): z poles, in-plane diagonals, elevated polar holes.
//             Same preset dropdown as the assembled d_xy.

// --- Customizer parameters ---
preset = 3;          // [0:Standard, 1:Equatorial Expanded, 2:Cuboctahedral, 3:All]
hole_diameter = 5.0; // [2.0:0.01:7.0]

/* [Hidden] */
$fa = 3;
$fs = 0.4;

// --- Shape constants ---
R_CTR   = 11.5;   // centre sphere radius
FIL_R   = 1.5;    // parent fillet radius (only used to locate the mate plane)
CONE_A  = 10.35;  // parent cone half-angle (only used to locate the mate plane)
CONE_B  = 3.175;  // parent wall offset  (only used to locate the mate plane)
PEG_SQ  = 5;      // square peg side (centre<->lobe joint)

// --- Build constants ---
FLAT_CUT  = 0;    // no bottom trim; the sphere is tangent to z=0
BOSS_WALL = 1.2;  // material kept around a socket when its boss is enabled (unused)
EPS       = 0.01; // overshoot so cut faces clear the surface cleanly
PEG_DEPTH = 5;    // socket hole depth / peg length — 5 everywhere
FIT       = 0.3;  // clearance added to the square socket for a printable fit

// --- Derived geometry ---
ZC = R_CTR - FLAT_CUT;   // sphere centre height (undersides on z=0)
// The lobe meets the sphere at the fillet tangency; the mate facet sits there.
FIL_PHI = CONE_A + asin((FIL_R + CONE_B * cos(CONE_A)) / (R_CTR + FIL_R));
MATE_T  = R_CTR * cos(FIL_PHI);   // facet distance from centre along each lobe axis

DIAG = R_CTR * sqrt(2) / 2; // in-plane diagonal offset (45 deg between lobes)
HALF = R_CTR / 2;           // polar-hole offset helpers
SQ2  = sqrt(2);

// --- Sockets --- (a socket is [position, direction, depth, boss, clear])
// Same layout as d-xy.scad, minus its four lobe-tip sockets.
POLES = [
    [[0, 0, ZC + R_CTR], [ 0,  0, -1], PEG_DEPTH, false],
    [[0, 0, 0],          [ 0,  0,  1], PEG_DEPTH, false],
];
DIAGS = [
    [[ DIAG,  DIAG, ZC], [-1, -1, 0], PEG_DEPTH, false],
    [[-DIAG,  DIAG, ZC], [ 1, -1, 0], PEG_DEPTH, false],
    [[-DIAG, -DIAG, ZC], [ 1,  1, 0], PEG_DEPTH, false],
    [[ DIAG, -DIAG, ZC], [-1,  1, 0], PEG_DEPTH, false],
];
// Elevated +-45 deg polar holes: 4 on top, 4 on bottom (bottom set rotated +90 deg).
CUSTOM_POLAR_HOLES = [
    [[ DIAG,     0, ZC + DIAG], [-1,  0, -1],   PEG_DEPTH, false],
    [[ HALF,  HALF, ZC + DIAG], [-1, -1, -SQ2], PEG_DEPTH, false],
    [[-DIAG,     0, ZC + DIAG], [ 1,  0, -1],   PEG_DEPTH, false],
    [[-HALF, -HALF, ZC + DIAG], [ 1,  1, -SQ2], PEG_DEPTH, false],
    [[    0,  DIAG, ZC - DIAG], [ 0, -1,    1], PEG_DEPTH, false],
    [[-HALF,  HALF, ZC - DIAG], [ 1, -1,  SQ2], PEG_DEPTH, false],
    [[    0, -DIAG, ZC - DIAG], [ 0,  1,    1], PEG_DEPTH, false],
    [[ HALF, -HALF, ZC - DIAG], [-1,  1,  SQ2], PEG_DEPTH, false],
];
PRESETS = [
    POLES,                                   // 0 "Standard": z poles only
    concat(POLES, DIAGS),                    // 1 "Equatorial Expanded": + in-plane diagonals
    concat(POLES, CUSTOM_POLAR_HOLES),       // 2 "Cuboctahedral": + the 8 polar holes
    concat(POLES, DIAGS, CUSTOM_POLAR_HOLES),// 3 "All"
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

// One lobe facet (+x): trim the sphere flat at the mate plane and recess a
// square socket for the lobe peg.
module mate_feature() {
    translate([MATE_T + 100, 0, 0]) cube([200, 200, 200], center = true);
    translate([MATE_T + EPS, 0, 0]) rotate([0, -90, 0])
        linear_extrude(PEG_DEPTH + EPS) square(PEG_SQ + FIT, center = true);
}

module body() {
    translate([0, 0, ZC])
    difference() {
        sphere(R_CTR);
        for (az = [0:90:270]) rotate([0, 0, az]) mate_feature();
    }
}

// --- Assembly ---
difference() {
    union() {
        body();
        for (s = sockets) if (s[3]) socket_boss(s);
    }
    for (s = sockets) socket_hole(s);
    for (s = sockets) if (s[4]) socket_clear(s);
}
