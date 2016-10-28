module hulled_card(size, thickness, front_square=false, rear_square=false) {
    // draw a card including a square or circle hull
    hull() {
        square([size[1], size[2]]); // card
        // place a circle or square in each corner
        color("blue")
        for (corner_i = [0, 1]) {
            for (corner_j = [0, 1]) {
                translate([corner_i*size[1] + (corner_i*2-1)*thickness/2,
                           corner_j*size[2] + (corner_j*2-1)*thickness/2]) {
                    // square or circle, depending on front or rear
                    if (   (corner_j == 0 && front_square)
                        || (corner_j == 1 && rear_square)) {
                        square(thickness, center=true);
                    } else {
                        circle(thickness/2);
                    }
                }
            }
        }
    }
}

module hulled_card_border(size, spacing, thickness, front_square=false, rear_square=false, rear_only=false) {
    // draw only the border of a card (of thickness)
    difference() {
        hulled_card(size, spacing+thickness, front_square=front_square, rear_square=rear_square);
        if (!rear_only) {
            hulled_card(size, spacing);
        } else {
            translate([-(thickness + spacing), -(thickness + spacing), 0])
            hulled_card([size[0], size[1]+thickness*2+spacing*2, size[2]+thickness+spacing], spacing);
        }
    }
}

module cardholder_part(size, spacing, thickness, visibility, raise, delta, front, rear, rear_visibility, extend_down=10, show_carts=false) {
    // there are three sections:
    // filled
    translate([0, 0, -extend_down]) {
        linear_extrude(raise+thickness + extend_down) {
            hulled_card(size, spacing+thickness);
        }
        // with card hole and front square, up to the height of the previous card holder
        if (!front) {
            linear_extrude(raise-delta+thickness+spacing+size[0] * (1-visibility)) {
                hulled_card_border(size, spacing, thickness, front_square=!front, rear_square=!rear);
            };
        }
    }
    // and the rest, up to visibility
    linear_extrude(raise+thickness + spacing + size[0] * (1-visibility)) {
        hulled_card_border(size, spacing, thickness, rear_square=!rear);
    };
    if (rear) {
        linear_extrude(raise+thickness + spacing + size[0] * (1-rear_visibility)) {
            hulled_card_border(size, spacing, thickness, rear_square=!rear, rear_only=true);
        };
    }
    
    if (show_carts) {
        // draw a fake card
        translate([0, 0, raise])
        color("gray") render() color("gray") cube([size[1], size[2], size[0]]);
    }
}

module cardholder(size=[85, 54, 1], thickness=3, spacing=1, cards=4, delta=25, visibility=0.3, rear_visibility=0.2, angle=0, crop_bottom=false, show_carts=false) {
    // hard conditions in the assignment
    if (len(size) > 1
        && size[0] > 0 && size[1] > 0
        && cards > 0) {
        // make sure size is 3-tuple
        size_ = [size[0], size[1], len(size) < 3 ? 0 : size[2]];
        // clamp the visibility, thickness, and spacnig
        visibility_ = visibility < 0 ? 0 : visibility > 1 ? 1 : visibility;
        thickness_  = thickness  < 0 ? 0 : thickness;
        spacing_    = spacing    < 0 ? 0 : spacing;
        // use an absolute delta
        delta_ = abs(delta);
        // prepare for rotation if delta is negative
        rot = delta < 0;
        // calculate the width and length so the structure can be centered.
        holder_width = thickness_*2 + spacing_*2 + size_[1];
        holder_length = (thickness_ + spacing_*2 + size_[2]) * cards + thickness_;
        // I only used this to verify
        holder_height = (delta_*(cards-1))  + (thickness_ + spacing_ + size_[0] * (1-visibility_));
        
        // this is crude: we cut off the parts of the cartholder
        // that end up under ground
        difference() {
            union() {
                // rotate if delta was negative
                rotate([0, 0, rot ? 180 : 0])
                // lay the card holder down
                rotate([-angle, 0, 0])
                // center the card holder as requested
                translate([-holder_width/2, -holder_length/2, 0]) {
                    // for each card
                    for (i = [0 : cards-1]) {
                        // render the card holder part, including the filled part from
                        // the ground, properly shifted so that it overlays the previous
                        // card holder part's rear thickness.
                        translate([thickness_+spacing_, thickness_+spacing_+i*(thickness_+spacing_*2+size_[2]), 0])
                            cardholder_part(size_, spacing_, thickness_, visibility_, delta_*i,
                            delta_,
                            front = i == 0,
                            rear  = i == cards-1,
                            rear_visibility = rear_visibility,
                            show_carts = show_carts);
                    }
                };
                
                if (angle) {
                    // add a back stand for stability
                    translate([-holder_width/2, holder_length/2, 0])
                    rotate([-angle, 0, 0])
                    translate([0, -thickness, 0])
                    cube([holder_width, holder_height, holder_height/4]);
                }
            }
            
            if (crop_bottom) {
                // a huge cube under the cartholder
                color("red") translate([-500, -500, -1000]) cube([1000, 1000, 1000]);
            }
            
        }
        
   }
}

angle = 22.5;
cardholder([65, 57, 7.5], thickness=3, spacing=1, cards=4, delta=25, visibility=0.8, angle=angle, rear_visibility=0.3, crop_bottom=true, show_carts=false);

