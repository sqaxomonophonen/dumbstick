include <dumbstick.scad>

SHOW_SOLENOID = true;
SHOW_IMUS = true;
TIPPER_ANGLE = 10;//[-45:1:45]

module VISHACK() {
    // OpenSCAD makes render errors sometimes...
    translate([0,0,0.001]) children();
}

translate([0,0,20]) B0_bottom();
translate([-10,0,20]) rotate([0,180,0]) B0_top();
translate([100,0,0]) {
    B0();
    translate([15,0,-15/2]) {
        VISHACK() TIPPER(angle = TIPPER_ANGLE);
        if (SHOW_IMUS) {
            TIPPER_imu(angle = TIPPER_ANGLE);
        }
    }
    if (SHOW_SOLENOID) {
        B0_solenoid();
    }
    if (SHOW_IMUS) {
        VISHACK() B0_imu();
    }
}

translate([0,-60,0]) {
    translate([0,0,0]) TIPPER_main();
    translate([30,0,0]) TIPPER_clamp();
}


