
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

ArrayList<Integer> collapseLayers(ArrayList<Integer> layerSlice) {
  /*
  Collapses any layer slice from left to right (Direction.RIGHT):
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
  
  Approach:
  - Drop empties.
  - From target to source combine adjacent pairs.
  - Place new list from target to source, padded with empties on source side.
  */
  ArrayList<Integer> collapsedSlice = (ArrayList<Integer>)layerSlice.clone();
  while (collapsedSlice.indexOf(0) != -1) {
    collapsedSlice.remove(collapsedSlice.indexOf(0));
  }
  
  if (collapsedSlice.size() > 1) {
    for (int layer = collapsedSlice.size() - 1; layer >0; layer--) {
      int value = collapsedSlice.get(layer);
      int precedingValue = collapsedSlice.get(layer - 1);
      
      if (value == precedingValue) {
        collapsedSlice.set(layer - 1, value * 2);
        // .remove preferentially removes from the index passed, rather than looking for the passed value and removing it
        collapsedSlice.remove(layer);
        layer--;
      }
    }
  }
  
  ArrayList<Integer> newSlice = new ArrayList<Integer>();
  while (newSlice.size() + collapsedSlice.size() < gridSize) {
    newSlice.add(0);
  }
  newSlice.addAll(collapsedSlice);
  return newSlice;
}

ArrayList<Integer> getLayerSlice(Direction moveDirection, int layer) {
  ArrayList<Integer> slice = new ArrayList<Integer>();
  switch (moveDirection) {
    case LEFT:
      for (int col = gridSize - 1; col >= 0; col--) {
        slice.add(grid[layer][col]);
      }
      break;
      
    case RIGHT:
      for (int col = 0; col < gridSize; col++) {
        slice.add(grid[layer][col]);
      }
      break;
      
    case DOWN:
      for (int row = 0; row < gridSize; row++) {
        slice.add(grid[row][layer]);
      }
      break;
      
    case UP:
      for (int row = gridSize - 1; row >= 0; row--) {
        slice.add(grid[row][layer]);
      }
      break;
  }
  return slice;
}

void writeLayerSlice(Direction moveDirection, int layer, ArrayList<Integer> slice) {
  // pop from the left of newLayerSlice and write from source to target in layer
  switch (moveDirection) {
    case LEFT:
      for (int col = gridSize - 1; col >= 0; col--) {
        grid[layer][col] = slice.get(gridSize - col - 1);
      }
      break;
      
    case RIGHT:
      for (int col = 0; col < gridSize; col++) {
        grid[layer][col] = slice.get(col);
      }
      break;
      
    case DOWN:
      for (int row = 0; row < gridSize; row++) {
        grid[row][layer] = slice.get(row);
      }
      break;
      
    case UP:
      for (int row = gridSize - 1; row >= 0; row--) {
        grid[row][layer] = slice.get(gridSize - row - 1);
      }
      break;
  }
}

void collapseGrid(Direction moveDirection) {
  for (int layer = 0; layer < gridSize; layer++) {
    ArrayList<Integer> layerSlice = getLayerSlice(moveDirection, layer);
    ArrayList<Integer> newLayerSlice = collapseLayers(layerSlice);
    writeLayerSlice(moveDirection, layer, newLayerSlice);
  }
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
      
      if (grid[row][col] != 0) {
        textAlign(CENTER, CENTER);
        textSize(32);
        fill(255, 255, 255);
        text("" + grid[row][col], cellX, cellY, cellSize, cellSize);
      }
    }
  }
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

void keyPressed() {
  Direction moveDirection = getMoveDirection();
  collapseGrid(moveDirection);
  
  boolean tilePlaced = spawnRandomTile(getOppositeDirection(moveDirection));
  
  if (!tilePlaced){
    // TODO This isn't actually the lose condition.
    println("Lose.");
  }
}

