/*

File: Grid.m

Abstract: Abstract superclass of regular geometric grids of GridCells that Bits can be placed on.

Version: 1.0

*/


#import "Grid.h"
#import "Bit.h"
#import "QuartzUtils.h"


@implementation Grid


- (id) initWithRows: (unsigned)nRows columns: (unsigned)nColumns
            spacing: (CGSize)spacing
           position: (CGPoint)pos
{
    NSParameterAssert(nRows>0 && nColumns>0);
    self = [super init];
    if( self ) {
        _nRows = nRows;
        _nColumns = nColumns;
        _spacing = spacing;
        _cellClass = [GridCell class];
        _lineColor = kBlackColor;

        self.bounds = CGRectMake(-1, -1, nColumns*spacing.width+2, nRows*spacing.height+2);
        self.position = pos;
        self.anchorPoint = CGPointMake(0,0);
        self.zPosition = kBoardZ;
        self.needsDisplayOnBoundsChange = YES;
        
        unsigned n = nRows*nColumns;
        _cells = [NSMutableArray arrayWithCapacity: n];
        id null = [NSNull null];
        while( n-- > 0 )
            [_cells addObject: null];

        [self setNeedsDisplay];
    }
    return self;
}


- (id) initWithRows: (unsigned)nRows columns: (unsigned)nColumns
              frame: (CGRect)frame
{
    CGFloat spacing = 16.0;
    return [self initWithRows: nRows columns: nColumns
                      spacing: CGSizeMake(spacing,spacing)
                     position: frame.origin];
}


static void setcolor( CGColorRef *var, CGColorRef color )
{
    if( color != *var ) {
        // Garbage collection does not apply to CF objects like CGColors!
        CGColorRelease(*var);
        *var = CGColorRetain(color);
    }
}

- (CGColorRef) cellColor                        {return _cellColor;}
- (void) setCellColor: (CGColorRef)cellColor    {setcolor(&_cellColor,cellColor);}

- (CGColorRef) lineColor                        {return _lineColor;}
- (void) setLineColor: (CGColorRef)lineColor    {setcolor(&_lineColor,lineColor);}

@synthesize cellClass=_cellClass, rows=_nRows, columns=_nColumns, spacing=_spacing;


#pragma mark -
#pragma mark GEOMETRY:


- (GridCell*) cellAtRow: (unsigned)row column: (unsigned)col
{
    if( row < _nRows && col < _nColumns ) {
        id cell = [_cells objectAtIndex: row*_nColumns+col];
        if( cell != [NSNull null] )
            return cell;
    }
    return nil;
}


/** Subclasses can override this, to change the cell's class or frame. */
- (GridCell*) createCellAtRow: (unsigned)row column: (unsigned)col 
               suggestedFrame: (CGRect)frame
{
    return [[_cellClass alloc] initWithGrid: self 
                                        row: row column: col
                                      frame: frame];
}


- (GridCell*) addCellAtRow: (unsigned)row column: (unsigned)col
{
    NSParameterAssert(row<_nRows);
    NSParameterAssert(col<_nColumns);
    unsigned index = row*_nColumns+col;
    GridCell *cell = [_cells objectAtIndex: index];
    if( (id)cell == [NSNull null] ) {
        CGRect frame = CGRectMake(col*_spacing.width, row*_spacing.height,
                                  _spacing.width,_spacing.height);
        cell = [self createCellAtRow: row column: col suggestedFrame: frame];
        if( cell ) {
            [_cells replaceObjectAtIndex: index withObject: cell];
            [self addSublayer: cell];
            [self setNeedsDisplay];
        }
    }
    return cell;
}


- (void) addAllCells
{
    for( int row=_nRows-1; row>=0; row-- )                // makes 'upper' cells be in 'back'
        for( int col=0; col<_nColumns; col++ ) 
            [self addCellAtRow: row column: col];
}


- (void) removeCellAtRow: (unsigned)row column: (unsigned)col
{
    NSParameterAssert(row<_nRows);
    NSParameterAssert(col<_nColumns);
    unsigned index = row*_nColumns+col;
    id cell = [_cells objectAtIndex: index];
    if( cell != [NSNull null] )
        [cell removeFromSuperlayer];
    [_cells replaceObjectAtIndex: index withObject: [NSNull null]];
    [self setNeedsDisplay];
}


#pragma mark -
#pragma mark DRAWING:


- (void) drawCellsInContext: (CGContextRef)ctx fill: (BOOL)fill
{
    // Subroutine of -drawInContext:. Draws all the cells, with or without a fill.
    for( unsigned row=0; row<_nRows; row++ )
        for( unsigned col=0; col<_nColumns; col++ ) {
            GridCell *cell = [self cellAtRow: row column: col];
            if( cell )
                [cell drawInParentContext: ctx fill: fill];
        }
}


- (void)drawInContext:(CGContextRef)ctx
{
    // Custom CALayer drawing implementation. Delegates to the cells to draw themselves
    // in me; this is more efficient than having each cell have its own drawing.
    if( _cellColor ) {
        CGContextSetFillColorWithColor(ctx, _cellColor);
        [self drawCellsInContext: ctx fill: YES];
    }
    if( _lineColor ) {
        CGContextSetStrokeColorWithColor(ctx,_lineColor);
        [self drawCellsInContext:ctx fill: NO];
    }
}


@end



#pragma mark -

@implementation GridCell


- (id) initWithGrid: (Grid*)grid 
                row: (unsigned)row column: (unsigned)col
              frame: (CGRect)frame
{
    self = [super init];
    if (self != nil) {
        _grid = grid;
        _row = row;
        _column = col;
        self.position = frame.origin;
        CGRect bounds = frame;
        bounds.origin.x -= floor(bounds.origin.x);  // make sure my coords fall on pixel boundaries
        bounds.origin.y -= floor(bounds.origin.y);
        self.bounds = bounds;
        self.anchorPoint = CGPointMake(0,0);
        self.borderColor = kHighlightColor;         // Used when highlighting (see -setHighlighted:)
    }
    return self;
}

- (NSString*) description
{
    return [NSString stringWithFormat: @"%@(%u,%u)", [self class],_column,_row];
}

@synthesize grid=_grid, row=_row, column=_column;


- (void) drawInParentContext: (CGContextRef)ctx fill: (BOOL)fill
{
    // Default implementation just fills or outlines the cell.
    CGRect frame = self.frame;
    if( fill )
        CGContextFillRect(ctx,frame);
    else
        CGContextStrokeRect(ctx, frame);
}


- (void) setBit: (Bit*)bit
{
    if( bit != self.bit ) {
        [super setBit: bit];
        if( bit ) {
            // Center it:
            CGSize size = self.bounds.size;
            bit.position = CGPointMake(floor(size.width/2.0),
                                       floor(size.height/2.0));
        }
    }
}

- (Bit*) canDragBit: (Bit*)bit
{
    if( bit==self.bit )
        return [super canDragBit: bit];
    else
        return nil;
}

- (BOOL) canDropBit: (Bit*)bit atPoint: (CGPoint)point
{
    return self.bit == nil;
}


//- (NSArray*) neighbors
//{
//    NSMutableArray *neighbors = [NSMutableArray arrayWithCapacity: 8];
//    for( int dy=-1; dy<=1; dy++ )
//        for( int dx=-1; dx<=1; dx++ )
//            if( (dx || dy) && !(orthogonal && dx && dy) ) {
//                GridCell *cell = [_grid cellAtRow: _row+dy column: _column+dx];
//                if( cell )
//                    [neighbors addObject: cell];
//            }
//    return neighbors;
//}


#pragma mark -
#pragma mark DRAG-AND-DROP:


// An image from another app can be dragged onto a Dispenser to change the Piece's appearance.


- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSPasteboard *pb = [sender draggingPasteboard];
    if( [NSImage canInitWithPasteboard: pb] )
        return NSDragOperationCopy;
    else
        return NSDragOperationNone;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    CGImageRef image = GetCGImageFromPasteboard([sender draggingPasteboard]);
    if( image ) {
        _grid.cellColor = CreatePatternColor(image);
        [_grid setNeedsDisplay];
        return YES;
    } else
        return NO;
}

- (void) setHighlighted: (BOOL)highlighted
{
    [super setHighlighted: highlighted];
    self.borderWidth = (highlighted ?6 :0);
}


//- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
//{
//    CGImageRef image = GetCGImageFromPasteboard([sender draggingPasteboard]);
//    if( image ) {
//        CGColorRef color = CreatePatternColor(image);
//        RectGrid *rectGrid = (RectGrid*)_grid;
//        if( rectGrid.altCellColor && ((_row+_column) & 1) )
//            rectGrid.altCellColor = color;
//        else
//            rectGrid.cellColor = color;
//        [rectGrid setNeedsDisplay];
//        return YES;
//    } else
//        return NO;
//}

@end


#pragma mark -

@implementation RectGrid


- (id) initWithRows: (unsigned)nRows columns: (unsigned)nColumns
            spacing: (CGSize)spacing
           position: (CGPoint)pos
{
    self = [super initWithRows: nRows columns: nColumns spacing: spacing position: pos];
    if( self ) {
		
	}
    return self;
}


- (CGColorRef) altCellColor                         {return _altCellColor;}
- (void) setAltCellColor: (CGColorRef)altCellColor  {setcolor(&_altCellColor,altCellColor);}


@end


