#include "platform.h"


platform_t platform;

typedef struct system_data_t {
    u32 tick;
    f32 time_previous;
    f32 time_elapsed_tick;
} system_data_t;

system_data_t g_data;


int eventHandler(PlaydateAPI *pd, PDSystemEvent event, uint32_t arg) {

    switch (event) {
        case kEventInit: {
            platform.playdate   = pd;
            platform.log        = pd->system->logToConsole;
            platform.delta_time = pd->system->getElapsedTime;
            pd->system->setUpdateCallback(&_update, pd);

            platform.log("Hello world");

            _initialize();
        } break;
        case kEventTerminate: {
            _close();
        } break;
        case kEventPause: {
            _pause();
        } break;
        case kEventResume: {
            _resume();
        } break;
        default: break;
    }

    return 0;
}

void _initialize(void) {
    g_data.time_elapsed_tick = platform.delta_time();

    initialize();
}

int _update(void *user) {
    f32 time       = platform.delta_time();
    f32 delta_time = time - g_data.time_previous;

    g_data.time_previous      = time;
    g_data.time_elapsed_tick += delta_time;

    if (UPDATE_PER_SECOND_DELTA_TIME_MAX < g_data.time_elapsed_tick) {
        g_data.time_elapsed_tick = UPDATE_PER_SECOND_DELTA_TIME_MAX;
    }

    bool did_update = false;

    while(UPDATE_PER_SECOND_DELTA_TIME_CHECK <= g_data.time_elapsed_tick) {
        g_data.time_elapsed_tick -= UPDATE_PER_SECOND_DELTA_TIME;
        g_data.tick++;

        tick();
        did_update = true;
    }

    if (did_update) {
        draw();
    }

    return 0;
}

void _close(void) {
    close();
}

void _pause(void) {
    pause();
}

void _resume(void) {
    resume();
}
