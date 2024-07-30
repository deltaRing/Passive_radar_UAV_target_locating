function target = UpdateTarget(target, time)
    for tt = 1:length(target)
        status = target{tt}.X(time);
        target{tt}.Pos = [status(1) status(3) status(5)];
    end
end