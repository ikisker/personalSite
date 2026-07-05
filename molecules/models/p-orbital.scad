// p-orbital.scad — CC BY 4.0, Isaac Kisker (isaackisker.com/molecules)
//
// p (2p) orbital: two lobes as one body — the union of two Ø16 spheres,
//   lobes   — spheres R8, centers 14.775 apart on the lobe (x) axis
//             (STEP centers −7.4 / +7.375, symmetrized to ±7.3875; the
//             0.0125 mm split is below print resolution)
//   sockets — 2 axial into the lobe tips (Ø5, flat bottoms at |x|=9.875 in
//             the STEP) + 1 into the waist along +z, bottoming at the model
//             centre (the drawing's three holes)

preset = 0;          // [0:Standard]
hole_diameter = 5.0; // [2.0:0.01:7.0]

/* [Hidden] */
$fa = 3;
$fs = 0.4;

R_SPH   = 8;        // lobe sphere radius (Ø16)
CX      = 7.3875;   // lobe sphere center offset on x (half of the 14.775 spacing)
POLE    = CX + R_SPH;                 // lobe tip on x = 15.3875
TIP_BOT = 9.875;                      // tip-socket flat bottom, |x| (from the STEP)
NECK_R  = sqrt(R_SPH*R_SPH - CX*CX);  // waist radius = 3.070
FLAT_CUT  = 0;      // trimmed off each lobe underside for a stable print face
BOSS_WALL = 1.2;    // Updated to match d-z2: material kept around the socket 
                    // to provide a proper structural collar.
EPS = 0.01;

FLAT_Z = -(R_SPH - FLAT_CUT);   // underside flat plane in the centered frame = −6
ZLIFT  =   R_SPH - FLAT_CUT;    // lift so the flat lands on z=0 = 6

DEPTH_TIP = POLE - TIP_BOT;     // 5.5125: pole to the socket flat bottom
DEPTH_CTR = 6.4;                // waist socket: centre (z=0) up through the
                                // surface (its rim rides to z≈6.33 on the flanks)

// A socket is [position, direction, depth, boss].
PRESETS = [
    // preset 0 "Standard": a socket in each lobe tip (axial), one in the
    // waist (+z) — the drawing's three holes.
    [
        [[-POLE, 0, 0], [ 1, 0, 0], DEPTH_TIP, false],
        [[ POLE, 0, 0], [-1, 0, 0], DEPTH_TIP, false],
        [[0, 0, 0],     [ 0, 0, 1], DEPTH_CTR, true ],
    ]
];

sockets = PRESETS[preset];

// Rotate children so their +z axis points along dir.
module orient(dir) {
    n = dir / norm(dir);
    rotate([0, acos(n[2]), atan2(n[1], n[0])]) children();
}

module socket_hole(s) {
    translate(s[0]) orient(s[1])
        translate([0, 0, -EPS]) cylinder(h = s[2] + EPS, d = hole_diameter);
}

// Replaced the spherical boss with the oriented cylindrical guide from d-z2
// This ensures the boss supports the entire length of the hole.
module socket_boss(s) {
    translate(s[0]) orient(s[1])
        cylinder(h = s[2], d = hole_diameter + 2 * BOSS_WALL);
}

module body() {
    intersection() {
        union() {
            translate([-CX, 0, 0]) sphere(R_SPH);
            translate([ CX, 0, 0]) sphere(R_SPH);
        }
        translate([0, 0, FLAT_Z + 100]) cube([200, 200, 200], center = true);
    }
}

translate([0, 0, ZLIFT])
difference() {
    union() {
        body();
        for (s = sockets) if (s[3]) socket_boss(s);
    }
    for (s = sockets) socket_hole(s);
}