-------------------------------------------------------------------
--"ToggleMacFlip.scpt" toggles MacFlip between the paused and active state. It only works when MacFlip is running. If you are using Snow Leopard, you could use Automator to put this script in the Services Menu and attach a keyboard shortcut to it (See http://modbookish.ning.com/profiles/blogs/tutorial-creating-your-own). Note that this script only works with versions of MacFlip updated on or after March 15, 2010. 
-------------------------------------------------------------------

tell application "System Events"
	get every process whose name is "MacFlip"
end tell
if result is not {} then
	try
		Toggle() of application "MacFlip"
	end try
end if
