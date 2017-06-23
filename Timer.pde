public class Timer
{
  int min;
  int sec;
  int frame;
  
  boolean running;
  int speed; //0 for normal, 1 for fast, 2 for fastest
  
  public Timer()
  {
    min = 0;
    sec = 0;
    frame = 0;
    
    running = true;
    speed = 0;
  }
  
  void update()
  {
    if(running)
    {
      frame++;
      switch(speed)
      {
        case 0:
        if(frame == 60) 
        {
          frame = 0;
          sec++;
        }
        break;
        case 1:
        if(frame >= 30)
        {
          frame = 0;
          sec++;
        }
        break;
        case 2:
        if(frame >= 15)
        {
          frame = 0;
          sec++;
        }
        break;
      }
      
      if(sec == 60) 
      {
        sec = 0;
        min++;
      }
    }
  }
  
  void setSpeed(int speed)
  {
    this.speed = speed;
  }
  
  void stop()
  {
    running = false;
  }
  
  String getTime()
  {
    return String.format("%02d", min) + ":" + String.format("%02d", sec);
  }
}