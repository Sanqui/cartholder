use <cartholder.scad>

DEBUG = false;

cartridge_dimensions = [69, 109, 16];

cartholder(cartridge_dimensions, show_carts=DEBUG, crop_bottom=!DEBUG, delta=50, carts=3);
