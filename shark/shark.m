% Author: Yida Wang
% Last date modified: June 10th, 2020 
% This MATLAB script implements the geometry transformations
% and lighting calculations to render an 2-D image of scene 
% consisting of a single 3-D object.
% This script is using a left-handed coordinate system

clc
help shark

% import x,y,z coordinates of 3-D model
data = importdata('shark_ag.raw');
% import parameters
shark_parameters;
% retrieve # of rows
rows = length(data);
% extract 3 vertices of each triangle
v1 = data(:,1:3);
v2 = data(:,4:6);
v3 = data(:,7:9);
% add w coordinate
w = ones(length(data),1);
v1 = [v1,w];
v2 = [v2,w];
v3 = [v3,w];

% rotation transformation around x,y,z axis
% define x,y,z rotation angles
x_rot_ang = pi*(x_ang/180);
y_rot_ang = pi*(y_ang/180);
z_rot_ang = pi*(z_ang/180);
% calling rotation function
[v1,v2,v3] = rotate_world(v1,v2,v3,x_rot_ang,y_rot_ang,z_rot_ang);

% translation operation
% calling translation function
[v1,v2,v3] = translate_world(v1,v2,v3,Tx,Ty,Tz);

% lighting calculation
% light color: white
C_light = [1, 1, 1];
% material color
M_dif = [Red/255, Green/255, Blue/255];
% initialize normal vector
normal = zeros(rows,3);
% normal vector calculation
v2_v1 = v2-v1;
v3_v1 = v3-v1;
% lighting direction vector point towards light source
% initialize L vector
L = zeros(rows,3);
% Cdif is the color of the triangle after lighting
% initialize Cdif
Cdif = zeros(rows,3);
% using for loop to get the color code of all the triangles after lighting
% initialize loop counter
counter = 1:rows;
for i = counter
    normal(i,:) = (cross(v2_v1(i,1:3),v3_v1(i,1:3)))/norm(cross(v2_v1(i,1:3),v3_v1(i,1:3)));
%     L(i,:) = (light_position - normal(i,1:3))/norm(light_position - normal(i,1:3));
    L(i,:) = (light_position - v1(i,1:3))/norm(light_position - v1(i,1:3));
    Cdif(i,:) = C_light.*M_dif * max(0, dot(normal(i,:),L(i,:)));
end


% view transformation
% Thanks to Wu's detailed explaination for view transformation on Piazza
% Camera's x,y,z position
Camera_position = [Cx, Cy, Cz];
% Translation matrix for translating camera from world-space origin
% to camera position in world space
camera_trans = [1,0,0,0;0,1,0,0;0,0,1,0;-Cx,-Cy,-Cz,1];
% normalized unit vector in the direction of z-axis
k = (camera_look_at - Camera_position)/norm(camera_look_at - Camera_position);
% define up vector
up_vector = [0 1 0];
% normalized unit vector in the direction of x-axis
i = cross(up_vector,k)/norm(cross(up_vector,k));
% normalized unit vector in the direction of y-axis
j = cross(k,i);
% The rotation is equivalent to rotating the view-space 
% x,y,z-axis to align with world-space x,y,z-axis
% Let R be the rotation matrix
R = inv([i;j;k]);
% adding the fourth w dimension
R = [R(1,:),0;R(2,:),0;R(3,:),0;0,0,0,1];
% The final view transformation matrix
V = camera_trans * R;
v1 = v1 * V;
v2 = v2 * V;
v3 = v3 * V;

% Perspective projection (LHS)
% r is the aspect ratio = width/height
r = 1;
% FOV stands for field of view. Smaller field of view, closer in, 
% bigger field of view, to be able to show the whole object.
FOV = pi*(FOV_ang/180);
% Perspective projection matrix
P = [(1/r)*cot(FOV/2),0,0,0;0,cot(FOV/2),0,0;0,0,z_far/(z_far-z_near),1;0,0,-(z_far*z_near)/(z_far-z_near),0];
v1 = v1 * P;
v2 = v2 * P;
v3 = v3 * P;
% divide by the fourth coordinate w
v1 = [(v1(:,1)./v1(:,4)),(v1(:,2)./v1(:,4)),(v1(:,3)./v1(:,4)),(v1(:,4)./v1(:,4))];
v2 = [(v2(:,1)./v2(:,4)),(v2(:,2)./v2(:,4)),(v2(:,3)./v2(:,4)),(v2(:,4)./v2(:,4))];
v3 = [(v3(:,1)./v3(:,4)),(v3(:,2)./v3(:,4)),(v3(:,3)./v3(:,4)),(v3(:,4)./v3(:,4))];
% combine all the vertices including lighting 
data = [v1(:,1:3),v2(:,1:3),v3(:,1:3),Cdif];

% applying z-clipping
% delete all facets whose z-values all fall outside the viewing frustum in the z-dimension
data(data(:,3) < 0, :) = [];
data(data(:,6) < 0, :) = [];
data(data(:,9) < 0, :) = [];
data(data(:,3) > 1, :) = [];
data(data(:,6) > 1, :) = [];
data(data(:,9) > 1, :) = [];

% recount # of rows
rows = length(data);
counter = 1:rows;
% z sorting
% initialize average z matrix
z_avg = zeros(rows,1);
% calculate every average z value of each triangle and store in z_avg
for i = counter
    z_avg(i,:) = mean(data(i,3:3:9));
end
% combine z_avg and Cdif columns into data matrix
data = [data,z_avg];
% sorting the entire matrix by z_avg from farthest to closest
data = sortrows(data, -13);
% extract Cdif after sorting
Cdif = data(:,10:12);

% start rendering
disp('Start rendering');
figure(1);
% define axis
axis([-1 1 -1 1]);
axis square;
% set background color
set(gca,'Color','k');
% delete edges while rendering
set(0,'DefaultPatchEdgeColor','none');
% patch all the triangles from data matrix
tstart = tic;
for index = 1:rows
    %   Adding 'LineStyle','none' in the patch function can also delete edges
    %   patch(data(index,1:3:7),data(index,2:3:8),Cdif(index,:),'LineStyle','none');
        patch(data(index,1:3:7),data(index,2:3:8),Cdif(index,:));
end
tend = toc(tstart);
fprintf('Rendering took %f seconds\n',tend)
% labeling
title('3D Model Projection on 2D X-Y Plane');
xlabel('x-axis');
ylabel('y-axis');
