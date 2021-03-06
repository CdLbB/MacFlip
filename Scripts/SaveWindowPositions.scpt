-------------------------------------------------------------------
-- Mac Flip can remember the positions of your application windows when you rotate out of a particular display orientation, so that, when you return, the windows will be where you left them. "SaveWindowPositions.scpt" activates and de-activates this ability. The script only works when MacFlip is running. If you are using Snow Leopard, you could use Automator to put this script in the Services Menu and attach a keyboard shortcut to it(See http://modbookish.ning.com/profiles/blogs/tutorial-creating-your-own). Note that this functionality may not work with all application windows, and only works in versions of MacFlip updated on or after March 25, 2010. 
-------------------------------------------------------------------

tell application "System Events"
	get every process whose name is "MacFlip"
end tell
if result is not {} then
	try
		SaveWinToggle() of application "MacFlip"
	end try
end if