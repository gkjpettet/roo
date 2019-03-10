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
				Begin IDEScriptBuildStep PostBuildLinux , AppliesTo = 2
					// This script won't work on anyone else's computer without tweaking.
					
					Dim name As String = "roo"
					Dim major As String = PropertyValue("App.MajorVersion")
					Dim minor As String = PropertyValue("App.MinorVersion")
					Dim bug As String = PropertyValue("App.BugVersion")
					Dim revision As String = ConstantValue("App.kRunCount")
					Dim source As String = CurrentBuildLocation()
					Dim destination As String = "/Users/garry/Desktop"
					Dim result As String
					
					Dim platform As String
					platform = "linuxARM"
					//platform = "linuxX86"
					
					// Use my custom publisher tool to zip the components, name them
					// correctly and determine thezip file's hash.
					result = DoShellCommand("/usr/local/bin/publisher/publisher -n " + name + " -m " + major + " -x " + _
					minor + " -b " + bug + " -r " + revision + " -p " + platform + " -s " + source + " -d " + destination + " --colour-off")
					
					// Display the hash of this build.
					Print(result)
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
				Begin IDEScriptBuildStep PostBuildMac , AppliesTo = 2
					// This script won't work on anyone else's computer without tweaking.
					
					Dim name As String = "roo"
					Dim major As String = PropertyValue("App.MajorVersion")
					Dim minor As String = PropertyValue("App.MinorVersion")
					Dim bug As String = PropertyValue("App.BugVersion")
					Dim revision As String = ConstantValue("App.kRunCount")
					Dim source As String = CurrentBuildLocation()
					Dim destination As String = "/Users/garry/Desktop"
					Dim result As String
					Dim platform As String = "macos"
					
					// Use my custom publisher tool to zip the components, name them
					// correctly and determine thezip file's hash.
					result = DoShellCommand("/usr/local/bin/publisher/publisher -n " + name + " -m " + major + " -x " + _
					minor + " -b " + bug + " -r " + revision + " -p " + platform + " -s " + source + " -d " + destination + " --colour-off")
					
					// Display the hash of this build.
					Print(result)
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
				Begin IDEScriptBuildStep PostBuildWin , AppliesTo = 2
					// This script won't work on anyone else's computer without tweaking.
					
					Dim name As String = "roo"
					Dim major As String = PropertyValue("App.MajorVersion")
					Dim minor As String = PropertyValue("App.MinorVersion")
					Dim bug As String = PropertyValue("App.BugVersion")
					Dim revision As String = ConstantValue("App.kRunCount")
					Dim source As String = CurrentBuildLocation()
					Dim destination As String = "/Users/garry/Desktop"
					Dim result As String
					Dim platform As String = "win64"
					
					// Use my custom publisher tool to zip the components, name them
					// correctly and determine thezip file's hash.
					result = DoShellCommand("/usr/local/bin/publisher/publisher -n " + name + " -m " + major + " -x " + _
					minor + " -b " + bug + " -r " + revision + " -p " + platform + " -s " + source + " -d " + destination + " --colour-off")
					
					// Display the hash of this build.
					Print(result)
				End
			End
#tag EndBuildAutomation
