// d-xy-lobe.scad — CC BY 4.0, Isaac Kisker (isaackisker.com/molecules)
//
// One outer lobe of the d_xy orbital, split off for easier printing.
//   shape   — the parent d_xy lobe profile (fillet, cone, R500 blend, end cap),
//             cut flat only where it meets the centre sphere (the mating face);
//             the rounded outer tip is left intact
//   orient  — mate face down: a 5x5x5 square peg points down off the mate face
//             (plugs into d-xy-center); the rounded lobe rises above it
//   socket  — one round bond socket bored into the rounded tip

// --- Customizer parameters ---
preset = 0;          // [0:Standard]
hole_diameter = 5.0; // [2.0:0.01:7.0]

/* [Hidden] */
$fa = 3;
$fs = 0.4;

// --- Shape constants (same lobe as public/models/d-xy.scad) ---
R_CTR   = 11.5;            // parent centre sphere radius (sets the mate plane)
R_LOBE  = 9.2;             // lobe end-cap sphere radius
LOBE_D  = 33;              // lobe sphere centre distance from the origin
TIP     = LOBE_D + R_LOBE; // lobe tip = 42.2
FIL_R   = 1.5;             // centre-sphere/cone fillet radius
BLEND_R = 500;             // cone-to-end-sphere blend arc radius
CONE_A  = 10.35;           // cone half-angle off the lobe axis — shape input
CONE_B  = 3.175;           // wall radial offset: r = tan(CONE_A)*t + CONE_B — shape input
PEG_SQ  = 5;               // square peg side (centre<->lobe joint)

// --- Build constants ---
FLAT_CUT  = 0;    // no trim — the rounded outer tip is left intact
BOSS_WALL = 1.2;  // material kept around a socket when its boss is enabled (unused)
EPS       = 0.01; // overshoot so cut faces clear the surface cleanly
PEG_DEPTH = 5;    // socket hole depth / peg length — 5 everywhere

// --- Derived geometry (identical to d-xy.scad) ---
FIL_PHI = CONE_A + asin((FIL_R + CONE_B * cos(CONE_A)) / (R_CTR + FIL_R));
FIL_CT  = (R_CTR + FIL_R) * cos(FIL_PHI);
FIL_CR  = (R_CTR + FIL_R) * sin(FIL_PHI);
BLEND_PSI = CONE_A + 180
          - asin((BLEND_R + LOBE_D * sin(CONE_A) + CONE_B * cos(CONE_A)) / (BLEND_R + R_LOBE));
BLEND_CT  = LOBE_D + (BLEND_R + R_LOBE) * cos(BLEND_PSI);
BLEND_CR  = (BLEND_R + R_LOBE) * sin(BLEND_PSI);
FIL_A0   = FIL_PHI - 180;
FIL_A1   = CONE_A - 90;
CONE_T1  = BLEND_CT + BLEND_R * sin(CONE_A);
CONE_R1  = BLEND_CR - BLEND_R * cos(CONE_A);
BLEND_A1 = BLEND_PSI - 180;
SPH_A1   = BLEND_PSI;

// The lobe profile starts where it meets the centre sphere (the fillet tangency),
// so the mate plane is exactly there: t = R_CTR*cos(FIL_PHI), r = R_CTR*sin(FIL_PHI).
MATE_T = R_CTR * cos(FIL_PHI);   // mate face distance along the lobe axis
LOBE_Z = PEG_DEPTH - MATE_T;     // shift so the mate face lands at z=PEG_DEPTH
TIP_Z  = TIP + LOBE_Z;           // rounded tip height in the print frame

// --- Sockets --- (a socket is [position, direction, depth, boss, clear])
// One bond socket bored into the rounded tip, down the lobe axis.
PRESETS = [
    [ [[0, 0, TIP_Z], [0, 0, -1], PEG_DEPTH, false] ]
];
sockets = PRESETS[preset];

// --- Profile ---
// The d-xy lobe outline in (r, t), but capped flat at the mate plane instead of
// running to the origin: [0, MATE_T] replaces d-xy's [0, 0].
LOBE_PROFILE = concat(
    [[0, MATE_T]],
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

// Revolve the profile, mate face down at z=PEG_DEPTH (rounded tip pointing up).
module body() {
    translate([0, 0, LOBE_Z]) rotate_extrude() polygon(LOBE_PROFILE);
}

// --- Assembly ---
difference() {
    union() {
        body();
        // square peg pointing down off the mate face, its foot on z=0
        linear_extrude(PEG_DEPTH + EPS) square(PEG_SQ, center = true);
        for (s = sockets) if (s[3]) socket_boss(s);
    }
    for (s = sockets) socket_hole(s);
    for (s = sockets) if (s[4]) socket_clear(s);
}
