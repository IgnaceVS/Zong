function similaritystats = fm_ind_excel(refmatrix, bird_data, filename)
%  Turn similaritystats into excel file for JMP
    % For tutee tutor
    writematrix(["Name","Group","Time123", "Timepoint","Sylls In Cluster","Dur Syll","M Dur Clus","SD Dur Clus" , "M Between Sim","Min Between Sim","FF syll", "M FF clus", "SD FF clus", "M Within Sim", "Clus ID", "Syll ID",...
        "Max Tutee Sim", "Closest Tutee Syll","Mean Max Tutee Sim", "Range Tutee Sim"],filename,'Range','A1:T1','WriteMode','replacefile');

    loading_msg = 'Writing Excel file... ';
    loading = waitbar(0, strcat(loading_msg, '0%'), 'Visible', 'on');

    for index=1:size(refmatrix, 1)
        birdname = strings(1,size(bird_data(index).ind_similaritystats,2));
        group = strings(1,size(bird_data(index).ind_similaritystats,2));
        time123 = strings(1,size(bird_data(index).ind_similaritystats,2));

        % Takes group
        if size(refmatrix,2) < 7 || isempty(refmatrix{index,7})
            group(1:size(bird_data(index).ind_similaritystats,2)) = "NA";
        else
            group(1:size(bird_data(index).ind_similaritystats,2)) = string(refmatrix{index,7});
        end
        % to simplify timepoint to 1 2 or 3 & add as descriptor
        time123(1:size(bird_data(index).ind_similaritystats,2)) = string(refmatrix{index,4});
        % determines birdname
        birdname(1:size(bird_data(index).ind_similaritystats,2)) = string(refmatrix{index,2});

        % compiles all stats
        % similaritystats = [birdname; time123; tut12; similaritystats];
        similaritystats = [birdname; group; time123; bird_data(index).ind_similaritystats];
        writematrix(similaritystats.',filename,'WriteMode','append');

        if isvalid(loading)
            text = strcat(loading_msg, num2str(round(100*index/size(refmatrix,1))), '%');
            waitbar(index/size(refmatrix,1), loading, text);
        end
    end

    if isvalid(loading)
        waitbar(1, loading, 'Done!');
        pause(1);
    end
    if isvalid(loading)
        close(loading);
    end
end