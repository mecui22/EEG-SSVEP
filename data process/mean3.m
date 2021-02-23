function y = mean3(x)
   x1 = squeeze(mean(x,3,'omitnan'));
   y = squeeze(mean(x1,2,'omitnan'));
end