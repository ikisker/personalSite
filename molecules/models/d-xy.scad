// d-xy.scad — CC BY 4.0, Isaac Kisker (isaackisker.com/molecules)
//
// 3d_xy orbital: centre sphere + four lobes along ±x/±y, one body.
//   centre  — sphere R11.5 at the origin
//   lobes   — end-cap spheres R9.2 centred 33 from the origin; side walls are
//             a 10.35° half-angle cone off each end sphere, blended into the
//             centre sphere by an R1.5 fillet torus and into the end sphere by
//             an R500 arc
//   sockets — 4 lobe tips, 2 z poles, 4 in-plane diagonals at 45° (Ø5 × 5 deep)

// --- Customizer parameters ---
preset = 2;          // [0:Standard, 1:Full, 2:Custom Top/Bottom, 3:All]
hole_diameter = 5.0; // [2.0:0.01:7.0]

/* [Hidden] */
$fa = 3;
$fs = 0.4;

// --- Shape constants ---
R_CTR   = 11.5;            // centre sphere radius
R_LOBE  = 9.2;             // lobe end-cap sphere radius
LOBE_D  = 33;              // lobe sphere centre distance from the origin
TIP     = LOBE_D + R_LOBE; // lobe tip = 42.2
FIL_R   = 1.5;             // centre-sphere/cone fillet radius
BLEND_R = 500;             // cone-to-end-sphere blend arc radius
CONE_A  = 10.35;           // cone half-angle off the lobe axis — shape input
CONE_B  = 3.175;           // wall radial offset: r = tan(CONE_A)*t + CONE_B — shape input

// --- Build constants ---
FLAT_CUT  = 0;    // trimmed off the bottom for a stable print face (0 is no trim)
BOSS_WALL = 1.2;  // material kept around a socket when its boss is enabled.
                  // Unused here: every socket bores into a solid core (centre
                  // or lobe sphere), so no wall thins even at Ø7.
EPS       = 0.01; // overshoot so cut faces clear the surface cleanly
PEG_DEPTH = 5;    // socket hole depth — one peg length for every socket

// --- Derived geometry ---
ZC = R_CTR - FLAT_CUT;  // lobe-axes plane height above the plate (the lobe
                        // undersides touch z=0 exactly)
// Fillet centre: on |centre| = R_CTR + FIL_R (tangent to the centre sphere),
// placed so the fillet is also tangent to the cone wall.
FIL_PHI = CONE_A + asin((FIL_R + CONE_B * cos(CONE_A)) / (R_CTR + FIL_R));
FIL_CT  = (R_CTR + FIL_R) * cos(FIL_PHI); // fillet centre (t along axis, r off axis)
FIL_CR  = (R_CTR + FIL_R) * sin(FIL_PHI);
// Blend centre: on |centre − end-sphere centre| = BLEND_R + R_LOBE (tangent to
// the end sphere), placed tangent to the cone wall.
BLEND_PSI = CONE_A + 180
          - asin((BLEND_R + LOBE_D * sin(CONE_A) + CONE_B * cos(CONE_A)) / (BLEND_R + R_LOBE));
BLEND_CT  = LOBE_D + (BLEND_R + R_LOBE) * cos(BLEND_PSI); // blend arc centre
BLEND_CR  = (BLEND_R + R_LOBE) * sin(BLEND_PSI);

// Profile angles:
FIL_A0   = FIL_PHI - 180;               // fillet from the centre-sphere tangency...
FIL_A1   = CONE_A - 90;                 // ...to the cone tangency; also the R500 arc start
CONE_T1  = BLEND_CT + BLEND_R * sin(CONE_A); // cone runs straight to here, where the
CONE_R1  = BLEND_CR - BLEND_R * cos(CONE_A); //   R500 arc takes over (start angle FIL_A1)
BLEND_A1 = BLEND_PSI - 180;             // R500 arc to the end-sphere tangency
SPH_A1   = BLEND_PSI;                   // end sphere from that tangency around to the tip

DIAG = R_CTR * sqrt(2) / 2; // in-plane diagonal offset (45° between lobes)
HALF = R_CTR / 2;           // polar-hole offset helpers
SQ2  = sqrt(2);

// --- Sockets --- (a socket is [position, direction, depth, boss, clear])
// clear (optional, default false): also cut geometry overhanging the insertion
// path. Unused here — every socket bores into a convex sphere, nothing overhangs.
STD = [
    [[ TIP, 0, ZC],      [-1,  0,  0], PEG_DEPTH, false],
    [[-TIP, 0, ZC],      [ 1,  0,  0], PEG_DEPTH, false],
    [[0,  TIP, ZC],      [ 0, -1,  0], PEG_DEPTH, false],
    [[0, -TIP, ZC],      [ 0,  1,  0], PEG_DEPTH, false],
    [[0, 0, ZC + R_CTR], [ 0,  0, -1], PEG_DEPTH, false],
    [[0, 0, 0],          [ 0,  0,  1], PEG_DEPTH, false],
];
DIAGS = [
    [[ DIAG,  DIAG, ZC], [-1, -1, 0], PEG_DEPTH, false],
    [[-DIAG,  DIAG, ZC], [ 1, -1, 0], PEG_DEPTH, false],
    [[-DIAG, -DIAG, ZC], [ 1,  1, 0], PEG_DEPTH, false],
    [[ DIAG, -DIAG, ZC], [-1,  1, 0], PEG_DEPTH, false],
];
// Elevated ±45° polar holes: 4 on top, 4 on bottom (bottom set rotated +90°).
CUSTOM_POLAR_HOLES = [
    // --- TOP 4 HOLES (elevation +45°), azimuths 0°, 45°, 180°, 225° ---
    [[ DIAG,     0, ZC + DIAG], [-1,  0, -1],   PEG_DEPTH, false], // aligned with +x lobe
    [[ HALF,  HALF, ZC + DIAG], [-1, -1, -SQ2], PEG_DEPTH, false], // 45° toward +x/+y diagonal
    [[-DIAG,     0, ZC + DIAG], [ 1,  0, -1],   PEG_DEPTH, false], // mirrored -x lobe
    [[-HALF, -HALF, ZC + DIAG], [ 1,  1, -SQ2], PEG_DEPTH, false], // 45° toward -x/-y diagonal
    // --- BOTTOM 4 HOLES (elevation -45°, rotated +90°), azimuths 90°, 135°, 270°, 315° ---
    [[    0,  DIAG, ZC - DIAG], [ 0, -1,    1], PEG_DEPTH, false], // aligned with +y lobe
    [[-HALF,  HALF, ZC - DIAG], [ 1, -1,  SQ2], PEG_DEPTH, false], // -x/+y diagonal
    [[    0, -DIAG, ZC - DIAG], [ 0,  1,    1], PEG_DEPTH, false], // aligned with -y lobe
    [[ HALF, -HALF, ZC - DIAG], [-1,  1,  SQ2], PEG_DEPTH, false], // +x/-y diagonal
];
PRESETS = [
    STD,                                     // preset 0 "Standard": lobe tips + z poles
    concat(STD, DIAGS),                      // preset 1 "Full": adds the in-plane diagonals
    concat(STD, CUSTOM_POLAR_HOLES),         // preset 2 "Custom Top/Bottom": adds the 8 polar holes
    concat(STD, DIAGS, CUSTOM_POLAR_HOLES),  // preset 3 "All": every hole defined
];
sockets = PRESETS[preset];

// --- Profile ---
// One lobe's revolved outline in (r, t), t along the lobe axis from the
// model centre: fillet arc, straight cone wall, R500 blend, end-cap sphere.
LOBE_PROFILE = concat(
    [[0, 0]],
    [for (i = [0:24]) let (a = FIL_A0 + (FIL_A1 - FIL_A0) * i / 24)
        [FIL_CR + FIL_R * sin(a), FIL_CT + FIL_R * cos(a)]],
    [[CONE_R1, CONE_T1]],
    [for (i = [1:8]) let (a = FIL_A1 + (BLEND_A1 - FIL_A1) * i / 8)
        [BLEND_CR + BLEND_R * sin(a), BLEND_CT + BLEND_R * cos(a)]],
    [for (i = [1:40]) let (a = SPH_A1 - SPH_A1 * i / 40)
        [R_LOBE * sin(a), LOBE_D + R_LOBE * cos(a)]]
);

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

module lobe() {
    rotate_extrude() polygon(LOBE_PROFILE);
}

module body() {
    difference() {
        translate([0, 0, ZC]) {
            sphere(r = R_CTR);
            for (az = [0:90:270]) rotate([0, 90, az]) lobe();
        }
        translate([0, 0, -50]) cube([100, 100, 100], center = true);
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
