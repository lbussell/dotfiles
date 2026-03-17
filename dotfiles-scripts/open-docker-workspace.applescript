on run argv
	set doTriage to false
	set autoRun to false

	repeat with arg in argv
		if arg as text is "--run-triage" then
			set doTriage to true
			set autoRun to true
		else if arg as text is "--triage" then
			set doTriage to true
		end if
	end repeat

	tell application "Ghostty"
		activate

		set homePath to POSIX path of (path to home folder)
		set cmd to "copilot --yolo -i \"/triage-pull-requests\""
		set cmd2 to "copilot --yolo -i \"/triage-pipelines\""

		set cfg1 to new surface configuration
		set initial working directory of cfg1 to homePath & "src/dotnet-docker"

		set cfg2 to new surface configuration
		set initial working directory of cfg2 to homePath & "src/docker-tools"

		set cfg3 to new surface configuration
		set initial working directory of cfg3 to homePath & "src/dotnet-framework-docker"

		set win to new window with configuration cfg1
		set tab2 to new tab in win with configuration cfg2
		set tab3 to new tab in win with configuration cfg3

		if doTriage then
			set allTerms to {}

			input text cmd to focused terminal of tab 1 of win
			set end of allTerms to focused terminal of tab 1 of win
			set split1 to split (focused terminal of tab 1 of win) direction right with configuration cfg1
			input text cmd2 to split1
			set end of allTerms to split1

			input text cmd to focused terminal of tab2
			set end of allTerms to focused terminal of tab2
			set split2 to split (focused terminal of tab2) direction right with configuration cfg2
			input text cmd2 to split2
			set end of allTerms to split2

			input text cmd to focused terminal of tab3
			set end of allTerms to focused terminal of tab3
			set split3 to split (focused terminal of tab3) direction right with configuration cfg3
			input text cmd2 to split3
			set end of allTerms to split3

			if autoRun then
				repeat with t in allTerms
					send key "enter" to t
				end repeat
			end if
		end if

		select tab (tab 1 of win)
	end tell
end run
