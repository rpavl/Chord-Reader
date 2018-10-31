#include "ChordGameApp.h"

//--------------------------------------------------------------
ChordGameApp :: ChordGameApp () {
    cout << "creating ChordGameApp" << endl;
}

//--------------------------------------------------------------
ChordGameApp :: ~ChordGameApp () {
    
    for(int i = 0; i < 8; i++){
        chordL[i] = 0;
    }
    for(int i = 0; i < myChord.size(); i++){
        myChord[i].done = true;
    }
    
    [appDelegate pauseSound];
    [appDelegate setAutoLength:chordL];
    [appDelegate updateAutoState];
    [appDelegate stopBacking];
    [appDelegate setAmp:@(1.0)];
    
    cout << "destroying ChordGameApp" << endl;
}


//--------------------------------------------------------------
void ChordGameApp::setup(){
    
    //Setup Delegate
    appDelegate=(MyAppDelegate *)[[UIApplication sharedApplication]delegate];
    
    ofSetOrientation(OF_ORIENTATION_90_LEFT);
    
    //Set game time
    [appDelegate setTime:[NSNumber numberWithFloat:0.0]];
    
    ofEnableAlphaBlending();
    
    //Setup timer font
    ofEnableAlphaBlending();
    fontSmall.load("fonts/OpenSans-Regular.ttf", ofGetHeight()*0.0275, true, true);
    fontSmall.setLineHeight(34.0);
    fontSmall.setLetterSpacing(1.035);
    
    //Setup anouncment font
    fontBig.load("fonts/OpenSans-Regular.ttf", 200
              , true, true);
    fontBig.setLineHeight(36.0);
    
    //Backing soundtrack millisecond postion
    backingMillis = 0;
    
    //Path for the timecodes of samples
    chordPath = [appDelegate codesPath];
    
    //Button displayed when game is paused
    playButton.load("images/playbutton.png");
    
    trackOver = false;
    //Countdown to begining of track
    startCount = true;
    startBacking = false;
    
    reset();
    
    [appDelegate setupBacking];
    backingLength = [appDelegate timeLength];

    header = ofGetHeight()*0.15;
    footer = ofGetHeight()*0.9;

    appDelegate.paused = false;
    
    appDelegate.guitar.reset();
    
    ofEnableSmoothing();
    ofSetCircleResolution(30);
    
    ofBackground(255);

}



//--------------------------------------------------------------
void ChordGameApp::update(){
    
    //Determine app orientation, left handed or right handed
    reverse = appDelegate.oreintation;
    
    //Position of crosshair that shows when note should be played
    if(!reverse)
        crosshair = ofGetWidth()*0.9;
    else crosshair = ofGetWidth()*0.1;

    [appDelegate update:[appDelegate.myBle peripherals] :true:true];

    //Reset lowest destination of chord
    lowestDist = 99999999999999;
    
    //Update chord positions
    for(int i = 0; i < myChord.size(); i++){
        myChord[i].reverse = reverse;
        myChord[i].update(millis);
        
        //Determine closest chord
        if(abs(myChord[i].pos.y  - crosshair) < lowestDist){
            lowestDist =  abs(myChord[i].pos.y  - crosshair);
            curChord = std::stoi(myChord[i].note);
            //appDelegate.curChord = curChord;
            [appDelegate setSemiChord: curChord-1];
        }
        
        //Determine if chord passed crosshair
        if((myChord[i].pos.y > crosshair && !reverse) || (myChord[i].pos.y < crosshair && reverse)){
            if(!myChord[i].done){
                for(int j = 0; j < 8; j++){
                    //actvate autoplay
                    if(myChord[i].note == btnNames[j] || myChord[i].note == ofToString(j + 1)){
                        if(chordL[j] > millis){

                        }else{
                            chordL[j] = millis + ((myChord[i].length));
                            [appDelegate setAutoLength:chordL];
                        }
                    }
                }
                
                
                [appDelegate updateAutoState];
                myChord[i].done = true;
                
            }
            
        }
        
    }
    
    //Count down to begining of song
    if(startCount){
        countDown();
    }
    
    //Start backing when countdown runs out
    if(startBacking){
        [appDelegate playBacking];
        startBacking = false;
    }
    
    [appDelegate getTime];
    prevMillis = millis;
    
    if(!startCount)
        millis = [appDelegate timeValueMS];
    
    
    if(millis < prevMillis){
        
        for(int i = 0; i < 8; i++){
            chordL[i] = 0;
        }
        
        [appDelegate setAutoLength:chordL];
        [appDelegate updateAutoState];
        
        for(int i = 0; i < myChord.size(); i++){
            
            if(!reverse){
                if(myChord[i].pos.y < crosshair)
                    myChord[i].done = false;
            }else{
                if(myChord[i].pos.y > crosshair)
                    myChord[i].done = false;
            }
            
        }
        
    }
    
    if (millis - metroTime >= 2000) {
        metroTime = millis;
        [appDelegate tick];
    }
    
}


//--------------------------------------------------------------
void ChordGameApp::countDown(){
    
    if(!appDelegate.paused)
        countMillis = ((float)ofGetElapsedTimeMillis() - millisSample)/1000;
    else{
       millisSample = (float)ofGetElapsedTimeMillis() - countMillis*1000;
    }


    
    if((int)countMillis % 60 > 5){
        startBacking = true;
        startCount = false;
        appDelegate.songBegin = true;
        [appDelegate setAmp:@(1.0)];
    }
    
    ofEnableAlphaBlending();
    
    if(5 - (int)countMillis >= 0){
        
 
        
        ofEnableAlphaBlending();
        ofSetColor(255, (255 * ((7.0 - countMillis)/6)));
        ofDrawRectangle( 0, 0, ofGetWidth(), ofGetHeight());
        
        ofSetColor(0,51,255);
        ofPushMatrix();
        if(5 - (int)countMillis < 1)
            ofTranslate( ofGetWidth()*0.3, ofGetHeight()*0.6);
        else
            ofTranslate( ofGetWidth()*0.46, ofGetHeight()*0.6);

        if(5 - (int)countMillis < 1){

        }
        else{
            fontBig.drawString(ofToString(5 - (int)countMillis), 0, 0);
        }
        ofPopMatrix();
    
    }
}




//--------------------------------------------------------------
void ChordGameApp::draw(){
    
    //Draw head of guitar
    ofSetRectMode(OF_RECTMODE_CENTER);
    ofSetColor(230, 230, 230);
    ofDrawRectangle(0, guitarHeadCenter, ofGetWidth()*2,guitarHeadHeight);
    
    ofSetRectMode(OF_RECTMODE_CORNER);
   
    ofEnableAlphaBlending();
    
    //Draw background
    ofSetColor( 248, 248, 250);
    ofFill();
    //Determine where to cut of background, depending on orientation
    if(!reverse)
        ofDrawRectangle(crosshair, ofGetHeight()*0.122, ofGetWidth()-crosshair,ofGetHeight()*0.75);
    else ofDrawRectangle(0, ofGetHeight()*0.122, crosshair, ofGetHeight()*0.75);

    
    //vertical sections seperating chords (simulate track movement)
    ofSetColor(245);
    ofSetLineWidth(2.5);
    for(int i = 0; i < 9; i++){

        //Determine direction of lines depending on orientation chosen in settings.
        if(!reverse)
            sectionPhase = (ofGetWidth()*0.1215) * i + ofMap(millis-timeStampMillis, 0, 1950, 0, ofGetWidth()*0.85);
        else sectionPhase = (ofGetWidth()*0.1215) * i + ofMap(millis-timeStampMillis, 0, 1950, ofGetWidth()*0.27, -ofGetWidth()*0.58);
        
        ofDrawLine(sectionPhase, ofGetHeight()*0.125, sectionPhase, ofGetHeight()*0.875);
    }
   
    if(ofMap(millis-timeStampMillis, 0, 1950, 0, ofGetWidth()*0.85) > ofGetWidth()*0.1215){
        timeStampMillis = millis;
    }
    //Return to original section position through time
    if(millis == 0)
        timeStampMillis = 0;
    
    //Draw grid seperating the buttons/row of the chords
    ofNoFill();
    ofSetColor(191, 191, 196);
    ofSetLineWidth(2.5);
    for(int i = 0; i < 4; i++){
        ofDrawLine(0, (guitarHeadCenter - (guitarHeadHeight / 2) + (singleButtonHeight/2)) + (singleButtonHeight ) * i   , ofGetWidth(),  (guitarHeadCenter - (guitarHeadHeight / 2) + (singleButtonHeight/2)) + (singleButtonHeight ) * i  );
    }
    
   
    //Draw long button highlights when pressed
    ofSetRectMode(OF_RECTMODE_CENTER);

    ofFill();
    for(int i = 0; i < 8; i++){
        if([[appDelegate.myBle uArray] count] > 0){
            if(i < 4){
                ofSetColor(255,50,100, 255/2 * appDelegate->myBtns[i]);
                
                ofDrawEllipse( crosshair, (guitarHeadCenter - (guitarHeadHeight / 2) + (singleButtonHeight/2)) + (singleButtonHeight ) * i  ,ofGetHeight()*0.1,ofGetHeight()*0.1);
                
                ofDrawRectangle( crosshair, (guitarHeadCenter - (guitarHeadHeight / 2) + (singleButtonHeight/2)) + (singleButtonHeight ) * i ,ofGetWidth()*2,singleButtonHeight);
            }else{
                ofSetColor(100, 50, 255, 255/2 * appDelegate->myBtns[i]);
                ofDrawEllipse( crosshair, (guitarHeadCenter - (guitarHeadHeight / 2) + (singleButtonHeight/2)) + (singleButtonHeight ) * (i - 4) ,ofGetHeight()*0.1,ofGetHeight()*0.1);
                
                ofDrawRectangle( crosshair, (guitarHeadCenter - (guitarHeadHeight / 2) + (singleButtonHeight/2)) + (singleButtonHeight ) * (i - 4) ,ofGetWidth()*2,singleButtonHeight);
            }
        }
    }
    
    ofSetRectMode(OF_RECTMODE_CORNER);
    
    for(int i = 0; i < myChord.size(); i++){
        if(myChord[i].pos.y < ofGetWidth()*2 || myChord[i].pos.y < -ofGetWidth()/4){
            myChord[i].draw();
        }
    }
    
    //Draw long button highlights when pressed
    ofSetColor(255);
    
    
    //Button background
    if(!reverse)
        ofDrawRectangle(0, 0,ofGetWidth() * 0.0625, ofGetHeight());
    else ofDrawRectangle(ofGetWidth() * 0.9375, 0,ofGetWidth() * 0.0625, ofGetHeight());
        
    
    ofSetRectMode(OF_RECTMODE_CENTER);
    

    
    //smaller Button graphics at end of screen
    //Guitar Head
    
    ofPushMatrix();
    
    if(appDelegate.iPhoneType == "iPhoneX"){
        if(reverse){
            ofTranslate(-ofGetWidth()*0.036, 0);
        }else{
             ofTranslate(ofGetWidth()*0.036, 0);
        }
    }
    
    
    
    for(int i = 0; i < 4; i++){
        
            if(i == 0){
                buttonPosOffset = 0;
                buttonHeighOffset = ofGetHeight()*0.3075;
            }else if(i == 3){
                buttonPosOffset = ofGetHeight()*0.118 + (ofGetHeight()*0.191  *  i);
                buttonHeighOffset = ofGetHeight()*0.21;
            }else{
               buttonPosOffset = ofGetHeight()*0.118 + (ofGetHeight()*0.191  *  i);
                buttonHeighOffset = ofGetHeight()*0.19;
            }
            if(reverse){
                
                ofSetColor(218, 72, 145);
                ofDrawRectangle(ofGetWidth() - (ofGetHeight()*0.035 / 2),     (guitarHeadCenter - (guitarHeadHeight / 2) + (singleButtonHeight/2)) + (singleButtonHeight ) * i ,
                                
                                ofGetHeight()*0.035,
                                singleButtonHeight-2);
                
                
                ofSetColor(255, 255 * appDelegate->myBtns[i]);
                ofDrawRectangle(ofGetWidth() - (ofGetHeight()*0.035 / 2),     (guitarHeadCenter - (guitarHeadHeight / 2) + (singleButtonHeight/2)) + (singleButtonHeight ) * i ,
                                
                                ofGetHeight()*0.035,
                                singleButtonHeight-2);
                
                ofSetColor(13, 51, 246);
                ofDrawRectangle(ofGetWidth() - ofGetHeight()*0.055,     (guitarHeadCenter - (guitarHeadHeight / 2) + (singleButtonHeight/2)) + (singleButtonHeight ) * i ,
                                
                                ofGetHeight()*0.035,
                                singleButtonHeight-2);
                
                ofSetColor(255, 255 * appDelegate->myBtns[i+4]);
                ofDrawRectangle(ofGetWidth() - ofGetHeight()*0.055,     (guitarHeadCenter - (guitarHeadHeight / 2) + (singleButtonHeight/2)) + (singleButtonHeight ) * i ,
                                
                                ofGetHeight()*0.035,
                                singleButtonHeight-2);
            }else{

                
                ofSetColor(218, 72, 145);
                ofDrawRectangle(ofGetHeight()*0.055,     (guitarHeadCenter - (guitarHeadHeight / 2) + (singleButtonHeight/2)) + (singleButtonHeight ) * i ,
                                
                                ofGetHeight()*0.035,
                                singleButtonHeight-2);
                
                ofSetColor(255, 255 * appDelegate->myBtns[i]);
                ofDrawRectangle(ofGetHeight()*0.055,     (guitarHeadCenter - (guitarHeadHeight / 2) + (singleButtonHeight/2)) + (singleButtonHeight ) * i ,
                                
                                ofGetHeight()*0.035,
                                singleButtonHeight-2);
                
                ofSetColor(13, 51, 246);
                ofDrawRectangle(ofGetHeight()*0.035/2,     (guitarHeadCenter - (guitarHeadHeight / 2) + (singleButtonHeight/2)) + (singleButtonHeight ) * i ,
                                
                                ofGetHeight()*0.035,
                                singleButtonHeight-2);
                
                ofSetColor(255, 255 * appDelegate->myBtns[i+4]);
                ofDrawRectangle(ofGetHeight()*0.035/2,     (guitarHeadCenter - (guitarHeadHeight / 2) + (singleButtonHeight/2)) + (singleButtonHeight ) * i ,
                                
                                ofGetHeight()*0.035,
                                singleButtonHeight-2);
                

            }
    }
    
    //Strum Meter indicator
    if([appDelegate.myBle.peripherals count] > 1){
        if([[appDelegate.myBle peripherals][1][4] floatValue] > 0.075 || [[appDelegate.myBle peripherals][1][4] floatValue] < -0.075)
            strumPos = [[appDelegate.myBle peripherals][1][4] floatValue] * -257;
        else strumPos = 0;
    }else strumPos = 0;
    
    if(reverse){
        ofSetColor(191, 191, 191);
        ofDrawRectangle(ofGetWidth() - ofGetHeight()*0.0925, ofGetHeight()*0.4975, ofGetHeight()*0.035,guitarHeadHeight);
        ofSetColor(255);
        ofPushMatrix();
        ofTranslate(0, strumPos ,0);
        ofDrawRectangle(ofGetWidth() - ofGetHeight()*0.0925, ofGetHeight()*0.4975, ofGetHeight()*0.031,ofGetHeight()*0.075);
        ofPopMatrix();
    }else{
        ofSetColor(191, 191, 191);
        ofDrawRectangle(ofGetHeight()*0.0925, ofGetHeight()*0.4975, ofGetHeight()*0.035,guitarHeadHeight);
        ofSetColor(255);
        ofPushMatrix();
        ofTranslate(0, strumPos ,0);
        ofDrawRectangle(ofGetHeight()*0.0925, ofGetHeight()*0.4975, ofGetHeight()*0.031,ofGetHeight()*0.075);
        ofPopMatrix();
    }
    
    ofSetRectMode(OF_RECTMODE_CORNER);
    ofPopMatrix();
    
    //Draw Crosshairs
    ofNoFill();
    ofSetColor(191, 191, 196);
    ofSetLineWidth(2.5);
    for(int i = 0; i < 4; i++){
        
        ofNoFill();
        ofSetColor(191, 191, 196);
        ofSetLineWidth(2.5);
        ofDrawEllipse( crosshair, rail[i],ofGetHeight()*0.1,ofGetHeight()*0.1
                      );
        
        ofSetColor(255,0,0);

    }
    
    ofFill();
    
    if(startCount){
        countDown();
    }
    
    ofDisableAlphaBlending();
    if(prevMillis/millis < 0.05){
        for(int i = 0; i < myChord.size(); i++)
            myChord[i].done = false;
        
        chordL[0] = 0.0;
        chordL[1] = 0.0;
        chordL[2] = 0.0;
        chordL[3] = 0.0;
        chordL[4] = 0.0;
        chordL[5] = 0.0;
        chordL[6] = 0.0;
        chordL[7] = 0.0;
    }
    
    //Show pause screen when tapped
    ofEnableAlphaBlending();
    if(appDelegate.paused){
        //if(!startCount)
            ofSetColor(45, 160);
       // else ofSetColor(255/1.1);
        ofDrawRectangle( 0, 0, ofGetWidth(), ofGetHeight());
        ofSetColor(255);
        ofPushMatrix();
        ofTranslate( ofGetWidth()*0.455, ofGetHeight()*0.39 );
        playButton.draw(0,0, playButton.getWidth()*0.3, playButton.getHeight()*0.3);
        ofPopMatrix();
        trackOver = false;
    }
    ofDisableAlphaBlending();
    
    ofSetColor(255);
    drawTime();
}

//--------------------------------------------------------------
void ChordGameApp::drawTime(){
    
    
    //Millis are set in the main kurvApp, before mplayButtonyChordGameApp.draw, through the backings millis
    //Convert millis into seconds
    if((int)millis/1000 % 60 < 10){
        seconds = "0" + ofToString((int)millis/1000 % 60);
    }else{
        seconds = ofToString((int)millis/1000 % 60);
    }
    
    minutes = ofToString(((int)millis/1000) / 60);
    
    backingDecimal = [appDelegate timeLength] / 1000;
    
    
    if(appDelegate.timeValueMS >= appDelegate.timeLength-50){

       // trackOver = true;
        [appDelegate muteAuto];
    }
    
  
    //Draw Current Time
    ofPushMatrix();
    ofTranslate(ofGetWidth()*0.065 ,ofGetHeight()*0.95);
    ofSetColor(102);
    ofEnableAlphaBlending();
    if(!trackOver){
        //Convert seconds into digital clock and draw it
        fontSmall.drawString(minutes + "." + seconds, 0, 0);
    }else{
        fontSmall.drawString(ofToString((int)(backingDecimal)/60) + "." + ofToString(((int)backingDecimal) % 60), 0, 0);
        

    }
    ofPopMatrix();
    
   
    //Draw Track Total Time
    ofPushMatrix();
    ofTranslate(ofGetWidth()*0.907 ,ofGetHeight()*0.95);
    ofSetColor(212);
    
    
    totalTime = ofToString((int)(backingDecimal)/60) + "." + ofToString(((int)backingDecimal) % 60);
    
    //Add decimel point to time when 10 20 30 40 50 or 60 seconds
    if(totalTime.size() < 4)
        totalTime = totalTime + "0";
    
    ofEnableAlphaBlending();
    fontSmall.drawString(totalTime, 0, 0);
    
    ofPopMatrix();
    
    
    
}



//--------------------------------------------------------------
void ChordGameApp::reset(){
    
    
    
    guitarHeadCenter = ofGetHeight()*0.4975;
    guitarHeadHeight = ofGetHeight()*0.75;
    singleButtonHeight = guitarHeadHeight/4;
    
    
    
    rail[0] = (guitarHeadCenter - (guitarHeadHeight / 2) + (singleButtonHeight/2)) + (singleButtonHeight ) * 0;
    rail[1] = (guitarHeadCenter - (guitarHeadHeight / 2) + (singleButtonHeight/2)) + (singleButtonHeight ) * 1;
    rail[2] = (guitarHeadCenter - (guitarHeadHeight / 2) + (singleButtonHeight/2)) + (singleButtonHeight ) * 2;
    rail[3] = (guitarHeadCenter - (guitarHeadHeight / 2) + (singleButtonHeight/2)) + (singleButtonHeight ) * 3;
    
    
    //Reset all timers
    millisSample = (float)ofGetElapsedTimeMillis();
    countMillis = 0;
    millis = 0;
    prevMillis = 0;
    
    
    
    linesOfTheFile.clear();
    ofBuffer buffer = ofBufferFromFile(chordPath);
    
    //Read chord placements from TXT
    for (auto line : buffer.getLines()){
        linesOfTheFile.push_back(line);
    }
    
    //Turn lines of text into chord
    for(int i = 0; i < linesOfTheFile.size()-1; i++){

        result = ofSplitString(linesOfTheFile[i], ":");
        
        Chord tempChord;
        
        //Trimg string for up and down
        if(result[1].size() > 1)
            result[1].erase(result[1].size() - 1);
        
        tempChord.setup(result[1], atoi(result[2].c_str()), atoi(result[0].c_str()) - [appDelegate offset] , atoi(result[0].c_str()) - [appDelegate offset]+ -2500, rail);
        
        if((tempChord.millisStart - (pChord.millisStart + pChord.length)) < 50 && tempChord.note == pChord.note)
            tempChord.isStrum = true;
        else tempChord.isStrum = false;
        
        myChord.push_back(tempChord);
        pChord = tempChord;
    }
    
    //Reset chord objects
    for(int i = 0; i < myChord.size(); i++)
        myChord[i].done = false;
    
    //Reset length of chords
    chordL[0] = 0.0;
    chordL[1] = 0.0;
    chordL[2] = 0.0;
    chordL[3] = 0.0;
    chordL[4] = 0.0;
    chordL[5] = 0.0;
    chordL[6] = 0.0;
    chordL[7] = 0.0;
    
    
}

//Map Values to different ratio
//--------------------------------------------------------------
float ofMap(float value, float istart, float istop, float ostart, float ostop) {
    return ostart + (ostop - ostart) * ((value - istart) / (istop - istart));
}


