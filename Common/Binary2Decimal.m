function s = Binary2Decimal(x)
    
    s = 0;
    len = length(x);

    for i = 0:len-1
        s = s + 2^i * x(len-i);
    end

return