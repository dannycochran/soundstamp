
import java.util.*;
import java.util.ArrayList;
import java.util.List;

public class music_element {
  
  float X;
  
  int number_of_notes;

  ArrayList pitch;
  ArrayList duration;
  
  music_element () { X = 0; }
  
  music_element (float i, int [] pitches, float [] durations ) {
    X = i; 
    for (int j =0; j < pitches.length; j++)
    {
      pitch.add(pitches[j]);
    }
      number_of_notes = pitches.length;
      
    for (int j =0; j < pitches.length; j++)
    {
      duration.add(durations[j]);
    }
  }

public float getX() {return X;}

}
