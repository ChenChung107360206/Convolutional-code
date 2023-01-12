function [new_state_metric, new_survivor] = Compare(row, column, state_metric, last_state, s)
    
    state_metric = state_metric + last_state; % new state metric

    if s.state_metric > state_metric % new state metric is smaller than old state metric
        new_state_metric = state_metric; 
        new_survivor = [row column];
    else
        new_state_metric = s.state_metric; % old state metric is smaller than new state metric
        if(sum( s.survivor == [-1 -1] ) == 2) % if this node don't have survivor
            new_survivor = [row column];
        else
            new_survivor = s.survivor; % survivor remains
        end
    end

return