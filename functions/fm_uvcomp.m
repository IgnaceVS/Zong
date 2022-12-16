function master = fm_uvcomp(bird1, bird2, least_syllables)
    data1 = bird1.syllablemaster;
    data2 = bird2.syllablemaster;
    maxxxx = max([length(data1) length(data2)]);
    data1(end:maxxxx,:) = zeros; 
    data2(end:maxxxx,:) = zeros;

    master.data = [data1(:,1:least_syllables) data2(:,1:least_syllables)];
    master.n = [size(bird1.U,2) size(bird2.U,2)];
    master.U = [bird1.U(:,1:least_syllables) bird2.U(:,1:least_syllables)];
    master.V = [bird1.V(:,1:least_syllables) bird2.V(:,1:least_syllables)];
end