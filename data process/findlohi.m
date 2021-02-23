function [lo, hi] = findlohi(a, b)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
      lo1 = min(min(min(a)));
      hi1 = max(max(max(a)));
      lo2 = min(min(min(b)));
      hi2 = max(max(max(b)));
      lo = min(lo1,lo2);
      hi = max(hi1,hi2);
      lo = min(lo,-hi);
      hi = -lo;
end

