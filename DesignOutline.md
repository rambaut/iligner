# Model-View-Controller (MVC) #

## View objects ##

A series of GUI components to draw aspects of the alignment.
  1. The first and most important is an AlignmentView which draws the actual alignment. This can display nucleotides or amino acids (or both), colour them, handle selections and insertion points, and animate drag-slide editing. On this last point, when I implemented this in Se-Al, when sliding of blocks of alignment I simply rendered a representation of this on the screen (using image blitting) rather than constantly manipulating the alignment. Only when the mouse button was released did the actual edit occur. I suggest we need plug-in painters that can provide foreground & background colours for given states (possibly even font formats) and also for particular sites (so you can colour by some variable such as alignment quality).
  1. Next is the taxon label list. I suggest this can be done using an NSOutlineView (a finder-lik tree). This will allow nested sequences. If we wish to add any extras we can add custom cell renderers.
  1. Then we need a site ruler for the top of the alignment. A simple custom view would OK for now.

## Model objects ##

These would store the actual data. This would be a transaction-type database (i.e., edits are stored as changes to the data and can be undone/redone). It would handle reading and writing to/from files. Import/Export format plugins would convert data to/from other formats.

We should consider using CoreData for this bit:

  * http://developer.apple.com/macosx/coredata.html
  * http://developer.apple.com/documentation/Cocoa/Conceptual/CoreData/index.html

This handles most of the above automatically. I don't see the need to use a library like BioCocoa to store our sequences/alignments internally as they are unlikely to meet our particular needs. We could use BioCocoa to quickly implement some import/export formats. CoreData can make files from the data in XML or Binary formats. It also handles the Undo/Redo automatically.

We should aim to create a self-contained alignment engine that knows nothing about user-interface.

## Controller objects ##

These create the connection between the View and the Model. All such connections must go through the controllers. What I envisage here is that the controller creates and caches buffers of state indices which are used by the Views. When the user does an edit, the controller passes it on to the Model and then rebuilds the buffers and tells the Views to update. Other things like copy/paste are handled here.
