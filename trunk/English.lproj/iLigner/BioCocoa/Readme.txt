Dear developer,

The BioCocoa project is still very much under construction. It consists of two major parts that are - at least for now - two separate code bases. 

First of all, there is BioCocoa 1.x which contains classes for sequence I/O, fetching sequences from Entrez and displaying them. This 1.x version of the framework represents sequences as strings. The latest stable release of BioCocoa 1.x is version 1.7, which can be found in the tags/1.7 folder (see below).

At the same time, we are working on a completely new framework structure that will consist of BCFoundation and BCAppKit. BCFoundation will introduce new classes, such as BCSequence, which will form the basis for the rest of the framework. You can view the current state of this new framework in the Trunk folder. 

All functionality that is now in BioCocoa 1.7 will be moved to this new structure. If you need this functionality right now, however, we recommend to use the string-based 1.7 version.

Peter Schols for the BioCocoa team



BioCocoa 1.7 -- (found in Tags / 1.7)

This new update of the classic BioCocoa code contains the following new features:

- BCReader, the standalone BCReader classes for sequence file IO (original version Peter Schols)
- EntrezController, a controller plus view for browsing and fetching NCBI's Entrez Database
- BCSequenceView+, a custom NSTextView for displaying biological sequences (original version Koen van der Drift)



BioCocoa 1.6 -- (found in Tags / 1.6)

This folder contains:
- the ProjectBuilder project of the SequenceConverter utility application (BioCocoa util.pbproj), which can be opened in ProjectBuilder on Mac OS X or in the GNUstep ProjectCenter on Linux/Windows (see www.gnustep.org)
- the compiled utility application SequenceConverter, ready to run on Mac OS X 10.2 or higher
- the ProjectBuilder project of the BioCocoa framework (BioCocoa Framework), which can be opened in ProjectBuilder on Mac OS X or in the GNUstep ProjectCenter on Linux/Windows (see www.gnustep.org)
- the compiled BioCocoa framework (BioCocoa.framework), which can be opened in ProjectBuilder on Mac OS X or in the GNUstep ProjectCenter on Linux/Windows (see www.gnustep.org)
- the GNU GPL

If you are not a developer and you are only interested in the SequenceConverter utility application (to convert between sequence file formats), you can remove everything in this package except for the SequenceConverter application itself.


Changes since version 1.2:
- BC now reads SwissProt, NCBI, and PDB files
- To be consistent when reading all filetypes, 'taxon' and 'taxa' were changed to 'item' and 'items' respectively in BCReader. BCCreator still uses 'taxon' and 'taxa'.
- Added a 'fileType' key-value

Changes since version 1.1:
- BC now reads and writes the GCG-MSF format
- Added Unix and Windows line break methods for cross-platform compatibility
- BC now recognizes the Trees Nexus block and stores all Newick strings in the root dictionary
- BC returns all Nexus blocks in the root dictionary
- BC now stores the line break of the original source file in the root dictionary

For more information on how to use BioCocoa in your own app, see the API docs at: http://www.bioinformatics.org/BioCocoa/docs and the header files in the framework.


Project homepage: http://www.bioinformatics.org/BioCocoa
e-mail: peter.schols@bio.kuleuven.ac.be
