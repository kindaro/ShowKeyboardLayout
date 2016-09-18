Show Keyboard Layout
====================

Introduction:
-------------

This simplish Linux X window system Haskell command line script will let you know what layout your
keyboard is set to.

It uses xset & setxkbmap to gather the facts, and some glue to isolate the layout information from
their rather wordy output.

Recipes:
--------

You can compile the script with a simple `ghc ...` if you wish it be slimmer and faster in
runtime.

Put this: `${execp ~/bin/ShowKeyboardLayout.hs}` -- in your `.conkyrc` to continuously observe
your keyboard layout.
