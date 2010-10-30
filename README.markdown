MacFlip
=======

An applet that rotates a MacBook or Modbook display to match the orientation with which it is held.

Description
-----------
When launched, this Applescript applet automatically rotates an Apple notebook display to match the orientation at which the notebook is held. It is designed with the [Axiotron Modbook][] (a modification of an Apple MacBook) in mind, but works with an ordinary MacBook as well. Note, however, some MacBook/Modbooks, namely those using Intel integrated graphics, do not properly support 90º and 270º orientations. This applet will work with such notebooks, but the 90º and 270º orientations will have limited usability. The applet, however, works great on MacBooks with NVIDIA graphics chip sets. It is also likely that it works well on all MacBook Pro notebooks. 

Requirements
------------
An Apple MacBook or Axiotron Modbook running either Leopard or Snow Leopard. (Tested on OSX 10.5.8 & OSX 10.6.4)

Installation
------------
After pulling or downloading the branch from GitHub, running the  AppleScript `AScompile.scpt` will compile the `MacFlip.scpt`, its associated utilities, and arrange any other needed resources into a working applet: `MacFlip.app`.

Usage
-----
The use is straightforward. The orientation of the display is rotated to match the users orientation of the notebook. There are, however, a few refinements: 

1) Turn the notebook over with display/base facing down for a count of two, and the app pauses --- effectively freezing the display in its present orientation.
2) Turn the notebook over again for a count of two to reactivate the app --- allowing the display to rotate in response to tilting the notebook again.
3) Turn the notebook over for a count of five to quit the app entirely. Clicking on the dock icon and selecting Quit from The MacFlip menu will also quit the app. 

In addition, to make it more convenient to pause and restart MacFlip, the download now includes a Scripts folder containing "ToggleMacFlip.scpt", which toggles MacFlip between the paused and active state. It only works when MacFlip is running. If you are using Snow Leopard, you could use Automator to put this script in the Services Menu and attach a keyboard shortcut to it (see http://modbookish.ning.com/profiles/blogs/tutorial-creating-your-own). Alternatively, you could use Quicksilver, Butler or Launchbar to attach it to an Abracadabra gesture, keystroke, or menu item(see http://modbookish.ning.com/profiles/blogs/pen-gestures-on-the-modbook). Note that this script only works with versions of MacFlip updated on or after March 15, 2010.

Use With a Macbook
------------------
As the app has no way to be certain of whether it is running on a MacBook or a Modbook, it assumes that it is working on a Modbook. Hence the display rotations are based on orientations of the notebook base. On a MacBook, you may want display orientation based on screen orientation. There is an initial dialog box that allows you to make that choice. If that is chosen, the script assumes that the screen is propped up at a 60º angle, and the display rotations are adjusted accordingly.

When I use MacFlip with a MacBook, I prefer to leave it in the "modbook" mode since that mode allows me to easily adjust my display orientation by briefly tilting the notebook base in the appropriate direction.

Calibration of the Sudden Motion Sensor
---------------------------------------
In order to calculate the orientation of your notebook MacFlip uses data from your notebook's sudden motion sensor (SMS). Not-uncommonly, a notebook's  SMS is poorly calibrated, that is, has an unconventional notion of which way is down. This, of course, can affect the functioning of this MacFlip. If you feel that MacFlip is rotating the display at inappropriate orientations, consider calibrating your notebook's SMS. Daniel Griscom's free application, SeisMaCalibrate, makes calibrating your SMS a simple, five minute process. SeisMaCalibrate is available at:

[http://www.suitable.com/tools/seismacalibrate.html][seismacalibrate]

Credits and Licenses
--------------------
The MacFlip script was written by Eric Nitardy (©2010). It is available for download from [Modbookish][] and may be modified and redistributed in accordance with the `License.txt` file.

The script uses the Unix utility smsutil and library smslib written by Daniel Griscom (©2007-2010). Please read the accompanying `smsutilCREDITS.txt` and `smsutilLICENSE.txt` file in the Resources folder for more information or visit his web site at [http://www.suitable.com][suitable]

The original code for fb-rotate comes from a programming example in
the book **Mac OS X Internals: A Systems Approach** by Amit Singh (© 2006). Usage info can be found in the `fb-rotateREADME.txt` file. The source is made available under the GNU General Public License (GPL). For more information, see the book's associated web site: [http://osxbook.com][osxbook]. Changes in the [code][fb-rotate rotate only] were made by [Eric Nitardy][ericn] (© 2010) and have to be made available under the same license. 



[Axiotron Modbook]: http://www.axiotron.com/index.php?id=modbook
[seismacalibrate]: http://www.suitable.com/tools/seismacalibrate.html
[Modbookish]: http://modbookish.lefora.com/2010/04/21/macflip-a-free-accelerometer-based-display-rotatio-3/
[suitable]: http://www.suitable.com
[osxbook]: http://osxbook.com]
[fb-rotate rotate only]: http://github.com/CdLbB/fb-rotate/tree/RotateOnly
[ericn]: http://modbookish.lefora.com/members/ericn/