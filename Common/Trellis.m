function [next_State, Output] = Trellis(memory, num_Input_Symbol, num_Output_Symbol, D1, D2)
    
    State = zeros(1,memory); % [S1 S2 S3 S4]:(左到右)
    next_State = zeros(2^memory,num_Input_Symbol);

    output = zeros(1,log2(num_Output_Symbol)); % [X1 X2]:(上到下)
    Output = zeros(2^memory,num_Input_Symbol);

    for i=0:2^memory - 1 % next state when input 0
    
        feedback = mod( sum(State .* D2(2:end)),2 ); % first register input(feedback from D2)
        tem_0 = mod(feedback + 0,2); % first register input(message is 0)

        next_state = [ tem_0 State(1:end - 1) ]; % next state
        next_State(i+1,1) = Binary2Decimal(next_state);

        feedback_output = mod( sum([tem_0 State] .* D1),2 ); % X2 output from D1 & D2
        output(:) = [0 feedback_output]; % Output X = [X1, X2]
        Output(i+1,1) = Binary2Decimal(output);
        
        if(i ~= 2^memory - 1)
            State = Decimal2Binary(memory,i+1);
        else
            State = Decimal2Binary(memory,0);
        end

    end

    for i=0:2^memory - 1 % next state when input 1
        
        feedback = mod( sum( State .* D2(2:end) ),2 ); % first register input(feedback from D2)
        tem_1 = mod(feedback + 1,2); % first register input(message is 1)

        next_state = [ tem_1 State(1:end - 1) ]; % next state
        next_State(i+1,2) = Binary2Decimal(next_state);

        feedback_output = mod( sum([tem_1 State] .* D1),2 ); % X2 output from D1 & D2        
        output(:) = [1 feedback_output]; % Output X = [X1, X2]
        Output(i+1,2) = Binary2Decimal(output);
        
        if(i ~= 2^memory - 1)
            State = Decimal2Binary(memory,i+1);
        else
            State = Decimal2Binary(memory,0);
        end
    
    end

return