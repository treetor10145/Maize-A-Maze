import java.util.Stack; //<>//
import java.util.LinkedList;
import java.util.Iterator;

import processing.sound.*;

Cell[][] maze;
int tileLength;

Cell start;
Cell end;

int playerCol;
int playerRow;
boolean showingMap;
boolean showingPath;
float angle;
float targetAngle;
int angleDirection;
int wallHeight;

//Player States
boolean rotating;
boolean moving;

int rotateTimer;
int showMapTimer;
int showPathTimer;

int continueTimer;

int state; //0 - Menu, 1 - Game, 2 - Victory, 3 - Help

float x;
float y;
float targetX;
float targetY;

boolean[] keys;

Timer timer;

Button startMaze;
Button controls;
Button returnToMenu;

int congratColor;
int colorChange;
ArrayList<Corn> corns; //idc about grammars

SoundFile backgroundMusic;
/* Enigma Kevin MacLeod (incompetech.com)
 * Licensed under Creative Commons: By Attribution 3.0 License
 * http://creativecommons.org/licenses/by/3.0/
 */
SoundFile victoryMusic;

void setup()
{
  size(400, 400, P3D);
  frameRate(60);
  smooth();

  state = 0;
  keys = new boolean[250];


  startMaze = new Button(100, 180, 200, 80, "Start the Maize");
  controls = new Button(100, 280, 200, 80, "Controls");
  
  returnToMenu = new Button(100, 300, 200, 80, "Return to Menu");
  
  
  tileLength = 10;
  maze = new Cell[40][40];
  for(int col = 0; col < maze.length; col++)
  {
    for(int row = 0; row < maze[0].length; row++)
    {
      maze[col][row] = new Cell(col, row);
    }
  }

  setupMaze(maze);
  findShortestPath(maze, start, end);

  playerCol = start.col;
  playerRow = start.row;

  x = playerCol * tileLength;
  y = playerRow * tileLength;
  targetX = x;
  targetY = y;

  angle = 0;
  targetAngle = angle;

  wallHeight = 15;

  moving = false;
  rotating = false;
  
  timer = new Timer();

  rotateTimer = 0;
  showMapTimer = 0;
  showPathTimer = 0;
  continueTimer = 90;
  
  congratColor = 0;
  colorChange = 3;
  corns = new ArrayList<Corn>();
  
  backgroundMusic = new SoundFile(this, "Enigma.mp3");
  victoryMusic = new SoundFile(this, "Victory.mp3");
}

void setupMaze(Cell[][] maze)
{
  start = maze[int(random(40))][int(random(40))];
  end = maze[int(random(40))][int(random(40))];
  end.isEnd = true;

  generateMaze(maze);
}

void generateMaze(Cell[][] maze)
{
  //Create a list of all visitedCells
  Stack<Cell> visitedCells = new Stack<Cell>();

  Cell currentCell = maze[int(random(40))][int(random(40))];
  generatePath(currentCell, visitedCells);
}

void generatePath(Cell currentCell, Stack<Cell> visitedCells)
{
  //Generate all neighbors that are not visited
  ArrayList<Cell> neighbors = currentCell.availableNeighborsToGenerate(maze);
  if(neighbors.size() > 0) //If there are neighbors
  {
    Cell nextCell = neighbors.get(int(random(neighbors.size()))); //Grab a random neighbor
    nextCell.visited = true; //Set that cell as visited so further neighbor calls won't grab it
    visitedCells.push(currentCell); //Add that cell to the visited cells list
    removeWalls(currentCell, nextCell); //Carve a path between the cells
    currentCell = nextCell; //Set the current cell to the generated one, for recursion
  }
  else if(!visitedCells.isEmpty()) //If the visited cells list is not empty and there are no neighbors with the current cell
  {
    currentCell = visitedCells.pop(); //Backtrack constantly until it reaches a cell w/ neighbors
  }

  //Use recursion and constantly call the method until it backtracks to the beginning
  if(!visitedCells.isEmpty()) generatePath(currentCell, visitedCells);
}

//Remove the walls between two cells
void removeWalls(Cell currentCell, Cell nextCell)
{
  if(currentCell.col - nextCell.col > 0)
  {
    currentCell.removeWall(3);
    nextCell.removeWall(1);
  }
  else if(currentCell.col - nextCell.col < 0)
  {
    currentCell.removeWall(1);
    nextCell.removeWall(3);
  }

  if(currentCell.row - nextCell.row > 0)
  {
    currentCell.removeWall(0);
    nextCell.removeWall(2);
  }
  else if(currentCell.row - nextCell.row < 0)
  {
    currentCell.removeWall(2);
    nextCell.removeWall(0);
  }
}

//Finds the Shortest Path Using Breadth First
void findShortestPath(Cell[][] maze, Cell start, Cell end)
{
  LinkedList<Cell> queue = new LinkedList<Cell>(); //Queue of all cells to search (FILO)
  queue.push(start); //Add the beginning to the search
  while(!queue.isEmpty()) //While the queue has things to search
  {
    Cell item = queue.pop(); //Get the top item and remove it
    item.searched = true; //Set it as searched so that it is not searched again
    ArrayList<Cell> neighbors = item.availableNeighborsToSearch(maze); //Get all neighbors that have not been searched
    for(Cell neighbor : neighbors) //For every neighbor
    {
      neighbor.parent = item; //Set the neighbor's parent to the source cell
      if(neighbor == end) break; //If that neighbor is the end, then end the loop
      else queue.addLast(neighbor); //Add the neighbor to the queue for searching if it is not the end
    }
  }

  Cell pathCell = end; //Set a variable to the end, for building out the path
  int length = 0;
  while(pathCell.parent != null) //While the path is not finished
  {
    pathCell.isPartOfPath = true; //Tell the cell that it is part of the path, and should be drawn as such
    pathCell = pathCell.parent; //Set the path variable to its parent, so it eventually loops back and finds the beginning
    length++;
  }
}

void draw()
{
  if(state == 0)
  {
      background(255);
      
      fill(0);
      textFont(createFont("Papyrus", 20));
      textAlign(CENTER);
      text("An insight into life bounded by walls;", width / 2, 25);
      text("a tragic tale of isolation", width / 2, 50);
      text("concluded only through escape:", width / 2, 75);
      textFont(createFont("Papyrus", 40));
      text("Maize", width / 2, 115);
      textFont(createFont("default", 20));
      
      startMaze.appear();
      controls.appear();
  }
  else if(state == 1)
  {
    background(255);

    float playerHeight = height - 20;
    int xOffset = 0;
    int yOffset = 0;

    if(angle < 0.1 || TWO_PI - angle < 0.1)
    {
      xOffset = 5;
      yOffset = 25;
    }
    else if(abs(HALF_PI - angle) < 0.1)
    {
      xOffset = -15;
      yOffset = 5;
    }
    else if(abs(PI - angle) < 0.1)
    {
      xOffset = 5;
      yOffset = -15;
    }
    else if(abs((PI + HALF_PI) - angle) < 0.1)
    {
      xOffset = 25;
      yOffset = 5;
    }

    int cameraY = -30;

    camera(
          x + xOffset,
          playerHeight + cameraY,
          y - height / 2 + yOffset,

          x + xOffset + sin(angle),
          playerHeight + cameraY + 2,
          y - height / 2 + yOffset - cos(angle),

          0, 1, 0);

    ambientLight(100, 100, 100);
    pointLight(255, 255, 255,
      x, playerHeight, y - 200);

    noStroke();

    for(int col = 0; col < maze.length; col++)
    {
      for(int row = 0; row < maze[0].length; row++)
      {
        Cell cell = maze[col][row];
        cell.draw3D(tileLength);
      }
    }

    pushMatrix();
    fill(255, 255, 0, 150);
    translate((playerCol + 0.5) * tileLength, height, (playerRow + 0.5) * tileLength - 200);
    box(tileLength * 2 / 3.0, wallHeight, tileLength * 2 / 3.0);
    popMatrix();

    pushMatrix();
    fill(0, 0, 255, 200);
    translate((end.col + 0.5) * tileLength, height, (end.row + 0.5) * tileLength - 200);
    box(tileLength, wallHeight * 10, tileLength);
    popMatrix();

    //For 2D Rendering
    hint(DISABLE_DEPTH_TEST);
    drawMap();
    drawCoordinates();
    
    fill(255, 210);
    rect(4, 4, 70, 25);
    textAlign(LEFT, TOP);
    textSize(23);
    fill(0);
    
    text(timer.getTime(), 4, 4);
    
    hint(ENABLE_DEPTH_TEST);

    refreshMap();
    updatePosition();
    checkKeys();
    
    if(showingPath) timer.setSpeed(2);
    else if(showingMap) timer.setSpeed(1);
    else timer.setSpeed(0);
    timer.update();
    
    if(playerCol == end.col && playerRow == end.row)
    {
      state = 2;
      timer.stop();
      backgroundMusic.stop();
      victoryMusic.play();
    }
  }
  else if(state == 2)
  {
    hint(DISABLE_DEPTH_TEST);
   
    noStroke();
    background(43, 53, 234);
    
    if(frameCount % 15 == 0 && corns.size() < 5)
    {
      corns.add(new Corn(width / 5.0, height / 3.0, random(TWO_PI)));
      corns.add(new Corn(width / 2.0, height / 6.0, random(TWO_PI)));
      corns.add(new Corn(width * 4.0 / 5, height / 3.0, random(TWO_PI)));
    }
    
    congratColor = congratColor + colorChange;
    if (congratColor >= width || congratColor <= 0) {
      colorChange *= -1;
    }
    
    Iterator<Corn> iterator = corns.iterator();
    while(iterator.hasNext())
    {
      Corn corn = iterator.next();
      corn.show();
      corn.update();
      
      if(corn.position.y > height / 2) iterator.remove();
    }
    for(Corn corn : corns)
    { 
      corn.show();
      corn.update();
      
      if(corn.position.y > height) corns.remove(corn);
    }
    
    fill(43, 53, 234);
    rect(0, height / 2, width, height / 2);
    
    textFont(createFont("default", 40));
    textAlign(CENTER);
    fill(255, 216 + ((congratColor / float(width)) * 39), (congratColor / float(width)) * 255);
    text("Congratulations!", width / 2, height * 3 / 4);
    
    fill(255);
    text(timer.getTime(), width / 2, 50);
    if(continueTimer > 0) continueTimer--;
    
    println(frameRate);
  }
  else if(state == 3)
  {
    background(255);
    textFont(createFont("default", 21));
    textAlign(CENTER);
    fill(0);
    
    pushMatrix();
    translate(0, -20);
    text("WASD = Movement", width/2, height/8);
    text("L = Show Map", width/2, height/8 + 24);
    text("; = Show Path While Map Is Open", width/2, height/8 + 48);
    text(", = Rotate Camera Counterclockwise", width/2, height/8 + 72);
    text(". = Rotate Camera Clockwise", width/2, height/8 + 96);
    
    text("Click Left or Right Portion =", width / 2, height / 8 + 144);
    text("Rotate Camera", width / 2, height / 8 + 168);
    text("Click Middle of Screen / Space =", width / 2, height / 8 + 192);
    text("Move Forwards", width / 2, height / 8 + 216);
    text("Click Map Area = Toggle", width / 2, height / 8 + 240);
    text("Between Show Map, Path, and Nothing", width / 2, height / 8 + 264);
    popMatrix();
    
    returnToMenu.appear();
  }
}

void drawMap()
{
  camera();
  pushMatrix();
  if(showingMap)
  {
    translate(width - maze[0].length * 2, maze.length * 2);
    for(int col = 0; col < maze.length; col++)
    {
      for(int row = 0; row < maze[0].length; row++)
      {
        Cell cell = maze[col][row];
        if(!(col == playerCol && row == playerRow))
        {
          cell.show(4, showingPath);
        }
      }
    }

    pushMatrix();
    translate(playerCol * 4 - 80, playerRow * 4 - 80);
    fill(255, 0, 0);
    rect(0, 0, 4, 4);
    popMatrix();
  }

  popMatrix();
}

void drawCoordinates()
{
  fill(255, 210);
  rect(74, 4, 165, 25);
  textSize(12);
  textAlign(CENTER, CENTER);
  fill(255, 0, 0);
  text("Player Coordinates: " + (playerCol + 1) + " : " + (playerRow + 1), 156, 10);
  fill(0, 0, 255);
  text("Goal Coordinates: " + (end.col + 1) + " : " + (end.row + 1), 160, 20);
}

void refreshMap()
{
  int endCol = end.col;
  int endRow = end.row;

  for(int col = 0; col < maze.length; col++)
  {
    for(int row = 0; row < maze[0].length; row++)
    {
      boolean[] walls = new boolean[4];
      System.arraycopy(maze[col][row].walls, 0, walls, 0, maze[col][row].walls.length);
      maze[col][row] = new Cell(col, row);
      System.arraycopy(walls, 0, maze[col][row].walls, 0, walls.length);
    }
  }
  end = maze[endCol][endRow];
  end.isEnd = true;
  findShortestPath(maze, maze[playerCol][playerRow], end);
}

void updatePosition()
{
  if(x != targetX)
  {
    x += signum(targetX - x) * 0.8;
    moving = true;
    if(abs(x - targetX) < 0.4 && abs(y - targetY) < 0.4)
    {
      x = targetX;
      y = targetY;
      moving = false;
    }
  }
  if(y != targetY)
  {
    y += signum(targetY - y) * 0.8;
    moving = true;
    if(abs(x - targetX) < 0.4 && abs(y - targetY) < 0.4)
    {
      x = targetX;
      y = targetY;
      moving = false;
    }
  }

  if(abs(targetAngle - angle) >= 0.5)
  {
    angle += angleDirection * PI / 12;

    if(angle > TWO_PI) angle -= TWO_PI;
    if(angle <= 0) angle += TWO_PI;

    if(abs(targetAngle - angle) < 0.5) angle = targetAngle;
    rotating = true;
    if(angle == targetAngle) rotating = false;
  }
}

void checkKeys()
{
  if(!(moving || rotating))
  {
    if(angle < 0.1 || TWO_PI - angle < 0.1)
    {
      if((keys['w'] || keys[' ']) && !maze[playerCol][playerRow].walls[0])
      {
        playerRow--;
        targetY = y - tileLength;
      }
      else if(keys['a'] && !maze[playerCol][playerRow].walls[3])
      {
        playerCol--;
        targetX = x - tileLength;
        //targetAngle -= HALF_PI;
        //angleDirection = -1;
      }
      else if(keys['s'] && !maze[playerCol][playerRow].walls[2])
      {
        playerRow++;
        targetY = y + tileLength;
        //targetAngle += PI;
        //angleDirection = 1;
      }
      else if(keys['d'] && !maze[playerCol][playerRow].walls[1])
      {
        playerCol++;
        targetX = x + tileLength;
        //targetAngle += HALF_PI;
        //angleDirection = 1;
      }
    }
    else if(abs(HALF_PI - angle) < 0.1)
    {
      if(keys['a'] && !maze[playerCol][playerRow].walls[0])
      {
        playerRow--;
        targetY = y - tileLength;
        //targetAngle -= HALF_PI;
        //angleDirection = -1;
      }
      else if(keys['s'] && !maze[playerCol][playerRow].walls[3])
      {
        playerCol--;
        targetX = x - tileLength;
        //targetAngle += PI;
        //angleDirection = 1;
      }
      else if(keys['d'] && !maze[playerCol][playerRow].walls[2])
      {
        playerRow++;
        targetY = y + tileLength;
        //targetAngle += HALF_PI;
        //angleDirection = 1;
      }
      else if((keys['w'] || keys[' ']) && !maze[playerCol][playerRow].walls[1])
      {
        playerCol++;
        targetX = x + tileLength;
      }
    }
    else if(abs(PI - angle) < 0.1)
    {
      if(keys['s'] && !maze[playerCol][playerRow].walls[0])
      {
        playerRow--;
        targetY = y - tileLength;
        //targetAngle += PI;
        //angleDirection = 1;
      }
      else if(keys['d'] && !maze[playerCol][playerRow].walls[3])
      {
        playerCol--;
        targetX = x - tileLength;
        //targetAngle += HALF_PI;
        //angleDirection = 1;
      }
      else if((keys['w'] || keys[' ']) && !maze[playerCol][playerRow].walls[2])
      {
        playerRow++;
        targetY = y + tileLength;
      }
      else if(keys['a'] && !maze[playerCol][playerRow].walls[1])
      {
        playerCol++;
        targetX = x + tileLength;
        //targetAngle -= HALF_PI;
        //angleDirection = -1;
      }
    }
    else if(abs((PI + HALF_PI) - angle) < 0.1)
    {
      if(keys['d'] && !maze[playerCol][playerRow].walls[0])
      {
        playerRow--;
        targetY = y - tileLength;
        //targetAngle += HALF_PI;
        //angleDirection = 1;
      }
      else if((keys['w'] || keys[' ']) && !maze[playerCol][playerRow].walls[3])
      {
        playerCol--;
        targetX = x - tileLength;
      }
      else if(keys['a'] && !maze[playerCol][playerRow].walls[2])
      {
        playerRow++;
        targetY = y + tileLength;
        //targetAngle -= HALF_PI;
        //angleDirection = -1;
      }
      else if(keys['s'] && !maze[playerCol][playerRow].walls[1])
      {
        playerCol++;
        targetX = x + tileLength;
        //targetAngle += PI;
        //angleDirection = 1;
      }
    }

    if(keys['.'] && rotateTimer == 0)
    {
      targetAngle = angle + HALF_PI;
      angleDirection = 1;

      rotateTimer = 20;
    }
    if(keys[','] && rotateTimer == 0)
    {
      targetAngle = angle - HALF_PI;
      angleDirection = -1;

      rotateTimer = 10;
    }
    if(targetAngle > TWO_PI) targetAngle -= TWO_PI;
    if(targetAngle <= 0) targetAngle += TWO_PI;
  }

  if(keys['l'] && showMapTimer == 0)
  {
    showingMap = !showingMap;
    showingPath = false;

    showMapTimer = 10;
  }
  if(keys[';'] && showingMap && showPathTimer == 0)
  {
    showingPath = !showingPath;

    showPathTimer = 10;
  }

  if(rotateTimer > 0) rotateTimer--;
  if(showMapTimer > 0) showMapTimer--;
  if(showPathTimer > 0) showPathTimer--;
}

void restart()
{
  state = 0;

  for(int col = 0; col < maze.length; col++)
  {
    for(int row = 0; row < maze[0].length; row++)
    {
      maze[col][row] = new Cell(col, row);
    }
  }

  setupMaze(maze);
  findShortestPath(maze, start, end);

  playerCol = start.col;
  playerRow = start.row;

  x = playerCol * tileLength;
  y = playerRow * tileLength;
  targetX = x;
  targetY = y;

  angle = 0;
  targetAngle = angle;

  moving = false;
  rotating = false;
  
  timer = new Timer();

  rotateTimer = 0;
  showMapTimer = 0;
  showPathTimer = 0;
  continueTimer = 300;
  showingMap = false;
  showingPath = false;
  
  backgroundMusic.jump(0);
  victoryMusic.jump(0);
  backgroundMusic.stop();
  victoryMusic.stop();
}

void keyPressed()
{
  if(key < 250) keys[key] = true;
  if(state == 2 && continueTimer == 0)
  {
    victoryMusic.stop();
    hint(ENABLE_DEPTH_TEST);
    restart();
  }
}

void keyReleased()
{
  if(key < 250) keys[key] = false;
}

void mousePressed()
{
  if(state == 0)
  {
    if(startMaze.hover()) 
    {
      state = 1;
      backgroundMusic.loop();
    }
    if(controls.hover()) state = 3;
  }
  else if(state == 1)
  {
    if(mouseX > width - 160 && mouseY > 0 && mouseX < width && mouseY < 160)
    {
      if(!showingMap) showingMap = true;
      else if(showingMap && !showingPath) showingPath = true;
      else if(showingMap && showingPath) 
      {
        showingMap = false;
        showingPath = false;
      }
    }
    else if(mouseX < width / 3.0 && !rotating) 
    {
      targetAngle -= HALF_PI; 
      angleDirection = -1;
    }
    else if(mouseX > width * 2.0 / 3 && !rotating)
    {
      targetAngle += HALF_PI;
      angleDirection = 1;
    }
    else if(mouseX > width / 3.0 && mouseX < width * 2.0 / 3)
    {
      boolean[] walls = maze[playerCol][playerRow].walls;
      if((angle < 0.1 || TWO_PI - angle < 0.1) && !walls[0])
      {
        playerRow--;
        targetY -= tileLength;
      }
      else if((abs(HALF_PI - angle) < 0.1) && !walls[1])
      {
        playerCol++;
        targetX += tileLength;
      }
      else if((abs(PI - angle) < 0.1) && !walls[2])
      {
        playerRow++;
        targetY += tileLength;
      }
      else if((abs((PI + HALF_PI) - angle) < 0.1) && !walls[3])
      {
        playerCol--;
        targetX -= tileLength;
      }
    }
    
    if(targetAngle > TWO_PI) targetAngle -= TWO_PI;
    if(targetAngle <= 0) targetAngle += TWO_PI;
  }
  else if(state == 3)
  {
    if(returnToMenu.hover()) state = 0;
  }
}

int signum(float number)
{
  if(number > 0) return 1;
  else if(number < 0) return -1;
  else return 0;
}