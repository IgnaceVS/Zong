function fm_simtoexcel(refmatrix, bird_data, filename)
%  Turn similaritystats into excel file for JMP

    % % For tutee tutor
    writematrix(["Name","Group", "Time123", "Tutorname", "dph","Tutorsonly","TutorID","Sylls In Cluster","Dur syll", "M Dur Clus" ,"SD Dur Clus" , "Mean Between Sim Clus","Min Between Sim Clus",...
        "FF syll", "M FF clus", "SD FF clus", "M Within Sim","#S tutee","#S Comp1","#S Comp2","Ent Clus","nsyllsT","p tutee",...
        "p Comp1","p Comp2","least syllables","Cluster ID" ,"Syllable ID",...
        "Max T-T", "Closest Tutor Syll", "Mean T-T Sim", "Range T-T", "Max Tutee", "Closest Tutee Syll",...
        "Mean Tutee Sim", "Range Tutee","Max Tutor", "Closest Tutor-Tutor Syll", "Mean Tutor Sim", "Range Tutor"],filename,'Range','A1:AN1','WriteMode','replacefile');

    loading_msg = 'Writing Excel file... ';
    loading = waitbar(0, strcat(loading_msg, '0%'), 'Visible', 'on');

    for index=1:size(refmatrix,1)
        compID1 = refmatrix{index,5};
        compID2 = refmatrix{index,6};

        if ~isempty(compID1)
            write_comp(refmatrix, bird_data, filename, index, 1, index, compID1);
            if ~isempty(compID2)
                write_comp(refmatrix, bird_data, filename, index, 2, index, compID2);
                write_comp(refmatrix, bird_data, filename, index, 3, compID1, compID2);
            end
        end

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

function write_comp(refmatrix, bird_data, filename, index, tt_index, compID1, compID2)
    birdname = strings(1,size(bird_data(index).tt_similaritystats{tt_index},2));
    group = strings(1,size(bird_data(index).tt_similaritystats{tt_index},2));
    time123 = strings(1,size(bird_data(index).tt_similaritystats{tt_index},2));

    if size(refmatrix,2) < 7 || isempty(refmatrix{index,7})
        group(1:size(bird_data(index).tt_similaritystats{tt_index},2)) = "NA";
    else
        group(1:size(bird_data(index).tt_similaritystats{tt_index},2)) = string(refmatrix{index,7});
    end

    time123(1:size(bird_data(index).tt_similaritystats{tt_index},2)) = refmatrix{index,4};
    birdname(1:size(bird_data(index).tt_similaritystats{tt_index},2)) = string(refmatrix{compID1,2});
    tutname(1:size(bird_data(index).tt_similaritystats{tt_index},2)) = string(refmatrix{compID2,2});
    similaritystats = [birdname; group; time123; tutname; bird_data(index).tt_similaritystats{tt_index}];
    writematrix(similaritystats.',filename,'WriteMode','append');
end
