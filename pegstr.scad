// PEGSTR - Pegboard Wizard
// Design by Marius Gheorghescu, November 2014
// Update log:
// November 9th 2014
//		- first coomplete version. Angled holders are often odd/incorrect.
// November 15th 2014
//		- minor tweaks to increase rendering speed. added logo. 
// November 28th 2014
//		- bug fixes
// March 2020
//      - compatibility with Euro pegboards

// preview[view:north, tilt:bottom diagonal]

// width of the orifice
holder_x_size = 10.0;

// depth of the orifice
holder_y_size = 10.0;

// hight of the holder
holder_height = 15;

// how thick are the walls. Hint: 6*extrusion width produces the best results.
wall_thickness = 1.85;

// how many times to repeat the holder on X axis
holder_x_count = 1;

// how many times to repeat the holder on Y axis
holder_y_count = 2;

// orifice corner radius (roundness). Needs to be less than min(x,y)/2.
corner_radius = 30;

// Use values less than 1.0 to make the bottom of the holder narrow
taper_ratio = 1.0;


/* [Advanced] */

// offset from the peg board, typically 0 unless you have an object that needs clearance
holder_offset = 0.0;

// what ratio of the holders bottom is reinforced to the plate [0.0-1.0]
strength_factor = 0.1;

// number of horizontal rows of pins, should be 1 or more.
min_pin_z_count=1;

// for bins: what ratio of wall thickness to use for closing the bottom
closed_bottom = 0.0;

// what percentage cu cut in the front (example to slip in a cable or make the tool snap from the side)
holder_cutout_side = 0.0;

// set an angle for the holder to prevent object from sliding or to view it better from the top
holder_angle = 0.0;


/* [Hidden] */

// what is the $fn parameter
holder_sides = max(50, min(20, holder_x_size*2));

// dimensions EU Pegboard
hole_spacing_z = 25;
hole_spacing_x = 37.5;

hole_size_x = 7;
hole_size_z = 4.5;
board_thickness = 1.8;

// TODO check this!!!
edge_size = 8.45;
edge_thickness = 2.5;
min_width_for_single_height = 32;

holder_total_y = wall_thickness + holder_y_count*(wall_thickness+holder_y_size);
holder_total_temp_x = wall_thickness + holder_x_count*(wall_thickness+holder_x_size);
holder_total_z = max(holder_height, (min_pin_z_count-1) * hole_spacing_z);
holder_roundness = min(corner_radius, holder_x_size/2, holder_y_size/2); 

pin_z_count = max(holder_height / hole_spacing_z, min_pin_z_count);

holder_total_x = pin_z_count == 1 ? max(min_width_for_single_height, holder_total_temp_x) : holder_total_temp_x;

pin_x_count = floor(holder_total_x/hole_spacing_x) + 1;


// what is the $fn parameter for holders
fn = 32;

epsilon = 0.1;

$fn = fn;

module round_rect_ex(x1, y1, x2, y2, z, r1, r2)
{
	$fn=holder_sides;
	brim = z/10;

	hull() {
        translate([-x1/2 + r1, y1/2 - r1, z/2-brim/2])
            cylinder(r=r1, h=brim,center=true);
        translate([x1/2 - r1, y1/2 - r1, z/2-brim/2])
            cylinder(r=r1, h=brim,center=true);
        translate([-x1/2 + r1, -y1/2 + r1, z/2-brim/2])
            cylinder(r=r1, h=brim,center=true);
        translate([x1/2 - r1, -y1/2 + r1, z/2-brim/2])
            cylinder(r=r1, h=brim,center=true);

        translate([-x2/2 + r2, y2/2 - r2, -z/2+brim/2])
            cylinder(r=r2, h=brim,center=true);
        translate([x2/2 - r2, y2/2 - r2, -z/2+brim/2])
            cylinder(r=r2, h=brim,center=true);
        translate([-x2/2 + r2, -y2/2 + r2, -z/2+brim/2])
            cylinder(r=r2, h=brim,center=true);
        translate([x2/2 - r2, -y2/2 + r2, -z/2+brim/2])
            cylinder(r=r2, h=brim,center=true);

    }
}

module pin(clipX, clipY)
{        
	if (clipX && clipY) {
        scale([1.0,hole_size_z/edge_size,1.0])
            cylinder(d = edge_size, h = board_thickness, center=true, $fn=12);
		
        intersection() {
			translate([0, 0, board_thickness / 2])
                cylinder(d=edge_size, h=edge_thickness, center=false, $fn=12);
        }
	} else if (clipX || clipY) {
        vertical = holder_total_z > holder_total_z;
        x = vertical ? 3 : hole_size_x * 0.85;
        y = vertical ? hole_size_x * 0.85 : 3;
        translate([0,0,-board_thickness / 2 + 0.4])
            scale([1.0,y/x,1.0])
            cylinder(d= hole_size_x*0.85, h = 0.8, center=true);
    }
}

module pinboard_clips() 
{
	rotate([0,90,0]){        
        xTempCount = floor(holder_total_x/(hole_spacing_x / 3));
        xCount = xTempCount % 3 == 1 ? xTempCount - 1 : (xTempCount% 3 == 3 ? xTempCount - 1 : xTempCount);
        zCount = pin_z_count * 2 - 2;
        
        for(x=[0:xCount]) {
            for(z=[0:zCount]) {
                
                rowIsEven = z % 2 == 0;
                firstItem = x == 0;
                lastItem = x == xCount - 1;
                firstRow = z == 0;
                skipWhen = !firstRow && rowIsEven && (firstItem || lastItem) && (firstItem && lastItem);
                
                if (!skipWhen) {                
                    translate([
                        z * hole_spacing_z/2 + (hole_size_x - hole_size_z)/4, 
                        -(hole_spacing_x/3) * xCount/2 + (x * hole_spacing_x/3), 
                        0])
                            pin(z % 2 == 0, (
                    (x % 3 == 1 && xCount % 3 != 0) ||
                    (xCount % 3 == 0 && x % 3 == 0)));
                }
            }
        }
    }
}

module pinboard()
{
        
	rotate([0,90,0])
	translate([-epsilon, 0, -wall_thickness - board_thickness/2 + epsilon])
	hull() {
		translate([0, 
			-holder_total_x/2,0])
			cylinder(r=hole_size_x/2, h=wall_thickness);

		translate([0, 
			holder_total_x/2,0])
			cylinder(r=hole_size_x/2,  h=wall_thickness);

		translate([max(strength_factor, pin_z_count - 1)*hole_spacing_z + 2,
			-hole_spacing_x*((pin_x_count-1)/2),0])
			cylinder(r=hole_size_x/2, h=wall_thickness);

		translate([max(strength_factor, pin_z_count - 1)*hole_spacing_z + 2,
			hole_spacing_x*((pin_x_count-1)/2),0])
			cylinder(r=hole_size_x/2,  h=wall_thickness);

	}
}

module holder(negative)
{
    delta_x = max(0, holder_total_x-(holder_x_count * (holder_x_size + 2*wall_thickness))) / 2;
    
	for(x=[1:holder_x_count]){
		for(y=[1:holder_y_count]) 
		render(convexity=2) {
			translate([
				-holder_total_y /*- (holder_y_size+wall_thickness)/2*/ + y*(holder_y_size+wall_thickness) + wall_thickness,

				delta_x - holder_total_x/2 + (holder_x_size+wall_thickness)/2 + (x-1)*(holder_x_size+wall_thickness) + wall_thickness/2,
				 0])			
	{
		rotate([0, holder_angle, 0])
		translate([
			-wall_thickness*abs(sin(holder_angle))-0*abs((holder_y_size/2)*sin(holder_angle))-holder_offset-(holder_y_size + 2*wall_thickness)/2 - board_thickness/2,
			0,
			-(holder_height/2)*sin(holder_angle) - holder_height/2 + hole_size_x/2
		])
		difference() {
			if (!negative)

				round_rect_ex(
					(holder_y_size + 2*wall_thickness), 
					holder_x_size + 2*wall_thickness, 
					(holder_y_size + 2*wall_thickness)*taper_ratio, 
					(holder_x_size + 2*wall_thickness)*taper_ratio, 
					holder_height, 
					holder_roundness + epsilon, 
					holder_roundness*taper_ratio + epsilon);

				translate([0,0,closed_bottom*wall_thickness])

				if (negative>1) {
					round_rect_ex(
						holder_y_size*taper_ratio, 
						holder_x_size*taper_ratio, 
						holder_y_size*taper_ratio, 
						holder_x_size*taper_ratio, 
						3*max(holder_height, hole_spacing_z),
						holder_roundness*taper_ratio + epsilon, 
						holder_roundness*taper_ratio + epsilon);
				} else {
					round_rect_ex(
						holder_y_size, 
						holder_x_size, 
						holder_y_size*taper_ratio, 
						holder_x_size*taper_ratio, 
						holder_height+2*epsilon,
						holder_roundness + epsilon, 
						holder_roundness*taper_ratio + epsilon);
				}

			if (!negative)
				if (holder_cutout_side > 0) {

				if (negative>1) {
					hull() {
						scale([1.0, holder_cutout_side, 1.0])
		 					round_rect_ex(
							holder_y_size*taper_ratio, 
							holder_x_size*taper_ratio, 
							holder_y_size*taper_ratio, 
							holder_x_size*taper_ratio, 
							3*max(holder_height, hole_spacing_z),
							holder_roundness*taper_ratio + epsilon, 
							holder_roundness*taper_ratio + epsilon);
		
						translate([0-(holder_y_size + 2*wall_thickness), 0,0])
						scale([1.0, holder_cutout_side, 1.0])
		 					round_rect_ex(
							holder_y_size*taper_ratio, 
							holder_x_size*taper_ratio, 
							holder_y_size*taper_ratio, 
							holder_x_size*taper_ratio, 
							3*max(holder_height, hole_spacing_z),
							holder_roundness*taper_ratio + epsilon, 
							holder_roundness*taper_ratio + epsilon);
					}
				} else {
					hull() {
						scale([1.0, holder_cutout_side, 1.0])
		 					round_rect_ex(
							holder_y_size, 
							holder_x_size, 
							holder_y_size*taper_ratio, 
							holder_x_size*taper_ratio, 
							holder_height+2*epsilon,
							holder_roundness + epsilon, 
							holder_roundness*taper_ratio + epsilon);
		
						translate([0-(holder_y_size + 2*wall_thickness), 0,0])
						scale([1.0, holder_cutout_side, 1.0])
		 					round_rect_ex(
							holder_y_size, 
							holder_x_size, 
							holder_y_size*taper_ratio, 
							holder_x_size*taper_ratio, 
							holder_height+2*epsilon,
							holder_roundness + epsilon, 
							holder_roundness*taper_ratio + epsilon);
						}
					}

				}
			}
		} // positioning
	} // for y
	} // for X
}


module pegstr() 
{
	difference() {
		union() {

			pinboard();


			difference() {
				hull() {
					pinboard();
	
					intersection() {
						translate([-holder_offset - (strength_factor-0.5)*holder_total_y - wall_thickness/4,0,0])
						cube([
							holder_total_y + 2*wall_thickness, 
							holder_total_x + wall_thickness, 
							2*holder_height
						], center=true);
	
						holder(0);
	
					}	
				}

				if (closed_bottom*wall_thickness < epsilon) {
						holder(2);
				}

			}

			color([0.7,0,0])
			difference() {
				holder(0);
				holder(2);
			}

			color([1,0,0])
				pinboard_clips();
		}
	
		holder(1);

		translate([-board_thickness/2,-1,-hole_size_x*2]) 
		rotate([-90,0,90]) {
			intersection() {
				union() {
					difference() {
						round_rect_ex(3, 10, 3, 10, 2, 1, 1);
						round_rect_ex(2, 9, 2, 9, 3, 1, 1);
					}
			
					translate([2.5, 0, 0]) 
						difference() {
							round_rect_ex(3, 10, 3, 10, 2, 1, 1);
							round_rect_ex(2, 9, 2, 9, 3, 1, 1);
						}
				}
			
				translate([0, -3.5, 0]) 
					cube([20,4,10], center=true);
			}
		
			translate([1.25, -2.5, 0]) 
				difference() {
					round_rect_ex(8, 7, 8, 7, 2, 1, 1);
					round_rect_ex(7, 6, 7, 6, 3, 1, 1);
		
					translate([3,0,0])
						cube([4,2.5,3], center=true);
				}
		
		
			translate([2.0, -1.0, 0]) 
				cube([8, 0.5, 2], center=true);
		
			translate([0,-2,0])
				cylinder(r=0.25, h=2, center=true, $fn=12);
		
			translate([2.5,-2,0])
				cylinder(r=0.25, h=2, center=true, $fn=12);
		}

	}
}


rotate([180,0,0]) pegstr();

