#pragma once

#include "vsip.h"
#include "../utilized/VU_cmprintm_d.h"

void clud_d(void) {
	printf("test complexed LU decomposition\n");
	vsip_index i = 0, j = 0;
	vsip_cmview_d* A     = vsip_cmcreate_d(6, 6, VSIP_ROW, VSIP_MEM_NONE); // cs:6, cl:6, rs:1, rl: 6, 6 x 6
	vsip_cmview_d* AX    = vsip_cmcreate_d(6, 6, VSIP_ROW, VSIP_MEM_NONE);
	vsip_cmview_d* I     = vsip_cmcreate_d(6, 6, VSIP_ROW, VSIP_MEM_NONE); // 6 x 6 Identity Matrix
	vsip_cmview_d* B     = vsip_cmcreate_d(6, 6, VSIP_ROW, VSIP_MEM_NONE); // 求解逆矩阵

	vsip_clu_d * clud = vsip_clud_create_d(6);
	vsip_cscalar_d one = { 1.0, 0.0 };
	vsip_cscalar_d zero = { 0.0, 0.0 };
	vsip_cscalar_d data[6][6] = {
		{{0.3506, 0.9205}, {0.3996, 0.8343}, {0.0826, 0.5191}, {0.6050, 0.3764}, {0.1085, 0.5714}, {0.7883, 0.9469}},
		{{0.5432, 0.0582}, {0.2208, 0.4730}, {0.0823, 0.7047}, {0.3618, 0.4256}, {0.2028, 0.3748}, {0.6273, 0.8077}},
		{{0.4687, 0.6994}, {0.1119, 0.7288}, {0.8025, 0.0438}, {0.7610, 0.5615}, {0.7049, 0.0957}, {0.1157, 0.1245}},
		{{0.0130, 0.5013}, {0.4317, 0.4028}, {0.7404, 0.2280}, {0.7192, 0.4739}, {0.6880, 0.3781}, {0.2305, 0.9662}},
		{{0.1311, 0.5152}, {0.2990, 0.1160}, {0.3861, 0.8297}, {0.5181, 0.1968}, {0.8477, 0.0761}, {0.3140, 0.6030}},
		{{0.6970, 0.4509}, {0.6392, 0.3902}, {0.9860, 0.4730}, {0.1091, 0.8426}, {0.6176, 0.1927}, {0.3131, 0.6766}}
	};

	for (int ii = 0; ii < 6; ii++) {
		for (int jj = 0; jj < 6; jj++) {
			if (ii == jj) vsip_cmput_d(I, ii, jj, one);
			else vsip_cmput_d(I, ii, jj, zero);
			vsip_cmput_d(A, ii, jj, data[ii][jj]);
			vsip_cmput_d(AX, ii, jj, data[ii][jj]);
		}
	}
	printf("Matrix A = \n");
	VU_cmprintm_d("7.2", AX); fflush(stdout);
	vsip_clud_d(clud, A);	// A 会变化
	printf("Matrix A = \n");
	VU_cmprintm_d("7.2", A); fflush(stdout);
	printf("vsip_lusol(lud,VSIP_MAT_NTRANS,X)\n");
	printf("Solve A X = I \n"); fflush(stdout);
	vsip_clusol_d(clud, VSIP_MAT_NTRANS, I);
	printf("for compact case X = \n"); 
	VU_cmprintm_d("7.2", I); fflush(stdout);

	vsip_cmprod_d(AX, I, B);
	vsip_cmview_d* R = vsip_cmtransview_f(AX);
	vsip_cmconj_d(R, R);

	printf("Matrix A = \n");
	VU_cmprintm_d("7.2", AX); fflush(stdout); 
	printf("Matrix R = \n");
	VU_cmprintm_d("7.2", R); fflush(stdout);
	printf("Matrix I = \n");
	VU_cmprintm_d("7.2", I); fflush(stdout);
	printf("mprod(A,X) = \n");
	VU_cmprintm_d("7.2", B); fflush(stdout);

	vsip_cmalldestroy_d(I);
	vsip_cmalldestroy_d(A);
	vsip_cmalldestroy_d(B);
	vsip_cmalldestroy_d(R);
	vsip_cmalldestroy_d(AX);
	vsip_clud_destroy_d(clud);

	return;
}


//A = [0.3506 + 0.9205i, 0.3996 + 1j * 0.8343, 0.0826 + 1j * 0.5191, 0.6050 + 1j * 0.3764, 0.1085 + 1j * 0.5714, 0.7883 + 1j * 0.9469;
//0.5432 + 1j * 0.0582, 0.2208 + 1j * 0.4730, 0.0823 + 1j * 0.7047, 0.3618 + 1j * 0.4256, 0.2028 + 1j * 0.3748, 0.6273 + 1j * 0.8077;
//0.4687 + 1j * 0.6994, 0.1119 + 1j * 0.7288, 0.8025 + 1j * 0.0438, 0.7610 + 1j * 0.5615, 0.7049 + 1j * 0.0957, 0.1157 + 1j * 0.1245;
//0.0130 + 1j * 0.5013, 0.4317 + 1j * 0.4028, 0.7404 + 1j * 0.2280, 0.7192 + 1j * 0.4739, 0.6880 + 1j * 0.3781, 0.2305 + 1j * 0.9662;
//0.1311 + 1j * 0.5152, 0.2990 + 1j * 0.1160, 0.3861 + 1j * 0.8297, 0.5181 + 1j * 0.1968, 0.8477 + 1j * 0.0761, 0.3140 + 1j * 0.6030;
//0.6970 + 1j * 0.4509, 0.6392 + 1j * 0.3902, 0.9860 + 1j * 0.4730, 0.1091 + 1j * 0.8426, 0.6176 + 1j * 0.1927, 0.3131 + 1j * 0.6766];