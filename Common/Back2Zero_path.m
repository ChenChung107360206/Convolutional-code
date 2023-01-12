function path = Back2Zero_path(memory, next_State) % 任意狀態歸0的路線

    path = zeros(2^memory,1);
    tem_path = zeros(2^memory,1);
    tem_path_index = 1;
    
    for back2zero_count = 1:2^(memory-1)
        for i = 1:2^memory
            for j = 1:2
               if next_State(i,j) == tem_path(back2zero_count)
                    path(i) = j;
                    tem_path(tem_path_index) = i-1;
                    tem_path_index = tem_path_index + 1;
               end
            end
        end
    end

return