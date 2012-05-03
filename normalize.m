function r = normalize( mat )
% normalize the magnitude of each column
% @author Jianxia Xue
% @version 0.20120208

nRows = size(mat,1);

bound_min = min(abs(mat)) * ones(nRows,1);
bound_max = max(abs(mat)) * ones(nRows,1);

r = (mat-bound_min) ./ (bound_max - bound_min);


