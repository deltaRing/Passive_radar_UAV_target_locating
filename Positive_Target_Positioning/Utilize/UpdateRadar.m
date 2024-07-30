function radar = UpdateRadar(radar, time)
    for rr = 1:length(radar)
        status = radar{rr}.X(time);
        radar{rr}.Pos = [status(1) status(3) status(5)];
    end
end