#ifndef SYSTEM_H
#define SYSTEM_H

#include "pd_api.h"
#include "src/types.h"

typedef struct {

} system_t;

void _initialize(void);
int  _update(void* user);
void _close(void);
void _pause(void);
void _resume(void);

#endif // SYSTEM_H
