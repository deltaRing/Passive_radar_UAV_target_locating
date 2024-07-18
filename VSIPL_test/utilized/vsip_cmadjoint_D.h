#pragma once

#ifndef _VSIP_CMADJOINT_D_H_ 
#define _VSIP_CMADJOINT_D_H_

#include "vsip.h"

vsip_cmview_f * vsip_cmadjoint_f(vsip_cmview_f * input, int rows, int cols) {
	vsip_cmview_f* output = vsip_cmcreate_f(cols, rows, VSIP_ROW, VSIP_MEM_NONE);
	for (int ii = 0; ii < rows; ii++){
		for (int jj = 0; jj < cols; jj++) {
			vsip_cscalar_f temp = vsip_cmget_f(input, ii, jj);
			temp.i = -temp.i;
			vsip_cmput_f(output, jj, ii, temp);
		}
	}
	return output;
}

#endif