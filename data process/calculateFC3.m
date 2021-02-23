function [fc, phase] = calculateFC3(x, f0, k)
   dbstop if error
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    fc = 0;
    x = squeeze(x);
    fs =1000;
    T = length(x)/fs;
    N = fs*T;
    n = 1 : N;
for i = 1 : k
    f = i * f0;
    omega = 2*f/fs*pi;
    temp = -1i*omega*n;
    e = exp(temp);
    y = sum(x'.* e);
    y = y / N;
    fc0 = abs(y).^2;
    phase = angle(y);
    fc = fc0 + fc;
end 
end

