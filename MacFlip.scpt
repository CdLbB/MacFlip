-----------------------------------------------------------------------------------------------------------------
-- The MacFlip script was written by Eric Nitardy (c)2010. It is available for download from Modbookish and may be modified and redistributed in accordance with the `License.txt` file.

-- The script uses the Unix utility smsutil and library smslib written by Daniel Griscom (c)2007-2010. Please read the accompanying `smsutilCREDITS.txt` and `smsutilLICENSE.txt` file in the Resources folder for more information or visit his web site at http://www.suitable.com

-- The original code for fb-rotate comes from a programming example in the book **Mac OS X Internals: A Systems Approach** by Amit Singh (c) 2006. Usage info can be found in the `fb-rotateREADME.txt` file. The source is made available under the GNU General Public License (GPL). For more information, see the book's associated web site: http://osxbook.com. Changes in the code were made by Eric Nitardy (c)2010 and have to be made available under the same license. 
-----------------------------------------------------------------------------------------------------------------


global smsutilPath, fbRotatePath, displayID, orientCheckDelay, sinIgnore, sinFlip, cosFlip, systemInfo, notebookOrient, displayOrient, rotateFastFlag, pauseMacFlip, iconPath, iconPathDim, winPositions, lastOrient

property typeComputer : "unknown" -- Is the computer a "macbook" or "modbook"?

property displayWidth : 32.5 -- Display width in centimeters.
property displayHeight : 22.7 -- Display height in centimeters.

property cosMacAdjust : 0.5 -- cosine of apx. angle of a MacBook screen tilt (60 degrees).
property sinMacAdjust : 0.8660254 -- sine of apx. angle of a MacBook screen tilt (60 degrees). ----
property saveWinPos : false

--------------------------------------------------------------------
------- "on run" initializes the main global variables -------
--------------------------------------------------------------------
on run
	
	
	set orientCheckDelay to 1.0 -- Number of seconds between each time the script updates the computer's orientation.
	
	set displayDiagonal to (displayWidth ^ 2 + displayHeight ^ 2) ^ 0.5
	set sinIgnore to 0.25 -- sine of angle off flat before script considers rotating the display (~15 degrees).
	
	----------- Calculate sine and cosine of Flip Angle -----------
	set sinFlip to displayHeight / displayDiagonal
	set cosFlip to displayWidth / displayDiagonal
	
	------ Paths to various files in /Contents/Resources/ ------
	set smsutilPath to quoted form of (POSIX path of (path to resource "smsutil"))
	set fbRotatePath to quoted form of (POSIX path of (path to resource "fb-rotate"))
	set iconPath to path to resource "applet.icns"
	set iconPathDim to path to resource "macflipDuckDim.icns"
	
	set displayOrient to 0
	set displayOrient to getDisplayOrient() -- Orientation of display 
	set notebookOrient to 0 -- Orientation of notebook
	set pauseMacFlip to false -- flag indicates whether Macflip is paused
	set winPositions to {{}, {}, {}, {}}
	set lastOrient to {displayOrient, displayOrient, displayOrient}
	
	set internalDisplay to do shell script fbRotatePath & " -i | /usr/bin/grep 'internal'"
	set displayID to (items 4 thru 13 of internalDisplay) as text
	
	
	--------- Determine Model ID and Graphics Chip for System ---------
	set systemInfo to systemsInfo()
	
	(*
	if (offset of "NVIDIA" in (item 2 of systemInfo)) = 0 and (offset of "Pro" in (item 1 of systemInfo)) = 0 then
		set rotateFastFlag to false
	else
		set rotateFastFlag to true -- flag indicates whether display rotates quickly
	end if
	*)
	
	
	--= Determine notebook type (MacBook or Modbook) ---
	------- and decide on MacFlip's rotation behavior --------
	--display alert "'" & (item 3 of systemInfo) & "'   '" & typeComputer & "'"
	if typeComputer is "unknown" then
		if (item 3 of systemInfo) is "Color LCD" then
			set typeComputer to "macbook"
		else
			set typeComputer to "modbook"
		end if
	end if
	if typeComputer is "macbook" or typeComputer is "macbook as modbook" then
		tell application "System Events"
			activate
			display alert "Your notebook appears to be a MacBook, not a Modbook." message "You have options for how MacFlip will function:" & return & "    ¥ Modbook functionality Ñ Rotate the display based on the orientation of the notebook's base." & return & "    ¥ MacBook functionality Ñ Rotate the display based on the orientation of the notebook's screen," & return & "       which is assumed to be tilted up at an angle of 60¼." buttons {"This is a Modbook!", "MacBook functionality", "Modbook functionality"} default button 3
			
			if button returned of result is "MacBook functionality" then
				set typeComputer to "macbook"
			else if button returned of result is "This is a Modbook!" then
				set typeComputer to "modbook"
			else
				set typeComputer to "macbook as modbook"
			end if
			quit
		end tell
	end if
	
	
	(*
	------ Provide escape sequences for spaces in path of smsutil and fb-rotate ------
	set TID to text item delimiters
	set text item delimiters to " "
	set aList to every text item of (smsutilPath as text)
	set bList to every text item of (fbRotatePath as text)
	set text item delimiters to "\\ "
	set smsutilPath to aList as text
	set fbRotatePath to bList as text
	set text item delimiters to TID
	*)
	
	return
end run
---------------------------------------------------------------------------
---------------------------------------------------------------------------




---------------------------------------------------------------------------
------- "on idle" repeats every orientCheckDelay seconds -------
---------------------------------------------------------------------------
on idle
	
	
	
	set notebookOrient to getNotebookOrient()
	
	--------------------------------- Errors ---------------------------------
	---------------------------------------------------------------------------	
	if notebookOrient is -1 then
		tell application "System Events"
			activate
			display alert "SMS Utility:  smsutil  is missing" & return message "The smsutil utility is suppose to be inside the application bundle (in /Contents/Resources). Someone (probably the AppleScript Editor) may have removed it."
			quit
		end tell
		quit
		return 0.5
	else if notebookOrient is -2 then
		tell application "System Events"
			activate
			display alert "SMS Utility: SMS  is not functioning properly." & return message "Your sudden motion sensor may not be working."
			quit
		end tell
		quit
		return 0.5
		
	else if notebookOrient is -3 then ----- Error -3 is notebook upside down ----
		if pauseMacFlip is false then
			tell application "System Events"
				activate
				try
					do shell script "afplay '/System/Library/Sounds/Submarine.aiff'"
				on error
					beep 2
				end try
				display dialog ("MacFlip:" & tab & "OFF" & tab & "(paused)") buttons {"OK"} default button 1 giving up after 1 with icon iconPathDim
				quit
			end tell
			delay 0.6
			
			set notebookOrient to getNotebookOrient()
			if notebookOrient >= 0 then
				set pauseMacFlip to true
				set orientCheckDelay to 2 * orientCheckDelay
				return orientCheckDelay
			end if
		else
			try
				do shell script "afplay '/System/Library/Sounds/Blow.aiff'"
			on error
				beep
			end try
			tell application "System Events"
				activate
				display dialog ("MacFlip:" & tab & "ON" & tab & "(reactivated)") buttons {"OK"} default button 1 giving up after 1 with icon iconPath
				quit
			end tell
			
			delay 0.3
			
			set notebookOrient to getNotebookOrient()
			if notebookOrient >= 0 then
				set pauseMacFlip to false
				set orientCheckDelay to orientCheckDelay / 2
				return orientCheckDelay
			end if
		end if
		try
			do shell script "afplay '/System/Library/Sounds/Basso.aiff'"
		on error
			beep 3
		end try
		tell application "System Events"
			activate
			set alertResult to display alert "MacFlip: Quitting" buttons {"Quit & Edit", "Reset Display & Quit", "Quit"} giving up after 120 default button 2
			if button returned of result is "Quit & Edit" then
				tell application "Finder"
					open (path to me) using path to application "AppleScript Editor"
				end tell
				
			else if button returned of result is "Reset Display & Quit" then
				set notebookOrient to 0
				my ChangeDisOrient(notebookOrient)
				
			end if
			
			quit
		end tell
		quit
		return 0.5
		
	else ---------- No  Errors ----------		
		----------------------------------
		
		------------- If MacFlip is paused, skip to end of handler -------------
		--- Otherwise, set display orientation to notebook orientation ---
		if pauseMacFlip is false then
			
			set displayOrient to getDisplayOrient()
			if (notebookOrient is not equal to displayOrient) then
				-------- Log present display and notebook orientation --------	
				log {displayOrient, notebookOrient}
				
				--- set display orientation to notebook orientation ---			
				set displayOrient to ChangeDisOrient(notebookOrient)
				if displayOrient is less than 0 then
					tell application "System Events"
						delay 1.0
						activate
						display alert "Display Rotation is Not Working at the Moment." & return message "The Unix utility \"fb-rotate\" is not working or missing. The \"fb-rotate\" utility is suppose to be inside the application bundle (in /Contents/Resources). Someone (probably the AppleScript Editor) may have removed it."
						
						quit
					end tell
					
					quit
					return 0.5
				end if
			end if
		end if
		
		--- Pause for a bit before repeating ---
		return orientCheckDelay
	end if
end idle
---------------------------------------------------------------------------
---------------------------------------------------------------------------



---------------------------------------------------------------------------
----------- Determine the orientation of the notebook -----------
---------------------------------------------------------------------------
on getNotebookOrient()
	
	--------------- Get five force vectors from the SMS ---------------
	try
		set theOutput to do shell script (smsutilPath & " -i0.025  -c5")
	on error
		return -1
	end try
	
	---------- Convert the force vector text to a list -----------
	set TID to text item delimiters
	set text item delimiters to return
	set vectorList to every text item of (theOutput as text)
	set text item delimiters to space
	repeat with i from 1 to count of vectorList
		set item i of vectorList to every text item of item i of vectorList
	end repeat
	set text item delimiters to TID
	
	
	------------------- Find vector magnitudes ---------------------
	--- If vectorList not numbers, then SMS not functioning ---
	try
		set vectorMags to {}
		repeat with i from 1 to count of vectorList
			set item 1 of item i of vectorList to (item 1 of item i of vectorList) as real
			set xCoord to item 1 of item i of vectorList
			set item 2 of item i of vectorList to (item 2 of item i of vectorList) as real
			set yCoord to item 2 of item i of vectorList
			set item 3 of item i of vectorList to (item 3 of item i of vectorList) as real
			set zCoord to item 3 of item i of vectorList
			set the end of vectorMags to (xCoord ^ 2 + yCoord ^ 2 + zCoord ^ 2) ^ 0.5
		end repeat
	on error
		return -2
	end try
	
	
	--------------- Find an average vector --------------
	-------- ignoring shock-type force vectors ---------
	set avVector to {0, 0, 0}
	set m to 0
	repeat with i from 1 to count of vectorList
		if (item i of vectorMags) is greater than 0.7 and (item i of vectorMags) is less than 1.3 then
			repeat with j from 1 to 3
				set item j of avVector to (item j of avVector) + (item j of item i of vectorList) / (item i of vectorMags)
				
			end repeat
			set m to m + 1
		end if
	end repeat
	
	if m is not 0 then
		repeat with j from 1 to 3
			set item j of avVector to (item j of avVector) / m
		end repeat
		
		------- Set x,y,z coordinates ---------
		----- adjusting for odd SMS's  ------
		set xCoord to (item 1 of avVector)
		set yCoord to item 2 of avVector
		set zCoord to (item 3 of avVector)
		
		
		------- For a MacBook, set the rotation around the screen--------
		------- which is assumed to be at a set angle to the base --------
		ignoring case
			if typeComputer is "Macbook" then
				set yCoord to cosMacAdjust * yCoord + sinMacAdjust * zCoord
				set zCoord to -sinMacAdjust * yCoord + cosMacAdjust * zCoord
			end if
		end ignoring
		
		
		-------------- Calculate notebook orientation --------------
		set longMag to (xCoord ^ 2 + yCoord ^ 2) ^ 0.5
		if longMag is greater than sinIgnore then
			
			if yCoord / longMag is greater than sinFlip then
				set notebookOrient to 0
			else
				if yCoord / longMag is less than -sinFlip then
					set notebookOrient to 180
				else
					if xCoord / longMag is greater than cosFlip then
						set notebookOrient to 270
					else
						if xCoord / longMag is less than -cosFlip then
							set notebookOrient to 90
						end if
					end if
				end if
			end if
		else
			if zCoord is less than 0 then
				return -3
			end if
			-- Otherwise leave notebookOrient Unchanged --
			set notebookOrient to getDisplayOrient()
		end if
	end if
	return notebookOrient
	
end getNotebookOrient
---------------------------------------------------------------------------




---------------------------------------------------------------------------
---- Get System information: Model ID and Graphic chip set ----
---------------------------------------------------------------------------
on systemsInfo()
	set TID to text item delimiters
	set text item delimiters to ": "
	set theModel to do shell script "/usr/sbin/system_profiler SPHardwareDataType |  grep " & quoted form of "Model Identifier:"
	set theModel to text item 2 of theModel
	set theGraphics to do shell script "/usr/sbin/system_profiler SPDisplaysDataType | grep " & quoted form of "Chipset Model:"
	set theGraphics to text item 2 of theGraphics
	set theDisplay to do shell script "/usr/sbin/system_profiler SPDisplaysDataType"
	set text item delimiters to ":" & return & "          Resolution:"
	set theDisplay to text item 1 of theDisplay
	set text item delimiters to return & "        "
	set theDisplay to text item -1 of theDisplay
	set text item delimiters to TID
	
	return {theModel, theGraphics, theDisplay}
end systemsInfo


--------------------- Use fb-rotate ----------------------
----- to determine present display orientation -----
on getDisplayOrient()
	
	try
		set internalDisplay to do shell script fbRotatePath & " -i | /usr/bin/grep 'internal'"
		return (word 8 of internalDisplay) as integer
	end try
	
	return displayOrient
end getDisplayOrient

------------ Use Amit Singh's "fb-rotate" -------------
----- to change the present display orientation -----
-------- return a -1 if there is an error ---------------
on ChangeDisOrient(notebookOrient)
	if saveWinPos is true then SaveWinPositions()
	try
		
		(*
		------ Old approach, rotate 90 degrees at a time ------
		---------------------------------------------------------------
		set displayOrient to getDisplayOrient()
		set diffO to notebookOrient - displayOrient
		if diffO is 180 or diffO is -180 then
			set averageO to ((notebookOrient + displayOrient) / 2) as integer
			do shell script fbRotatePath & " -d 0 -r " & (averageO as string)
			
			if rotateFastFlag is false then
				delay 2
			else
				delay 0.5
			end if
		end if
		*)
		
		do shell script fbRotatePath & " -d " & displayID & " -r " & (notebookOrient as string)
		
		------ New approach, adjust digitizer (tablet) orientation ------
		-------------------------------------------------------------------------
		if typeComputer is "modbook" then
			set appName to "TabletDriver.app"
			try
				tell application appName
					if notebookOrient < 180 then
						if notebookOrient = 0 then
							set Çclass OrenÈ of Çclass TbltÈ 1 to Çconstant OrntLandÈ
						else
							set Çclass OrenÈ of Çclass TbltÈ 1 to Çconstant OrntPortÈ
						end if
					else
						if notebookOrient = 180 then
							set Çclass OrenÈ of Çclass TbltÈ 1 to Çconstant OrntLflpÈ
						else
							set Çclass OrenÈ of Çclass TbltÈ 1 to Çconstant OrntPflpÈ
						end if
					end if
				end tell
			end try
		else
			-- Figure out how to rotate the macbook touch pad.
			
		end if
		
		
	on error
		return -1
	end try
	if saveWinPos is true then RestoreWinPositions()
	return notebookOrient
end ChangeDisOrient


on SaveWinPositions()
	tell application "System Events"
		set TheApps to {}
		set TheProcesses to every application process whose (background only is false)
		repeat with i in TheProcesses
			set processName to name of i
			set processID to unix id of i
			set end of TheApps to {processName, processID}
		end repeat
	end tell
	
	set AppData to {}
	repeat with i from 1 to count of TheApps
		set theApp to item 1 of item i of TheApps
		try
			set winCount to 0
			set _bounds to {}
			set winIDs to {}
			tell application theApp
				set ert to windows
				set winCount to count of ert
				if winCount is not 0 then
					repeat with j from 1 to winCount
						try
							set end of winIDs to window j
							set _bounds to _bounds & {bounds of window j}
						end try
					end repeat
					
				end if
			end tell
			
			
			set end of AppData to {item i of TheApps, winIDs, _bounds}
		end try
		
	end repeat
	set theIndex to (displayOrient / 90 + 1) as integer
	--display dialog theIndex as string
	set item theIndex of winPositions to AppData
	return
end SaveWinPositions

on RestoreWinPositions()
	
	set theIndex to (notebookOrient / 90 + 1) as integer
	delay 1.8
	set AppData to item theIndex of winPositions
	if AppData is not {} then
		repeat with i from 1 to count of AppData
			set theApp to item 1 of item 1 of item i of AppData
			set appPresent to false
			try
				tell application "System Events"
					if unix id of process theApp is item 2 of item 1 of item i of AppData then
						set appPresent to true
					end if
				end tell
				
			end try
			if appPresent then
				tell application theApp
					set ert to windows
					set winCount to count of ert
					repeat with j from 1 to winCount
						set winIDs to (item 2 of item i of AppData)
						repeat with k from 1 to count of winIDs
							try
								if item k of winIDs is window j then
									
									set _bounds to item 3 of item i of AppData
									set bounds of window j to item k of _bounds
									
								end if
							end try
						end repeat
					end repeat
				end tell
			end if
		end repeat
	end if
	return
end RestoreWinPositions

----- Handler allowing external script -----
------- to pause and restart MacFlip -------
on Toggle()
	if pauseMacFlip is false then
		set pauseMacFlip to true
		tell application "System Events"
			activate
			try
				do shell script "afplay '/System/Library/Sounds/Submarine.aiff'"
			on error
				beep 2
			end try
			display dialog ("MacFlip:" & tab & "OFF" & tab & "(paused)") buttons {"OK"} default button 1 giving up after 1 with icon iconPathDim
			quit
		end tell
	else
		try
			do shell script "afplay '/System/Library/Sounds/Blow.aiff'"
		on error
			beep
		end try
		tell application "System Events"
			activate
			display dialog ("MacFlip:" & tab & "ON" & tab & "(reactivated)") buttons {"OK"} default button 1 giving up after 1 with icon iconPath
			quit
		end tell
		set pauseMacFlip to false
	end if
	
	return
end Toggle

on SaveWinToggle()
	if saveWinPos is false then
		tell application "System Events"
			activate
			try
				do shell script "afplay '/System/Library/Sounds/Purr.aiff'"
			on error
				beep 2
			end try
			display dialog ("MacFlip: Saving Window Positions" & return & tab & tab & " for each Orientation.") buttons {"OK"} default button 1 giving up after 2 with icon iconPath
			quit
		end tell
		set saveWinPos to true
	else
		set saveWinPos to false
		try
			do shell script "afplay '/System/Library/Sounds/Frog.aiff'"
		on error
			beep
		end try
		tell application "System Events"
			activate
			display dialog ("MacFlip: NOT Saving Window Positions." & return) buttons {"OK"} default button 1 giving up after 2 with icon iconPath
			quit
		end tell
		set winPositions to {{}, {}, {}, {}}
		
	end if
	
	return
end SaveWinToggle