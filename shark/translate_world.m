% world translation function
function [v1,v2,v3] = translate_world(v1,v2,v3,Tx,Ty,Tz)
    trans_matrix = [1,0,0,0;0,1,0,0;0,0,1,0;Tx,Ty,Tz,1];
    v1 = v1 * trans_matrix;
    v2 = v2 * trans_matrix;
    v3 = v3 * trans_matrix;
end