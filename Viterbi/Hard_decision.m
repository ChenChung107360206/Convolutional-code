function hard_receive = Hard_decision(x, cword_len)

    hard_receive = zeros(1,cword_len);

    for i = 1:cword_len
        
        if(x(i) >= 0)
            hard_receive(i) = 0;
        elseif(x(i)<0)
            hard_receive(i) = 1;
        end
        
    end

return