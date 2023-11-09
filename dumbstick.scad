// length unit: millimeters


PULL = 0; //[0:0.1:13]
PRINT_EPSILON = 0.4;
CAD_EPSILON = 0.05;
AXIS_DIAMETER = 6;

module __customizer_delimiter__(){} // every variable below here is not shown in customizer

solenoid_body_diameter = 26;
solenoid_thread_diameter = 13;

module metal_part() {
    C = 0.8;
    color([C,C,C]) children();
}

module electronics_part() {
    color([0,0.3,0.8]) children();
}

module solenoid() {
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

    metal_part() {
        body_diameter = solenoid_body_diameter;
        body_height = 53;
        thread_diameter = solenoid_thread_diameter;
        thread_extend = 8;

        cylinder(h=body_height,d=body_diameter);
        translate([0,0,-thread_extend])
            cylinder(h=thread_extend,d=thread_diameter);
        plunger();
    }
}

module imu() {
    electronics_part() {
        cube([21, 15, 1.2]); // GY-521
    }
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
        translate([70,105,0]) rotate([-90,0,0]) cylinder(h=100,d=solenoid_body_diameter+PRINT_EPSILON);
    }
}

module B0_solenoid() {
    translate([70,105,0])
    rotate([-90,0,0])
    solenoid();
}

module B0_imu() {
    translate([5,20,20])
    imu();
}

module fastener(s, sub_epsilon = false) {
    // XXX does PRINT_EPSILON hold at an angle?
    dh = sub_epsilon ? -PRINT_EPSILON : 0;
    ds = sub_epsilon ? -PRINT_EPSILON : 0;
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

module TIPPER(angle = 0) {
    d = tipper_depth;
    margin = tipper_margin;
    w = tipper_pull_radius*2 + margin*2;
    ln = tipper_height;
    hh = ln/2;
    stripw = 8;
    striph = 5;
    module strip_hole() {
        translate([0,0,-50]) cube([stripw,striph,100]);
    }
    translate([0,hh,0]) rotate([0,0,angle]) translate([0,-hh,0]) {
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
}

module TIPPER_imu(angle = 0) {
    hh = tipper_height/2;
    translate([0,0,15]) {
        translate([0,hh,0]) rotate([0,0,angle]) translate([0,-hh,0]) {
            translate([-43,15,0]) {
                imu();
            }
        }
    }
}


module tipper_cut() {
    translate([tipper_pull_radius-tipper_margin,0,tipper_depth/2]) cube([100,100,30]);
}

module groove_diamond(w,d,h,xt,eps) {
    linear_extrude(height=h+xt)
    polygon([
        [-w/2+eps,0],
        [0,d-eps],
        [w/2-eps,0],
        [0,-d+eps]
    ]);
}

module tipper_groove(xt=0,eps=0) {
    translate([tipper_pull_radius-tipper_margin,tipper_height/2,tipper_depth/2])
    rotate([90,0,0])
    rotate([0,90,0])
    groove_diamond(3,1,tipper_margin*2,xt,eps);
}

module tipper_grooves(xt=0,eps=0) {
    d = 3;
    translate([0,d,0]) tipper_groove(xt,eps);
    translate([0,-d,0]) tipper_groove(xt,eps);
}

module TIPPER_main() {
    difference() {
        TIPPER();
        tipper_cut();
        tipper_grooves(CAD_EPSILON);
    }
}

module TIPPER_clamp() {
    translate([0,tipper_height,tipper_depth/2])
    rotate([180,0,0])
    translate([0,0,-tipper_depth/2])
    union() {
        intersection() {
            TIPPER();
            tipper_cut();
        }
        tipper_grooves(0,PRINT_EPSILON);
    }
}
