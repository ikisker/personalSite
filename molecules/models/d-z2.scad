 // d-z2.scad — CC BY 4.0, Isaac Kisker (isaackisker.com/molecules)
//
// 3d_z² orbital: two axial teardrop lobes + equatorial ring, one body.
//   lobes  — spheres R11.5, centers 30 apart, side walls blended by R90
//            arcs tangent to the spheres (arc centers 101.5 = 90 + 11.5
//            from the sphere centers)
//   ring   — torus, tube-center radius 9.625, tube radius 3.7, on the
//            mid-plane (outer radius 13.325)
//   sockets — 2 axial into the lobe poles, 4 radial into the ring outer
//            equator along ±x/±y (Ø5 × 6.5 deep)

preset = 2;          // [0:Standard, 1:Tetrahedral, 2:All]
hole_diameter = 5.0; // [2.0:0.01:7.0]

/* [Hidden] */
$fa = 3;
$fs = 0.4;

R_SPH   = 11.5;    // lobe end-cap sphere radius
LOBE_CC = 30;      // spacing between the two sphere centers
RING_R  = 9.625;   // ring tube-center radius
RING_T  = 3.7;     // ring tube radius
ARC_R   = 90;      // lobe side-wall arc radius
ARC_CX  = 95.4122; // arc center (r, z) in the lower-sphere frame
ARC_CZ  = 34.6230;
FLAT_CUT  = 0;     // trimmed off the bottom pole: stable print face
BOSS_WALL = 1.2;   // material kept around a socket when the boss is enabled.
                   // 1.2 keeps the ring bosses flush inside the 7.4 tube at
                   // the reference Ø5 hole; a collar emerges only at larger
                   // holes, where the bare tube wall would drop below 1.2.
EPS = 0.01;

Z0  = R_SPH - FLAT_CUT;   // lower sphere center height
ZR  = Z0 + LOBE_CC / 2;   // ring mid-plane
Z1  = Z0 + LOBE_CC;       // upper sphere center
TOP = Z1 + R_SPH;         // top pole
RING_OUT = RING_R + RING_T;

// Profile angles (degrees) derived from the STEP surfaces:
A_TAN  = 19.9447;   // sphere/arc tangency, measured at the sphere center
ARC_A0 = -160.0553; // arc from that tangency...
ARC_A1 = -165.1104; // ...to its intersection with the ring tube circle
RING_A = -108.7742; // ring tube angle at that intersection

// Tetrahedral Socket Configuration
R_TETRA = 11.0;     // Base distance from center to the outer face of the tetrahedral boss
D_TETRA = 6.5;      // Depth of the tetrahedral hole
T_TETRA = 27.0;     // [0:0.01:90] Tilt angle for the sockets (tuned to 29 deg)
O_TETRA = 2.0;      // Outward offset to prevent the bottom of the hole from clipping the lobe

EFF_R_TETRA = R_TETRA + O_TETRA; // Total distance from center to socket face

// Parameterized symmetric tetrahedral vectors using spherical coordinates
T1 = [ cos(45)*cos(T_TETRA),  sin(45)*cos(T_TETRA),  sin(T_TETRA) ];
T2 = [ cos(225)*cos(T_TETRA), sin(225)*cos(T_TETRA), sin(T_TETRA) ];
T3 = [ cos(315)*cos(T_TETRA), sin(315)*cos(T_TETRA), -sin(T_TETRA) ];
T4 = [ cos(135)*cos(T_TETRA), sin(135)*cos(T_TETRA), -sin(T_TETRA) ];

STD = [
    [[0, 0, 0],           [ 0,  0,  1], 4.725, false],
    [[0, 0, TOP],         [ 0,  0, -1], 5.0,   false],
    [[ RING_OUT, 0, ZR],  [-1,  0,  0], 6.5,   true],
    [[-RING_OUT, 0, ZR],  [ 1,  0,  0], 6.5,   true],
    [[0,  RING_OUT, ZR],  [ 0, -1,  0], 6.5,   true],
    [[0, -RING_OUT, ZR],  [ 0,  1,  0], 6.5,   true],
];

TETRA = [
        [[ T1[0]*EFF_R_TETRA, T1[1]*EFF_R_TETRA, ZR + T1[2]*EFF_R_TETRA ], -T1, D_TETRA, true],
        [[ T2[0]*EFF_R_TETRA, T2[1]*EFF_R_TETRA, ZR + T2[2]*EFF_R_TETRA ], -T2, D_TETRA, true],
        [[ T3[0]*EFF_R_TETRA, T3[1]*EFF_R_TETRA, ZR + T3[2]*EFF_R_TETRA ], -T3, D_TETRA, true],
        [[ T4[0]*EFF_R_TETRA, T4[1]*EFF_R_TETRA, ZR + T4[2]*EFF_R_TETRA ], -T4, D_TETRA, true]
];
// A socket is [position, direction, depth, boss].
PRESETS = [
    STD,// preset 0 "Standard": both lobe poles axially, ring at ±x/±y radially.
    TETRA,// preset 1 "Tetrahedral": 4 symmetric sockets for sp3 bonds, bosses enabled for structural support.
    concat(STD, TETRA),// preset 2 All 
];
sockets = PRESETS[preset];

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

module body() {
    rotate_extrude() polygon(PROFILE);
}

difference() {
    union() {
        body();
        for (s = sockets) if (s[3]) socket_boss(s);
    }
    for (s = sockets) socket_hole(s);
}