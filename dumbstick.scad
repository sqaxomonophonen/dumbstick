// length unit: millimeters

PULL = 0; //[0:0.1:13]
EPSILON = 0.4;
AXIS_DIAMETER = 6;

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

    // primary stop screw
    stop0_diameter = 6.5;
    stop0_angle = 25;
    stop0_offset = 72;

    wire_diameter = 4;

    difference() {
        translate([0,0,-20]) linear_extrude(height=40, convexity=3) import("b0.dxf");
        translate([-50,-10,-10]) cube([100,40+10,20]);
        translate([15,15,-50]) cylinder(h=100,d=AXIS_DIAMETER);
        translate([stop0_offset,0,0]) rotate([0,0,stop0_angle]) rotate([-90,0,0]) cylinder(h=100,d=stop0_diameter);
        translate([70,0,0]) rotate([-90,0,0]) cylinder(h=100,d=wire_diameter);
        translate([70,105,0]) rotate([-90,0,0]) cylinder(h=100,d=solenoid_body_diameter+EPSILON);
    }
}

module fastener(s, sub_epsilon = false) {
    // XXX does EPSILON hold at an angle?
    dh = sub_epsilon ? -EPSILON : 0;
    ds = sub_epsilon ? -EPSILON : 0;
    cylinder(h=3+dh,d1=s+ds,d2=s/2+ds);
    mirror([0,0,1]) cylinder(h=3+dh,d1=s+ds,d2=s/2+ds);
}

module B0_fasteners(sub_epsilon = false) {
    translate([17,55,0]) fastener(10, sub_epsilon);
    translate([52,70,0]) fastener(7, sub_epsilon);
    translate([52,100,0]) fastener(7, sub_epsilon);
}

module B0_bottom() {
    union() {
        difference() {
            B0();
            translate([-10,0,0]) cube([200,200,100]);
        }
        B0_fasteners(true);
    }
}

module B0_top() {
    difference() {
        difference() {
                B0();
                translate([-10,0,-100]) cube([200,200,100]);
            }
        B0_fasteners();
    }
}

module concave_cut(w,d,h) {
    m = 1.2;
    ex = w/2 * m;
    ey = d - (d/(w/2)) * (w/2)*m;
    linear_extrude(height=h)
    polygon([
        [-ex,ey],
        [ 0,d],
        [ ex,ey],
        [ ex,-10+ey],
        [-ex,-10+ey]
    ]);
}

tipper_depth = 15;
tipper_pull_radius = 55;
tipper_margin = 10;
tipper_height = 30;

module TIPPER() {
    d = tipper_depth;
    margin = tipper_margin;
    w = tipper_pull_radius*2 + margin*2;
    ln = tipper_height;
    stripw = 8;
    striph = 5;
    module strip_hole() {
        translate([0,0,-50]) cube([stripw,striph,100]);
    }
    translate([-w/2,0,0]) {
        difference() {
            cube([w,ln,d]);
            translate([w/2,ln/2,-d/2]) cylinder(h=30,d=AXIS_DIAMETER);
            translate([0,0,d/2]) rotate([0,90,0]) translate([0,0,-margin/2]) concave_cut(d,2.5,w+margin);
            translate([w/2-stripw/2,7,0]) {
                sd0 = 26;
                translate([sd0,0,0]) strip_hole();
                translate([-sd0,0,0]) strip_hole();
                sd1 = 38;
                translate([sd1,0,0]) strip_hole();
                translate([-sd1,0,0]) strip_hole();
            }
            translate([w-margin,ln/2,-30]) {
                dx = 4.5;
                dy = 8;
                screw_diameter = 4;
                translate([-dx,-dy,0])    cylinder(h=60,d=screw_diameter);
                translate([ dx,-dy,0])    cylinder(h=60,d=screw_diameter);
                translate([ dx, dy,0])    cylinder(h=60,d=screw_diameter);
                translate([-dx, dy,0])    cylinder(h=60,d=screw_diameter);
            }
        }
    }
}

module tipper_cut() {
    translate([tipper_pull_radius-tipper_margin,0,tipper_depth/2]) cube([100,100,30]);
}

module TIPPER_main() {
    difference() {
        TIPPER();
        tipper_cut();
    }
}

module TIPPER_clamp() {
    translate([0,tipper_height,tipper_depth/2])
    rotate([180,0,0])
    translate([0,0,-tipper_depth/2])
    intersection() {
        TIPPER();
        tipper_cut();
    }
}
