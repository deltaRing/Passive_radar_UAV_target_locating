#pragma once
#ifndef _ANGLEINFOEXTRACT_H_
#define _ANGLEINFOEXTRACT_H_

#include "vsip.h"
#include "../utilized/DBSCAN.h"
#include "utilized/VU_mprintm_f.h"

int AngleInfoExtract(vsip_cmview_f* AngleMap, int azNum, int elNum, 
	vsip_mview_f* output, int maxTarget, float ratio,
	float minAzimuth, float maxAzimuth, float minElevation, float maxElevation) {
	vsip_mview_f* AbsAngleMap = vsip_mcreate_f(azNum, elNum, VSIP_ROW, VSIP_MEM_NONE);
	float deltaAzi = (maxAzimuth - minAzimuth) / azNum;
	float deltaEle = (maxElevation - minElevation) / elNum;

	float maxValue = -1, meanValue = 0;
	for (int ii = 0; ii < azNum; ii++) {
		for (int jj = 0; jj < elNum; jj++) {
			vsip_cscalar_f data = vsip_cmget_f(AngleMap, ii, jj);
			float norm = sqrt(data.r * data.r + data.i * data.i);
			vsip_mput_f(AbsAngleMap, ii, jj, norm);
			meanValue += norm;
			maxValue = norm > maxValue ? norm : maxValue;
		}
	}
	meanValue = meanValue / azNum / elNum;

	if (maxValue <= meanValue * 1.25) { vsip_malldestroy_f(AbsAngleMap); return -1; }

	//  find(abs(angleInfo) > maxValue * ratio);
	int count = 0;
	vsip_mview_f* output_ = vsip_mcreate_f(3, maxTarget, VSIP_ROW, VSIP_MEM_NONE);
	for (int ii = 0; ii < azNum; ii++) {
		for (int jj = 0; jj < elNum; jj++) {
			vsip_scalar_f data = vsip_mget_f(AbsAngleMap, ii, jj);
			if (data >= ratio * maxValue) {
				vsip_mput_f(output_, 0, count, minAzimuth + deltaAzi * ii);
				vsip_mput_f(output_, 1, count, minElevation + deltaEle * jj);
				vsip_mput_f(output_, 2, count, data);
				count++;
			}
			if (count >= maxTarget) break;
		}
		if (count >= maxTarget) break;
	}
	vsip_mview_f* output__ = vsip_mcreate_f(3, count, VSIP_ROW, VSIP_MEM_NONE);
	int outputSize = DBSCAN(output_, count, output__, 0.15, 1);

	int maxIndex = -1;
	for (int ii = 0; ii < outputSize; ii++) {
		if (maxIndex < vsip_mget_f(output__, 2, ii))
			maxIndex = vsip_mget_f(output__, 2, ii);
	}

	for (int ii = 0; ii <= maxIndex; ii++) {
		float xx = -10000, yy = -10000;
		for (int iii = 0; iii < count; iii++) {
			if (vsip_mget_f(output__, 2, iii) == ii) {
				if (xx == -10000 && yy == -10000) {
					xx = vsip_mget_f(output__, 0, iii);
					yy = vsip_mget_f(output__, 1, iii);
				}
				else {
					xx = (xx + vsip_mget_f(output__, 0, iii)) / 2;
					yy = (yy + vsip_mget_f(output__, 1, iii)) / 2;
				}
			}
		}
		vsip_mput_f(output, 0, ii, xx);
		vsip_mput_f(output, 1, ii, yy);
		vsip_mput_f(output, 2, ii, ii);
	}

	vsip_malldestroy_f(AbsAngleMap);
	vsip_malldestroy_f(output__);
	vsip_malldestroy_f(output_);
	return maxIndex;
}

#endif // !_ANGLEINFOEXTRACT_H_
