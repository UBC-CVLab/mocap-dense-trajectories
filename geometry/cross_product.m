function [result] = cross_product(V1,V2)
%CROSS_PRODUCT Matlab version is too slow.
i=(V1(2)*V2(3) - V2(2)*V1(3));
j=(V1(3)*V2(1) - V2(3)*V1(1));
k=(V1(1)*V2(2) - V2(1)*V1(2));
result=[i,j,k]; 
end