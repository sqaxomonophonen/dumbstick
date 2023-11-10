include <dumbstick.scad>

SHOW_SOLENOID = true;
SOLENOID_PULL = 0;//[0:1:18]
SHOW_IMUS = true;
SHOW_STICK = true;
TIPPER_ANGLE = 10;//[-45:1:45]

module VISHACK() {
    // OpenSCAD makes render errors sometimes...
    translate([0,0,0.001]) children();
}

translate([0,0,20]) B0_bottom();
translate([-10,0,20]) rotate([0,180,0]) B0_top();

dhat = 10;
//dhat = -130;
translate([0,dhat,0]) translate([0,0,20]) B0_hat_bottom();
translate([0,dhat,0]) translate([-10,0,20]) rotate([0,180,0]) B0_hat_top();


translate([0,-60,0]) {
    translate([0,0,0]) TIPPER_main();
    translate([30,0,0]) TIPPER_clamp();
}

translate([300,0,0]) {
    B0();
    GRIP();
    translate([15,0,-15/2]) {
        VISHACK() TIPPER(angle = TIPPER_ANGLE);
        if (SHOW_IMUS) {
            TIPPER_imu(angle = TIPPER_ANGLE);
        }
        if (SHOW_STICK) {
            TIPPER_stick(angle = TIPPER_ANGLE);
        }
    }
    if (SHOW_SOLENOID) {
        B0_solenoid(SOLENOID_PULL);
    }
    if (SHOW_IMUS) {
        VISHACK() B0_imu();
    }
}
