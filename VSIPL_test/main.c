#include <stdio.h>
#include <math.h>
#include "include/vsip.h"
#include "algorithm/MVDR.h"
#include "stdlib.h"

int main() {
	int channels = 25; int sampleNum = 500;
	int azNum = 360; int elNum = 90;
	float f0 = 5.8 * 1000000000;
	float r0 = 0.2586;
	vsip_cmview_f* signal = vsip_cmcreate_f(channels, sampleNum, VSIP_ROW, VSIP_MEM_NONE);
	vsip_cmview_f* output = vsip_cmcreate_f(azNum, elNum, VSIP_ROW, VSIP_MEM_NONE);

	FILE* file = fopen("filename_1.txt", "r");
	if (file == NULL) {
		return 1;
	}

	float real = -1, imag = -1;
	int channelIndex = 0; int sampleIndex = 0;
	while (1) {
		if (fscanf(file, "%f", &real));
		else break;
		if (fscanf(file, "%f", &imag));
		else break;
		if (channelIndex >= channels) 
			break;
		vsip_cscalar_f temp = { real, imag };
		vsip_cmput_f(signal, channelIndex, sampleIndex, temp);
		sampleIndex++;
		if (sampleIndex >= sampleNum) {
			sampleIndex = 0;
			channelIndex++;
		}
	}

	MVDR(signal, output, f0, r0, azNum, elNum, channels, sampleNum);

	vsip_cmalldestroy_d(signal);
	vsip_cmalldestroy_d(output);
	printf("�������");
	return 0;
}