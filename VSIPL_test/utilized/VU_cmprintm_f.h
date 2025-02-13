#pragma once
#ifndef VU_CMPRINTM_F_H
#define VU_CMPRINTM_F_H 1
#include<string.h>
#include "vsip.h"

static void VU_cmprintm_f(const char s[], vsip_cmview_f* X) {
    char format[50];
    vsip_length RL = vsip_cmgetrowlength_f(X);
    vsip_length CL = vsip_cmgetcollength_f(X);
    vsip_length row, col;
    vsip_cscalar_f x;
    strcpy(format, "(%");
    strcat(format, s);
    strcat(format, "lf %+");
    strcat(format, s);
    strcat(format, "lfi) %s");
    printf("[\n");
    for (row = 0; row < CL; row++) {
        for (col = 0; col < RL; col++) {
            x = vsip_cmget_f(X, row, col);
            printf(format, vsip_real_f(x), vsip_imag_f(x), ((col == (RL - 1)) ? ";" : " "));
        }
        printf("\n");
    }
    printf("];\n");
    return;
}

#endif