public class Corn
{
  PVector position;
  float angle;
  
  PVector velocity;
  PVector acceleration;
  
  int green;
  int blue;
  
  PImage image = loadImage("corn.png");
  
  public Corn(float x, float y, float angle)
  {
    position = new PVector(x, y);
    velocity = new PVector(random(-2.5, 2.5), 0);
    acceleration = new PVector(0, -random(0.3));
    
    this.angle = angle;
  }
  
  void update()
  {
    acceleration.add(0, 0.01);
    
    this.velocity.add(acceleration);
    this.position.add(velocity);
    
    this.angle += 0.01;
  }
  
  public void show()
  {
    pushMatrix();
    translate(position.x, position.y);
    rotate(angle);
    
    fill(255, 255, 40);
    imageMode(CENTER);
    image(image, 0, 0, 50, 50);
    
    popMatrix();
  }
}