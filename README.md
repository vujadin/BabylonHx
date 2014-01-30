BabylonHx
=========

BabylonHx is a direct port of BabylonJs engine to Haxe/OpenFL. 
It supports (almost) all features of the original.

<i>Not supported features:</i>

<ul>
  <li>Video textures</li>
  <li>Image flipping (images have to be flipped by 'hand')</li>
  <li>Incremental loading (because of OpenFL and its way of handling assets)</li>
  <li>Support for drag'n'drop</li>
  <li>Physics</li>
</ul>

And probably a few more things ...

Visit http://babylonjs.com/ for more info about the engine.

<b>Known bugs (major ones):</b>
<ul>
  <li>There is a bug with lights, most noticable in 'Train' and 'Heart' demos.</li>
  <li>Bug in 'Train' scene (particles and camera attached to train don't work</li>
</ul>

<b>TODO list</b>
<ul>
  <li>Fix bug with lights</li>
  <li>Update 'Matrix' class to use Float32Array for JavaScript target</li>
  <li>Code refactor - remove reflections from critical places and general code cleanup</li>
  <li>Keep up with BabylonJs (implement all stuff that was added/fixed between versions 1.8.0 and 1.8.5)</li>
</ul>

