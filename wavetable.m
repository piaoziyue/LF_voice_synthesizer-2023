function y = wavetable(x, t, F0)

y = [];
T0 = 1/F0 * 1000; 
N = t/T0;
for n = 1:N
    y = cat(1, y, x);
end

end