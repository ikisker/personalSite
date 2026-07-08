// d-z2.scad — CC BY 4.0, Isaac Kisker (isaackisker.com/molecules)
//
// 3d_z² orbital: two axial teardrop lobes + equatorial ring, one body.
//   lobes   — spheres R11.5, centers 30 apart, side walls blended by R90
//             arcs tangent to the spheres (arc centers 101.5 = 90 + 11.5
//             from the sphere centers)
//   ring    — torus, tube-center radius 9.625, tube radius 3.7, on the
//             mid-plane (outer radius 13.325)
//   sockets — 2 axial into the lobe poles, 4 radial into the ring outer
//             equator along ±x/±y (Ø5 × 5 deep)

// --- Customizer parameters ---
preset = 2;          // [0:Standard, 1:Tetrahedral, 2:All]
hole_diameter = 5.0; // [2.0:0.01:7.0]

/* [Hidden] */
$fa = 3;
$fs = 0.4;

// --- Shape constants ---
R_SPH   = 11.5;    // lobe end-cap sphere radius
LOBE_CC = 30;      // spacing between the two sphere centers
RING_R  = 9.625;   // ring tube-center radius
RING_T  = 3.7;     // ring tube radius
ARC_R   = 90;      // lobe side-wall arc radius
A_TAN   = 20;      // sphere/arc tangency angle at the sphere center — shape input

// --- Build constants ---
FLAT_CUT  = 0;     // trimmed off the bottom pole for a stable print face
BOSS_WALL = 1.2;   // material kept around a socket when its boss is enabled.
                   // 1.2 keeps the ring bosses flush inside the 7.4 tube at
                   // the reference Ø5 hole; a collar emerges only at larger
                   // holes, where the bare tube wall would drop below 1.2.
EPS       = 0.01;  // overshoot so cut faces clear the surface cleanly
PEG_DEPTH = 5;     // socket hole depth — one peg length for every socket

// --- Derived geometry ---
// Arc center as an (r, z) offset from a sphere center: the arc is tangent to
// the sphere, so its center lies R_SPH + ARC_R away along the A_TAN direction.
ARC_CX = (R_SPH + ARC_R) * cos(A_TAN);
ARC_CZ = (R_SPH + ARC_R) * sin(A_TAN);

Z0  = R_SPH - FLAT_CUT;   // lower sphere center height
ZR  = Z0 + LOBE_CC / 2;   // ring mid-plane
Z1  = Z0 + LOBE_CC;       // upper sphere center
TOP = Z1 + R_SPH;         // top pole
RING_OUT = RING_R + RING_T;

// Both intersection points of two circles (centers c1, c2; radii r1, r2).
function circle_isect(c1, r1, c2, r2) =
    let (d = norm(c2 - c1),
         a = (d * d + r1 * r1 - r2 * r2) / (2 * d),
         h = sqrt(r1 * r1 - a * a),
         m = c1 + a * (c2 - c1) / d,
         u = [-(c2[1] - c1[1]), c2[0] - c1[0]] / d)
    [m + h * u, m - h * u];

// Profile angles
ARC_A0 = A_TAN - 180;   // arc starts at the sphere tangency, pointing back at
                        // the sphere center
// The arc ends where the R90 arc crosses the ring tube circle; take the lower
// crossing. Ring center in the sphere-center frame is (RING_R, LOBE_CC/2).
XPT    = let (p = circle_isect([ARC_CX, ARC_CZ], ARC_R,
                               [RING_R, LOBE_CC / 2], RING_T))
         p[0][1] < p[1][1] ? p[0] : p[1];
ARC_A1 = atan2(XPT[1] - ARC_CZ, XPT[0] - ARC_CX);      // arc end at that crossing
RING_A = atan2(XPT[1] - LOBE_CC / 2, XPT[0] - RING_R); // ring tube angle there

// Tetrahedral socket configuration (preset 1)
R_TETRA = 11.0;      // base distance from center to the tetrahedral boss face
T_TETRA = 27.0;      // [0:0.01:90] socket tilt angle (tuned to 27 deg)
O_TETRA = 2.0;       // outward offset so the hole bottom clears the lobe
EFF_R_TETRA = R_TETRA + O_TETRA; // total distance from center to socket face

// Symmetric tetrahedral direction vectors (spherical coords)
T1 = [ cos(45)*cos(T_TETRA),  sin(45)*cos(T_TETRA),   sin(T_TETRA) ];
T2 = [ cos(225)*cos(T_TETRA), sin(225)*cos(T_TETRA),  sin(T_TETRA) ];
T3 = [ cos(315)*cos(T_TETRA), sin(315)*cos(T_TETRA), -sin(T_TETRA) ];
T4 = [ cos(135)*cos(T_TETRA), sin(135)*cos(T_TETRA), -sin(T_TETRA) ];

// --- Sockets --- (a socket is [position, direction, depth, boss, clear])
// clear (optional, default false): also cut geometry overhanging the insertion
// path. Left off for the tetrahedral sockets — they bore into the lobes and
// must not carve a channel out the far side.
STD = [
    [[0, 0, 0],           [ 0,  0,  1], PEG_DEPTH, false],
    [[0, 0, TOP],         [ 0,  0, -1], PEG_DEPTH, false],
    [[ RING_OUT, 0, ZR],  [-1,  0,  0], PEG_DEPTH, true],
    [[-RING_OUT, 0, ZR],  [ 1,  0,  0], PEG_DEPTH, true],
    [[0,  RING_OUT, ZR],  [ 0, -1,  0], PEG_DEPTH, true],
    [[0, -RING_OUT, ZR],  [ 0,  1,  0], PEG_DEPTH, true],
];
TETRA = [
    [[ T1[0]*EFF_R_TETRA, T1[1]*EFF_R_TETRA, ZR + T1[2]*EFF_R_TETRA ], -T1, PEG_DEPTH, true],
    [[ T2[0]*EFF_R_TETRA, T2[1]*EFF_R_TETRA, ZR + T2[2]*EFF_R_TETRA ], -T2, PEG_DEPTH, true],
    [[ T3[0]*EFF_R_TETRA, T3[1]*EFF_R_TETRA, ZR + T3[2]*EFF_R_TETRA ], -T3, PEG_DEPTH, true],
    [[ T4[0]*EFF_R_TETRA, T4[1]*EFF_R_TETRA, ZR + T4[2]*EFF_R_TETRA ], -T4, PEG_DEPTH, true],
];
PRESETS = [
    STD,                 // preset 0 "Standard": both poles axial, ring ±x/±y radial
    TETRA,               // preset 1 "Tetrahedral": 4 symmetric sp3 sockets, bosses on
    concat(STD, TETRA),  // preset 2 "All"
];
sockets = PRESETS[preset];

// --- Profile ---
// Half of the revolved outline: sphere (from a0 up to the arc tangency),
// R90 side-wall arc, then the ring tube out to its outer equator.
function half_profile(zc, a0) = concat(
    [for (i = [0:64]) let (a = a0 + (A_TAN - a0) * i / 64)
        [R_SPH * cos(a), zc + R_SPH * sin(a)]],
    [for (i = [1:20]) let (a = ARC_A0 + (ARC_A1 - ARC_A0) * i / 20)
        [ARC_CX + ARC_R * cos(a), zc + ARC_CZ + ARC_R * sin(a)]],
    [for (i = [1:24]) let (a = RING_A - RING_A * i / 24)
        [RING_R + RING_T * cos(a), ZR + RING_T * sin(a)]]
);

lower = half_profile(Z0, -asin((R_SPH - FLAT_CUT) / R_SPH)); // starts on z=0
upper = half_profile(Z0, -90);                               // full pole; mirrored below

PROFILE = concat(
    [[0, 0]],
    lower,
    [for (i = [len(upper) - 2 : -1 : 0]) [upper[i][0], 2 * ZR - upper[i][1]]]
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

module body() {
    rotate_extrude() polygon(PROFILE);
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
