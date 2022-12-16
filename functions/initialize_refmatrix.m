function refmatrix = initialize_refmatrix(tutors_folder, tutees_folder)
% This function initializes the reference matrix. 
% Tutors_folder and tutees_folder must have the same parent.

    % Find all tutor folders
    tutor_paths = dir(tutors_folder);
    tutor_paths = tutor_paths([tutor_paths(:).isdir]);
    tutor_paths = tutor_paths(~ismember({tutor_paths(:).name},{'.','..'}));
    tutor_paths = fullfile(tutors_folder, {tutor_paths.name});
    tutor_rows = numel(tutor_paths);
  
    % Find all tutee (sub)folders.
    tutee_paths = dir(strcat(tutees_folder,filesep,'*',filesep));
    tutee_paths = tutee_paths([tutee_paths(:).isdir]);
    tutee_paths = tutee_paths(~ismember({tutee_paths(:).name},{'.','..'}));
    tutee_paths = fullfile({tutee_paths.folder}, {tutee_paths.name});
    tutee_rows = numel(tutee_paths);
    
    file_count = tutor_rows + tutee_rows;
    refmatrix = cell(file_count, 7);
    refmatrix(:,1) = [transpose(tutor_paths); transpose(tutee_paths)];

    % Tutor part in refmatrix
    refmatrix(1:tutor_rows,2) = extractAfter(refmatrix(1:tutor_rows,1), fullfile(tutors_folder,filesep));
    refmatrix(1:tutor_rows,7) = {'Tut'};
    
    % Tutee part in refmatrix
    tutee_specs = split(extractAfter(refmatrix(tutor_rows+1:file_count,1), fullfile(tutees_folder,filesep)), filesep);
    if size(tutee_specs,1) ~= tutee_rows
        tutee_specs = transpose(tutee_specs);
    end
    refmatrix(tutor_rows+1:file_count,2) = tutee_specs(:,1);
    if size(tutee_specs, 2) > 1
        refmatrix(tutor_rows+1:file_count,3) = tutee_specs(:,2);
    end
    % Sort per bird based on days post hatch.
    i=1;
    while i <= file_count
        occurrences = nnz(strcmp(refmatrix(:,2),refmatrix(i,2)));
        dph = str2double(refmatrix(:,3));
        [~,sortOrder] = sort(dph(i:i+occurrences-1));
        tempfb = refmatrix(i:i+occurrences-1,1:3);
        refmatrix(i:i+occurrences-1,1:3) = tempfb([sortOrder sortOrder + occurrences sortOrder + 2*occurrences]);
        refmatrix(i:i+occurrences-1,4) = num2cell(1:occurrences);
        i = i+occurrences;
   end
end
