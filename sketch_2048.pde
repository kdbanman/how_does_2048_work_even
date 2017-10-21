
int gridSize;
int[][] grid;

int cellSize;
int cellPadding;

int effectiveSize() {
  return cellSize + cellPadding;
}

int gridDrawSize() {
  return effectiveSize() * gridSize + cellPadding;
}

void seedGrid() {
  int midpoint = gridSize / 2;
  if (gridSize % 2 == 0) {
    grid[midpoint][midpoint] = 2;
    grid[midpoint - 1][midpoint] = 2;
    grid[midpoint][midpoint - 1] = 2;
    grid[midpoint - 1][midpoint - 1] = 2;
  } else {
    grid[midpoint][midpoint] = 2;
  }
}

void collapseGrid(Direction moveDirection) {
  /*
  For left to right moveDirection (Direction.RIGHT), we need:
  [0, 0, 0, 0] -> [0, 0, 0, 0]
  [0, 0, 0, 2] -> [0, 0, 0, 2]
  [0, 0, 2, 0] -> [0, 0, 0, 2]
  [0, 0, 2, 2] -> [0, 0, 0, 4]
  [2, 2, 2, 2] -> [0, 0, 4, 4]
  [4, 4, 2, 2] -> [0, 0, 8, 4]
  [0, 2, 2, 2] -> [0, 0, 2, 4]
  [2, 0, 2, 2] -> [0, 0, 2, 4]
  [2, 2, 0, 2] -> [0, 0, 2, 4]
  [2, 2, 2, 0] -> [0, 0, 2, 4]
  
  General:
  - Drop empties.
  - From target to source combine adjacent pairs.
  - Place new list from target to source, padded with empties on source side.
  */
  return;
}

ArrayList<Integer> getFreeCellIndices(Direction wallSide, int layer) {
  ArrayList<Integer> freeCellIndices = new ArrayList<Integer>();
  for (int idx = 0; idx < gridSize; idx++) {
    int gridValue = -1;
    switch (wallSide) {
      case LEFT:
        gridValue = grid[idx][layer];
        break;
        
      case RIGHT:
        gridValue = grid[idx][gridSize - layer - 1];
        break;
        
      case DOWN:
        gridValue = grid[gridSize - layer - 1][idx];
        break;
        
      case UP:
        gridValue = grid[layer][idx];
        break;
    }
    if (gridValue == 0) {
      freeCellIndices.add(idx);
    }
  }
  
  return freeCellIndices;
} 

void spawnTile(Direction wallSide, int layer, int indexToFill) {
  int row = -1;
  int col = -1;
  
  switch (wallSide) {
    case LEFT:
      row = indexToFill;
      col = layer;
      break;
      
    case RIGHT:
      row = indexToFill;
      col = gridSize - layer - 1;
      break;
      
    case DOWN:
      row = gridSize - layer - 1;
      col = indexToFill;
      break;
      
    case UP:
      row = layer;
      col = indexToFill;
      break;
  }
  println("" + row + ", " + col);
  grid[row][col] = 2;
}

boolean spawnRandomTile(Direction wallSide) {
  /*
  March in from wallSide, if open tile(s) at layer, randomly choose from them in that layer.
  If no more layers, return false.
  */
  boolean tilePlaced = false;
  for (int layer = 0; layer < gridSize; layer++) {
    ArrayList<Integer> freeCellIndices = getFreeCellIndices(wallSide, layer);
    if (freeCellIndices.size() != 0) {
      int indexToFill = freeCellIndices.get(int(random(freeCellIndices.size())));
      spawnTile(wallSide, layer, indexToFill);
      tilePlaced = true;
      break;
    }
  }
  
  return tilePlaced;
}

void setup() {
  gridSize = 4;
  grid = new int[gridSize][];
  for (int i = 0; i < gridSize; i++) {
    grid[i] = new int[gridSize];
  }
  seedGrid();
  
  cellSize = 100;
  cellPadding = 5;
  
  size(gridDrawSize(), gridDrawSize());
  frameRate(24);
}

void draw() {
  clearScreen();
  
  for (int row = 0; row < gridSize; row++) {
    for (int col = 0; col < gridSize; col++) {
      // DESIGN: cells should own their own shape, color, text, other view magic
      
      setFillForValue(grid[row][col]);
      int cellX = effectiveSize() * col + cellPadding;
      int cellY = effectiveSize() * row + cellPadding;
      // x y w h r
      rect(cellX, cellY, cellSize, cellSize, cellSize / 10);
      
      textAlign(CENTER, CENTER);
      textSize(32); 
      fill(255, 255, 255);
      text("" + grid[row][col], cellX, cellY, cellSize, cellSize);
    }
  }
}

void setFillForValue(int value) {
  switch (value) {
    case 0:
      fill(20, 20, 20);
      break;
    
    case 2:
      fill(55, 98, 25);
      break;
    
    case 4:
      fill(145, 18, 25);
      break;
    
    default:
      fill(255, 105, 180);
      break;
  }
}

void clearScreen() {
  background(0);
}

Direction getMoveDirection() {
  if (key == CODED) {
    if (keyCode == LEFT) {
      return Direction.LEFT;
    } else if (keyCode == RIGHT) {
      return Direction.RIGHT;
    } else if (keyCode == UP) {
      return Direction.UP;
    } else if (keyCode == DOWN) {
      return Direction.DOWN;
    }
  }
  return Direction.NONE;
}

Direction getOppositeDirection(Direction inDirection) {
  Direction opposite = Direction.NONE;
  switch (inDirection) {
    case LEFT:
      opposite = Direction.RIGHT;
      break;
      
    case RIGHT:
      opposite = Direction.LEFT;
      break;
      
    case DOWN:
      opposite = Direction.UP;
      break;
      
    case UP:
      opposite = Direction.DOWN;
      break;
  }
  return opposite;
}

void keyPressed() {
  Direction moveDirection = getMoveDirection();
  collapseGrid(moveDirection);
  
  boolean tilePlaced = spawnRandomTile(getOppositeDirection(moveDirection));
  
  if (!tilePlaced){
    println("Lose.");
  }
}

