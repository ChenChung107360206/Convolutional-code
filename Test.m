clear; close all;
addpath("Common\", "Encode\", "Viterbi\", "0103 test\");
% trellis = poly2trellis(5,[37 33],37);


%----------trellis----------
memory = 6;
Constraint_Length = memory + 1;
num_Input_Symbol = 2;
num_Output_Symbol = 4;
D1 = [1, 1, 1, 1, 0, 0, 1]; % NUM(分子)
D2 = [1, 0, 1, 1, 0, 1, 1]; % DEN(分母)
%D1 = [1, 0, 1]; % NUM(分子)
%D2 = [1, 1, 1]; % DEN(分母)
[next_State, Output] = Trellis(memory, num_Input_Symbol, num_Output_Symbol, D1, D2);


% next_State(1,1) = 0; next_State(1,2) = 2; Output(1,1) = 0; Output(1,2) = 3; % 0 state
% next_State(2,1) = 0; next_State(2,2) = 2; Output(2,1) = 3; Output(2,2) = 0; % 1 state
% next_State(3,1) = 1; next_State(3,2) = 3; Output(3,1) = 2; Output(3,2) = 1; % 2 state
% next_State(4,1) = 1; next_State(4,2) = 3; Output(4,1) = 1; Output(4,2) = 2; % 3 state
backtozero_path = Back2Zero_path(memory,next_State);

%----------setting----------
coderate = num_Input_Symbol/num_Output_Symbol;
EbN0dB = 5;
EbN0 = 10^(EbN0dB/10);
sigma = sqrt( 1/(2*coderate*EbN0) );

msg_len = 5; % input msg's number
decision_type = 2; % 1 is hard-decision, 2 is soft-decision
window_len = 30;
truncation_type = 2; % 1 = fixed state, 2 = best state, 3 = majority-vote


%----------encode----------
%input_msg = input("Input message : ");
input_msg = randi([0 1], 1, msg_len); %msg = fliplr(input_msg); % generate message
x = zeros(1, (msg_len + memory)*log2(num_Output_Symbol)); % encode result

msg = [0 1 0 0 1];

current_state = 0; % initialization phase
index = 1;
for i=1:length(msg) % encode
    
    x(index:index+1) = Decimal2Binary( log2(num_Output_Symbol), Output(current_state+1,msg(i)+1) );
    current_state = next_State(current_state+1, msg(i)+1);
    index = index + 2;
    
end
[x(log2(num_Output_Symbol)*msg_len+1:end), ...
    msg(msg_len + 1:msg_len + memory)] = Termination_phase(memory, D1, D2, current_state);
msg(msg_len + 1:msg_len + memory) = zeros(1,memory);


%----------decode----------
send = 1 - 2*x; % x after BPSK modulation
receive = send + sigma * randn(1, length(x)); % receive codeword
%receive = fliplr(receive);
switch decision_type
    case 1
        receive = Hard_decision(receive, length(x)); % receive after hard-decision
        %disp("Hard-decision");
    case 2
        %disp("Soft-decision");
end
%receive = [0 1 1 1 0 0 1 1 0 1 1 1 1 1];
%receive = importdata("no error.txt")';
%msg_len = length(receive) / 2 - memory;
%input_msg = zeros(1,msg_len);
%msg = zeros(1,length(receive) / 2);


%----------viterbi----------
field1 = "survivor"; value1 = [-1 -1]; % last node with smallest state, [-1 -1] means it has no value
field2 = "state_metric"; value2 = Inf; % node's smallest state , 10 is to calculate the min state metric
s(1:2^memory,1:window_len) = struct(field1,value1,field2,value2); % data of each node
decode_result = zeros(1, length(receive)/log2(num_Output_Symbol));
decode_index = 1;

if window_len > length(msg) + 1 % don't need truncation

    for i = 1:num_Input_Symbol % start
        next_row = next_State(1,i); % next state when currnet state 0 has (i-1) as input
        next_cword = Decimal2Binary(log2(num_Output_Symbol), Output(1,i));
    
        state_metric_result = State_metric(decision_type, receive(1:log2(num_Output_Symbol)), next_cword);
        s(next_row+1,2).state_metric = state_metric_result;
        s(next_row+1,2).survivor = [1 1];
    end
    index = 3;
    for j = 2:length(msg) % viterbi processing
    
        for i = 1:2^memory
            if(sum( s(i,j).survivor ~= [-1 -1] ) == 2) % this node has value

                if j > length(msg) - memory
                    path = backtozero_path(i);
                    next_row0 = next_State(i,path); % next state when input 0
                    next_cword0 = Decimal2Binary(log2(num_Output_Symbol), Output(i,path)); % i state output when input 0
                    state_metric_result0 = State_metric(decision_type, receive(index:index+1), next_cword0);
                    [s(next_row0+1,j+1).state_metric, s(next_row0+1,j+1).survivor] = ...
                        Compare(i, j, state_metric_result0, s(i,j).state_metric, s(next_row0+1,j+1));        
                else
                    next_row0 = next_State(i,1); % next state when input 0
                    next_cword0 = Decimal2Binary(log2(num_Output_Symbol), Output(i,1)); % i state output when input 0
                    state_metric_result0 = State_metric(decision_type, receive(index:index+1), next_cword0);
                    [s(next_row0+1,j+1).state_metric, s(next_row0+1,j+1).survivor] = ...
                        Compare(i, j, state_metric_result0, s(i,j).state_metric, s(next_row0+1,j+1));
        
                    next_row1 = next_State(i,2); % next state when input 1
                    next_cword1 = Decimal2Binary(log2(num_Output_Symbol), Output(i,2)); % i state output when input 1       
                    state_metric_result1 = State_metric(decision_type, receive(index:index+1), next_cword1);
                    [s(next_row1+1,j+1).state_metric, s(next_row1+1,j+1).survivor] = ...
                        Compare(i, j, state_metric_result1, s(i,j).state_metric, s(next_row1+1,j+1));               
                end

            end
        end
        index = index + log2(num_Output_Symbol);
    
    end 

    node = [1 length(msg)+1];
    for i = 1:length(msg) % final decision
        state2 = node(1);
        node = s(node(1),node(2)).survivor; % first state survivor of current column
        state1 = node(1);
        decode_result(length(msg) + 1 - decode_index) = Trellis_output(state1, state2, next_State);
        decode_index = decode_index + 1;
    end


%----------viterbi window is not full----------    
else % need truncation

    for i = 1:num_Input_Symbol % start
        next_row = next_State(1,i); % next state when currnet state 0 has i as input
        next_cword = Decimal2Binary(log2(num_Output_Symbol), Output(1,i));
    
        state_metric_result = State_metric(decision_type, receive(1:log2(num_Output_Symbol)), next_cword);
        s(next_row+1,2).state_metric = state_metric_result;
        s(next_row+1,2).survivor = [1 1];
    end
    index = 3;
    for j = 2:window_len - 1 % window is not full
   
        for i = 1:2^memory
            if(sum( s(i,j).survivor ~= [-1 -1] ) == 2) % this node has value  
                next_row0 = next_State(i,1); % next state when input 0
                next_cword0 = Decimal2Binary(log2(num_Output_Symbol), Output(i,1)); % i state output when input 0
                state_metric_result0 = State_metric(decision_type, receive(index:index+1), next_cword0);
                [s(next_row0+1,j+1).state_metric, s(next_row0+1,j+1).survivor] = ...
                    Compare(i, j, state_metric_result0, s(i,j).state_metric, s(next_row0+1,j+1));
    
                next_row1 = next_State(i,2); % next state when input 1
                next_cword1 = Decimal2Binary(log2(num_Output_Symbol), Output(i,2)); % i state output when input 1       
                state_metric_result1 = State_metric(decision_type, receive(index:index+1), next_cword1);
                [s(next_row1+1,j+1).state_metric, s(next_row1+1,j+1).survivor] = ...
                    Compare(i, j, state_metric_result1, s(i,j).state_metric, s(next_row1+1,j+1));
            end
        end
        index = index + log2(num_Output_Symbol);
    
    end
    
    
%----------viterbi window is full,start truncaiton----------
    fix_j = window_len;
    for j = window_len:length(msg) % viterbi with truncation
        
        decode_result(decode_index) = Truncation(memory, truncation_type, window_len, fix_j, s, next_State);
        decode_index = decode_index + 1;
        
        if fix_j == window_len % clear data after truncation
            for clear_count = 1:2^memory
                s(clear_count,1).survivor = [-1 -1]; s(clear_count,1).state_metric = inf;
            end
        else
            for clear_count = 1:2^memory
                s(clear_count,fix_j+1).survivor = [-1 -1]; s(clear_count,fix_j+1).state_metric = inf;
            end
        end
    
        for i = 1:2^memory 
            if(sum( s(i,fix_j).survivor ~= [-1 -1] ) == 2) % this node has value
    
                if j > length(msg) - memory
                    path = backtozero_path(i);
                    next_row0 = next_State(i,path);
                    next_cword0 = Decimal2Binary(log2(num_Output_Symbol), Output(i,path));
                    state_metric_result0 = State_metric(decision_type, receive(index:index+1), next_cword0);
                    if fix_j == window_len
                        [s(next_row0+1,1).state_metric, s(next_row0+1,1).survivor] = ...
                        Compare(i, fix_j, state_metric_result0, s(i,fix_j).state_metric, s(next_row0+1,1));
                    else
                        [s(next_row0+1,fix_j+1).state_metric, s(next_row0+1,fix_j+1).survivor] = ...
                        Compare(i, fix_j, state_metric_result0, s(i,fix_j).state_metric, s(next_row0+1,fix_j+1));
                    end                
                else
                    next_row0 = next_State(i,1); % next state when input 0
                    next_cword0 = Decimal2Binary(log2(num_Output_Symbol), Output(i,1)); % i state output when input 0
                    state_metric_result0 = State_metric(decision_type, receive(index:index+1), next_cword0);
                    if fix_j == window_len
                        [s(next_row0+1,1).state_metric, s(next_row0+1,1).survivor] = ...
                        Compare(i, fix_j, state_metric_result0, s(i,fix_j).state_metric, s(next_row0+1,1));
                    else
                        [s(next_row0+1,fix_j+1).state_metric, s(next_row0+1,fix_j+1).survivor] = ...
                        Compare(i, fix_j, state_metric_result0, s(i,fix_j).state_metric, s(next_row0+1,fix_j+1));
                    end
        
                    next_row1 = next_State(i,2); % next state when input 1
                    next_cword1 = Decimal2Binary(log2(num_Output_Symbol), Output(i,2)); % i state output when input 1       
                    state_metric_result1 = State_metric(decision_type, receive(index:index+1), next_cword1);
                    if fix_j == window_len
                        [s(next_row1+1,1).state_metric, s(next_row1+1,1).survivor] = ...
                        Compare(i, fix_j, state_metric_result1, s(i,fix_j).state_metric, s(next_row1+1,1));
                    else
                        [s(next_row1+1,fix_j+1).state_metric, s(next_row1+1,fix_j+1).survivor] = ...
                        Compare(i, fix_j, state_metric_result1, s(i,fix_j).state_metric, s(next_row1+1,fix_j+1));
                    end
                end
    
            end
        end
        index = index + log2(num_Output_Symbol);
    
        if mod(j,window_len) == 0
            fix_j = 0;
        end

        fix_j = fix_j + 1;
    
    end
    
    
%----------viterbi final part----------
    tem_decode_result = zeros(1,window_len - 1);decode_index = 1;
    node = [1 fix_j];
    for i = 1:window_len - 1 % final decision
        state2 = node(1);
        node = s(node(1),node(2)).survivor; % first state survivor of current column
        state1 = node(1);
        tem_decode_result(decode_index) = Trellis_output(state1, state2, next_State);
        decode_index = decode_index + 1;
    end
    decode_result(length(msg)-(window_len-1)+1:end) = fliplr(tem_decode_result);
end

output_msg = decode_result(1:msg_len);
Sliding_window_data(memory, window_len, s);
error = sum( output_msg ~= input_msg );


