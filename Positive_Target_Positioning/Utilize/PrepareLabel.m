function labels = PrepareLabel(Target_Location, ...
    expect_range, ...
    expect_number, ...
    eps, enhance)
if nargin == 1
    expect_range = [-1000 1000 -1000 1000 0 500];
    expect_number = [256, 256, 64];
    eps = 10.0;
    enhance = 1e8;
end

    tarNum = size(Target_Location, 1); % 目标数目
    
    % 生成目标概率分布函数
    for tt = 1:tarNum
        locX = Target_Location(tt, 1);
        locY = Target_Location(tt, 2);
        locZ = Target_Location(tt, 3);
        func{tt} = @(x, y, z) 1 / (sqrt(2 * pi)^3 * eps^3) * ...
            exp(-((x - locX)^2 + (y - locY)^2 + (z - locZ)^2) / 2 / eps^2);
    end
    
    expect_range_x_min = expect_range(1);
    expect_range_x_max = expect_range(2);
    expect_range_y_min = expect_range(3);
    expect_range_y_max = expect_range(4);
    expect_range_z_min = expect_range(5);
    expect_range_z_max = expect_range(6);
    
    xNumber = expect_number(1);
    yNumber = expect_number(2);
    zNumber = expect_number(3); % 
    rangeXAxis = linspace(expect_range_x_min, expect_range_x_max, xNumber);
    rangeYAxis = linspace(expect_range_y_min, expect_range_y_max, yNumber);
    rangeZAxis = linspace(expect_range_z_min, expect_range_z_max, zNumber);
    
    labels = zeros([xNumber, yNumber, zNumber]);
    for zz = 1:zNumber
        for xx = 1:xNumber
            for yy = 1:yNumber
                for tt = 1:tarNum
                    labels(xx, yy, zz) = labels(xx, yy, zz) + enhance * func{tt}(rangeXAxis(xx), ...
                        rangeYAxis(yy), rangeZAxis(zz));
                end
            end
        end
    end
end