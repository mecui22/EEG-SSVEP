function y = remove_inf(x)
y = [];
for i = 1 : length(x)
    if x(i)~= -inf
        y = [y,x(i)];
    end
end
