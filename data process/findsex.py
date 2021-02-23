import h5py
import xlrd

sheet = xlrd.open_workbook(r'sub_info.xlsx')
data = sheet.sheet_by_name('Sheet1')
name_ns = h5py.File(r'‪name_ns.mat','r')
print(name_ns)

for i in range(data.nrows):
    print(data.row_values(i))