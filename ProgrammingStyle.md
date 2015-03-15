Apple has a good document about Cocoa programming style:

http://developer.apple.com/documentation/Cocoa/Conceptual/CodingGuidelines/index.html

I think we should stick to it.

  * Use fully verbose identifiers (both methods and variables). The exception being local iterator variables (such as i, j etc)
  * Class names should have a two letter name-space identifier. I suggest 'IL' as in ILAlignmentView. We should possibly consider the data core to be a sub-entity which we may wish to use in other contexts. So we could give these a different prefix (this also helps segregate the parts of the program).