
import java.util.*;
import java.util.ArrayList;
import java.util.List;

public class music_element {
  
  float X;
  
  int number_of_notes;

  ArrayList pitch;
  float duration;
  
  music_element () { X = 0; number_of_notes = 0; }
  
  music_element (float i, int [] pitches, float durations) {
      X = i;
      duration = durations;
      number_of_notes = pitches.length;
      for (int j =0; j < pitches.length; j++)
      {
        pitch.add(pitches[j]);
      }
  }

public float getX() {return X;}

public int getPitch(int i) { return (int) (Integer) pitch.get(i); }

public int pitch_exists (int i) //checks if a particular pitch exists in this musical element, returns index of note
{
      for (int j =0; j < pitch.size(); j++)
    {
      if ( (Integer) pitch.get(j) == i)
        {return j;}
    }
    
    return -1;
}

public void commit_element (float i, int [] pitches, float durations)
{
    X = i;
    for (int j =0; j < pitches.length; j++)
    {
      if (pitch_exists(pitches[j]) == -1)
        { pitch.add(pitches[j]); number_of_notes++; }
      else { pitch.remove(j); pitch.add(pitches[j]);}
    }    
}

public void remove_note (int [] pitches){
  for (int j =0; j < pitches.length; j++)
    {
      if (pitch_exists(pitches[j]) == -1)
        { pitch.remove(j);}
    }    
}

}
