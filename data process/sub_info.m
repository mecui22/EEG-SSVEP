function sub_info(data,savepath)
   name0 = data.name;
   age = data.age;
   gender = data.gender;
   name = regexprep(name0, '[\u4E00-\u9FA5\uF900-\uFA2D]','');
   file = fopen([savepath,'sub_info.txt'],'wt');
   fprintf(file,'%s\n',name);
   fprintf(file,'%s\n',gender);
   fprintf(file,'%.2f',age);
   fclose(file);
end