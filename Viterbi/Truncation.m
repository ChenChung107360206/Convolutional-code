function decode_msg = Truncation(memory, truncation_type, window_len, column, s, next_State)

    switch truncation_type
        case 1 % fixed state

            fix_state = 1; % choose zero state
            node = [fix_state column]; % node at (first state,column)
            for i = window_len:-1:2
                node = s(node(1),node(2)).survivor;
                if i == 3 % decode_msg's next state
                    state2 = node(1);
                end
                if i == 2 % decode_msg's state
                    state1 = node(1);
                end
            end

        case 2 % best state
            
            state = s(1,column).state_metric;
            best_state = 1;
            for i = 1:(2^memory - 1) % find best state
                if state >= s(i+1,column).state_metric
                    state = s(i+1,column).state_metric;
                    best_state = i + 1;
                end
            end
            node = [best_state column]; % node at (best state,column)
            for i = window_len:-1:2
                node = s(node(1),node(2)).survivor;
                if i == 3 % decode_msg's next state
                    state2 = node(1);
                end
                if i == 2 % decode_msg's state
                    state1 = node(1);
                end
            end

        case 3 % majority-vote

            vote = zeros(1,2);
            for j = 1:2^memory
                if(sum( s(j,column).survivor ~= [-1 -1] ) == 2)

                    node = [j column];
                    for i = window_len:-1:2
                        node = s(node(1),node(2)).survivor;
                        if i == 3 % decode_msg's next state
                            state2 = node(1);
                        end
                        if i == 2 % decode_msg's state
                            state1 = node(1);
                        end
                    end
                    if next_State(state1,1) == state2 - 1 % calculate msg when state1 change to state2
                        vote(1,1) = vote(1,1) + 1;
                    elseif next_State(state1,2) == state2 - 1
                        vote(1,2) = vote(1,2) + 1;
                    end

                end
            end
            if vote(1,1) >= vote(1,2)
                state1 = 1;
                state2 = next_State(1,1) + 1;
            else
                state1 = 1;
                state2 = next_State(1,2) + 1;
            end

    end

    decode_msg = Trellis_output(state1, state2, next_State); % calculate msg when state1 change to state2

return