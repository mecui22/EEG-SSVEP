function  S = svdshrinage(x,sigma)
S = x;
   for i = 1 : rank(x)
       temp = x(i,i) - sigma;
       if temp >0
           S(i,i) = temp;
       end
   end

end