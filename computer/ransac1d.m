function best=ransac1d(x,minn,niter,thresh,ntarget)

best=struct('est',NaN,'err',Inf,'set',[]);
mask=false([size(x,1) 1]);
for iter=1:niter
    mask(:)=0;
    p=randperm(size(x,1));
    mask(p(1:minn))=true;
    mask=or(mask,dist(mean(x(mask,:)),x)<thresh);
    if(sum(mask)>ntarget)
        avg=mean(x(mask,:));
        err=mean(dist(avg,x(mask,:)));
        if(err<best.err)
            best.err=err;
            best.est=avg;
            best.set=mask;
        end
    end
end

    function r=dist(a,b)
        % a is [1 p], b is [n p]
        r=sqrt(sum((repmat(a,[size(b,1) 1])-b).^2,2));
    end
end