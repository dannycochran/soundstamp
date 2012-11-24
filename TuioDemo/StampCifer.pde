/*
    TUIO processing demo - part of the reacTIVision project
    http://reactivision.sourceforge.net/

    Copyright (c) 2005-2009 Martin Kaltenbrunner <mkalten@iua.upf.edu>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

// we need to import the TUIO library
// and declare a TuioProcessing client variable
import java.util.*;
import TUIO.*;
TuioProcessing tuioClient;
import arb.soundcipher.*;        // simple audio library "SoundCipher"  (tempo=120 bpm)

// these are some helper variables which are used
// to create scalable graphical feedback
float cursor_size = 15;
float object_size = 60;
float table_size = 760;
float scale_factor = 1;
PFont font;

float previous_angle;

//Size of hardware screen devoted to staff music
int x_length;
int y_length;

float note_duration;
double min_duration = 0.015625;

int object_id = 77; //id of fiducial

SoundCipher note;

void setup()
{  
  //size(screen.width,screen.height);
  size(640,480);
  noStroke();
  fill(0);
  
  loop();
  frameRate(30);
  //noLoop();
  
  hint(ENABLE_NATIVE_FONTS);
  font = createFont("Arial", 18);
  scale_factor = height/table_size;
  
  // we create an instance of the TuioProcessing client
  // since we add "this" class as an argument the TuioProcessing class expects
  // an implementation of the TUIO callback methods (see below)
  tuioClient  = new TuioProcessing(this);
 
  note = new SoundCipher(this);   // sound object for audio feedback
//  sc.playNote(60, 500, 1/4); // pitch number, volume, duration in beats
  
  previous_angle = 0;
  
  x_length = 90;
  y_length = 60;
  
  note_duration = 1;
}

/*void stop()
{
  minim.stop() ;
  super.stop() ;
}*/

// within the draw method we retrieve a Vector (List) of TuioObject and TuioCursor (polling)
// from the TuioProcessing client and then loop over both lists to draw the graphical feedback.
void draw()
{
  background(255);
  textFont(font,18*scale_factor);
  float obj_size = object_size*scale_factor; 
  float cur_size = cursor_size*scale_factor; 
  
  rect (23,24,67,67);
   
  Vector tuioObjectList = tuioClient.getTuioObjects();
  for (int i=0;i<tuioObjectList.size();i++) {
     TuioObject tobj = (TuioObject)tuioObjectList.elementAt(i);
     stroke(0);
     fill(0);
     pushMatrix();
     translate(tobj.getScreenX(width),tobj.getScreenY(height));
     rotate(tobj.getAngle());
     rect(-obj_size/2,-obj_size/2,obj_size,obj_size);
     popMatrix();
     fill(255);
     text(""+tobj.getSymbolID(), tobj.getScreenX(width), tobj.getScreenY(height));
   }
   
   Vector tuioCursorList = tuioClient.getTuioCursors();
   for (int i=0;i<tuioCursorList.size();i++) {
      TuioCursor tcur = (TuioCursor)tuioCursorList.elementAt(i);
      Vector pointList = tcur.getPath();
      
      if (pointList.size()>0) {
        stroke(0,0,255);
        TuioPoint start_point = (TuioPoint)pointList.firstElement();;
        for (int j=0;j<pointList.size();j++) {
           TuioPoint end_point = (TuioPoint)pointList.elementAt(j);
           line(start_point.getScreenX(width),start_point.getScreenY(height),end_point.getScreenX(width),end_point.getScreenY(height));
           start_point = end_point;
        }
        
        stroke(192,192,192);
        fill(192,192,192);
        ellipse( tcur.getScreenX(width), tcur.getScreenY(height),cur_size,cur_size);
        fill(0);
        text(""+ tcur.getCursorID(),  tcur.getScreenX(width)-5,  tcur.getScreenY(height)+5);
      }
   }
   
}

// these callback methods are called whenever a TUIO event occurs

// called when an object is added to the scene
void addTuioObject(TuioObject tobj) {
       if (tobj.getSymbolID() == object_id) {
      previous_angle = tobj.getAngle();   
      note.playNote(60, 500, note_duration);
      println("add object at"+ previous_angle + " " + "with duration of " + note_duration);
  }
}

// called when an object is removed from the scene
void removeTuioObject(TuioObject tobj) {
  note_duration = 1;
  //  println("remove object "+tobj.getSymbolID()+" (" +tobj.getSessionID()+")" + " " + tobj.getMotionSpeed()+" "+tobj.getRotationSpeed());
}

// called when an object is moved
void updateTuioObject (TuioObject tobj) {  if (tobj.getSymbolID() == object_id) {
       if (tobj.getSymbolID() == object_id) {
    if (tobj.getAngle() > previous_angle + 0.3 || tobj.getAngle() < previous_angle - 0.3) {
      previous_angle = tobj.getAngle();
      if (tobj.getRotationSpeed() < 0 && note_duration > min_duration) {
        note_duration = note_duration/2;
        note.playNote(60, 500, note_duration);
        println("update object at"+ previous_angle + " " + "with duration of " + note_duration);}
      if (tobj.getRotationSpeed() > 0 && note_duration < 1) {
        note_duration = note_duration*2;
        note.playNote(60, 500, note_duration);
        println("update object at"+ previous_angle + " " + "with duration of " + note_duration);}   
  }
  }
}}

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



