function state = State_metric(decision_type, receive, cword)

    switch decision_type
        case 1 % hard-decision
            state = Binary2Decimal( sum(cword ~= receive) ); % calculate Hamming distance
        case 2 % soft-decision
            soft_cword = 1 - 2*cword;
            state = sum( (soft_cword - receive) .^ 2 ); % calculate Euclidean distance square
    end

return