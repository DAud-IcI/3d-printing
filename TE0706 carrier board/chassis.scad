phy_div = 10.79;

width= 1079; // 100 mm
depth = 689; // 64.61 mm
height = 1.77 * phy_div; // 1.77 mm

unit_height = 15.5 * phy_div;
unit_bottom_gap = 4.21 * phy_div;

clearance = 2 * phy_div;
wall = 3 * phy_div;

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

max_y = eth_y;
box_height = wall + unit_bottom_gap + max_y + clearance;

module hole(x,y,r,h) translate([x, y, -1]) cylinder(h + 2, r, r);

module holes(h = height, radius_more = 0) {
    hole(screw_0x, screw_0z, edge_screw_radius + radius_more, h);
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
    chassis_clearance = 2 * clearance + 2 * wall;
        
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

scale(1 / phy_div) {
    union() {
        // Board illustration
        //translate([wall + clearance, wall + clearance, wall + unit_bottom_gap]) baseboard();
        
        chassis_bottom();
        
        // Screw posts.
        difference() {
            translate([wall + clearance, wall + clearance, 0]) post();
            
            // Cutoff for an underside capacitor.
            // Board coordinates.
            translate([wall + clearance, wall + clearance, wall]) 
                // Bottom left of the #1 post.
                translate([screw_1x - screw_radius - wall, screw_1z - screw_radius - wall, 0])
                cube([0.75 * wall, 2 * wall + 2 * screw_radius, 1000]);
        }
    }
}
