function [name, gender, age] = extractInfo(filepath)
slCharacterEncoding('UTF-8') 
filename = [filepath,'\recordInformation.json'];
file = loadjson(filename);
sex = file.Gender;
birthday = file.BirthDate;
age = 2018 - (str2num(birthday(1:4))-double(str2num(birthday(6:7)))/12);
if strcmp(num2str(sex),'1')
    gender = 'female';
else
    gender = 'male';
end
name = file.PatientName;
end