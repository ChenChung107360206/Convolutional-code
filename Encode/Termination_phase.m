function [x, y] = Termination_phase(Memory, D1, D2, current_state)
    
    x = zeros(1,2*Memory); % convolutional code output of termination phase
    y = zeros(1,Memory); % X1 output when it is termination phase
    State = Decimal2Binary(Memory, current_state);
    
    index = 1;
    for i=1:Memory
        
        feedback = mod( sum(State .* D2(2:end)),2 ); % first register input(feedback from D2)
        y(i) = feedback;
        termination_input = mod(2*feedback,2); % first register input always 0(equal to feedback value)
        out = mod( sum([termination_input State] .* D1),2 ); % X2 output
        x(index:index+1) = [feedback out]; % X1 equals to feedback
        State = [termination_input State(1:end-1)];

        index = index + 2;

    end

return