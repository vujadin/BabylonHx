BabylonHx
=========

BabylonHx is a direct port of BabylonJs engine to Haxe/OpenFL. 
It supports (almost) all features of the original.

**IMPORTANT:** Use this settings in your application.xml file for mobile targets to work (thanks @labe-me):<br/>
***&lt;window require-shaders="true" hardware="true" depth-buffer="true" /&gt;***

*Not supported features:*


  * Video textures
  * Image flipping (images have to be flipped by 'hand')
  * Incremental loading (because of OpenFL and its way of handling assets)
  * Support for drag'n'drop
  * Physics


And probably a few more things ...

Visit http://babylonjs.com/ for more info about the engine.

**Known bugs (major ones):**

  * There is a bug with lights, most noticable in 'Train' and 'Heart' demos.
  * Mesh.clone() doesn't work (Tools.deepCopy() should be fixed)
  * Bug in 'Train' scene (particles and camera attached to train don't work


**TODO:**

  * Fix bug with lights
  * ~~Update 'Matrix' class to use Float32Array for JavaScript target~~
  * Code refactor - remove reflections from critical places and general code cleanup
  * Keep up with BabylonJs (implement all stuff that was added/fixed between versions 1.8.0 and 1.8.5)


