# Introduction #

The objective of the iLigner code project is to develop a manual/semi-automated sequence alignment editor for Mac OS X with a rich feature set and a snappy intuitive interface.


# Details #

  1. Adopt `iApps' GUI conventions to match overall
  1. Alignments are like iTunes `playlists', displayed on the left-hand side in which multiple alignments can be stored for the same set of sequences.  Alignments are compactly stored as lists of indels and don't edit the sequences themselves.
  1. Plug-ins for automated alignment and database seasrching.
  1. Graphical display at base of window that can display various site-specific statistics, e.g. Shannon entropy.
  1. Drag-and-drop interface so that files on the desktop that contain sequences in any format (e.g. Genbank) can be dragged into the iLigner window and incorporated into the sequence set.  Automated alignment of sequences that are dropped into window.
  1. Ability to create sequence folders that contain a subset of sequences, which can be collapsed so that the sequences within are represented by a consensus.  Alignment applied to the consensus sequence are propagated to all sequences in folder.
  1. Simultaneous visualization of codons and translated amino acids, using Quartz transparency.
  1. Allow user to `lock' sections of the alignment, e.g. when aligning HIV env, lock conserved `C' regions.  Similar to sequence folders, but grouping by site.
  1. Optional display of summary statistics on sequences, e.g. indel content, pairwise sequence identity to a reference sequence.
  1. Allow minor sequence edits inline, i.e. to resolve sequencing errors and ambiguities.
  1. All accessory panels are collapsable/hide-able.
  1. Multiple (unlimited?) undos.
  1. Several semi-automated alignment tools; perturbation-based (sliding) alignment optimization; seleet rectangular region for local alignment (heuristic improvement).  Drag-and-drop automated alignment, new sequence adopts gaps of current set of sequences.
  1. Fast clean panoramic view of alignment, zoom out and click on region to zoom back in when working with extremely large alignments.  Click and drag alignment to traverse.


