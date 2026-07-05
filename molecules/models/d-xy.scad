// d-xy.scad — CC BY 4.0, Isaac Kisker (isaackisker.com/molecules)
//
// 3d_xy orbital, assembled: centre sphere + four lobes along ±x/±y, one body.
//   centre — sphere R11.5 at the origin
//   lobes  — end-cap spheres R9.2 centred 33 from the origin; side walls are
//            a 10.3487° half-angle cone off each end sphere, blended into the
//            centre sphere by an R1.5 fillet torus and into the end sphere by
//            an R500 arc (every tangency exact in the STEP)
//   sockets — Ø5 × 5 deep in the reference: 4 lobe tips, 2 z poles, 4
//            in-plane diagonals at 45° between the lobes

preset = 2;          // [0:Standard, 1:Full]
hole_diameter = 5.0; // [2.0:0.01:7.0]

/* [Hidden] */
$fa = 3;
$fs = 0.4;

R_CTR  = 11.5;          // centre sphere radius
R_LOBE = 9.2;           // lobe end-cap sphere radius
LOBE_D = 33;            // lobe sphere centre distance from the origin
TIP    = 42.2;          // lobe tip = LOBE_D + R_LOBE
FIL_R  = 1.5;           // centre-sphere/cone fillet radius
FIL_CT = 11.1225008;    // fillet centre (t = along lobe axis, r = off axis);
FIL_CR = 6.7297828;     //   |centre| = 13 = 11.5 + 1.5, tangent to the centre sphere
BLEND_R  = 500;         // cone-to-end-sphere blend arc radius
BLEND_CT = -70.5886846; // blend arc centre, tangent to cone and end sphere
BLEND_CR = 498.5519275;
FLAT_CUT  = 0;        // trimmed off the bottom: stable print face
BOSS_WALL = 1.2;        // material kept around a socket when the boss is enabled.
                        // Unused here: every socket bores into a solid core
                        // (centre or lobe sphere), so no wall thins even at Ø7.
EPS = 0.01;

ZC = R_CTR - FLAT_CUT;  // lobe-axes plane height above the plate (9.2 —
                        // the lobe undersides touch z=0 exactly)

// Profile angles (degrees) derived from the STEP surfaces:
FIL_A0   = -148.823536; // fillet from the centre-sphere tangency...
FIL_A1   =  -79.651316; // ...to the cone tangency (t 11.391958, r 5.254184)
CONE_T1  = 19.2303931;  // cone runs straight to here, where the R500 arc
CONE_R1  = 6.6855500;   //   takes over (same angle: FIL_A1 = the arc's start)
BLEND_A1 = -78.262147;  // R500 arc to the end-sphere tangency
SPH_A1   = 101.737853;  // end sphere from that tangency around to the tip

DIAG = R_CTR * sqrt(2) / 2; // diagonal socket opening offset (8.1317, on the sphere)

// A socket is [position, direction, depth, boss].
// Depths from the STEP: every socket bottoms 5 under its entry surface
// (tips: 42.2→37.2, poles: 11.5→6.5, diagonals: 11.5→6.5 radially). The
// bottom pole socket keeps that 5 mm measured from the flat print face.
STD = [
    [[ TIP, 0, ZC],      [-1,  0,  0], 5, false],
    [[-TIP, 0, ZC],      [ 1,  0,  0], 5, false],
    [[0,  TIP, ZC],      [ 0, -1,  0], 5, false],
    [[0, -TIP, ZC],      [ 0,  1,  0], 5, false],
    [[0, 0, ZC + R_CTR], [ 0,  0, -1], 5, false],
    [[0, 0, 0],          [ 0,  0,  1], 5, false],
];
DIAGS = [
    [[ DIAG,  DIAG, ZC], [-1, -1, 0], 5, false],
    [[-DIAG,  DIAG, ZC], [ 1, -1, 0], 5, false],
    [[-DIAG, -DIAG, ZC], [ 1,  1, 0], 5, false],
    [[ DIAG, -DIAG, ZC], [-1,  1, 0], 5, false],
];
// Math helpers for the 45-degree elevated offset holes
HALF = R_CTR / 2;
SQ2 = sqrt(2);

// Custom Top and Bottom Holes
CUSTOM_POLAR_HOLES = [
    // --- TOP 4 HOLES (Elevation +45 deg) ---
    // Azimuths: 0°, 45°, 180°, 225°
    // 1. Aligned with front (+x) lobe
    [[ DIAG,     0, ZC + DIAG], [-1,  0, -1],   5, false],
    // 2. 45 deg offset to the left (+x / +y diagonal)
    [[ HALF,  HALF, ZC + DIAG], [-1, -1, -SQ2], 5, false],
    // 3. Mirrored back (-x) lobe
    [[-DIAG,     0, ZC + DIAG], [ 1,  0, -1],   5, false],
    // 4. 45 deg offset to its right (-x / -y diagonal)
    [[-HALF, -HALF, ZC + DIAG], [ 1,  1, -SQ2], 5, false],

    // --- BOTTOM 4 HOLES (Elevation -45 deg, Rotated +90 deg left) ---
    // Azimuths: 90°, 135°, 270°, 315°
    // 5. Rotated 90 deg from front (Aligned with +y lobe)
    [[    0,  DIAG, ZC - DIAG], [ 0, -1,    1], 5, false],
    // 6. Rotated 90 deg from the left diagonal (-x / +y diagonal)
    [[-HALF,  HALF, ZC - DIAG], [ 1, -1,  SQ2], 5, false],
    // 7. Rotated 90 deg from back (Aligned with -y lobe)
    [[    0, -DIAG, ZC - DIAG], [ 0,  1,    1], 5, false],
    // 8. Rotated 90 deg from the right diagonal (+x / -y diagonal)
    [[ HALF, -HALF, ZC - DIAG], [-1,  1,  SQ2], 5, false],
];
PRESETS = [
    STD,                                 // preset 0 "Standard": lobe tips + z poles
    concat(STD, DIAGS),                  // preset 1 "Full": adds the in-plane diagonals
    concat(STD, CUSTOM_POLAR_HOLES),     // preset 2 "polar": adds the 8 new polar holes
];

sockets = PRESETS[preset];

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

difference() {
    union() {
        body();
        for (s = sockets) if (s[3]) socket_boss(s);
    }
    for (s = sockets) socket_hole(s);
}
