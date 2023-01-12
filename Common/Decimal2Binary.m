function s = Decimal2Binary(len, Quotient)

    Binary_flip = zeros(1,len);

    for i = 1:len
        Remainder = mod(Quotient,2);
        Quotient = (Quotient - Remainder)/2;
        Binary_flip(i) = Remainder;
        if(Quotient == 0 || Quotient == 1)
                Binary_flip(i+1) = Quotient;
                break;
        end
    end
    s = fliplr(Binary_flip);

return