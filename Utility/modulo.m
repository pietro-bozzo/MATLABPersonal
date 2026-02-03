function m = modulo(x,a,b)
% modulo Remap elements of x to numbers in [a,b), using modulo b-a transformations
%
% arguments:
%     x    values to map into range
%     a    range lower limit
%     b    range upper limit

m = a + mod(x-a,b-a);