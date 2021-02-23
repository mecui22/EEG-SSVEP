function y = remove_nan(x)
    dims = ndims(x);
    if dims == 4
        for i = 1 : size(x,1)
            for j = 1:size(x,2)
                for k = 1 :size(x,3)
                    for ii = 1 :size(x,4)
                        if (x(i,j,k,ii)==-inf) 
                            y(i,j,k,ii) = nan;
                        else
                            y(i,j,k,ii) = x(i,j,k,ii);
                        end
                    end
                end
            end
        end  
    elseif dims == 3
        for i = 1 : size(x,1)
            for j = 1:size(x,2)
                for k = 1 :size(x,3)
                    if (x(i,j,k)==-inf) 
                        y(i,j,k) = nan;
                    else
                        y(i,j,k) = x(i,j,k);
                    end
                end
            end
        end  
     elseif dims == 2
        for i = 1 : size(x,1)
            for j = 1:size(x,2)
                if (x(i,j)==-inf) 
                    y(i,j) = nan;
                else
                    y(i,j) = x(i,j);
                end
            end
        end  
    end
    
end