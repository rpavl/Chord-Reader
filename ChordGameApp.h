#pragma once

#include "Chord.h"
#include <algorithm>
#include <string>
#include "ofxiOS.h"
#include "MyAppDelegate.h"

class ChordGameApp : public ofxiOSApp {
    
    
public:
    ChordGameApp ();
    ~ChordGameApp ();
    
    void setup();
    void update();
    void draw();
    void countDown();
    void drawTime();
    void reset();
    
    MyAppDelegate *appDelegate;
    ofSoundPlayer backing;
    vector < string > linesOfTheFile;
    vector < string > result;
    vector < string > trigResult;
    float millis, millisSample, prevMillis, backingMillis;
    string seconds;
    string minutes;
    float backingDecimal;
    bool begin = false;
    bool sendFirstChord = false;
    bool ChordGameAppHidden = false;
    bool startCount;
    float countMillis;
    bool startBacking;
    float crosshair;
    vector <Chord> myChord; //Initialise resizable array for however many chords we might have
    ofTrueTypeFont fontSmall;
    ofTrueTypeFont fontBig;//Helvetica to show countdown
    float backingLength;
    bool trackOver = false;
    int header,footer;
    bool reverse = false;
    int metroTime;
    int chordL[8] = { 0, 0, 0, 0, 0, 0, 0, 0};
    ofImage playButton;
    string chordPath;
    string btnNames[8] = {"A", "B", "C", "D", "E", "F", "G", "H"};
    Chord pChord;//Stores the previous chord to asses weather its a strum or a press
    int timeStampMillis = 0;
    float lowestDist; //Stores value of lowest distance chord
    int curChord = 0;
    int offset = 0;
    float sectionPhase;
    float buttonPosOffset, buttonHeighOffset;
    float strumPos;
    string totalTime = "0";
    float guitarHeadCenter, guitarHeadHeight, singleButtonHeight;
    float *rail = new float[4];  
    
};

