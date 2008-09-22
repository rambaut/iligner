/*

File: Grid.h

Abstract: Abstract superclass of regular geometric grids of GridCells that Bits can be placed on.

*/


#import "BitHolder.h"
@class GridCell;


/** Abstract superclass of regular geometric grids of GridCells that Bits can be placed on. */
@interface Grid : CALayer
{
    unsigned _nRows, _nColumns;                         
    CGSize _spacing;                                    
    Class _cellClass;                                   
    CGColorRef _cellColor, _lineColor;                  
    NSMutableArray *_cells;                             // Really a 2D array, in row-major order.
}

/** Initializes a new Grid with the given dimensions and cell size, and position in superview.
    Note that a new Grid has no cells! Either call -addAllCells, or -addCellAtRow:column:. */
- (id) initWithRows: (unsigned)nRows columns: (unsigned)nColumns
            spacing: (CGSize)spacing
           position: (CGPoint)pos;

/** Initializes a new Grid with the given dimensions and frame in superview.
    The cell size will be computed by dividing frame size by dimensions.
    Note that a new Grid has no cells! Either call -addAllCells, or -addCellAtRow:column:. */
- (id) initWithRows: (unsigned)nRows columns: (unsigned)nColumns
              frame: (CGRect)frame;

@property Class cellClass;                      // What kind of GridCells to create
@property (readonly) unsigned rows, columns;    // Dimensions of the grid
@property (readonly) CGSize spacing;            // x,y spacing of GridCells
@property CGColorRef cellColor, lineColor;      // Cell background color, line color (or nil)

/** Returns the GridCell at the given coordinates, or nil if there is no cell there.
    It's OK to call this with off-the-board coordinates; it will just return nil.*/
- (GridCell*) cellAtRow: (unsigned)row column: (unsigned)col;

/** Adds cells at all coordinates, creating a complete grid. */
- (void) addAllCells;

/** Adds a GridCell at the given coordinates. */
- (GridCell*) addCellAtRow: (unsigned)row column: (unsigned)col;

/** Removes a particular cell, leaving a blank space. */
- (void) removeCellAtRow: (unsigned)row column: (unsigned)col;


// protected:
- (GridCell*) createCellAtRow: (unsigned)row column: (unsigned)col 
               suggestedFrame: (CGRect)frame;

@end


/** Abstract superclass of a single cell in a grid. */
@interface GridCell : BitHolder
{
    Grid *_grid;
    unsigned _row, _column;
}

- (id) initWithGrid: (Grid*)grid 
                row: (unsigned)row column: (unsigned)col
              frame: (CGRect)frame;

@property (readonly) Grid* grid;
@property (readonly) unsigned row, column;
//@property (readonly) NSArray* neighbors;        // Dependent on grid.usesDiagonals

// protected:
- (void) drawInParentContext: (CGContextRef)ctx fill: (BOOL)fill;
@end


/** A rectangular grid of squares. */
@interface RectGrid : Grid
{
    CGColorRef _altCellColor;
}

/** If non-nil, alternate cells will be drawn with this background color, in a checkerboard pattern.
    The precise rule is that cells whose row+column is odd use the altCellColor.*/
@property CGColorRef altCellColor;

@end

