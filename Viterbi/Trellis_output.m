function decode_msg = Trellis_output(state1, state2, next_State)

    if next_State(state1,1) == state2 - 1
        decode_msg = 0;
    end
    if next_State(state1,2) == state2 - 1
        decode_msg = 1;
    end

return