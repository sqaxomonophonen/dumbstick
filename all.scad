include <dumbstick.scad>

SHOW_SOLENOID = true;

translate([0,0,20]) B0_bottom();
translate([-10,0,20]) rotate([0,180,0]) B0_top();
translate([100,0,0]) B0();

translate([0,-60,0]) {
    translate([0,0,0]) TIPPER_main();
    translate([30,0,0]) TIPPER_clamp();
}

translate([100+15,0,-15/2]) TIPPER();

if (SHOW_SOLENOID) {
    C = 0.8;
    color([C,C,C])
    translate([70+100,105,0])
    rotate([-90,0,0])
    solenoid();
}
