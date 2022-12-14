tolerance = 0.5;
fudge = 0.005;
$fn = 40;

module cyl(dims) {
    scale(dims) translate([0.5, 0.5, 0]) cylinder(h=1, d=1);
}

module rrect(dims, border_radius) {
    cyl_d = border_radius * 2;
    hull() {
        for (ax=[0:1:1]) {
            for (ay=[0:1:1]) {
                translate([
                    ax * (dims.x - cyl_d),
                    ay * (dims.y - cyl_d),
                    0
                ]) cyl([
                    cyl_d,
                    cyl_d,
                    dims.z
                ]);
            }
        }
    }
}

function addz(xy, z) = concat(xy, [z]);

module base(
    pack_dims,
    pack_border_radius,
    wall_width,
    floor_width,
    support_width,
    support_height,
    lip_height,
    chamber_height,
    rack_rim_width,
    first_pill_center,
    pill_distance,
    pill_size,
    num_pills
) {
    difference() {

        // exterior
        rrect([
            wall_width + tolerance + pack_dims.x + tolerance + wall_width,
            wall_width + tolerance + pack_dims.y + tolerance + wall_width,
            floor_width + chamber_height + lip_height
        ], pack_border_radius + tolerance + wall_width);

        // space above rack
        translate([
            wall_width,
            wall_width,
            floor_width + chamber_height
        ]) rrect([
            tolerance + pack_dims.x + tolerance,
            tolerance + pack_dims.y + tolerance,
            lip_height + fudge
        ], pack_border_radius + tolerance);

        // support holes
        translate([
            wall_width,
            wall_width,
            floor_width + chamber_height - support_width + fudge,
        ]) support(
            [
                tolerance + pack_dims.x + tolerance,
                tolerance + pack_dims.y + tolerance
            ],
            tolerance + support_width + tolerance,
            support_height,
            [
                first_pill_center.x + tolerance,
                first_pill_center.y + tolerance
            ],
            pill_distance,
            pill_size,
            num_pills
        );

        // collection chamber
        translate([
            wall_width + tolerance + rack_rim_width,
            wall_width + tolerance + rack_rim_width,
            floor_width
        ]) rrect([
            pack_dims.x - 2 * rack_rim_width,
            pack_dims.y - 2 * rack_rim_width,
            chamber_height + fudge,
        ], pack_border_radius - rack_rim_width);
    }
}

module support(
    pack_dims,
    support_width,
    support_height,
    first_pill_center,
    pill_distance,
    pill_size,
    num_pills
) {
    for (i = [0:1:num_pills.x - 2]) {
        translate([
            first_pill_center.x
            + pill_distance.x / 2
            + pill_distance.x * i
            - support_width / 2,
            0,
            0
        ]) cube([
            support_width,
            pack_dims.y,
            support_height
        ]);
    }
    
    half_height = (num_pills.y / 2) - 1;
    translate([
        0,
        first_pill_center.y
        + pill_distance.y / 2
        + pill_distance.y * half_height
        - support_width / 2,
        0
    ]) cube([
        pack_dims.x,
        support_width,
        support_height
    ]);
}

module maiden(
    pack_dims,
    pack_border_radius,
    wall_width,
    rack_rim_width,
    first_pill_center,
    pill_distance,
    pill_size,
    num_pills,
    bluntness,
    label_indent,
    skip
) {

    bottom_height = first_pill_center.y - pill_size.y/2;

    difference() {

        // surface
        rrect([
            pack_dims.x,
            pack_dims.y,
            wall_width
        ], pack_border_radius);

        // label
        translate([
            pack_border_radius,
            bottom_height / 4,
            wall_width - label_indent + fudge
        ]) rrect([
            pack_dims.x - 2 * pack_border_radius,
            bottom_height / 2,
            wall_width - label_indent + fudge
        ], bottom_height / 4);
    }

    // spikes
    for (i = [0:1:num_pills.x - 1]) {
        for (j = [0:1:num_pills.y - 1]) {
            if (skip.x != i || skip.y != j) {
                translate([
                    first_pill_center.x + i * pill_distance.x,
                    first_pill_center.y + j * pill_distance.y,
                    wall_width - fudge
                ]) scale([
                    pill_size.x,
                    pill_size.y,
                    pill_size.z
                ]) cylinder(
                    h=1,
                    d1=1,
                    d2=bluntness
                );
            }
        }
    }
}

module main(
    pack_dims = [65, 106],
    pack_border_radius = 7,
    wall_width = 2,
    floor_width = 2,
    support_width = 4,
    support_height = 4,
    lip_height = 20,
    chamber_height = 20,
    rack_rim_width = 4,
    first_pill_center = [9, 12],
    pill_distance = [23.5, 17],
    pill_size = [10, 10, 6],
    num_pills = [3, 6],
    bluntness = 0.3,
    label_indent = 0.5,
    skip = [],
) {

    // render support to the side
    translate([
        2 * (wall_width + pack_dims.x + wall_width + 20),
        0,
        0
    ])

    /*
    // render support in-place
    translate([
        wall_width + tolerance,
        wall_width + tolerance,
        floor_width + chamber_height - support_height + fudge,
    ])
    */

    support(
        pack_dims,
        support_width,
        support_height,
        first_pill_center,
        pill_distance,
        pill_size,
        num_pills
    );

    // render maiden in-place
    /*
    translate([
        pack_dims.x + wall_width + tolerance,
        wall_width + tolerance,
        wall_width + chamber_height + wall_width + tolerance
    ]) rotate([0, 180, 0])
    */

    // render maiden to the side
    translate([
        wall_width + pack_dims.x + wall_width + 20,
        0,
        0
    ])

    maiden(
        pack_dims,
        pack_border_radius,
        wall_width,
        rack_rim_width,
        first_pill_center,
        pill_distance,
        pill_size,
        num_pills,
        bluntness,
        label_indent,
        skip
    );

    base(
        pack_dims,
        pack_border_radius,
        wall_width,
        floor_width,
        support_width,
        support_height,
        lip_height,
        chamber_height,
        rack_rim_width,
        first_pill_center,
        pill_distance,
        pill_size,
        num_pills
    );
}

module algal(test=false) {
    main(
        pack_dims = [65, 106],
        pack_border_radius = 7,
        wall_width = 2,
        floor_width = test ? 0 : 2,
        support_width = 4,
        support_height = 4,
        lip_height = test ? 4 : 20,
        chamber_height = test ? 2 : 20,
        rack_rim_width = 5,
        first_pill_center = [10, 12],
        pill_distance = [22.5, 17],
        pill_size = [10, 10, 6],
        num_pills = [3, 6],
        bluntness = 0.3,
        label_indent = 0.5,
        skip = []
    );
}

module meb(test=false) {
    main(
        pack_dims = [90, 70],
        pack_border_radius = 5,
        wall_width = 2,
        floor_width = test ? 0 : 2,
        support_width = 4,
        support_height = 4,
        lip_height = test ? 4 : 10,
        chamber_height = test ? 2 : 20,
        rack_rim_width = 4,
        first_pill_center = [8, 18],
        pill_distance = [74/7, 34],
        pill_size = [8, 22, 6],
        num_pills = [8, 2],
        bluntness = 0.3,
        label_indent = 0.5,
        skip = [4, 0]
    );
}

module all() {
    algal();
    translate([250, 0, 0]) algal(test=true);
    translate([0, 150, 0]) {
        meb();
        translate([400, 0, 0]) meb(test=true);
    }
}

algal();
