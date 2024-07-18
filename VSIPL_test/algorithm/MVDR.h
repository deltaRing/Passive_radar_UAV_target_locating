#pragma once

#ifndef _MVDR_H_
#define _MVDR_H_

#include "math.h"
#include "vsip.h"
#include "../utilized/VU_cmprintm_f.h"
#include "../utilized/vsip_cmadjoint_D.h"

// MVDR 测角算法
// signal 复信号输入 至少需要 4个通道 
// 输入示例 signal = vsip_cmcreate_f(4, sampleNum, VSIP_ROW, VSIP_MEM_NONE);
// output 角度谱输出 大小为  azNum x elNum
// 需要输入指针
// f0 载频信号频率 （2.4GHz/5.8GHz）
// r0 阵列半径 （半波长）
// azNum 方位向遍历数目
// elNum 俯仰向遍历数目
void MVDR(vsip_cmview_f * signal, vsip_cmview_f * output,
	float f0, float r0, int azNum, int elNum, int channels, int sampleNum) {
	if (output == NULL) {
		return;
	}

	const float _PI = 3.1415926535;      // 圆周
	const float _C = 3.0 * 100000000;   // 光速
	const float _LAMBDA = _C / f0;    // 波长 

	vsip_cmview_f* R = vsip_cmcreate_f(channels, channels, VSIP_ROW, VSIP_MEM_NONE); // 自相关矩阵
	vsip_cmview_f* invR = vsip_cmcreate_f(channels, channels, VSIP_ROW, VSIP_MEM_NONE); // 自相关矩阵求解逆矩阵
	vsip_cmview_f* R_ = vsip_cmcreate_f(channels, channels, VSIP_ROW, VSIP_MEM_NONE); // 做逆矩阵需要临时变量

	vsip_cmview_f* signalT = vsip_cmadjoint_f(signal, channels, sampleNum); // 转置后的信号
	vsip_cmprod_f(signal, signalT, R); // 矩阵转置

	// 求解逆矩阵
	vsip_clu_f* clud = vsip_clud_create_f(channels);
	vsip_cmcopy_f_f(R, R_); // 复制变量

	vsip_clud_f(clud, R_);	// A 会变化
	vsip_cscalar_f one  = { 1, 0 };
	vsip_cscalar_f zero = { 0, 0 };
	for (int ii = 0; ii < channels; ii++) {
		for (int iii = 0; iii < channels; iii++) {
			if (ii == iii) vsip_cmput_f(invR, ii, iii, one);
			else vsip_cmput_f(invR, ii, iii, zero);
		}
	}
	vsip_clusol_f(clud, VSIP_MAT_NTRANS, invR);
	vsip_cmview_f * invRT = vsip_cmadjoint_f(invR, channels, channels); // 矩阵转置
	vsip_cmalldestroy_f(R_);

	// 迭代遍历空间谱
	for (int ii = 0; ii < azNum; ii++) {
		vsip_scalar_f angleAz = 2 * _PI / azNum * (ii + 1);
		for (int jj = 0; jj < elNum; jj++) {
			vsip_scalar_f angleEl = _PI / 2 / elNum * (jj + 1);
			vsip_cmview_f* A = vsip_cmcreate_f(1, channels, VSIP_ROW, VSIP_MEM_NONE);

			// 导向矢量计算
			for (int rr = 0; rr < channels; rr++) {
				float tau = r0 / _LAMBDA *
					cos(angleAz - 2 * _PI * rr / channels) * sin(angleEl);
				vsip_cscalar_f A_ = {
					cos(2 * _PI * tau),
					sin(2 * _PI * tau)
				};
				vsip_cmput_f(A, 0, rr, A_);
			}

			// 权重计算
			vsip_cmview_f * AT = vsip_cmadjoint_f(A, 1, channels);
			vsip_cmview_f * upper = vsip_cmcreate_f(channels, 1, VSIP_ROW, VSIP_MEM_NONE);
			vsip_cmprod_f(invR, AT, upper);

			// 权重
			vsip_cmview_f* w = vsip_cmcreate_f(channels, 1, VSIP_ROW, VSIP_MEM_NONE);
			// 逆矩阵运算
			vsip_cmview_f* down = vsip_cmcreate_f(1, 1, VSIP_ROW, VSIP_MEM_NONE);
			vsip_cmview_f* down_left = vsip_cmcreate_f(1, channels, VSIP_ROW, VSIP_MEM_NONE);
			vsip_cmprod_f(A, invRT, down_left);
			vsip_cmprod_f(down_left, AT, down);
			vsip_cscalar_f downINV = vsip_cmget_f(down, 0, 0);
			float xx = downINV.r; float yy = downINV.i;
			downINV.r = xx / (xx * xx + yy * yy);
			downINV.i = -yy / (xx * xx + yy * yy);
			vsip_cmput_f(down, 0, 0, downINV);
			vsip_cmprod_f(upper, down, w);
			// 遍历计算
			vsip_cmview_f* wT = vsip_cmadjoint_f(w, channels, 1); // 矩阵转置
			vsip_cmview_f* result = vsip_cmcreate_f(1, 1, VSIP_ROW, VSIP_MEM_NONE);
			vsip_cmprod_f(wT, R, down_left);
			vsip_cmprod_f(down_left, w, result); // result

			// 输入结果
			vsip_cscalar_f result_ = vsip_cmget_f(result, 0, 0);
			vsip_cmput_f(output, ii, jj, result_);

			vsip_cmalldestroy_f(A);
			vsip_cmalldestroy_f(AT);
			vsip_cmalldestroy_f(upper);
			vsip_cmalldestroy_f(down);
			vsip_cmalldestroy_f(down_left);
			vsip_cmalldestroy_f(w);
			vsip_cmalldestroy_f(wT);
			vsip_cmalldestroy_f(result);
		}
	}

	// 删除变量
	vsip_cmalldestroy_f(R);
	vsip_cmalldestroy_f(invR);
	vsip_cmalldestroy_f(invRT);
	vsip_cmalldestroy_f(signalT);
	vsip_clud_destroy_f(clud);
}

#endif
