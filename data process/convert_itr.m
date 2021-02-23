function ITR = convert_itr(acc,time) 
   restTime = 0.5;
   ITR = 60*calculateITR( 40,acc,time+restTime);
end