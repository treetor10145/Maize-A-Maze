public class Button 
{
  float x;
  float y;
  float bWidth, bHeight;
  boolean hover;
  boolean visible;
  String message;
  
  Button (float x, float y, float bWidth, float bHeight, String message)
  { 
    this.x = x;
    this.y = y;
    
    this.bWidth = bWidth;
    this.bHeight = bHeight;
    
    this.message = message;
    
    hover = false;
    visible = true;
  }
  void appear() 
  {
    if(visible) 
    {
      fill(0, 255, 0);
      if(hover()) fill(100, 255, 100);
      rect(x, y, bWidth, bHeight);
      fill(0);
      textSize(20);
      textAlign(CENTER, CENTER);
      text(message, x + bWidth / 2, y + bHeight / 2);
    }
  }
  
  boolean hover() 
  {
    return mouseX > x && mouseY > y && mouseX < x + bWidth && mouseY < y + bHeight;
  }
}