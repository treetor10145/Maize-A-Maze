public class Cell
{
  int col;
  int row;
  
  boolean[] walls;
  boolean visited;
  boolean searched;
  boolean isPartOfPath;
  boolean isEnd;
  
  Cell parent;
  
  public Cell(int col, int row)
  {
    this.col = col;
    this.row = row;
    
    walls = new boolean[] {true, true, true, true};
    visited = false;
    searched = false;
    isPartOfPath = false;
    
    isEnd = false;
    
    parent = null;
  }
  
  public void removeWall(int index)
  {
    walls[index] = false;
  }
  
  public ArrayList<Cell> availableNeighborsToGenerate(Cell[][] maze)
  {
    ArrayList<Cell> neighbors = new ArrayList<Cell>();
    
    if(row - 1 >= 0) 
    {
      if(!maze[col][row - 1].visited) 
      {
        neighbors.add(maze[col][row - 1]);
      }
    }
    if(col - 1 >= 0) 
    {
      if(!maze[col - 1][row].visited) 
      {
        neighbors.add(maze[col - 1][row]);
      }
    }
    if(row + 1 < maze[0].length) 
    {
      if(!maze[col][row + 1].visited) 
      {
        neighbors.add(maze[col][row + 1]);
      }
    }
    if(col + 1 < maze.length) 
    {
      if(!maze[col + 1][row].visited)
      {
        neighbors.add(maze[col + 1][row]); 
      }
    }
    
    return neighbors;
  }
  
  public ArrayList<Cell> availableNeighborsToSearch(Cell[][] maze)
  {
    ArrayList<Cell> neighbors = new ArrayList<Cell>();
    
    if(row - 1 >= 0) 
    {
      if(!maze[col][row - 1].searched && !walls[0]) neighbors.add(maze[col][row - 1]);
    }
    if(col - 1 >= 0) 
    {
      if(!maze[col - 1][row].searched && !walls[3]) neighbors.add(maze[col - 1][row]);
    }
    if(row + 1 < maze[0].length) 
    {
      if(!maze[col][row + 1].searched && !walls[2]) neighbors.add(maze[col][row + 1]);
    }
    if(col + 1 < maze.length) 
    {
      if(!maze[col + 1][row].searched && !walls[1]) neighbors.add(maze[col + 1][row]); 
    }
    
    return neighbors;
  }
  
  public void show(float tileLength, boolean showingPath)
  {
    pushMatrix();
    translate(col * tileLength - 80, row * tileLength - 80);
    
    if(isEnd) fill(0, 0, 255);
    else if(isPartOfPath && showingPath) fill(255, 255, 0);
    else fill(0, 75, 20);
    noStroke();
    rect(0, 0, tileLength, tileLength);
    
    stroke(0);
    if(walls[0]) line(0, 0, 0 + tileLength, 0);
    if(walls[1]) line(0 + tileLength, 0, 0 + tileLength, 0 + tileLength);
    if(walls[2]) line(0 + tileLength, 0 + tileLength, 0, 0 + tileLength);
    if(walls[3]) line(0, 0 + tileLength, 0, 0);
    noStroke();
    
    popMatrix();
  }
  
  public void draw3D(int tileLength)
  {
    pushMatrix();
    if(isPartOfPath && showingPath) fill(255, 255, 0);
    else fill(0, 75, 20);
    translate((col + 0.5) * tileLength, height, -200 + (row + 0.5) * tileLength);
    box(tileLength + 1, 1, tileLength + 1);
    popMatrix();

    if(walls[0])
    {
      pushMatrix();
      fill(10, 170, 0);
      translate((col + 0.5) * tileLength, height, -200 + row * tileLength);
      box(tileLength, wallHeight, 1);
      popMatrix();
    }
    if(walls[1])
    {
      pushMatrix();
      fill(10, 170, 0);
      translate((col + 1) * tileLength, height, -200 + (row + 0.5) * tileLength);
      box(1, wallHeight, tileLength);
      popMatrix();
    }
    if(walls[2])
    {
      pushMatrix();
      fill(10, 170, 0);
      translate((col + 0.5) * tileLength, height, -200 + (row + 1) * tileLength);
      box(tileLength, wallHeight, 1);
      popMatrix();
    }
    if(walls[3])
    {
      pushMatrix();
      fill(10, 170, 0);
      translate(col * tileLength, height, -200 + (row + 0.5) * tileLength);
      box(1, wallHeight, tileLength);
      popMatrix();
    }
  }
  
  public boolean equalTo(Cell cell)
  {
    return (this.col == cell.col && this.row == cell.row);
  }
}