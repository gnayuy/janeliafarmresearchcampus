% movement parameters analysis				
% data from Yang on 01031845				
				
function [V]=plotmov(dir0,s,e)

				
ii=1;				
K=s:e;				
for k=K				
    %disp(k)				
    fname=[dir0,'mc_',num2str(k),'Affine.txt'];			
    fid = fopen(fname,'r');				
    				
    while ~feof(fid)				
        for i=1:3				
            fgets(fid);				
        end				
        line = fgets(fid); %# read the line				
        A = strsplit(line);				
        x=str2double(A(11));				
        y=str2double(A(12));				
        z=str2double(A(13));				
        for i=1:2				
            fgets(fid);				
        end				
    end				
    v=[x;y;z;sqrt(x^2+y^2+z^2)];				
    V(:,ii)=v;				
    ii=ii+1;				
    fclose(fid);				
end				
				
%save Movement.mat V				
%%				
				
figure				
plot(K,V(4,:),'r-',K,V(3,:),'b:',K,V(2,:),'g-.',K,V(1,:),'k--');				
xlabel('File #')				
ylabel('Movement')				
legend('Whole','z','y','x')				
