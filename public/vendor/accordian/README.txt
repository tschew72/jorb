A Pen created at CodePen.io. You can find this one at http://codepen.io/chriswrightdesign/pen/cmanI.

 I wanted to make a nice animated accordion that didn't rely on jQuery and used a definition list. 
This relies on javascript for the interactions (using the classie helpers) but uses CSS for all of the animations.

There are some magic numbers in here - as I was animating max height to achieve the accordion effect.

This is best viewed in full mode - seems to flicker a little in codepen's editor mode. Technically, it's responsive - but on a small device this toggle could be potentially horrible if there is a lot of content in there.

Issues: Magic number on max-height anim, noticed the + rotation on safari needs a set origin or else its motion wonky and not circular.