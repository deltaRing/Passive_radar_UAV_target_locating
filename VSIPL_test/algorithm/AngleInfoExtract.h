#pragma once
#ifndef _ANGLEINFOEXTRACT_H_
#define _ANGLEINFOEXTRACT_H_

#include "vsip.h"
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
	for (int ii = 0; ii < azNum; ii++) {
		for (int jj = 0; jj < elNum; jj++) {
			vsip_scalar_f data = vsip_mget_f(AbsAngleMap, ii, jj);
			if (data >= ratio * maxValue) {
				vsip_mput_f(output, 0, count, minAzimuth + deltaAzi * ii);
				vsip_mput_f(output, 1, count, minElevation + deltaEle * jj);
				vsip_mput_f(output, 2, count, data);
				count++;
			}
			if (count >= maxTarget) break;
		}
		if (count >= maxTarget) break;
	}

	vsip_malldestroy_f(AbsAngleMap);
	return count;
}

#endif // !_ANGLEINFOEXTRACT_H_
