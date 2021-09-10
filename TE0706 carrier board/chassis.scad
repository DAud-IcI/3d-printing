phy_div = 10.79;

width= 1079; // 100 mm
depth = 689; // 64.61 mm
height = 1.77 * phy_div; // 1.77 mm

unit_height = 15.5 * phy_div;
unit_bottom_gap = 4.21 * phy_div;

clearance = 2 * phy_div;
wall = 3 * phy_div;
chassis_clearance = 2 * clearance + 2 * wall;

edge_screw_radius = 32 / 2;
screw_0x = 68 - edge_screw_radius;
screw_0z = 76 - edge_screw_radius;

screw_radius = 36 / 2;
screw_1x = 243 - screw_radius;
screw_1z = 180 - screw_radius;

screw_2x = screw_1x;
screw_2z = 544 - screw_radius;

screw_3x = 718 - screw_radius;
screw_3z = screw_1z;

screw_4x = screw_3x;
screw_4z = screw_2z;

gap_barrel = 96;
gap_reset = 30;
gap_usb = 75;
gap_card = 120;
gap_eth = 178;
gap_serial = 130;

barrel_y = 12 * phy_div + height;
barrel_z = 135;
reset_y = 7 * phy_div;
reset_z = 287;
usb_y = 14 * phy_div + height;
usb_z = 362;
card_y = 2 * height;
card_z = 452;
eth_y = 13.35 * phy_div + height;
eth0_z = 275;
eth1_z = 503;
serial_z = 30;
serial_y1 = 12.77 * phy_div + height;
serial_y0 = serial_y1 - 8 * phy_div;

intake_x = 401;
intake_y = 306;
intake_size = 118;
fan_h = 132;
fan_h0 = fan_h - intake_size;
fan_w = 176;
fan_w0 = fan_w - intake_size;

max_y = eth_y;
box_height = wall + unit_bottom_gap + max_y + clearance + wall;

board_coordinates = [wall + clearance, wall + clearance, wall];

module hole(x,y,r,h) translate([x, y, -1]) cylinder(h + 2, r, r);

module hole0(h = height, radius_more = 0) {
    hole(screw_0x, screw_0z, edge_screw_radius + radius_more, h);
}

module holes(h = height, radius_more = 0) {
    hole0(h, radius_more);
    hole(screw_1x, screw_1z, screw_radius + radius_more, h);
    hole(screw_2x, screw_2z, screw_radius + radius_more, h);
    hole(screw_3x, screw_3z, screw_radius + radius_more, h);
    hole(screw_4x, screw_4z, screw_radius + radius_more, h);
}

module post() {
    translate([0, 0, 1])
        difference() {
            holes(unit_bottom_gap + wall - 2, wall);
            scale([1, 1, 10]) 
                translate([0, 0, -unit_bottom_gap / 2]) 
                    holes(unit_bottom_gap + wall);
        }
}

module baseboard()
    color("green")
    difference() {
        cube([width, depth, height], center = false);
        holes();
    }

module chassis_bottom() {
    difference() {
        cube([
            width + chassis_clearance,
            depth + chassis_clearance,
            box_height], center = false);
        
        translate([wall + clearance, wall + clearance, 0]) 
            scale([1, 1, 10]) 
                translate([0, 0, -unit_bottom_gap / 2]) 
                    holes(unit_bottom_gap + wall);
        
        translate([wall, wall, wall]) 
            cube([
                width + 2 * clearance,
                depth + 2 * clearance,
                box_height], center = false);
        
        translate([-10, wall + clearance, wall + unit_bottom_gap]) union() {
            translate([0, barrel_z, height]) cube([100,gap_barrel,barrel_y - height]);
            translate([0, reset_z, height]) cube([100,gap_reset,reset_y - height]);
            translate([0, usb_z, 0]) cube([100,gap_usb,usb_y]);
            translate([0, card_z, height / 2]) cube([100,gap_card,card_y]);
        };
        
        translate([wall * 0.75, wall + clearance, wall + unit_bottom_gap]) union()
            translate([0, usb_z - (gap_usb / 4), 0])
            cube([100, gap_usb * 1.5, usb_y*10]);
        
        translate([width + chassis_clearance - wall - 10, wall + clearance, wall + unit_bottom_gap]) union() {
            translate([0, eth0_z, 0]) cube([100,gap_eth,eth_y]);
            translate([0, eth1_z, 0]) cube([100,gap_eth,eth_y]);
            translate([0, serial_z, serial_y0]) cube([100,gap_serial,serial_y1 - serial_y0]);
        };
        
        //* Branding
        translate([50, 10, 50])
            scale([1,10,1])
            rotate([90,0,0])    
            linear_extrude( 3.6)
            projection(cut = true)
            translate ([0,0,70])
            surface(file = "hastlayer-logo-tagline-120h.png", center = false, invert = true);
        // */
    }
}

module chassis_top() {
    difference() {
        union() {
            // Top flush layer
            translate([0, 0, box_height]) 
                cube([
                    width + chassis_clearance,
                    depth + chassis_clearance,
                    wall], center = false);
            // Bottom indented layer
            translate([wall, wall, box_height - wall]) 
                cube([
                    width + 2 * clearance,
                    depth + 2 * clearance,
                    wall], center = false);
        }
        
        translate(board_coordinates) {
            // Bottom left screw hole
            scale([1, 1, 10]) 
                translate([0, 0, -unit_bottom_gap / 2]) 
                    hole0(unit_bottom_gap + wall);
            
            // Intake hole
            translate([intake_x, intake_y, 0])
            cube([intake_size, intake_size, box_height * 2], center = false);
        }
        
        // Fan power connector hole
        fan_wire_hole_size = 10 * phy_div;
        translate([75 * phy_div, 12 * phy_div, 0])
            cube([fan_wire_hole_size, fan_wire_hole_size, box_height * 2], center=false);
        
        // Fan screw holes
        translate([658, 121, 0])
            cylinder(h = box_height * 2, r = screw_radius);
        translate([1060.5, 577.5, 0])
            cylinder(h = box_height * 2, r = screw_radius);
    }
}

// Placeholder for the fan - base top left corner is origin
module fan() {
    scale(phy_div) {
        //translate([0, -50.69, 0]) cube([51.37, 50.69, 10], center=false); // 51.37mm x 50.69mm
        import("FANBB5015H12.stl");
    }
}

module funnel_shape(lip, lip_offset = 0, inset = 0) {
    union() {
        translate([inset, inset, -lip + lip_offset]) 
            linear_extrude(lip)
                square(intake_size - 2 * inset, center = false);
        
        hull() {
            translate([inset, inset, 0])
                linear_extrude(1)
                    square(intake_size - 2 * inset, center = false);
         
            for (i = [0 : 10])
            translate([intake_size, 75 + inset, 17 + inset])
                rotate([0, (i * -9) - 90, 0])
                    linear_extrude(1)
                        square([
                            fan_h - (fan_h0 * i / 10.0) - 2 * inset,
                            fan_w - (fan_w0 * i / 10.0) - 2 * inset], center = false); 
        }
        translate([intake_size + lip - lip_offset, 75 + inset, 17 + inset])
            rotate([0, -90, 0])
                linear_extrude(lip)
                    square([fan_h - 2 * inset, fan_w - 2 * inset], center = false);
    }
}

module funnel() {
    inside_mul = 0.8;
    translate([intake_x, intake_y, box_height])
    {
        difference() {
            funnel_shape(wall);
            funnel_shape(wall * 10, 1, wall / 2);
        }
    }
}

scale(1 / phy_div) {
    // Board illustration
    //translate([wall + clearance, wall + clearance, wall + unit_bottom_gap]) baseboard();
    
    //* Bottom chassis model
    color("azure")
    union() {
        chassis_bottom();
        
        // Screw posts.
        difference() {
            translate([wall + clearance, wall + clearance, 0]) post();
            
            // Cutoff for an underside capacitor.
            // Board coordinates.
            translate(board_coordinates) 
                // Bottom left of the #1 post.
                translate([screw_1x - screw_radius - wall, screw_1z - screw_radius - wall, 0])
                cube([0.75 * wall, 2 * wall + 2 * screw_radius, 1000]);
        }
    } // */
    
    //* Top chassis model
    color("lightblue")
        chassis_top();
    // */
    
    //* Funnel between the fan and the air intake
    translate(board_coordinates) {
        color("lightgreen")
        funnel();
        
        //translate([intake_x + intake_size, intake_y + intake_size + 150, box_height]) fan(); 
    }
    // */
}