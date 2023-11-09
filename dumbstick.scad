// length unit: millimeters


PULL = 0; //[0:0.1:13]
PRINT_EPSILON = 0.4;
CAD_EPSILON = 0.05;
AXIS_DIAMETER = 6;

module __customizer_delimiter__(){} // every variable below here is not shown in customizer

solenoid_body_diameter = 26;
solenoid_thread_diameter = 13;
solenoid_body_height = 53;

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
        thread_diameter = solenoid_thread_diameter;
        thread_extend = 8;

        cylinder(h=solenoid_body_height,d=body_diameter);
        translate([0,0,-thread_extend])
            cylinder(h=thread_extend,d=thread_diameter);
        plunger();
    }
}

// IMU: GY-521
IMU_DIM = [21, 15, 1.2];
IMU_DHOLE = 2.54;
IMU_RHOLE = 3;

IMU_B0_POS = [5,25,20];
IMU_TIPPER_POS = [-43,15,15];

module imu_hole_cylinders(h=10,dh=0,r=IMU_RHOLE+PRINT_EPSILON) {
    module hole() {
        translate([0,0,dh]) cylinder(h=h, d=r);
    }
    translate([IMU_DHOLE, IMU_DHOLE, 0])  hole();
    translate([IMU_DIM[0]-IMU_DHOLE, IMU_DHOLE, 0])  hole();
}

module imu() {
    module hole() {
        translate([0,0,-10]) cylinder(h=20, d=3);
    }
    electronics_part() {
        difference() {
            cube(IMU_DIM);
            imu_hole_cylinders(h=10,dh=-5);
        }
    }
}

module imu_B0_cutout() {
    outer_hole_depth = 2;
    outer_hole_dr = 4;
    translate(IMU_B0_POS) {
        imu_hole_cylinders(30,dh=-20);
        imu_hole_cylinders(5+outer_hole_depth,dh=-15,r=IMU_RHOLE+outer_hole_dr);
    }
}

module imu_TIPPER_cutout() {
    e = PRINT_EPSILON;
    e2 = e*2;
    translate(IMU_TIPPER_POS) {
        translate([-e,-e,0]) {
            cube([IMU_DIM[0]+e2,IMU_DIM[1]+e2,10]);
        }
        imu_hole_cylinders(30,dh=-20);
    }
}

module B0() {
    // primary stop screw
    stop0_diameter = 6.5;
    stop0_angle = 25; // TODO angle should be from "outer" endpoint? (or at least the other endpoint)
    stop0_offset = 72;

    wire_diameter = 4;

    difference() {
        translate([0,0,-20]) linear_extrude(height=40, convexity=3) import("b0.dxf");
        translate([-50,-10,-10]) cube([100,40+10,20]);
        translate([15,15,-50]) cylinder(h=100,d=AXIS_DIAMETER);
        translate([stop0_offset,0,0]) rotate([0,0,stop0_angle]) rotate([-90,0,0]) cylinder(h=100,d=stop0_diameter);
        translate([70,0,0]) rotate([-90,0,0]) cylinder(h=100,d=wire_diameter);
        translate([70,105,0]) rotate([-90,0,0]) cylinder(h=solenoid_body_height+1,d=solenoid_body_diameter+PRINT_EPSILON);
        imu_B0_cutout();
    }
}

module B0_solenoid() {
    translate([70,105,0])
    rotate([-90,0,0])
    solenoid();
}

module B0_imu() {
    translate(IMU_B0_POS) imu();
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
    xt=100;
    module strip_hole() {
        d0=10;
        r0=sqrt(pow(d0,2) + pow(tipper_depth/2,2));
        translate([0,0,-xt/2]) {
            difference() {
                cube([stripw,striph,xt]);
                translate([stripw/2,-d0,xt/2+d/2]) rotate([0,90,0]) translate([0,0,-50]) cylinder(r=r0,h=100);
            }
        }
    }
    module strip_holes() {
        translate([w/2-stripw/2,7,0]) {
            sd0 = 26;
            translate([sd0,0,0]) strip_hole();
            translate([-sd0,0,0]) strip_hole();
            sd1 = 38;
            translate([sd1,0,0]) strip_hole();
            translate([-sd1,0,0]) strip_hole();
        }
    }
    translate([0,hh,0]) rotate([0,0,angle]) translate([0,-hh,0]) {
        translate([-w/2,0,0]) {
            difference() {
                cube([w,ln,d]);
                translate([w/2,ln/2,-d/2]) cylinder(h=30,d=AXIS_DIAMETER);
                translate([0,0,d/2]) rotate([0,90,0]) translate([0,0,-margin/2]) concave_cut(d,2.5,w+margin);
                strip_holes();
                translate([w-margin,ln/2,-30]) {
                    dx = 4.5;
                    dy = 8;
                    screw_diameter = 4;
                    translate([-dx,-dy,0])    cylinder(h=60,d=screw_diameter);
                    translate([ dx,-dy,0])    cylinder(h=60,d=screw_diameter);
                    translate([ dx, dy,0])    cylinder(h=60,d=screw_diameter);
                    translate([-dx, dy,0])    cylinder(h=60,d=screw_diameter);
                }
                translate([w/2,0,-IMU_DIM[2]]) imu_TIPPER_cutout();
            }
        }
    }
}

module TIPPER_imu(angle = 0) {
    hh = tipper_height/2;
    translate([0,hh,0]) rotate([0,0,angle]) translate([0,-hh,0]) {
        translate([0,0,-IMU_DIM[2]+CAD_EPSILON]) translate(IMU_TIPPER_POS) imu();
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
