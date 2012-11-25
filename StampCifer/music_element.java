
import java.util.*;
import java.util.ArrayList;
import java.util.List;

public class music_element {
  
  float X;

  ArrayList pitch;
  ArrayList duration;
  
  music_element () {
    X = 0; pitch = 60; duration = 1;
  }
  
  music_element (float i, int [] pitches ) {
    X = i; 
    pitch = 60; 
    duration = 1;
  }

public float getX() {return X;}

}
