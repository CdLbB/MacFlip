----------------------------------------------------------------------------------------------------------------
-- This script was designed to compile "KeyboardAutoHide.scpt" and move any resources needed for the compiled applet to the "Resources" folder compiling them if required.
----------------------------------------------------------------------------------------------------------------

property scriptName : "MacFlip"

--- determine where we are ---
tell application "Finder"
	set theFolder to (folder of (path to me))
	set theResources to (folder "Resources" of theFolder)
end tell

set theFolderP to POSIX path of (theFolder as alias)
set theResourcesP to POSIX path of (theResources as alias)

--- main AppleScript Compiling ---
set theScriptIn to theFolderP & scriptName & ".scpt"
set theScriptOut to theFolderP & scriptName & ".app"
do shell script "osacompile -o " & quoted form of theScriptOut & " -s " & quoted form of theScriptIn

--- determine where the app's Resources are ---
set appResources to ((theFolder as alias) as string) & scriptName & ".app:Contents:Resources:"
set appResourcesP to POSIX path of (appResources as alias)

tell application "Finder"
	repeat with f in theResources
		set nameF to name of f
		set extNameF to (items -2 thru -1 of nameF) as string
		
		--- C-code compiling some items ---
		if extNameF is ".c" then
			set nameFshort to (items 1 thru -3 of nameF) as string
			set theCodeIn to theResourcesP & nameF
			set theCodeOut to appResourcesP & nameFshort
			
			do shell script "gcc -w -O3 -o " & quoted form of theCodeOut & " " & quoted form of theCodeIn & "  -framework IOKit -framework ApplicationServices -framework Foundation"
			
			--- other items are just copied ---		
		else if extNameF is ".m" then
			-- Compile "smsutil.m" later since it needs a library
		else if extNameF is ".h" then
			-- Do nothing
		else
			duplicate f to folder appResources with replacing
		end if
		
		-- Compile "smsutil.m" with library "smslib.m"
		set theCodeIn to theResourcesP & "smsutil.m"
		set theCodeInLib to theResourcesP & "smslib.m"
		set theCodeOut to appResourcesP & "smsutil"
		do shell script "gcc  -O3 " & quoted form of theCodeInLib & " " & quoted form of theCodeIn & " -o " & quoted form of theCodeOut & " -framework IOKit -framework ApplicationServices -framework Foundation"
	end repeat
end tell