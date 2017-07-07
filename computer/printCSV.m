% x,y,z

N=size(x,1);
display('x,y,z')

for i=1:N
    
   %str = sprintf('%d,%d,%d', x(i), y(i), z(i));
   fprintf('%d,%d,%d\n', int16(x6(i)), int16(y6(i)), z6(i));
   
end
