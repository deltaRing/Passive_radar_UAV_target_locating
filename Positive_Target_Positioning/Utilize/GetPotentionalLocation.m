% 获取潜在的位置信息
% 1、角度谱图（方位 + 俯仰角）
% 2、距离点数
% 3、最大距离
function Map = GetPotentionalLocation(RadarLoc, AngleMap, AzimuthAxis, ElevationAxis, ...
    MaxRangeXYZ, RangePoints)

    if nargin == 2
        AzimuthAxis   = linspace(pi, -pi, 360);
        ElevationAxis = linspace(0, pi / 2, 90);
        MaxRangeXYZ   = [-1000 1000 -1000 1000 0 500];
        RangePoints   = [128 128 32];
    end


    minX = MaxRangeXYZ(1);
    maxX = MaxRangeXYZ(2); RangePointsX = RangePoints(1);
    minY = MaxRangeXYZ(3);
    maxY = MaxRangeXYZ(4); RangePointsY = RangePoints(2);
    minZ = MaxRangeXYZ(5);
    maxZ = MaxRangeXYZ(6); RangePointsZ = RangePoints(3);

    RangeX_Axis = linspace(minX, maxX, RangePointsX);
    RangeY_Axis = linspace(minY, maxY, RangePointsY);
    RangeZ_Axis = linspace(minZ, maxZ, RangePointsZ);
    AngleMap = abs(AngleMap) / max(max(abs(AngleMap)));
    
    Map      = zeros([RangePointsX, RangePointsY, RangePointsZ]);
    RlocX = RadarLoc(1); RlocY = RadarLoc(2); RlocZ = RadarLoc(3);
    for zz = 1:RangePointsZ
        for xx = 1:RangePointsX
            for yy = 1:RangePointsY
                locX = RangeX_Axis(xx);
                locY = RangeY_Axis(yy);
                locZ = RangeZ_Axis(zz); % 位置
                
                azi = atan2(locY - RlocY, locX - RlocX);
                ele = atan2(locZ - RlocZ, norm([locY - RlocY, locX - RlocX]));
                [~, index_azi] = min(abs(AzimuthAxis - azi));
                [~, index_ele] = min(abs(ElevationAxis - ele));
                Map(xx, yy, zz) = AngleMap(index_azi, index_ele);
            end
        end
    end
end

% [x,y,z] = meshgrid(RangeX_Axis,RangeY_Axis,RangeZ_Axis);
% data = Map;
% cdata = smooth3(rand(size(data)),'box',7);
% p = patch(isosurface(x,y,z,data,0.5));
% isonormals(x,y,z,data,p)
% isocolors(x,y,z,cdata,p)
% p.FaceColor = 'interp';
% p.EdgeColor = 'none';
% view(150,30)
% daspect([1 1 1])
% axis tight
% camlight
% lighting gouraud