
import java.util.*;
import java.util.ArrayList;
import java.util.List;

public class music_element {
  
  float X;
  
  int number_of_notes;

  int volume;
  ArrayList pitch;
  float duration;
  
  music_element () { X = 0; number_of_notes = 0; duration = 1; pitch = new ArrayList(); volume = 500;}
  
  music_element (float i, int p, float d) {
      X = i;
      pitch = new ArrayList();
      pitch.add(p);
      duration = d;
      number_of_notes = 1;
      volume = 500;
  }

public float getX() {return X;}

public int getPitch(int i) { if (pitch.size() > i) {return (int) (Integer) pitch.get(i);} return 0;}

public void modify_duration (float d)
{ duration = d;}

public void modify_volume (int v)
{ volume = v;}

public void decreaseX()
{X--;}

public void add_note (int p){
        if (pitch_exists(p) == -1)
          {pitch.add(p); number_of_notes++;}     
}

public void create_rest () {
  pitch.clear();
  pitch.add(0);
  volume = 0;
  number_of_notes = 1;
}

public int pitch_exists (int i) //checks if a particular pitch exists in this musical element, returns index of note
{
      for (int j =0; j < pitch.size(); j++)
    {
      if ( (Integer) pitch.get(j) == i)
        {return j;}
    }
    
    return -1;
}

}
