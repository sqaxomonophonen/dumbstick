// length unit: millimeters

SHOW_SOLENOID = true;
PULL = 0; //[0:0.1:13]

module __customizer_delimiter__(){} // every variable below here is not shown in customizer

solenoid_body_diameter = 26;
solenoid_thread_diameter = 13;

module solenoid() {
    body_diameter = solenoid_body_diameter;
    body_height = 53;
    thread_diameter = solenoid_thread_diameter;
    thread_extend = 8;

    module plunger() {
        diameter = 10;
        extend = 35 - PULL;
        cut_depth = 10;
        cut_width = 2.7;
        cut_hole_diameter = 2.7;
        cut_aux = diameter*2;
        cut_epsilon = 0.1;
        cut_zcenter = 4;
        difference() {
            translate([0,0,-extend])
                cylinder(h=extend,d=diameter);
            translate([-cut_aux/2, -cut_width/2,-extend-cut_epsilon])
                cube([cut_aux, cut_width, cut_depth+cut_epsilon]);
            translate([0,0,-extend+cut_zcenter]) rotate([90,0,0])
                cylinder(h=diameter*20, d=cut_hole_diameter, center = true);
        }
    }

    cylinder(h=body_height,d=body_diameter);
    translate([0,0,-thread_extend])
        cylinder(h=thread_extend,d=thread_diameter);
    plunger();
}

module B0() {
    axis_diameter = 6;

    // primary stop screw
    stop0_diameter = 6.5;
    stop0_angle = 25;
    stop0_offset = 72;

    wire_diameter = 4;

    difference() {
        translate([0,0,-20]) linear_extrude(height=40, convexity=3) import("b0.dxf");
        translate([-50,-10,-10]) cube([100,30+10,20]);
        translate([15,15,-50]) cylinder(h=100,d=axis_diameter);
        translate([stop0_offset,0,0]) rotate([0,0,stop0_angle]) rotate([-90,0,0]) cylinder(h=100,d=stop0_diameter);
        translate([70,0,0]) rotate([-90,0,0]) cylinder(h=100,d=wire_diameter);
        translate([70,105,0]) rotate([-90,0,0]) cylinder(h=100,d=solenoid_body_diameter+0.4);
    }
}

module B0_bottom() {
    translate([0,0,20])
    difference() {
        B0();
        translate([-10,0,0]) cube([200,200,100]);
    }
}

module B0_top() {
    translate([0,0,20])
    difference() {
        rotate([0,180,0]) B0();
        translate([-150,-20,0]) cube([200,200,100]);
    }
}

B0_bottom();
translate([-10,0,0]) B0_top();
translate([100,0,0]) B0();



if (SHOW_SOLENOID) {
    C = 0.8;
    color([C,C,C])
    translate([70,105,0])
    rotate([-90,0,0])
    solenoid();
}
