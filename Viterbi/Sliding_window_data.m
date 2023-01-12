function Sliding_window_data(memory, window_len, s)

decode_process = zeros(2^memory,window_len);

for i = 1:2^memory
    for j = 1:window_len
        if s(i,j).state_metric == inf
            decode_process(i,j) = -10;
        else
            decode_process(i,j) = s(i,j).state_metric;
        end
    end
end

imagesc(decode_process); title("window data");