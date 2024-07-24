#pragma once

#ifndef _DBSCAN_H_
#define _DBSCAN_H_

#include "vsip.h"

int DBSCAN(vsip_mview_f* input, int inputsize,
	vsip_mview_f* output, float eps, int minpoints) {

	vsip_mview_i* data_type = vsip_mcreate_i(1, inputsize, VSIP_ROW, VSIP_MEM_NONE);
	vsip_mview_i* data_points = vsip_mcreate_i(1, inputsize, VSIP_ROW, VSIP_MEM_NONE); // 记录已有点数
	int data_index = 0;
	for (int ii = 0; ii < inputsize; ii++) {
		vsip_mput_i(data_type, 0, ii, -1);
		vsip_mput_i(data_points, 0, ii, 0);
	}
	for (int ii = 0; ii < inputsize; ii++) {
		int points = 1;
		if (vsip_mget_i(data_type, 0, ii) == -1) {
			vsip_mput_i(data_type, 0, ii, data_index);
			data_index++;
		}
		else {
			points = vsip_mget_i(data_points, 0, vsip_mget_i(data_type, 0, ii));
		}
		float point_x = vsip_mget_f(input, 0, ii), point_y = vsip_mget_f(input, 1, ii);
		for (int iii = 0; iii < inputsize; iii++) {
			if (ii == iii) continue;
			if (vsip_mget_i(data_type, 0, iii) != -1) continue;
			float delta_xx = vsip_mget_f(input, 0, iii) - point_x,
				delta_yy = vsip_mget_f(input, 1, iii) - point_y;
			if (sqrt(delta_xx * delta_xx + delta_yy * delta_yy) < eps) {
				vsip_mput_i(data_type, 0, iii, vsip_mget_i(data_type, 0, ii));
				points++;
			}
		}
		vsip_mput_i(data_points, 0, vsip_mget_i(data_type, 0, ii), points);
	}

	vsip_mview_i* outlier_index = vsip_mcreate_i(1, inputsize, VSIP_ROW, VSIP_MEM_NONE);
	for (int ii = 0; ii < inputsize; ii++)
		vsip_mput_i(outlier_index, 0, ii, -1);


	int re_index = 0, output_size = 0;
	for (int ii = 0; ii < data_index; ii++) {
		if (vsip_mget_i(data_points, 0, ii) < minpoints) {
			for (int iii = 0; iii < inputsize; iii++) {
				if (vsip_mget_i(data_type, 0, iii) == ii) {
					vsip_mput_i(outlier_index, 0, ii, -1);
				}
			}
		}
		else {
			for (int iii = 0; iii < inputsize; iii++) {
				if (vsip_mget_i(data_type, 0, iii) == ii) {
					vsip_mput_i(outlier_index, 0, iii, re_index);
					output_size += 1;
				}
			}
			re_index++;
		}
	}

	int tarIndex = 0;
	for (int ii = 0; ii < re_index; ii++) {
		for (int iii = 0; iii < inputsize; iii++) {
			if (vsip_mget_i(outlier_index, 0, iii) == ii) {
				vsip_mput_f(output, 0, tarIndex, vsip_mget_f(input, 0, iii));
				vsip_mput_f(output, 1, tarIndex, vsip_mget_f(input, 1, iii));
				vsip_mput_f(output, 2, tarIndex, ii);
				tarIndex++;
			}
		}
	}

	vsip_malldestroy_i(outlier_index);
	vsip_malldestroy_i(data_type);	
	vsip_malldestroy_i(data_points);
	return output_size;
}


#endif 