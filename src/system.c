#include "system.h"

int eventHandler(PlaydateAPI* pd, PDSystemEvent event, uint32_t arg) {
    pd->system->logToConsole("Hello world");

    switch (event) {
        case kEventInit: {
            pd->system->setUpdateCallback(&_update, pd);

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

}

int _update(void *user) {
    return 0;
}

void _close(void) {

}

void _pause(void) {

}

void _resume(void) {

}
