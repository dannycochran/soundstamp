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
float cursor_size = 15;
float object_size = 60;
float table_size = 760;
float scale_factor = 1;
PFont font;

// we use this to dynamically change note duration based on angle delta
float previous_angle = 0;

// size of hardware screen devoted to staff music
float xlength = 1;
float ylength = 1;

// global value for note volume.
int note_volume = 500;

// default values for duration & pitch
float Default_note_duration = 1;
int Default_note_pitch = 60;

// duration can only drop to a 16th note (0.0625)
double min_duration = (double) 1 / 16; 

// our fiduciary object ID
int object_id = 77; 

// this is where we store our user's array of sounds
ArrayList piece = new ArrayList();

// this creates a user's music note
SoundCipher note;

// variables to store temporarly the components of the musical element before commiting the element and saving it
int local_note_count = 0;
int local_note_pitch = Default_note_pitch;
float local_note_duration = Default_note_duration;

// button for playing music
int checkClick = -1;
int buttonX=570; 
int buttonY=20;
int buttonSize = 30;

void setup()
{  
  // size(screen.width,screen.height);
  size(640,480);
  noStroke();
  fill(0);
  
  // set to loop and identify frameRate 
  loop();
  frameRate(30);
  // noLoop();
  
  // set font size 
  hint(ENABLE_NATIVE_FONTS);
  font = createFont("Arial", 18);
  scale_factor = height/table_size;
  
  // we create an instance of the TuioProcessing client
  // since we add "this" class as an argument the TuioProcessing class expects
  // an implementation of the TUIO callback methods (see below)
  tuioClient  = new TuioProcessing(this);
 
  note = new SoundCipher(this);   // sound object for audio feedback
//  note.playNote(60, 500, 1/4); // pitch number, volume, duration in beats

// tempo is 120 by default, but we can set it using this:
//  double new_tempo = 120;
//  note.tempo (new_tempo);

// instrument is 0 (Grand piano) by default, but we can set it using this:
//  double new_instrument = 0;
//  note.instrument (new_instrument);

}

// check to see if button has been pressed, Play_notes() if it has.
void mousePressed() {
  if(!(((mouseX > ( buttonX+buttonSize)) || (mouseY > (buttonY+buttonSize))) || ((mouseX < buttonX) || (mouseY < buttonY)))) {
    checkClick = checkClick*-1;
    println(checkClick);
    Play_notes();
  }
}

// within the draw method we retrieve a Vector (List) of TuioObject (polling)
// from the TuioProcessing client and then loop over both lists to draw the graphical feedback.
void draw()
{
  background(255);
  textFont(font,18*scale_factor);
  float obj_size = object_size*scale_factor; 
  float cur_size = cursor_size*scale_factor; 
  // draw boxes to represent 12 different notes on a staff
  noFill();
  rect (20,0,500,40);
  text ("G",5,25);
  rect (20,40,500,40);
  text ("F",5,65);
  rect (20,80,500,40);
  text ("E",5,105);
  rect (20,120,500,40);
  text ("D",5,145);
  rect (20,160,500,40);
  text ("C",5,185);
  rect (20,200,500,40);
  text ("B",5,225);
  rect (20,240,500,40);
  text ("A",5,265);
  rect (20,280,500,40);
  text ("G",5,305);
  rect (20,320,500,40);
  text ("F",5,345);
  rect (20,360,500,40);
  text ("E",5,385);
  rect (20,400,500,40);
  text ("D",5,425);
  rect (20,440,500,40);
  text ("C",5,465);
  rect (buttonX,buttonY,buttonSize,buttonSize);
  text ("Play",575,40);
  
  // default TUIO code for displaying fiducial markers on the screen
  Vector tuioObjectList = tuioClient.getTuioObjects();
  for (int i=0;i<tuioObjectList.size();i++) {
    TuioObject tobj = (TuioObject)tuioObjectList.elementAt(i);
     stroke(0);
     pushMatrix();
     translate(tobj.getScreenX(width),tobj.getScreenY(height));
     rotate(tobj.getAngle());
     rect(-obj_size/2,-obj_size/2,obj_size,obj_size);
     popMatrix();
     text(""+tobj.getSymbolID(), tobj.getScreenX(width), tobj.getScreenY(height));
   } 
}

// these callback methods are called whenever a TUIO event occurs

// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
  // find current angle and set it to previous_angle      
  if (tobj.getSymbolID() == object_id) {
       previous_angle = tobj.getAngle();
       if (checkRegion(tobj) < piece.size()) {}
         else {} 
       Scan_notes(tobj);
 
   }
}

// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) {
  local_note_count--;
  local_note_pitch = 60;
  local_note_duration = 1;
  // code should store value in array once removed
}

// called when an object is moved
void updateTuioObject (TuioObject tobj) {
  if (tobj.getSymbolID() == object_id) {
    // check if angle has moved, if it has, updated it according to rotation direction
    if (tobj.getAngle() > previous_angle + 0.3 || tobj.getAngle() < previous_angle - 0.3) {
      previous_angle = tobj.getAngle();
      // Increase duration of note
      if (tobj.getRotationSpeed() > 0 && local_note_duration < 1) {
        local_note_duration = local_note_duration*2;
        Scan_notes(tobj);
        println("update object at"+ previous_angle + " " + "with duration of " + local_note_duration);}
      // Decrease duration of note
      if (tobj.getRotationSpeed() < 0 && local_note_duration > min_duration) {
        local_note_duration = local_note_duration/2;
        Scan_notes(tobj);
        println("update object at"+ previous_angle + " " + "with duration of " + local_note_duration);}
      // Remove note
      if (tobj.getRotationSpeed() < 0 && local_note_duration <= min_duration) {
        
      }
  }
  }
}

// called after each message bundle
// representing the end of an image frame
void refresh(TuioTime bundleTime) { 
  redraw();
}

void Scan_notes(TuioObject tobj)
{
    // look for notes on y-axis by dividing it into 12 categories 
   for(int i=0; i < 12 ; i++)
{
  if (tobj.getY() >= (i) * ylength / 12 && tobj.getY() < (i+1) * ylength / 12)
  {
     local_note_pitch = map_pitches(i);     
     local_note_count++;
  }
}  
  }
  
void Play_notes()
{ 
    // play one musical element at a time
   for(int i=0; i < piece.size() ; i++)
  {
    //temp is a temporary variable used to store the musical elements of the piece 
    music_element temp = (music_element) piece.get(i);
     
     if (temp.number_of_notes == 1)
     { note.playNote(temp.getPitch(0), note_volume, temp.duration); }
     
     if (temp.number_of_notes > 1)
     { float [] chord = new float [temp.number_of_notes];
       for (int j=0; i < temp.number_of_notes ; j++)
        {chord[j] = (float) temp.getPitch(j);} 
       note.playChord(chord, note_volume, temp.duration); }
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
     return 0;
}

int checkRegion(TuioObject tobj)
{
// check in which region of the screen the object is in 
  int partitions = piece.size() + 1; // screen is divided by number of music elements in the piece plus an empty region to add an additional element
  float xregion = (float) xlength / partitions; // size of the equal regions in x coordinates
  float objcor = (float) tobj.getX() / xregion;
  int objregion = floor(objcor); // index of region where the object is
  if (objregion >= partitions) {objregion = piece.size();} //making sure the object is within bounds
  if (objregion < 0) {objregion = 0;} //making sure the object is within bounds
  return objregion;
}


//Cursor procedures

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

