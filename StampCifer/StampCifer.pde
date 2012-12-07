  /*
    StampCifer is an open source project created at Stanford University.
    
    We utilize the TUIO processing demo - part of the reacTIVision project
    http://reactivision.sourceforge.net/, as well as the SoundCipher library.
*/

// import Java ArrayList for handling of music elements class
import java.util.*;
import java.util.ArrayList;
import java.util.List;

import processing.serial.*;

import cc.arduino.*;

// import the TUIO library and declare a TuioProcessing client variable
import TUIO.*;
TuioProcessing tuioClient;

// simple audio library "SoundCipher"  (tempo=120 bpm)
import arb.soundcipher.*;

Arduino arduino;

// these are some helper variables which are used to create scalable graphical feedback
PFont font;
int screen_width;
int screen_height;
float width_scaling;
float staff_width;
float staff_height;
float start_increment;
float y_increment;
float names_increment;

// we use this to dynamically change note duration based on angle delta
float previous_angle = 0;

// size of hardware screen devoted to staff music
float xwidth = 1;
float ywidth = 1;

// default values for duration, pitch, and volume
float Default_note_duration = 1;
int Default_note_pitch = 60;
int Default_note_volume = 500;
int Default_instrument = 0;
int Default_tempo = 160;

// duration can only drop to an 8th note (0.125)
float min_duration = (float) 1 / 8; 

// our fiduciary objects ID
int object_id = 77; 
int object_id1 = 54;
int object_id2 = 90;
int object_id3 = 91;
int object_id4 = 44;

int object_idb = 185;
int object_idb1 = 162;
int object_idb2 = 198;
int object_idb3 = 199;
int object_idb4 = 152;

// this is where we store our user's array of sounds
ArrayList piece = new ArrayList();

// this creates a user's music note
SoundCipher note;

// variables to store temporarly the components of the musical element before commiting the element and saving it
int local_note_pitch = Default_note_pitch;
float local_note_duration = Default_note_duration;
int local_note_volume = Default_note_volume;
int instrument = Default_instrument;
int tempo = Default_tempo;

// List of the notes names
String [] note_names;

// button for playing music
float buttonX = (float) 510 * width_scaling; 
float buttonY = (float) staff_height / 4 / 12;
float button_width = (float) 30 * width_scaling;
float button_height = (float) staff_height / 2 / 12;

// used to limit the amount of notes added
boolean wait = true;
int iterations = 0;

//moving the screen
int offset = 0;
int menu = 0; // default menu - Homepage

//Activities variables
boolean activity_on = false;
boolean note_entered = false;
int second_pitch = 0;
int start_pitch = 0;
int entered_pitch = 0;
String feedback;
boolean display_wait = true;
int iterations2 = 0;
boolean feedback_wait = false;
int iterations3 = 0;

//list of txt files
String [] txtFiles;

//shapes
PShape delete;
PShape logo;
PShape restNote;
PShape soundNote;
PShape rotateKnob;

void setup()
{   
  // Set up dimensions
  screen_width = displayWidth;
  screen_height = displayHeight;
  size(screen_width,screen_height);
  width_scaling = (float) screen_width / 640;
  staff_width = (float) 0.7 * screen_width;
  staff_height = (float) 0.9 * screen_height;
  start_increment = (float) 0.05 * screen_width;
  y_increment = (float) 0.05 * screen_height;
  names_increment = (float) start_increment / 2;
  
  // button for playing music
  buttonX = (float) 510 * width_scaling; 
  buttonY = (float) staff_height / 4 / 12;
  button_width = (float) 80 * width_scaling;
  button_height = (float) staff_height / 2 / 6;

  background(0);
  noStroke();
  fill(255);
 
  // set to loop and identify frameRate 
  loop();
  frameRate(30);
  // noLoop();
  
  // set font size 
  hint(ENABLE_NATIVE_FONTS);
  font = loadFont("Lobster1.4-48.vlw");
  
  // we create an instance of the TuioProcessing client
  // since we add "this" class as an argument the TuioProcessing class expects
  // an implementation of the TUIO callback methods (see below)
  tuioClient  = new TuioProcessing(this);
 
  note = new SoundCipher(this);   // sound object for audio feedback

  // Set up the names of the notes that will appear on the staff
  note_names = new String [12];
  note_names[0] = "G"; note_names[1] = "F"; note_names[2] = "E"; note_names[3] = "D"; note_names[4] = "C"; note_names[5] = "B"; 
  note_names[6] = "A"; note_names[7] = "G"; note_names[8] = "F"; note_names[9] = "E"; note_names[10] = "D"; note_names[11] = "C";
  
    arduino = new Arduino(this, Arduino.list()[1], 57600);
  
  for (int i = 0; i <= 13; i++)
    arduino.pinMode(i, Arduino.INPUT);
}

// check to see if a button has been pressed
void mousePressed() {
    if (menu == 1) {
       if(!(((mouseX > ( buttonX+button_width)) || (mouseY > ((staff_height / 8)*2 + button_height))) || ((mouseX < buttonX) || (mouseY < (staff_height / 8)*2)))) // Back Button
           {writeMusic();}
       if(!(((mouseX > ( buttonX+button_width)) || (mouseY > ((staff_height / 8)*3 + button_height))) || ((mouseX < buttonX) || (mouseY < (staff_height / 8)*3)))) // Tempo Button
           {tempo += 20; if(tempo == 500) {tempo = 20;}}
       if(!(((mouseX > ( buttonX+button_width)) || (mouseY > ((staff_height / 8)*5 + button_height))) || ((mouseX < buttonX) || (mouseY < (staff_height / 8)*5)))) // Instrument Button
           {instrument += 1; if (instrument ==128) {instrument = 0;}}
        if(!(((mouseX > ( buttonX+button_width)) || (mouseY > ((staff_height / 8)*7 + button_height))) || ((mouseX < buttonX) || (mouseY < (staff_height / 8)*7)))) // Clear button
           {piece.clear();}
         }        
  if(!(((mouseX > ( buttonX+button_width)) || (mouseY > (buttonY + button_height))) || ((mouseX < buttonX) || (mouseY < buttonY)))) // Back Button
  {menu = 0; piece.clear(); activity_on = false; note_entered = false; wait = false; iterations = 0; display_wait = true; iterations2 = 0; instrument = Default_instrument; tempo = Default_tempo; note.score.instrument(instrument); note.score.tempo(tempo);}
  if(!(((mouseX > ( buttonX+button_width)) || (mouseY > (buttonY+ staff_height /8 + button_height))) || ((mouseX < buttonX) || (mouseY < buttonY + staff_height /8)))) // Play Button
  { if (menu == 1) {Play_notes(instrument, tempo, 0);}
    if (menu == 2) 
    {   note.score.empty();
        note.score.addNote(0.2, start_pitch, Default_note_volume, Default_note_duration);
        note.score.addNote(1.2, second_pitch, Default_note_volume, Default_note_duration);
        note.score.play(0, 55);
    }
  }
  if (menu == 0) {
  if(!(((mouseX > ((screen_width/2 - screen_width/16) + (screen_width / 8))) || (mouseY > ((screen_height/2 - 60 - screen_height/16) + (screen_height / 8)))) || ((mouseX < (screen_width/2 - screen_width/16) || (mouseY < (screen_height / 2 - 60 - screen_height/16)))))) // Compose Button
  {menu = 1; return;}
  if(!(((mouseX > ((screen_width/2 - screen_width/16) + (screen_width / 8))) || (mouseY > ((screen_height/2 + screen_height/8 - 40 - screen_height/16) + (screen_height / 8)))) || ((mouseX < (screen_width/2 - screen_width/16) || (mouseY < (screen_height / 2 + screen_height/8 - 40 - screen_height/16)))))) // Compose Button
  {menu = 2; return;}
  if(!(((mouseX > ((screen_width/2 - screen_width/16) + (screen_width / 8))) || (mouseY > ((screen_height/2 + (screen_height/8)*2 - 20 - screen_height/16) + (screen_height / 8)))) || ((mouseX < (screen_width/2 - screen_width/16) || (mouseY < (screen_height / 2 + (screen_height/8)*2 - 20 - screen_height/16)))))) // Compose Button
  {menu = 3; return;}
  }
 
  if (menu == 3){
  for (int i = 0; i < txtFiles.length; i++) {
    if(!(((mouseX > (screen_width / 2 - screen_width / 8 + screen_width /6)) || (mouseY > ((1.3*i*100) + 100 + screen_height / 8))) || ((mouseX < screen_width / 2 - screen_width / 8) || (mouseY < (1.3*i*100) + 100)))) // Open song
    {menu = 1; readMusic(txtFiles[i]); return;}
    if(!(((mouseX > (screen_width / 2 - screen_width / 8 + 270 + 50)) || (mouseY > ((1.3*i*100) +120 + 50))) || ((mouseX < screen_width / 2 - screen_width / 8 + 270) || (mouseY < (1.3*i*100) +120)))) // Open song
    {menu = 3; String [] m1 = match((txtFiles[i]), "myMusic");
      if(m1!=null) {
        menu = 3; deleteFile((txtFiles[i])); return;} 
      }   
    }
  }
}

// Fiducial version of mousePressed - check to see if a button has been pressed
void Buttons(TuioObject tobj) {
    if (menu == 1) {
       if(!(((tobj.getScreenX(screen_width) > ( buttonX+button_width)) || (tobj.getScreenY(screen_height) > ((staff_height / 8)*2 + button_height))) || ((tobj.getScreenX(screen_width) < buttonX) || (tobj.getScreenY(screen_height) < (staff_height / 8)*2)))) // Back Button
           {writeMusic();}
       if(!(((tobj.getScreenX(screen_width) > ( buttonX+button_width)) || (tobj.getScreenY(screen_height) > ((staff_height / 8)*3 + button_height))) || ((tobj.getScreenX(screen_width) < buttonX) || (tobj.getScreenY(screen_height) < (staff_height / 8)*3)))) // Tempo Button
           {tempo += 20; if(tempo == 500) {tempo = 20;}}
       if(!(((tobj.getScreenX(screen_width) > ( buttonX+button_width)) || (tobj.getScreenY(screen_height) > ((staff_height / 8)*5 + button_height))) || ((tobj.getScreenX(screen_width) < buttonX) || (tobj.getScreenY(screen_height) < (staff_height / 8)*5)))) // Instrument Button
           {instrument += 1; if (instrument ==128) {instrument = 0;}}
        if(!(((tobj.getScreenX(screen_width) > ( buttonX+button_width)) || (tobj.getScreenY(screen_height) > ((staff_height / 8)*7 + button_height))) || ((tobj.getScreenX(screen_width) < buttonX) || (tobj.getScreenY(screen_height) < (staff_height / 8)*7)))) // Clear button
           {piece.clear();}
         }        
  if(!(((tobj.getScreenX(screen_width) > ( buttonX+button_width)) || (tobj.getScreenY(screen_height) > (buttonY + button_height))) || ((tobj.getScreenX(screen_width) < buttonX) || (tobj.getScreenY(screen_height) < buttonY)))) // Back Button
  {menu = 0; piece.clear(); activity_on = false; note_entered = false; wait = false; iterations = 0; display_wait = true; iterations2 = 0; instrument = Default_instrument; tempo = Default_tempo; note.score.instrument(instrument); note.score.tempo(tempo);}
  if(!(((tobj.getScreenX(screen_width) > ( buttonX+button_width)) || (tobj.getScreenY(screen_height) > (buttonY+ staff_height /8 + button_height))) || ((tobj.getScreenX(screen_width) < buttonX) || (tobj.getScreenY(screen_height) < buttonY + staff_height /8)))) // Play Button
  { if (menu == 1) {Play_notes(instrument, tempo, 0);}
    if (menu == 2) 
    {   note.score.empty();
        note.score.addNote(0.2, start_pitch, Default_note_volume, Default_note_duration);
        note.score.addNote(1.2, second_pitch, Default_note_volume, Default_note_duration);
        note.score.play(0, 55);
    }
  }
  if (menu == 0) {
  if(!(((tobj.getScreenX(screen_width) > ((screen_width/2 - screen_width/16) + (screen_width / 8))) || (tobj.getScreenY(screen_height) > ((screen_height/2 - 60 - screen_height/16) + (screen_height / 8)))) || ((tobj.getScreenX(screen_width) < (screen_width/2 - screen_width/16) || (tobj.getScreenY(screen_height) < (screen_height / 2 - 60 - screen_height/16)))))) // Compose Button
  {menu = 1; return;}
  if(!(((tobj.getScreenX(screen_width) > ((screen_width/2 - screen_width/16) + (screen_width / 8))) || (tobj.getScreenY(screen_height) > ((screen_height/2 + screen_height/8 - 40 - screen_height/16) + (screen_height / 8)))) || ((tobj.getScreenX(screen_width) < (screen_width/2 - screen_width/16) || (tobj.getScreenY(screen_height) < (screen_height / 2 + screen_height/8 - 40 - screen_height/16)))))) // Compose Button
  {menu = 2; return;}
  if(!(((tobj.getScreenX(screen_width) > ((screen_width/2 - screen_width/16) + (screen_width / 8))) || (tobj.getScreenY(screen_height) > ((screen_height/2 + (screen_height/8)*2 - 20 - screen_height/16) + (screen_height / 8)))) || ((tobj.getScreenX(screen_width) < (screen_width/2 - screen_width/16) || (tobj.getScreenY(screen_height) < (screen_height / 2 + (screen_height/8)*2 - 20 - screen_height/16)))))) // Compose Button
  {menu = 3; return;}
  }

  if (menu == 3){
  for (int i = 0; i < txtFiles.length; i++) {
    if(!(((tobj.getScreenX(screen_width) > (screen_width / 2 - screen_width / 8 + screen_width /6)) || (tobj.getScreenY(screen_height) > ((1.3*i*100) + 100 + screen_height / 8))) || ((tobj.getScreenX(screen_width) < screen_width / 2 - screen_width / 8) || (tobj.getScreenY(screen_height) < (1.3*i*100) + 100)))) // Open song
    {menu = 1; readMusic(txtFiles[i]); return;}
    if(!(((tobj.getScreenX(screen_width) > (screen_width / 2 - screen_width / 8 + 270 + 50)) || (tobj.getScreenY(screen_height) > ((1.3*i*100) +120 + 50)) || ((tobj.getScreenX(screen_width) < screen_width / 2 - screen_width / 8 + 270))|| (tobj.getScreenY(screen_height) < (1.3*i*100) +120)))) // Open song
    {menu = 3; String [] m1 = match((txtFiles[i]), "myMusic");
      if(m1!=null) {
        menu = 3; deleteFile((txtFiles[i])); return;} 
      }   
    }
  }
}

// within the method we retrieve a Vector (List) of TuioObject (polling)
// from the TuioProcessing client and then loop over both lists to draw the graphical feedback.
void draw()
{
    Vector tuioObjectList = tuioClient.getTuioObjects();
  if (tuioObjectList.size() != 0) { if (arduino.digitalRead(7) == Arduino.HIGH) {wait = false;}}
   println(wait);
  background(0);
  textFont(font,24);
  
//    if (wait == true)
//  { iterations++;
//    if (iterations == 80)
//    {
//      iterations = 0;
//      wait = false;
//    }
//  }
  
  if (menu == 1)
{
  // draw boxes to represent 12 different notes on a staff
  noFill();
  stroke(100);
  float rect_y = y_increment;
  rotateKnob = loadShape("rotateKnob.svg");
  for (int i = 0; i < 12; i++)
  {
    float rect_height = (float) staff_height / 12;
    rect_y += (float) i * rect_height;
    float note_names_placement = (float) (rect_y + 0.625 * rect_height);
    rect (start_increment, rect_y, staff_width, staff_height / 12);
    text (note_names[i], names_increment, note_names_placement);
    rect_y -= (float) i * rect_height;
  }
    noFill();
    stroke(255);
    rect (buttonX, buttonY, button_width, button_height, 7);
    rect (buttonX, buttonY + staff_height /8, button_width, button_height, 7);
    rect (buttonX, buttonY + (staff_height / 8)*2, button_width, button_height, 7);
    shape (rotateKnob, buttonX, buttonY + (staff_height / 8)*3.5, button_width/2, button_width/2);
    shape (rotateKnob, buttonX, buttonY + (staff_height / 8)*5.5, button_width/2, button_width/2);
    rect (buttonX, buttonY + (staff_height / 8)*7, button_width, button_height, 7);

    fill(255);
    text ("Back", buttonX + button_width * 0.1, buttonY + button_width * 0.2);
    text ("Play", buttonX + button_width * 0.1, buttonY + staff_height /8 + button_width * 0.2);
    text ("Save", buttonX + button_width * 0.1, buttonY + (staff_height / 8)*2 + button_width * 0.2);
    text ("Set Tempo", buttonX + button_width * 0.1, buttonY + (staff_height / 8)*3 + button_width * 0.2);
    text (Integer.toString(tempo), buttonX + button_width * 0.1, buttonY + (staff_height / 8)*4.2 + button_width * 0.2);
    text ("Set Instrument", buttonX + button_width * 0.1, buttonY + (staff_height / 8)*5.0 + button_width * 0.2);
    text (map_Instruments(instrument), buttonX + button_width * 0.1, buttonY + (staff_height / 8)*6.2 + button_width * 0.2);
    text ("Clear", buttonX + button_width * 0.1, buttonY + (staff_height / 8)*7 + button_width * 0.2);
  }
  
  noFill();
  stroke(255);
  draw_notes();
  
  if (menu == 2)
  { 
    noFill();
    stroke(255);
    rect (buttonX, buttonY, button_width, button_height, 7);
    rect (buttonX, buttonY + staff_height /8, button_width, button_height, 7);
    fill(255);
    text ("Back", buttonX + button_width * 0.3, buttonY + button_width * 0.3);
    text ("Play", buttonX + button_width * 0.3, buttonY + staff_height /8 + button_width * 0.3);
    instrument = Default_instrument;
    tempo = Default_tempo;
    if (activity_on == false) {background(255); textFont(font,60); fill(0); text("Guess what the second note is relative to the first one", staff_width /4, staff_height /8, staff_width /2, staff_height/2);}
    if (display_wait == true)
    { iterations2++;
    if (iterations2 == 80)
    {
      iterations2 = 0;
      display_wait = false;
    }
    }
    if(note_entered == true && feedback_wait == true)
    {
      fill(224, 255, 255);
      rect(0, 0.9* screen_height, screen_width, 0.1 * screen_height);
      if(entered_pitch == second_pitch)
        {draw_notes(50, 205, 50); fill(50, 205, 50); text("Correct! You are making amazing progress", screen_width/4, 0.95 * screen_height);}
      else {draw_notes(255, 30, 0); fill(255, 30, 0); text("Try Again! You will get it next time", screen_width/4, 0.95 * screen_height);}
      iterations3++;
      if (iterations3 == 80)
      {
        iterations3 = 0;
        feedback_wait = false;
      } 
     }
    if(display_wait == false)
    {
    // draw boxes to represent 12 different notes on a staff
    noFill();
    stroke(50);
    float rect_y = y_increment;
    for (int i = 0; i < 12; i++)
    {
      float rect_height = (float) staff_height / 12;
      rect_y += (float) i * rect_height;
      float note_names_placement = (float) (rect_y + 0.625 * rect_height);
      rect (start_increment, rect_y, staff_width, staff_height / 12);
      text (note_names[i], names_increment, note_names_placement);
      rect_y -= (float) i * rect_height;
    }
    Learn1();
    }
  }
 
 if(menu == 0)
  {
    logo = loadShape("SoundStampLogo.svg");
    fill(255);
    shape (logo, 0, 0, screen_width, 206);
    noFill();
    stroke(255);
    // danny code from here // 
    rect (screen_width/2-screen_width/16, screen_height / 2 - screen_height / 16 - 60, screen_width / 8, screen_height / 8, 20);
    fill(200);
    text ("Compose", screen_width / 2 - screen_height / 20, screen_height / 2 - 60 );
    noFill();
    stroke(255);
    
    rect (screen_width/2-screen_width/16, screen_height / 2 - screen_height / 16 + (screen_height/8) - 40, screen_width / 8, screen_height / 8, 20);
    text ("Learn", screen_width / 2 - screen_height / 20, screen_height / 2 + (screen_height/8)-40);
    
    rect (screen_width/2-screen_width/16, screen_height / 2 - screen_height / 16 + (screen_height/8)*2 - 20, screen_width / 8, screen_height / 8, 20);
    text ("Library", screen_width / 2 - screen_height / 20, screen_height / 2 + (screen_height/8)*2-20);
    // danny code to here // 
  }
  
 if(menu == 3)
 { 
  findtxt();
  delete = loadShape("delete.svg");
  noFill();
  stroke(255);
  rect (buttonX, buttonY, button_width, button_height, 7);
  fill(255);
  text ("Back", buttonX + button_width * 0.3, buttonY + button_width * 0.3);
  for (int i = 0; i < txtFiles.length; i++) {
  String txtParsed = txtFiles[i].replace(".txt","");
  fill(0);
  stroke(255);
  rect (screen_width / 2 - screen_width / 8, (1.3*i*100) + 100, screen_width / 6, screen_height / 8, 20);
  fill(255);
  stroke(255);
  shape (delete, screen_width / 2 - screen_width / 8 + 270, (1.3*i*100) +120, 50, 50);
  fill(255);
  text (txtParsed, screen_width / 2 - screen_width / 9, (1.3*i*100)+100+screen_height/16);
 }
 }
}

// these callback methods are called whenever a TUIO event occurs

// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
  Buttons(tobj);
  if (menu == 1)
{
  // find current angle and set it to previous_angle
     previous_angle = tobj.getAngle();
       if (checkRegion(tobj) < piece.size() && checkRegion(tobj) != -1) // the user is manipulating an existing element
            { music_element t;
              t = (music_element) piece.get(checkRegion(tobj));
                if (t.pitch_exists (Scan_notes(tobj)) == -1 && t.volume != 0 && wait == false) // if pitch does not exist already and is not a rest
                   { t.add_note(Scan_notes(tobj)); // add new pitch to the element
                     piece.set(checkRegion(tobj), t);
                     note.instrument (instrument);
                     note.playNote(local_note_pitch, local_note_volume, local_note_duration); // Play note for immediate feedback
                     wait = true;
                    }
             } 
        else // the user is adding a new element
         { if (Scan_notes(tobj) != -1 && wait == false && checkRegion(tobj) != -1) 
             { music_element t; 
               t = new music_element(checkRegion(tobj), Scan_notes(tobj), local_note_duration);
               piece.add(t);
               note.instrument (instrument);
               note.playNote(local_note_pitch, local_note_volume, local_note_duration); // Play note for immediate feedback
               wait = true;
             }
         }
}
  if (menu == 2 && piece.size() < 2 && activity_on == true && wait == false && note_entered == false && checkRegion(tobj) != -1 && feedback_wait == false)
  { 
        entered_pitch = Scan_notes(tobj);
        note.score.empty();
        note.score.addNote(0.2, start_pitch, Default_note_volume, Default_note_duration);
        note.score.addNote(1.2, entered_pitch, Default_note_volume, Default_note_duration);
        note.score.play(0, 55);
        music_element t;
        t = new music_element(0, entered_pitch, local_note_duration);
        piece.add(t);
        draw_notes();
        note_entered = true;
        wait = true;
        feedback_wait = true;
  }
}

// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) {
  local_note_pitch = Default_note_pitch;
  local_note_duration = Default_note_duration;
  local_note_volume = Default_note_volume;
  // code should store value in array once removed
}

// called when an object is moved
void updateTuioObject (TuioObject tobj) {
  Buttons(tobj);
  if (menu == 1)
{  if (checkRegion(tobj) < piece.size() && checkRegion(tobj) != -1) // the user is manipulating an existing element
      { music_element t; 
        t = (music_element) piece.get(checkRegion(tobj));
        local_note_duration = t.duration;
        local_note_volume = t.volume;
          if (t.pitch_exists (Scan_notes(tobj)) == -1 && t.volume != 0 && wait == false) // if pitch does not exist already and it is not a rest
             { t.add_note(Scan_notes(tobj)); // add new pitch to the element
               piece.set(checkRegion(tobj), t);
               note.instrument (instrument); 
               note.playNote(local_note_pitch, local_note_volume, local_note_duration); // Play note for immediate feedback
               wait = true;
              }
           else
           { // check if angle has moved, if it has, updated it according to rotation direction
             if (tobj.getAngle() > previous_angle + 0.2 || tobj.getAngle() < previous_angle - 0.2) 
              {   previous_angle = tobj.getAngle();
                  // Increase duration of note
                  if (tobj.getRotationSpeed() > 0 && local_note_duration < 1 && local_note_volume == Default_note_volume) 
                    { local_note_duration = local_note_duration*2;
                      t.modify_duration(local_note_duration); // change duration of the element
                      piece.set(checkRegion(tobj), t);
                      note.instrument (instrument);
                      note.playNote(local_note_pitch, local_note_volume, local_note_duration); // Play note for immediate feedback
                      return;
                    }
                  // Decrease duration of note
                  if (tobj.getRotationSpeed() < 0 && local_note_duration > min_duration && local_note_volume == Default_note_volume)
                    { local_note_duration = (float) local_note_duration / 2;
                      t.modify_duration(local_note_duration); // change duration of the element
                      piece.set(checkRegion(tobj), t);
                      note.instrument (instrument);
                      note.playNote(local_note_pitch, local_note_volume, local_note_duration); // Play note for immediate feedback
                      return;
                    }
                  // Create rest from note
                  if (tobj.getRotationSpeed() < 0 && local_note_duration <= min_duration && local_note_volume == Default_note_volume)
                    {
                      t.create_rest();
                      local_note_volume = 0;
                      local_note_duration = 1;
                      t.modify_duration(local_note_duration);
                      piece.set(checkRegion(tobj), t);
                      return;
                    }
                  // Create note from rest
                  if (tobj.getRotationSpeed() > 0 && local_note_duration == 1 && local_note_volume == 0)
                    {
                      local_note_volume = Default_note_volume;
                      t.modify_volume(local_note_volume);
                      local_note_duration = (float) min_duration;
                      t.modify_duration(local_note_duration);
                      piece.set(checkRegion(tobj), t);
                      return;
                    }
                  // Increase duration of rest
                  if (tobj.getRotationSpeed() > 0 && local_note_duration < 1 && local_note_volume == 0) 
                    { local_note_duration = local_note_duration*2;
                      t.modify_duration(local_note_duration); // change duration of the element
                      piece.set(checkRegion(tobj), t);
                      return;
                    }
                  // Decrease duration of note
                  if (tobj.getRotationSpeed() < 0 && local_note_duration > min_duration && local_note_volume == 0)
                    { local_note_duration = (float) local_note_duration / 2;
                      t.modify_duration(local_note_duration); // change duration of the element
                      piece.set(checkRegion(tobj), t);
                      note.instrument (instrument);
                      note.playNote(local_note_pitch, local_note_volume, local_note_duration); // Play note for immediate feedback
                      return;
                    }
                  // Delete music element all together
                   if (tobj.getRotationSpeed() < 0 && local_note_duration <= min_duration && local_note_volume == 0)
                    { piece.remove(checkRegion(tobj));
                      if (checkRegion(tobj) < piece.size()) // if the musical element was not at the end of the piece
                        {for(int k=checkRegion(tobj); k < piece.size(); k++)
                          { music_element temp = (music_element) piece.get(k);
                            t.decreaseX(); // shift all other elements to the left
                          } 
                        } 
                    }    
              }
           } 
         }
      else // the user is adding a new element
       { if (Scan_notes(tobj) != -1 && wait == false && checkRegion(tobj) != -1) 
           { music_element t; 
             t = new music_element(checkRegion(tobj), Scan_notes(tobj), local_note_duration);
             piece.add(t);
             note.instrument (instrument);
             note.playNote(local_note_pitch, local_note_volume, local_note_duration); // Play note for immediate feedback
             wait = true;
           }
         if(!(((tobj.getScreenX(screen_width) > (buttonX+button_width/2)) || (tobj.getScreenY(screen_height) > (buttonY + (staff_height / 8)*3.5 + button_width/2))) || ((tobj.getScreenX(screen_width) < buttonX) || (tobj.getScreenY(screen_height) < buttonY + (staff_height / 8)*3.5)))) // Set instrument button
         { if (tobj.getAngle() > previous_angle + 0.2 || tobj.getAngle() < previous_angle - 0.2) 
              {   previous_angle = tobj.getAngle();
                  if (tobj.getRotationSpeed() > 0) 
                    { instrument += 1; if (instrument < 127) {instrument = 127;}}
              }
          if (tobj.getAngle() > previous_angle + 0.2 || tobj.getAngle() < previous_angle - 0.2) 
            {   previous_angle = tobj.getAngle();
                if (tobj.getRotationSpeed() < 0) 
                  { instrument -= 1; if (instrument < 0) {instrument = 0;}}
            }
         }       
         
         if(!(((tobj.getScreenX(screen_width) > (buttonX+button_width/2)) || (tobj.getScreenY(screen_height) > (buttonY + (staff_height / 8)*5.5 + button_width/2))) || ((tobj.getScreenX(screen_width) < buttonX) || (tobj.getScreenY(screen_height) < buttonY + (staff_height / 8)*5.5)))) // Set tempo button
         { if (tobj.getAngle() > previous_angle + 0.2 || tobj.getAngle() < previous_angle - 0.2) 
              {   previous_angle = tobj.getAngle();
                  if (tobj.getRotationSpeed() > 0) 
                    {tempo += 20; if (tempo > 500) {tempo = 500;}}
              }
          if (tobj.getAngle() > previous_angle + 0.2 || tobj.getAngle() < previous_angle - 0.2) 
            {   previous_angle = tobj.getAngle();
                if (tobj.getRotationSpeed() < 0) 
                  {tempo -= 20; if (tempo < 20) {tempo = 20;}}
            }
         }
       }      
  }   

  if(menu == 2 && piece.size() < 2 && activity_on == true && wait == false && note_entered == false && checkRegion(tobj) != -1 && feedback_wait == false)
  { 
        entered_pitch = Scan_notes(tobj);
        note.score.empty();
        note.score.addNote(0.2, start_pitch, Default_note_volume, Default_note_duration);
        note.score.addNote(1.2, entered_pitch, Default_note_volume, Default_note_duration);
        note.score.play(0, 55);
        music_element t;
        t = new music_element(0, entered_pitch, local_note_duration);
        piece.add(t);
        draw_notes();
        note_entered = true;
        wait = true;
        feedback_wait = true;
  }
}

int Scan_notes(TuioObject tobj)
{
  if (tobj.getScreenY(screen_height) >= y_increment && tobj.getScreenY(screen_height) <= y_increment + staff_height)  
   { // look for notes on y-axis by dividing it into 12 categories 
      float yregion = (float) staff_height / 12; // size of the equal regions in y coordinates
      float objcor = (float) tobj.getScreenY(screen_height) - y_increment; //yregion;
      float objpartition = (float) objcor / yregion;
      int objregion = floor(objpartition); // index of region where the object is
      local_note_pitch = map_pitches(objregion);
      return local_note_pitch;
   }
    return -1;  
}

void Play_notes(int instrument, int tempo, int repeat)
{ /*
  // play one musical element at a time
   for(int i=0; i < piece.size() ; i++)
  {
    //temp is a temporary variable used to store the musical elements of the piece 
    music_element temp = (music_element) piece.get(i);
     
     if (temp.number_of_notes == 1)
     { note.playNote(temp.getPitch(0), local_note_volume, temp.duration); }
     
     if (temp.number_of_notes > 1)
     { float [] chord = new float [temp.number_of_notes];
       for (int j=0; j < temp.number_of_notes ; j++)
        {chord[j] = (float) temp.getPitch(j);} 
       note.playChord(chord, temp.volume, temp.duration); }
       
       for(double q=0; q < 100000000; q++){}
  } 
  test();  
}  */
   note.score.empty();
   // Set tempo, tempo is 120 by default.
   note.score.tempo (tempo);
   // Set instrument, instrument is 0 (Grand piano) by default.
   note.score.instrument (instrument);
  
  float [] pitches = new float [piece.size()];
  double [] durations = new double [piece.size()];
  double [] volume = new double [piece.size()];
  // play one musical element at a time   
   for(int i=0; i < piece.size() ; i++)
  {
    //temp is a temporary variable used to store the musical elements of the piece 
    music_element temp = (music_element) piece.get(i);
    float [] chord = new float [temp.number_of_notes];
     for (int j=0; j < temp.number_of_notes ; j++)
      {
        chord[j] = temp.getPitch(j);
        durations[i] = temp.duration;
        volume[i] = temp.volume;
      }
    if(temp.number_of_notes == 1){note.score.addNote(i+0.2, chord[0], volume[i], durations[i]);}
        else {note.score.addChord(i+0.2, chord, volume[i], durations[i]);}
      note.score.play(repeat, tempo);
}
}
  
int map_pitches(int i)
{
     if (i == 0) {return 79;}
     if (i == 1) {return 77;}
     if (i == 2) {return 76;}
     if (i == 3) {return 74;}
     if (i == 4) {return 72;}
     if (i == 5) {return 71;}
     if (i == 6) {return 69;}
     if (i == 7) {return 67;}
     if (i == 8) {return 65;}
     if (i == 9) {return 64;}
     if (i == 10) {return 62;}
     if (i == 11) {return 60;}
     return 69;
}

int remap_pitches(int p)
{
     if (p == 79) {return 0;}
     if (p == 77) {return 1;}
     if (p == 76) {return 2;}
     if (p == 74) {return 3;}
     if (p == 72) {return 4;}
     if (p == 71) {return 5;}
     if (p == 69) {return 6;}
     if (p == 67) {return 7;}
     if (p == 65) {return 8;}
     if (p == 64) {return 9;}
     if (p == 62) {return 10;}
     if (p == 60) {return 11;}
     return 6;
}

String map_Instruments(int p)
{
     p-= 1;
     if (p == 128) {return "Gunshot";}
     if (p == 127) {return "Applause";}
     if (p == 126) {return "Helicopter";}
     if (p == 125) {return "Telephone Ring";}
     if (p == 124) {return "Bird Tweet";}
     if (p == 123) {return "Seashore";}
     if (p == 122) {return "Breath Noise";}
     if (p == 121) {return "Guitar Fret Noise";}
     if (p == 120) {return "Reverse Cymbal";}
     if (p == 119) {return "Synth Drum";}
     if (p == 118) {return "Melodic Tom";}
     if (p == 117) {return "Taiko Drum";}
     if (p == 116) {return "Woodblock";}
     if (p == 115) {return "Steel Drums";}
     if (p == 114) {return "Agogo";}
     if (p == 113) {return "Tinkle Bell";}
     if (p == 112) {return "Shanai";}
     if (p == 111) {return "Fiddle";}
     if (p == 110) {return "Bag pipe";}
     if (p == 109) {return "Kalimba";}
     if (p == 108) {return "Koto";}
     if (p == 107) {return "Shamisen";}
     if (p == 106) {return "Banjo";}
     if (p == 105) {return "Sitar";}
     if (p == 104) {return "FX 8 (sci-fi)";}
     if (p == 103) {return "FX 7 (echoes)";}
     if (p == 102) {return "FX 6 (goblins)";}
     if (p == 101) {return "FX 5 (brightness)";}
     if (p == 100) {return "FX 4 (atmosphere)";}
     if (p == 99) {return "FX 3 (crystal)";}
     if (p == 98) {return "FX 2 (soundtrack)";}
     if (p == 97) {return "FX 1 (rain)";}
     if (p == 96) {return "Pad 8 (sweep)";}
     if (p == 95) {return "Pad 7 (halo)";}
     if (p == 94) {return "Pad 6 (metallic)";}
     if (p == 93) {return "Pad 5 (bowed)";}
     if (p == 92) {return "Pad 4 (choir)";}
     if (p == 91) {return "Pad 3 (polysynth)";}
     if (p == 90) {return "Pad 2 (warm)";}
     if (p == 89) {return "Pad 1 (new age)";}
     if (p == 88) {return "Lead 8 (fifths)";}
     if (p == 87) {return "Lead 7 (fifths)";}
     if (p == 86) {return "Lead 6 (voice)";}
     if (p == 85) {return "Lead 5 (charang)";}
     if (p == 84) {return "Lead 4 (chiff)";}
     if (p == 83) {return "Lead 3 (callipoe)";}
     if (p == 82) {return "Lead 2 (sawtooth)";}
     if (p == 81) {return "Lead 1 (square)";}
     if (p == 80) {return "Ocarina";}
     if (p == 79) {return "Whistle";}
     if (p == 78) {return "Shakuhachi";}
     if (p == 77) {return "Blown Bottle";}
     if (p == 76) {return "Pan Flute";}
     if (p == 75) {return "Recorder";}
     if (p == 74) {return "Flute";}
     if (p == 73) {return "Piccolo";}
     if (p == 72) {return "Clarinet";}
     if (p == 71) {return "Bassoon";}
     if (p == 70) {return "English Horn";}
     if (p == 69) {return "Oboe";}
     if (p == 68) {return "Baritone Sax";}
     if (p == 67) {return "Tenor Sax";}
     if (p == 66) {return "Alto Sax";}
     if (p == 65) {return "SopranoSax";}
     if (p == 64) {return "SynthBrass 2"; }
     if (p == 63) {return "SynthBrass 1";}
     if (p == 62) {return "Brass Section";}
     if (p == 61) {return "French Horn";}
     if (p == 60) {return "Muted Trumpet";}
     if (p == 59) {return "Tuba";}
     if (p == 58) {return "Trombone";}
     if (p == 57) {return "Trumpet";}
     if (p == 56) {return "Orchestra Hit";}
     if (p == 55) {return "Synth Voice";}
     if (p == 54) {return "Voice Oohs";}
     if (p == 53) {return "Choir Aahs";}
     if (p == 52) {return "SynthStrings 2";}
     if (p == 51) {return "SynthStrings 1";}
     if (p == 50) {return "String Ensemble 2";}
     if (p == 1) {return "Acoustic Grand Piano";}
     if (p == 2) {return "Bright Acoustic Piano";}
     if (p == 3) {return "Electric Grand Piano";}
     if (p == 4) {return "Honky-tonk Piano";}
     if (p == 5) {return "Electric Piano 1";}
     if (p == 6) {return "Electric Piano 2";}
     if (p == 7) {return "Harpsichord";}
     if (p == 8) {return "Clavi";}
     if (p == 9) {return "Celesta";}
     if (p == 10) {return "Glockenspiel";}
     if (p == 11) {return "Music Box";}
     if (p == 12) {return "Vibraphone";}
     if (p == 13) {return "Marimba";}
     if (p == 14) {return "Xylophone";}
     if (p == 15) {return "Tubular Bells";}
     if (p == 16) {return "Dulcimer";}
     if (p == 17) {return "Drawbar Organ";}
     if (p == 18) {return "Percussive Organ";}
     if (p == 19) {return "Rock Organ";}
     if (p == 20) {return "Church Organ";}
     if (p == 21) {return "Reed Organ";}
     if (p == 22) {return "Accordion";}
     if (p == 23) {return "Harmonica";}
     if (p == 24) {return "Tango Accordion";}
     if (p == 25) {return "Acoustic Guitar (nylon)";}
     if (p == 26) {return "Acoustic Guitar (steel)";}
     if (p == 27) {return "Electric Guitar (jazz)";}
     if (p == 28) {return "Electric Guitar (clean)";}
     if (p == 29) {return "Electric Guitar (muted)";}
     if (p == 30) {return "Overdriven Guitar";}
     if (p == 31) {return "Distortion Guitar";}
     if (p == 32) {return "Guitar Harmonics";}
     if (p == 33) {return "Acoustic Bass";}
     if (p == 34) {return "Electric Bass (finger)";}
     if (p == 35) {return "Electric Bass (pick)";}
     if (p == 36) {return "Frestless Bass";}
     if (p == 37) {return "Slap Bass 1";}
     if (p == 38) {return "Slap Bass 2";}
     if (p == 39) {return "Synth Bass 1";}
     if (p == 40) {return "Synth Bass 2";}
     if (p == 41) {return "Violin";}
     if (p == 42) {return "Viola";}
     if (p == 43) {return "Cello";}
     if (p == 44) {return "Contrabass";}
     if (p == 45) {return "Tremolo Strings";}
     if (p == 46) {return "Pizzicato Strings";}
     if (p == 47) {return "Orchestral Harp";}
     if (p == 48) {return "Timpani";}
     if (p == 49) {return "String Ensemble 1";}
     return "Acoustic Grand Piano";
}

int checkRegion(TuioObject tobj)
{
// check in which region of the screen the object is in 
  if(tobj.getScreenX(screen_width) >= start_increment && tobj.getScreenX(screen_width) <= start_increment + staff_width)
  {
    int partitions = piece.size() + 1; // screen is divided by number of music elements in the piece plus an empty region to add an additional element
    println(partitions);
    float xregion = (float) staff_width / partitions; // size of the equal regions in x coordinates
    float objcor = (float) tobj.getScreenX(screen_width) - start_increment;
    float objpartition = (float) objcor / xregion;
    int objregion = floor(objpartition); // index of region where the object is
    println("At "+ tobj.getScreenX(screen_width) + " and Region is " + objregion);
    return objregion;
  }
  else { return -1;}
}

// Drawing Functions 
void draw_notes()
{draw_notes(255, 255, 255);}
void draw_notes(int R, int G, int B)
{
  soundNote = loadShape("soundNote.svg");
  restNote = loadShape("restNote.svg");
  noStroke();
  //width
  float partitions_width = staff_width / (piece.size() + 1);
  float note_width = (float) partitions_width / 2;
  float x_increment = (float) note_width / 2;
  x_increment = x_increment + start_increment; 
  
  //height
  float partitions_height = staff_height / 12; // Staff can accomodate 12 notes only 
  float note_height = (float) partitions_height / 2;
  float y_increment = (float) note_height / 2;
  
  for (int i=0; i < piece.size(); i++)
  {
    float pos0 = invregress(i, start_increment, start_increment + staff_width, 0, 1);
    float pos1 = invregress(i+1, start_increment, start_increment + staff_width, 0, 1);
    float center = (pos0 + pos1) / 2;
    //temp is a temporary variable used to store the musical elements of the piece 
    music_element temp = (music_element) piece.get(i);
    float x_start = partitions_width * i + x_increment;
    for (int j=0; j < temp.number_of_notes; j++)
    {
      fill(R, G, B);
      note_width = (float) partitions_width * temp.duration / 2;
      note_height = (float) partitions_height * temp.duration / 2;
      float y_start = partitions_height * remap_pitches(temp.getPitch(j)) + y_increment;
      if (temp.volume == 0)
        {shape(restNote,x_start, y_start, note_width, note_height);}
      else {shape(soundNote,x_start, y_start, note_width, note_height);}
    } 
  }
    // default TUIO code for displaying fiducial markers on the screen
  Vector tuioObjectList = tuioClient.getTuioObjects();
  for (int i=0;i<tuioObjectList.size();i++) {
    TuioObject tobj = (TuioObject)tuioObjectList.elementAt(i);
     stroke(0);
     pushMatrix();
   //  translate(tobj.getScreenX(height),tobj.getScreenY(height));
   //  rotate(tobj.getAngle());
     int visible_width = floor(screen_width * 0.8);
     ellipse(tobj.getScreenX(visible_width),tobj.getScreenY(screen_height),note_width, note_height);
     popMatrix();
   //  text(""+tobj.getSymbolID(), tobj.getScreenX(visible_width), tobj.getScreenY(screen_height));
   }
}

float regress (float xin, float inmin, float inmax, float outmin, float outmax)
 { 
   return ((xin - inmin) * ((outmax - outmin) / (inmax - inmin)) + outmin) ;}
   
float invregress (float yin, float inmin, float inmax, float outmin, float outmax)
 { 
   return ((yin - outmin) * ((inmax - inmin) / (outmax - outmin)) + inmin) ;}
   
   
// Learning Activities
void Learn1()
{  
  if (activity_on == false)
  { //  for (int i = 0; i < 70; i ++) {noLoop(); }
      Random generator = new Random();
      start_pitch = map_pitches(generator.nextInt(12));
      music_element t; 
      t = new music_element(0, start_pitch, local_note_duration);
      piece.add(t);
      draw_notes();
      second_pitch = map_pitches(generator.nextInt(12));
      activity_on = true;
      note.score.empty();
      note.score.addNote(0.2, start_pitch, Default_note_volume, Default_note_duration);
      note.score.addNote(1.2, second_pitch, Default_note_volume, Default_note_duration);
      note.score.play(0, 55);
  }
  if (note_entered == true)
  {
    if  (entered_pitch == second_pitch && feedback_wait == false)
       { background(255);
         stroke(0);
         piece.clear();
         activity_on = false;
         note_entered = false;
       }
    if  (entered_pitch != second_pitch && feedback_wait == false)
       {
         piece.remove(1);
         note_entered = false;  
       } 
  }
}

// Cursor procedures

// called when a cursor is added to the scene
void addTuioCursor(TuioCursor tcur) {
  println("add cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY());
}

// called when a cursor is moved
void updateTuioCursor (TuioCursor tcur) {
  println("update cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+ ") " +tcur.getX()+" "+tcur.getY()
          +" "+tcur.getMotionSpeed()+" "+tcur.getMotionAccel());
}

// called when a cursor is removed from the scene
void removeTuioCursor(TuioCursor tcur) {
  println("remove cursor "+tcur.getCursorID()+" ("+tcur.getSessionID()+")");
}

// called after each message bundle
// representing the end of an image frame
void refresh(TuioTime bundleTime) { 
  redraw();
}

// Quicksort Sorting Algorithm
int partition(int arr[], int left, int right) 
{ int i = left, j = right; 
  int tmp; 
  int pivot = arr[(left + right) / 2]; 
  while (i <= j) { 
    while (arr[i] < pivot) 
       i++; 
       while (arr[j] > pivot) 
          j--; 
          if (i <= j) { 
            tmp = arr[i]; 
            arr[i] = arr[j]; 
            arr[j] = tmp; 
            i++; 
            j--; 
            } 
      }; 
      return i; 
} 
 
void quickSort(int arr[], int left, int right) { 
  int index = partition(arr, left, right); 
  if (left < index - 1) 
    quickSort(arr, left, index - 1); 
    if (index < right) 
      quickSort(arr, index, right); 
}

/*void test()
{
  for (int i=0; i < piece.size(); i++)
  {
    music_element temp = (music_element) piece.get(i);
    for (int j=0; j < temp.number_of_notes; j++)
    { println("Add at " + i + " " + temp.getPitch(j) + " "); }
    println ("\n");
  }
}*/

//for importing txt files into a 2d array
void readMusic(String filename) 
  {
  String lines[] = loadStrings(filename);
  float [][] txt;
  int txtWidth=0;
  
  //calculate max width of txt file
  for (int i=0; i < lines.length; i++) {
    String [] chars=split(lines[i],',');
    if (chars.length>txtWidth){
      txtWidth=chars.length;
    }
  }
  
  //create txt array based on # of rows and columns in txt file
  txt = new float [lines.length][txtWidth];
  
  //parse values into 2d array
  for (int i=0; i < lines.length; i++) {
    String [] temp = new String [lines.length];
    temp= split(lines[i], ',');
    for (int j=0; j < temp.length; j++){
     txt[i][j] = new Float(temp[j]); // parse these values to float 
    }
  }
  
  for (int i = 0; i < txt.length; i++) 
  {
    music_element t = new music_element();  
    t.modify_duration(txt[i][1]);
    if (txt[i][0]==0) { //create rest if first value in row is equal to zero
        t.create_rest();
      }
    else 
      { 
       for (int j = 3; j < txt[i][2]+3; j++) { t.add_note(int(txt[i][j]));}
      }
    piece.add(t);
  } 
}
// finds our txt files to play them back
void findtxt() 
{
java.io.File folder = new java.io.File(dataPath(""));
 
// let's set a filter (which returns true if file's extension is .jpg)
java.io.FilenameFilter txtFilter = new java.io.FilenameFilter() {
  public boolean accept(File dir, String name) {
    return name.toLowerCase().endsWith(".txt");
  }
};
 
// list the files in the data folder, passing the filter as parameter
txtFiles = folder.list(txtFilter);
}

void writeMusic() {
  Data data=new Data();
  // SAVING
  data.beginSave();
 for (int i = 0; i < piece.size(); i++) {
    music_element t = (music_element) piece.get(i);
    String v = "";
    if (t.volume != 0) {v = "1";} else {v = "0";}
    float d = t.duration;
    String temp = Float.toString(d);
    String musicEntry = v + "," + temp;
    if (t.volume != 0)
    {
      musicEntry += "," + t.number_of_notes;
    { for (int j =0 ; j < t.number_of_notes; j++)
      musicEntry += "," + Integer.toString(t.getPitch(j)); }
    }
    data.add(musicEntry);
  }
  data.endSave(
    data.getIncrementalFilename(
      sketchPath("data"+
        java.io.File.separator+
        "myMusic ##.txt")));
}

// DATA CLASS

class Data {
  ArrayList datalist;
  String filename,data[];
  int datalineId;
 
  // begin data saving
  void beginSave() {
    datalist=new ArrayList();
  }
 
  void add(String s) {
    datalist.add(s);
  }
 
  void add(float val) {
    datalist.add(""+val);
  }
 
  void add(int val) {
    datalist.add(""+val);
  }
 
  void add(boolean val) {
    datalist.add(""+val);
  }
 
  void endSave(String _filename) {
    filename=_filename;
 
    data=new String[datalist.size()];
    data=(String [])datalist.toArray(data);
 
    saveStrings(filename, data);
    println("Saved data to '"+filename+
      "', "+data.length+" lines.");
  }
 
  void load(String _filename) {
    filename=_filename;
 
    datalineId=0;
    data=loadStrings(filename);
    println("Loaded data from '"+filename+
      "', "+data.length+" lines.");
  }
 
  float readFloat() {
    return float(data[datalineId++]);
  }
 
  int readInt() {
    return int(data[datalineId++]);
  }
 
  boolean readBoolean() {
    return boolean(data[datalineId++]);
  }
 
  String readString() {
    return data[datalineId++];
  }
 
  // Utility function to auto-increment filenames
  // based on filename templates like "name-###.txt" 
 
  public String getIncrementalFilename(String templ) {
    String s="",prefix,suffix,padstr,numstr;
    int index=0,first,last,count;
    File f;
    boolean ok;
 
    first=templ.indexOf('#');
    last=templ.lastIndexOf('#');
    count=last-first+1;
 
    if( (first!=-1)&& (last-first>0)) {
      prefix=templ.substring(0, first);
      suffix=templ.substring(last+1);
 
      // Comment out if you want to use absolute paths
      // or if you're not using this inside PApplet
      if(sketchPath!=null) prefix=savePath(prefix);
 
      index=0;
      ok=false;
 
      do {
        padstr="";
        numstr=""+index;
        for(int i=0; i< count-numstr.length(); i++) padstr+="0";
        s=prefix+padstr+numstr+suffix;
 
        f=new File(s);
        ok=!f.exists();
        index++;
 
        // Provide a panic button. If index > 10000 chances are it's an
        // invalid filename.
        if(index>10000) ok=true;
 
      }
      while(!ok);
 
      // Panic button - comment out if you know what you're doing
      if(index> 10000) {
        println("getIncrementalFilename thinks there is a problem - "+
          "Is there  more than 10000 files already in the sequence "+
          " or is the filename invalid?");
        println("Returning "+prefix+"ERR"+suffix);
        return prefix+"ERR"+suffix;
      }
    }
 
    return s;
  }
 
}

void deleteFile(String filename) {
  String txtFile = dataPath(filename);
  File file = sketchFile(txtFile);
  System.gc();
  println(file);
  boolean success = file.delete();
}
