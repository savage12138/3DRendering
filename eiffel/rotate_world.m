% world rotation function
function [v1,v2,v3] = rotate_world(v1,v2,v3,x_rot_ang,y_rot_ang,z_rot_ang)
    z_rotation_matrix = [cos(z_rot_ang),sin(z_rot_ang),0,0;-sin(z_rot_ang),cos(z_rot_ang),0,0;0,0,1,0;0,0,0,1];
    y_rotation_matrix = [cos(y_rot_ang),0,-sin(y_rot_ang),0;0,1,0,0;sin(y_rot_ang),0,cos(y_rot_ang),0;0,0,0,1];
    x_rotation_matrix = [1,0,0,0;0,cos(x_rot_ang),sin(x_rot_ang),0;0,-sin(x_rot_ang),cos(x_rot_ang),0;0,0,0,1];
    v1 = v1 * x_rotation_matrix;
    v2 = v2 * x_rotation_matrix;
    v3 = v3 * x_rotation_matrix;
    v1 = v1 * y_rotation_matrix;
    v2 = v2 * y_rotation_matrix;
    v3 = v3 * y_rotation_matrix;
    v1 = v1 * z_rotation_matrix;
    v2 = v2 * z_rotation_matrix;
    v3 = v3 * z_rotation_matrix;
end