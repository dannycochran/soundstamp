  /*
    StampCifer is an open source project created at Stanford University.
    
    We utilize the TUIO processing demo - part of the reacTIVision project
    http://reactivision.sourceforge.net/, as well as the SoundCipher library.
*/

// import Java ArrayList for handling of music elements class
import java.util.*;
import java.util.ArrayList;
import java.util.List;

// import the TUIO library and declare a TuioProcessing client variable
import TUIO.*;
TuioProcessing tuioClient;

// simple audio library "SoundCipher"  (tempo=120 bpm)
import arb.soundcipher.*;

// these are some helper variables which are used to create scalable graphical feedback
PFont font;
int screen_width = 1500;
int screen_height = 700;
float width_scaling = (float) screen_width / 640;
float staff_width = (float) 480 * width_scaling;
float staff_height = screen_height;
float start_increment = (float) 20 * width_scaling;
float names_increment = (float) 5 * width_scaling;

// we use this to dynamically change note duration based on angle delta
float previous_angle = 0;

// size of hardware screen devoted to staff music
float xwidth = 1;
float ywidth = 1;

// default values for duration, pitch, and volume
float Default_note_duration = 1;
int Default_note_pitch = 60;
int Default_note_volume = 500;

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
int instrument = 0;
int tempo = 160;

// List of the notes names
String [] note_names;

// button for playing music
float buttonX = (float) 510 * width_scaling; 
float buttonY = (float) staff_height / 4 / 12;
float button_width = (float) 30 * width_scaling;
float button_height = (float) staff_height / 2 / 12;

// used to limit the amount of notes added
boolean wait = false;
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

//list of CSV files
String [] csvFiles;

//shapes
PShape s;

void setup()
{   
  // size(screen.height,screen.height);
  size(screen_width,screen_height);
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
}

// check to see if a button has been pressed
void mousePressed() {
  if(!(((mouseX > ( buttonX+button_width)) || (mouseY > (buttonY + button_height))) || ((mouseX < buttonX) || (mouseY < buttonY)))) // Back Button
  {menu = 0; piece.clear(); activity_on = false; note_entered = false; wait = false; iterations = 0; }
  if(!(((mouseX > ( buttonX+button_width)) || (mouseY > (buttonY+ staff_height /8 + button_height))) || ((mouseX < buttonX) || (mouseY < buttonY + staff_height /8)))) // Play Button
  { if (menu == 1) {Play_notes(instrument, tempo, 0);}
    if (menu == 2) 
    {   note.score.empty();
        note.score.addNote(0.2, start_pitch, Default_note_volume, Default_note_duration);
        note.score.addNote(1.2, second_pitch, Default_note_volume, Default_note_duration);
        note.score.play(0, 55);
    }
  }
  if (menu == 1) {
      println("Hello world");
  }
  if (menu == 0) {
  if(!(((mouseX > (screen_width / 2 - screen_width / 8 + screen_width / 8)) || (mouseY > (screen_height / 2 - screen_height / 8 + screen_height / 8))) || ((mouseX < screen_width / 2 - screen_width / 8) || (mouseY < screen_height / 2 - screen_height / 8)))) // Compose Button
  {menu = 1; return;}
  if(!(((mouseX > (screen_width / 2 - screen_width / 13 + screen_width / 8)) || (mouseY > (screen_height / 2 + screen_height / 32 + screen_height / 8))) || ((mouseX < screen_width / 2 - screen_width / 8) || (mouseY < screen_height / 2 + screen_height / 32)))) // Learn Button
  {menu = 2; return;}
  if(!(((mouseX > (screen_width / 2 - screen_width / 8 + screen_width / 8)) || (mouseY > (screen_height / 2 + screen_height / 8 + screen_height / 16 + screen_height / 8))) || ((mouseX < screen_width / 2 - screen_width / 8) || (mouseY < screen_height / 8)))) // Library Button
  {menu = 3; return;}
  }
  
  if (menu == 3){
  for (int i = 0; i < csvFiles.length; i++) {
    if(!(((mouseX > (screen_width / 2 - screen_width / 8 + screen_width / 8)) || (mouseY > ((i*100)+100 + screen_height / 8))) || ((mouseX < screen_width / 2 - screen_width / 8) || (mouseY < (i*100)+100)))) // Open song
    {menu = 1; readMusic(csvFiles[i]); return;}
  }
  }
}


// check to see if a button has been pressed
void Buttons(TuioObject tobj) {/*
  if(!(((tobj.getScreenX(screen_width) > ( buttonX+button_width)) || (tobj.getScreenY(screen_height) > (buttonY + button_height))) || ((tobj.getScreenX(screen_width) < buttonX) || (tobj.getScreenY(screen_height) < buttonY)))) // Back Button
  {menu = 0; piece.clear(); activity_on = false; note_entered = false; wait = false; iterations = 0; }
  if(!(((tobj.getScreenX(screen_width) > ( buttonX+button_width)) || (tobj.getScreenY(screen_height) > (buttonY+ staff_height /8 + button_height))) || ((tobj.getScreenX(screen_width) < buttonX) || (tobj.getScreenY(screen_height) < buttonY + staff_height /8)))) // Play Button
  { if (menu == 1) {Play_notes(instrument, tempo, 0); return;}
    if (menu == 2) {music_element t = new music_element(1,second_pitch,local_note_duration); piece.add(t); Play_notes(instrument, tempo, 0); piece.remove(1);}
  }
  if(!(((tobj.getScreenX(screen_width) > (screen_width / 2 - screen_width / 8 + screen_width / 8)) || (tobj.getScreenY(screen_height) > (screen_height / 2 - screen_height / 8 + screen_height / 8))) || ((tobj.getScreenX(screen_width) < screen_width / 2 - screen_width / 8) || (tobj.getScreenY(screen_height) < screen_height / 2 - screen_height / 8)))) // Compose Button
  {menu = 1; println (menu); return;}
  if(!(((tobj.getScreenX(screen_width) > (screen_width / 2 - screen_width / 13 + screen_width / 8)) || (tobj.getScreenY(screen_height) > (screen_height / 2 + screen_height / 32 + screen_height / 8))) || ((tobj.getScreenX(screen_width) < screen_width / 2 - screen_width / 8) || (tobj.getScreenY(screen_height) < screen_height / 2 + screen_height / 32)))) // Learn Button
  {menu = 2; return;}
  if(!(((tobj.getScreenX(screen_width) > (screen_width / 2 - screen_width / 8 + screen_width / 8)) || (tobj.getScreenY(screen_height) > (screen_height / 2 + screen_height / 8 + screen_height / 16 + screen_height / 8))) || ((tobj.getScreenX(screen_width) < screen_width / 2 - screen_width / 8) || (tobj.getScreenY(screen_height) < screen_height / 8)))) // Library Button
  {menu = 3; return;}*/
}

// within the method we retrieve a Vector (List) of TuioObject (polling)
// from the TuioProcessing client and then loop over both lists to draw the graphical feedback.
void draw()
{
  background(0);
  textFont(font,24);
  
    if (wait == true)
  { iterations++;
    if (iterations == 80)
    {
      iterations = 0;
      wait = false;
    }
  }
  
  if (menu == 1 || menu == 2)
{
  // draw boxes to represent 12 different notes on a staff
  noFill();
  stroke(50);
  for (int i = 0; i < 12; i++)
  {
    float rect_height = (float) staff_height / 12;
    float rect_y = (float) i * rect_height;
    float note_names_placement = (float) (rect_y + 0.625 * rect_height);
    rect (start_increment, rect_y, staff_width, staff_height / 12);
    text (note_names[i], names_increment, note_names_placement);
  }
  if (menu == 1)
  { 
    noFill();
    stroke(255);
    rect (buttonX, buttonY, button_width, button_height, 7);
    rect (buttonX, buttonY + staff_height /8, button_width, button_height, 7);
    rect (buttonX, buttonY + (staff_height / 8)*2, button_width, button_height, 7);
    rect (buttonX, buttonY + (staff_height / 8)*3, button_width, button_height, 7);
    rect (buttonX, buttonY + (staff_height / 8)*4, button_width, button_height, 7);
    rect (buttonX, buttonY + (staff_height / 8)*5, button_width, button_height, 7);

    fill(255);
    text ("Back", buttonX + button_width * 0.3, buttonY + button_width * 0.3);
    text ("Play", buttonX + button_width * 0.3, buttonY + staff_height /8 + button_width * 0.3);
    text ("Save", buttonX + button_width * 0.3, buttonY + (staff_height / 8)*2 + button_width * 0.3);
    text ("Set Tempo", buttonX + button_width * 0.3, buttonY + (staff_height / 8)*3 + button_width * 0.3);
    text ("Set Instrument", buttonX + button_width * 0.3, buttonY + (staff_height / 8)*4 + button_width * 0.3);
    text ("Clear", buttonX + button_width * 0.3, buttonY + (staff_height / 8)*5 + button_width * 0.3);
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
    Learn1();
  }

 }
 
 if(menu == 0)
  {
    noFill();
    stroke(255);

    rect (screen_width / 2 - screen_width / 8, screen_height / 2 - screen_height / 8, screen_width / 8, screen_height / 8, 20);
    text ("Compose", screen_width / 2 - screen_width / 12, screen_height / 2 - screen_height / 18);
   
    rect (screen_width / 2 - screen_width / 8, screen_height / 2 + screen_height / 32, screen_width / 8, screen_height / 8, 20);
    text ("Learn", screen_width / 2 - screen_width / 13, screen_height / 2 + screen_width / 30 + screen_height / 32);
    
    rect (screen_width / 2 - screen_width / 8, screen_height / 2 + screen_height / 8 + screen_height / 16, screen_width / 8, screen_height / 8, 20);
    text ("Library", screen_width / 2 - screen_width / 8 + screen_width / 23, screen_height / 2 + screen_height / 8 + screen_height / 16 + screen_height / 15);
  }
  
 if(menu == 3)
 { 
  findCSV();
  s = loadShape("delete.svg");
   noFill();
   stroke(255);
   rect (buttonX, buttonY, button_width, button_height, 7);
   fill(255);
   text ("Back", buttonX + button_width * 0.3, buttonY + button_width * 0.3);
   for (int i = 0; i < csvFiles.length; i++) {
    String csvParsed = csvFiles[i].replace(".csv","");
    fill(0);
    stroke(255);
    rect (screen_width / 2 - screen_width / 8, (i*100)+100, screen_width / 8, screen_height / 8, 20);
    fill(255);
    stroke(255);
    shape (s, screen_width / 2 - screen_width / 8 + 200, (i*100)+110, 50, 50);
    fill(255);
    text (csvParsed, screen_width / 2 - screen_width / 12, (i*100)+100+screen_height/16);
   }
//  call a csv to be played
//  readMusic("odetojoy.csv");
//  csvFiles;

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
       if (checkRegion(tobj) < piece.size()) // the user is manipulating an existing element
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
         { if (Scan_notes(tobj) != -1 && wait == false) 
             { music_element t; 
               t = new music_element(checkRegion(tobj), Scan_notes(tobj), local_note_duration);
               piece.add(t);
               note.instrument (instrument);
               note.playNote(local_note_pitch, local_note_volume, local_note_duration); // Play note for immediate feedback
               wait = true;
             }
         }
}
  if (menu == 2 && piece.size() < 2 && activity_on == true && wait == false && note_entered == false)
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
{  if (checkRegion(tobj) < piece.size()) // the user is manipulating an existing element
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
       { if (Scan_notes(tobj) != -1 && wait == false) 
           { music_element t; 
             t = new music_element(checkRegion(tobj), Scan_notes(tobj), local_note_duration);
             piece.add(t);
             note.instrument (instrument);
             note.playNote(local_note_pitch, local_note_volume, local_note_duration); // Play note for immediate feedback
             wait = true;
           }
       }
  }

  if (menu == 2 && piece.size() < 2 && activity_on == true && wait == false && note_entered == false)
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
  }
}

int Scan_notes(TuioObject tobj)
{
    // look for notes on y-axis by dividing it into 12 categories 
   for(int i=0; i < 12 ; i++)
    {
      if (tobj.getY() >= (i) * ywidth / 12 && tobj.getY() < (i+1) * ywidth / 12)
      {
         local_note_pitch = map_pitches(i);
         return local_note_pitch;
      }
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

int checkRegion(TuioObject tobj)
{
// check in which region of the screen the object is in 
  int partitions = piece.size() + 1; // screen is divided by number of music elements in the piece plus an empty region to add an additional element
  float xregion = (float) staff_width / screen_width / partitions; // size of the equal regions in x coordinates
  float objcor = (float) regress(tobj.getX(), 0.1, 0.9, 0, 1) / xregion;
  int objregion = floor(objcor); // index of region where the object is
  if (objregion >= partitions) {objregion = piece.size();} //making sure the object is within bounds
  if (objregion < 0) {objregion = 0;} //making sure the object is within bounds
  return objregion;
}

// Drawing Functions
void draw_notes()
{
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
    //temp is a temporary variable used to store the musical elements of the piece 
    music_element temp = (music_element) piece.get(i);
    float x_start = partitions_width * i + x_increment;
    for (int j=0; j < temp.number_of_notes; j++)
    {
      fill(255);
      note_width = (float) partitions_width * temp.duration / 2;
      note_height = (float) partitions_height * temp.duration / 2;
      float y_start = partitions_height * remap_pitches(temp.getPitch(j)) + y_increment;
      if (temp.volume == 0)
        {rect(x_start, y_start, note_width, note_height);}
      else {ellipse(x_start, y_start, note_width, note_height);}
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
    if  (entered_pitch == second_pitch)
       { background(255);
         stroke(0);
         text("You are correct!", screen_width/2 - 100, screen_height / 2 + 50);
         delay(5000);  
       //for (int i = 0; i < 50000000; i ++) { }
         piece.clear();
         activity_on = false;
         note_entered = false;
       }
      else
       {
      //   for (int i = 0; i < 200; i ++) {noLoop(); }
         rect(screen_width/2 - 100, screen_height / 2 + 50, 100, 50);
         text("You are incorrect!", screen_width/2 - 100, screen_height / 2 + 50);
         for (int i = 0; i < 50000; i ++) { }
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

//for importing csv files into a 2d array
void readMusic(String filename) 
  {
  String lines[] = loadStrings(filename);
  float [][] csv;
  int csvWidth=0;
  
  //calculate max width of csv file
  for (int i=0; i < lines.length; i++) {
    String [] chars=split(lines[i],',');
    if (chars.length>csvWidth){
      csvWidth=chars.length;
    }
  }
  
  //create csv array based on # of rows and columns in csv file
  csv = new float [lines.length][csvWidth];
  
  //parse values into 2d array
  for (int i=0; i < lines.length; i++) {
    String [] temp = new String [lines.length];
    temp= split(lines[i], ',');
    for (int j=0; j < temp.length; j++){
     csv[i][j] = new Float(temp[j]); // parse these values to float 
    }
  }
  
  //test
  
  println(csv.length);
  println(csv[0].length);
  
  for (int i = 0; i < csv.length; i++) {
    music_element t = new music_element();  
    t.modify_duration(csv[i][1]);
    if (csv[i][0]==0) { //create rest if first value in row is equal to zero
        t.create_rest();  
      }
      else { println(csv[i][2]+3);
       for (int j = 3; j < csv[i][2]+3; j++) { 
         t.add_note(int(csv[i][j]));
         println("Runned " + i + " "+ j);
         piece.add(t);
      }
    }
  } 
}
// finds our CSV files to play them back
void findCSV() 
{
java.io.File folder = new java.io.File(dataPath(""));
 
// let's set a filter (which returns true if file's extension is .jpg)
java.io.FilenameFilter csvFilter = new java.io.FilenameFilter() {
  public boolean accept(File dir, String name) {
    return name.toLowerCase().endsWith(".csv");
  }
};
 
// list the files in the data folder, passing the filter as parameter
csvFiles = folder.list(csvFilter);
 
// get and display the number of jpg files
//println(filenames.length + " csv files in specified directory");
 
// display the filenames
//for (int i = 0; i < filenames.length; i++) {
//  println(filenames[i]);
}
