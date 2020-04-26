function [E, H, obj_array, src_array] = supress_output(substrate_thickness, L, D, NWspacing_x, NWspacing_z, Laser_angle, Laser_pol, max_NWlength, roughness_rate, grid_size, max_wire_xz_gridsize, max_wire_y_gridsize, max_tip_gridsize, PML_cells, z_location, opts, min_tip_src_dist, src_top_dist, Dim_3D, solveropts, wire_shape, UniformNWCells, TFSF, inspect_only, show_solution, save_solution, runningfilenamebase, NW_tip, top_source_testing, substrate_exist, max_x_gridsize, max_y_gridsize, max_z_gridsize, overall_gridsize_limit, superCellnum_x, superCellnum_z, NW_Diameter_Delta, NW_xpos_Delta, NW_zpos_Delta, NW_exist)
    [E, H, obj_array, src_array] = evalc('nanowire_3d_func(substrate_thickness, L, D, NWspacing_x, NWspacing_z, Laser_angle, Laser_pol, max_NWlength, roughness_rate, grid_size, max_wire_xz_gridsize, max_wire_y_gridsize, max_tip_gridsize, PML_cells, z_location, opts, min_tip_src_dist, src_top_dist, Dim_3D, solveropts, wire_shape, UniformNWCells, TFSF, inspect_only, show_solution, save_solution, runningfilenamebase, NW_tip, top_source_testing, substrate_exist, max_x_gridsize, max_y_gridsize, max_z_gridsize, overall_gridsize_limit, superCellnum_x, superCellnum_z, NW_Diameter_Delta, NW_xpos_Delta, NW_zpos_Delta, NW_exist);');
end