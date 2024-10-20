#ifndef PLATFORM_H
#define PLATFORM_H


#undef TARGET_EXTENSION
#define TARGET_EXTENSION 1

#include "pd_api.h"
#include "src/types.h"

#define UPDATE_PER_SECOND                  50
#define UPDATE_PER_SECOND_DELTA_TIME       0.0200f
#define UPDATE_PER_SECOND_DELTA_TIME_MAX   0.0600f
#define UPDATE_PER_SECOND_DELTA_TIME_CHECK 0.0195f


typedef struct platform_t {
    PlaydateAPI *playdate;

    void (*log)(const char *fmt, ...);
    f32  (*delta_time)(void);
} platform_t;

extern platform_t platform;


void _initialize(void);
int  _update(void* user);
void _close(void);
void _pause(void);
void _resume(void);

void initialize(void);
void tick(void);
void draw(void);
void close(void);
void pause(void);
void resume(void);

#endif // PLATFORM_H
