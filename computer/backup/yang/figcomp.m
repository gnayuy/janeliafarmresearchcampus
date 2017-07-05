n=196;

for i=1:n
   
    
    k1=0; % qi
    k2=0;
    
    for j=1:n
       
        if qi(j) == qisort(i)
        
            
            qasort(i) = qa(j);
            
            k1=j;
            
        
        end
        
        
    end
    
    
%     for j=1:n
%        
%         if qa(j) == qascrsort(i)
%             
%             k2=j;
%             
%         
%         end
%         
%         
%     end
%     
%     disp(i)
%     disp(k1)
%     disp(k2)
%     disp('')
    
end

