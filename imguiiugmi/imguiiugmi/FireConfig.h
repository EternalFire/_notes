#ifndef FireConfig_h
#define FireConfig_h

#include <FireDefinition.h>

NS_FIRE_BEGIN

struct StConfig {
    float width;
    float height;
    
    StConfig() {
        width = 1280.0f;
        height = 720.0f;
    }
    
    ~StConfig() {
        
    }
};

StConfig config;

NS_FIRE_END__

#endif /* FireConfig_h */
