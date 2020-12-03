#tag BuildAutomation
			Begin BuildStepList Linux
				Begin IDEScriptBuildStep PreBuildLinux , AppliesTo = 0
					// Automatically increment the debug run count so we know how
					// many times the project has been debugged.
					Dim value As String = ConstantValue("App.kRunCount")
					Dim count As Integer = Val(value)
					count = count + 1
					ConstantValue("App.kRunCount") = Str(count)
					
				End
				Begin BuildProjectStep Build
				End
			End
			Begin BuildStepList Mac OS X
				Begin IDEScriptBuildStep PreBuildMac , AppliesTo = 0
					// Automatically increment the debug run count so we know how
					// many times the project has been debugged.
					Dim value As String = ConstantValue("App.kRunCount")
					Dim count As Integer = Val(value)
					count = count + 1
					ConstantValue("App.kRunCount") = Str(count)
					
				End
				Begin BuildProjectStep Build
				End
			End
			Begin BuildStepList Windows
				Begin IDEScriptBuildStep PreBuildWin , AppliesTo = 0
					// Automatically increment the debug run count so we know how
					// many times the project has been debugged.
					Dim value As String = ConstantValue("App.kRunCount")
					Dim count As Integer = Val(value)
					count = count + 1
					ConstantValue("App.kRunCount") = Str(count)
					
				End
				Begin BuildProjectStep Build
				End
			End
#tag EndBuildAutomation
