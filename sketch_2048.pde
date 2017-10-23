
int gridSize;
Grid grid;

int cellSize;
int cellPadding;

void setup() {
  gridSize = 4;
  grid = new Grid(gridSize);
  grid.seedGrid();
  
  cellSize = 100;
  cellPadding = 5;
  
  size(gridDrawSize(), gridDrawSize());
  frameRate(24);
}

void draw() {
  clearScreen();
  
  boolean gameLost = gameLost();
  
  for (int row = 0; row < gridSize; row++) {
    for (int col = 0; col < gridSize; col++) {
      // DESIGN: cells should own their own shape, color, text, other view magic
      
      setFillForValue(grid.getGridValue(row, col));
      int cellX = effectiveSize() * col + cellPadding;
      int cellY = effectiveSize() * row + cellPadding;
      // x y w h r
      rect(cellX, cellY, cellSize, cellSize, cellSize / 10);
      
      if (grid.getGridValue(row, col) != 0) {
        String boxText = gameLost ? ":(" : "" + grid.getGridValue(row, col);
        textAlign(CENTER, CENTER);
        textSize(32);
        fill(255, 255, 255);
        text(boxText, cellX, cellY, cellSize, cellSize);
      }
    }
  }
}

void keyPressed() {
  Direction moveDirection = getMoveDirection();
  boolean gridCollapsed = grid.collapseGrid(moveDirection);
  
  boolean tilePlaced = false;
  if (gridCollapsed) {
    tilePlaced = grid.spawnRandomTile(getOppositeDirection(moveDirection));
  }
}

boolean gameLost() {
  Direction[] allDirections = new Direction[]{Direction.LEFT, Direction.RIGHT, Direction.DOWN, Direction.UP};
  for (Direction direction : allDirections) {
    Grid throwawayGrid = grid.copyGrid();
    boolean gridCollapsed = throwawayGrid.collapseGrid(direction);
    
    if (gridCollapsed) {
      return false;
    }
  }
  return true;
}

int effectiveSize() {
  return cellSize + cellPadding;
}

int gridDrawSize() {
  return effectiveSize() * gridSize + cellPadding;
}

void setFillForValue(int value) {
  switch (value) {
    case 0:
      fill(20, 20, 20);
      break;
    
    case 2:
      fill(204, 0, 0);
      break;
    
    case 4:
      fill(191, 0, 0);
      break;
    
    case 8:
      fill(146, 0, 0);
      break;
    
    case 16:
      fill(93, 0, 0);
      break;
      
    case 32:
      fill(78, 4, 150);
      break;
    
    case 64:
      fill(57, 4, 109);
      break;
    
    case 128:
      fill(40, 3, 75);
      break;
    
    case 256:
      fill(6, 54, 148);
      break;
    
    case 512:
      fill(6, 40, 108);
      break;
    
    case 1024:
      fill(4, 28, 74);
      break;
    
    case 2048:
      fill(10, 104, 0);
      break;
    
    case 4096:
      fill(6, 58, 0);
      break;
    
    case 8192:
      fill(0, 109, 94);
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

