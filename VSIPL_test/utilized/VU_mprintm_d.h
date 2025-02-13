#pragma once
#include "vsip.h"

#ifndef VU_MPRINTM_D_H
#define VU_MPRINTM_D_H 1
#include<string.h>
static void VU_mprintm_d(const char s[], vsip_mview_d* X) {
    char format[50];
    vsip_length RL = vsip_mgetrowlength_d(X);
    vsip_length CL = vsip_mgetcollength_d(X);
    vsip_length row, col;
    vsip_scalar_d x;
    strcpy(format, "%");
    strcat(format, s);
    strcat(format, "f %s");
    printf("[\n");
    for (row = 0; row < CL; row++) {
        for (col = 0; col < RL; col++) {
            x = vsip_mget_d(X, row, col);
            printf(format, x, ((col == (RL - 1)) ? ";" : " "));
        }
        printf("\n");
    }
    printf("];\n");
    return;
}
#endif