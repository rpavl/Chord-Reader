#ifndef _CHORD
#define _CHORD
#include "ofMain.h"
class Chord {
    
public:
    
    void setup(string _note, int _length, float _triggerMillis, int _millisStart, float rail[]);
    void update(float millis);
    void draw();
    
    ofVec3f pos;
    string note;
    float length;
    float tailLength;
    ofColor chordColor;
    
    int millisStart;
    int triggerMillis;
    bool done, triggered;
    bool isStrum = true;
    bool reverse = true;
    bool iPhone = true;
    
    Chord();
};
#endif
