import java.util.ArrayList;
import java.util.concurrent.ThreadLocalRandom;

public class Grid {
  private int gridSize;
  private int[][] grid;
  
  public Grid(int gridSize) {
    this.gridSize = gridSize;
    
    grid = new int[gridSize][];
    for (int i = 0; i < gridSize; i++) {
      grid[i] = new int[gridSize];
    }
  }
  
  public Grid(Grid toCopy) {
    this.gridSize = toCopy.getGridSize();
    this.grid = toCopy.copyGridInternal();
  }
  
  public int getGridSize() {
    return gridSize;
  }
  
  public int getGridValue(int row, int col) {
    return grid[row][col];
  }
  
  public int getGridValue(Coordinate coord) {
    return grid[coord.row][coord.col];
  }
  
  public Grid copyGrid() {
    return new Grid(this);
  }
  
  public void seedGrid() {
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
  
  public boolean gridEquals(int[][] otherGrid) {
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        if (otherGrid[row][col] != grid[row][col]) {
          return false;
        }
      }
    }
    return true;
  }
  
  public boolean collapseGrid(Direction moveDirection) {
    /*
    Returns false if the grid was already fully collapsed.
    */
    int[][] previousGrid = copyGridInternal();
    for (int layer = 0; layer < gridSize; layer++) {
      ArrayList<Integer> layerSlice = getLayerSlice(moveDirection, layer);
      ArrayList<Integer> newLayerSlice = collapseLayers(layerSlice);
      writeLayerSlice(moveDirection, layer, newLayerSlice);
    }
    
    return !gridEquals(previousGrid);
  }
  
  public Coordinate spawnRandomTile(Direction wallSide) {
    /*
    Places a tile (value 2) in a random location as close to the specified wall as possible.
    Returns the Coordinate of the tile, or null if it couldn't be placed.
    */
    
    // March in from wallSide, if open tile(s) at layer, randomly choose from them in that layer.
    // If no more layers, return null.
    Coordinate tileLocation = null;
    for (int layer = 0; layer < gridSize; layer++) {
      ArrayList<Integer> freeCellIndices = getFreeCellIndices(wallSide, layer);
      if (freeCellIndices.size() != 0) {
        int indexToFill = freeCellIndices.get(ThreadLocalRandom.current().nextInt(0, freeCellIndices.size()));
        tileLocation = spawnTile(wallSide, layer, indexToFill);
        break;
      }
    }
    
    return tileLocation;
  }
  
  private int[][] copyGridInternal() {
    int[][] newGrid = new int[gridSize][];
    for (int row = 0; row < gridSize; row++) {
      newGrid[row] = new int[gridSize];
      
      for (int col = 0; col < gridSize; col++) {
        newGrid[row][col] = grid[row][col];
      }
    }
    
    return newGrid;
  }
  
  private ArrayList<Integer> collapseLayers(ArrayList<Integer> layerSlice) {
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
  
  private ArrayList<Integer> getLayerSlice(Direction moveDirection, int layer) {
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
  
  private void writeLayerSlice(Direction moveDirection, int layer, ArrayList<Integer> slice) {
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
  
  private ArrayList<Integer> getFreeCellIndices(Direction wallSide, int layer) {
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
  
  private Coordinate spawnTile(Direction wallSide, int layer, int indexToFill) {
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
    return new Coordinate(row, col);
  }
}
