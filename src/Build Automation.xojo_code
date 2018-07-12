#tag BuildAutomation
			Begin BuildStepList Linux
				Begin BuildProjectStep Build
				End
				Begin IDEScriptBuildStep PostBuildLinux , AppliesTo = 2
					dim name as String = "roo"
					dim major as String = PropertyValue("App.MajorVersion")
					dim minor as String = PropertyValue("App.MinorVersion")
					dim bug as String = PropertyValue("App.BugVersion")
					dim source as String = CurrentBuildLocation()
					dim destination as String = "/Users/garry/Desktop"
					dim result as String
					
					result = DoShellCommand("/usr/local/bin/publisher -n " + name + " -m " + major + " -x " + minor + " -b " + bug + _
					" -p linux" + " -s " + source + " -d " + destination + " --colour-off")
					
					Print(result)
				End
			End
			Begin BuildStepList Mac OS X
				Begin BuildProjectStep Build
				End
				Begin IDEScriptBuildStep PostBuildMac , AppliesTo = 2
					dim name as String = "roo"
					dim major as String = PropertyValue("App.MajorVersion")
					dim minor as String = PropertyValue("App.MinorVersion")
					dim bug as String = PropertyValue("App.BugVersion")
					dim source as String = CurrentBuildLocation()
					dim destination as String = "/Users/garry/Desktop"
					dim result as String
					
					result = DoShellCommand("/usr/local/bin/publisher -n " + name + " -m " + major + " -x " + minor + " -b " + bug + _
					" -p macos" + " -s " + source + " -d " + destination + " --colour-off")
					
					Print(result)
				End
			End
			Begin BuildStepList Windows
				Begin BuildProjectStep Build
				End
				Begin IDEScriptBuildStep PostBuildWin , AppliesTo = 2
					dim name as String = "roo"
					dim major as String = PropertyValue("App.MajorVersion")
					dim minor as String = PropertyValue("App.MinorVersion")
					dim bug as String = PropertyValue("App.BugVersion")
					dim source as String = CurrentBuildLocation()
					dim destination as String = "/Users/garry/Desktop"
					dim result as String
					
					result = DoShellCommand("/usr/local/bin/publisher -n " + name + " -m " + major + " -x " + minor + " -b " + bug + _
					" -p win64" + " -s " + source + " -d " + destination + " --colour-off")
					
					Print(result)
				End
			End
#tag EndBuildAutomation
