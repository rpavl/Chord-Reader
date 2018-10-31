#include "Chord.h"
Chord::Chord(){
}

void Chord::setup(string _note, int _length, float _triggerMillis, int _millisStart, float rail[]){
    
    note = _note;
    length = _length;
    millisStart = _millisStart;
    triggerMillis = _triggerMillis;
    triggered = false;
    
    //Y Position and Color determined by note
    if(note == "A" || note == "1"){
        pos.x = rail[0];
        chordColor = ofColor(218,28,93);
    } else if (note == "B" || note == "2"){
        pos.x = rail[1];
        chordColor = ofColor(218,28,93);
    } else if (note == "C" || note == "3"){
        pos.x = rail[2];
        chordColor = ofColor(218,28,93);
    }   else if (note == "D" || note == "4"){
        pos.x = rail[3];
        chordColor = ofColor(218,28,93);
    } else if (note == "E" || note == "5"){
        pos.x = rail[0];
        chordColor = ofColor(0,51,255);
    } else if (note == "F" || note == "6"){
        pos.x = rail[1];
        chordColor = ofColor(0,51,255);
    }   else if (note == "G" || note == "7"){
        pos.x = rail[2];
        chordColor = ofColor(0,51,255);
    }   else if (note == "H" || note == "8"){
        pos.x = rail[3];
        chordColor = ofColor(0,51,255);
    }
    
}

void Chord::update(float millis){
    
    if(!reverse)
        pos.y = ofMap(millis, millisStart, triggerMillis, -ofGetWidth()*0.2, ofGetWidth()*0.85);
    else pos.y = ofMap(millis, millisStart, triggerMillis, ofGetWidth()*1.2, ofGetWidth()*0.15);
    
    if(!reverse)
        tailLength = ofMap(millis-length, millisStart, triggerMillis, -ofGetWidth()*0.2, ofGetWidth()*0.85);
    else tailLength = ofMap(millis-length, millisStart, triggerMillis, ofGetWidth()*1.2, ofGetWidth()*0.15);
    
}

void Chord::draw(){
    
    ofFill();
    if(!triggered)
        ofSetColor(chordColor);
    else{
        if(note == "A" || note == "B" || note == "C" || note == "D" || note == "1" || note == "2" ||note == "3" || note == "4")
            ofSetColor(chordColor.r*5, chordColor.g*6, chordColor.b*3);
        else   ofSetColor(chordColor.r*3, chordColor.g*6, chordColor.b*6);
    }
    
    //scalling for ipad/iphone
    if(iPhone)
        ofSetLineWidth(5);
    else ofSetLineWidth(9);
    
    ofDrawLine( pos.y, pos.x, tailLength, pos.x);
    
    if(!isStrum){
        if(note == "A" || note == "B" || note == "C" || note == "D" || note == "1" || note == "2" ||note == "3" || note == "4")
            ofSetColor(chordColor);
        else   ofSetColor(chordColor);
        ofDrawEllipse(pos.y, pos.x, ofGetHeight()*0.1, ofGetHeight()*0.1);
    }else ofDrawLine( pos.y, pos.x - ofGetHeight()*0.05 ,pos.y , pos.x + ofGetHeight()*0.05);
    
    ofSetLineWidth(1);
}

//--------------------------------------------------------------
float ofMap(float value, float istart, float istop, float ostart, float ostop) {
    return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
}

