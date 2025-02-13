#pragma once
#ifndef VU_CMPRINTM_D_H
#define VU_CMPRINTM_D_H 1

#include "vsip.h"
#include<string.h>
static void VU_cmprintm_d(const char s[], vsip_cmview_d* X) {
    char format[50];
    vsip_length RL = vsip_cmgetrowlength_d(X);
    vsip_length CL = vsip_cmgetcollength_d(X);
    vsip_length row, col;
    vsip_cscalar_d x;
    strcpy(format, "(%");
    strcat(format, s);
    strcat(format, "lf %+");
    strcat(format, s);
    strcat(format, "lfi) %s");
    printf("[\n");
    for (row = 0; row < CL; row++) {
        for (col = 0; col < RL; col++) {
            x = vsip_cmget_d(X, row, col);
            printf(format, vsip_real_d(x), vsip_imag_d(x), ((col == (RL - 1)) ? ";" : " "));
        }
        printf("\n");
    }
    printf("];\n");
    return;
}

#endif