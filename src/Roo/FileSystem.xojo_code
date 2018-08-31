#tag Module
Protected Module FileSystem
	#tag Method, Flags = &h1
		Protected Function CopyTo(Extends source As FolderItem, destination As FolderItem, overwrite As Boolean = False) As Error
		  Return CopyTo(source, destination, overwrite)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function CopyTo(source As FolderItem, destination As FolderItem, overwrite As Boolean = False) As Error
		  ' This method copies the source file or folder to the specified destination.
		  ' `source` is the file or folder to copy.
		  ' `destination` must be a folder and must exist. 
		  
		  ' Nil object checks.
		  If source = Nil Then
		    Return Error.SourceIsNil
		  ElseIf destination = Nil Then
		    Return Error.DestinationIsNil
		  End If
		  
		  ' Do `source` and `destination` exist?
		  If Not source.Exists Then Return Error.SourceDoesNotExist
		  If Not destination.Exists Then Return Error.DestinationDoesNotExist
		  
		  Dim count, i As Integer
		  Dim item As FolderItem
		  
		  ' Copy a file
		  ' -----------
		  If source.Directory= False Then
		    
		    ' Does destination contain a file with the same name as `source`?
		    count = destination.Count
		    For i = 1 To count
		      item = destination.Item(i)
		      If Not item.Directory And item.Name = source.Name Then
		        ' Destination contains an identically named file. Should we overwrite?
		        If overwrite Then ' Yes.
		          Try
		            If item.ReallyDelete(safeMode) <> 0 Then Return Error.UnableToDeleteFile
		            Exit
		          Catch err
		            If safeMode Then
		              Return Error.AttemptToDeleteProtectedFolderItem
		            Else
		              Return Error.UnableToDeleteFile
		            End If
		          End Try
		        Else ' Do not overwrite the existing file - abort.
		          Return Error.Aborted
		        End If
		      End If
		    Next i
		    
		    ' At this point, we are copying a file to a valid destination folder and we are sure there is 
		    ' not a file at this destination with the same name. All that's left is to do the file copy.
		    #If TargetWindows
		      Return WindowsCopyFile(source, destination)
		    #Else
		      Return UnixCopyFile(source, destination)
		    #EndIf
		    
		  End If
		  
		  ' Copy a folder
		  ' -------------
		  If source.Directory Then
		    
		    ' Does destination contain a folder with the same name as `source`?
		    count = destination.Count
		    For i = 1 To count
		      item = destination.Item(i)
		      If item.Directory And item.Name = source.Name Then
		        ' Destination contains an identically named folder. Should we overwrite?
		        If overwrite Then ' Yes.
		          Try
		            If item.ReallyDelete(safeMode) <> 0 Then Return Error.UnableToDeleteFolder
		            Exit
		          Catch err
		            If safeMode Then
		              Return Error.AttemptToDeleteProtectedFolderItem
		            Else
		              Return Error.UnableToDeleteFolder
		            End If
		          End Try
		        Else ' Do not overwrite the existing folder - abort.
		          Return Error.Aborted
		        End If
		      End If
		    Next i
		    
		    ' At this point, we are copying a folder to a valid destination folder and we are sure there is 
		    ' not a folder at this destination with the same name. All that's left is to do the folder copy.
		    #If TargetWindows
		      Return WindowsCopyFolder(source, destination)
		    #Else
		      Return UnixCopyFolder(source, destination)
		    #EndIf
		    
		  End If
		  
		  ' If we've got here something went wrong.
		  Return Error.Unknown
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Sub Initialise()
		  SetupProtectedFiles
		  
		  mInitialised = True
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function MoveTo(Extends source As FolderItem, destination As FolderItem, overwrite As Boolean = False) As Error
		  Return MoveTo(source, destination, overwrite)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function MoveTo(source As FolderItem, destination As FolderItem, overwrite As Boolean = False) As Error
		  ' This method moves the source file or folder to the specified destination.
		  ' `source` is the file or folder to move.
		  ' `destination` must be a folder.
		  
		  ' Nil object checks.
		  If source = Nil Then
		    Return Error.SourceIsNil
		  ElseIf destination = Nil Then
		    Return Error.DestinationIsNil
		  End If
		  
		  ' Do `source` and `destination` exist?
		  If Not source.Exists Then Return Error.SourceDoesNotExist
		  If Not destination.Exists Then Return Error.DestinationDoesNotExist
		  
		  Dim count, i As Integer
		  Dim item As FolderItem
		  
		  ' Move a file
		  ' -----------
		  If source.Directory= False Then
		    
		    ' Does destination contain a file with the same name as `source`?
		    count = destination.Count
		    For i = 1 To count
		      item = destination.Item(i)
		      If Not item.Directory And item.Name = source.Name Then
		        ' Destination contains an identically named file. Should we overwrite?
		        If overwrite Then ' Yes.
		          Try
		            If item.ReallyDelete(safeMode) <> 0 Then Return Error.UnableToDeleteFile
		            Exit
		          Catch err
		            If safeMode Then
		              Return Error.AttemptToDeleteProtectedFolderItem
		            Else
		              Return Error.UnableToDeleteFile
		            End If
		          End Try
		        Else ' Do not overwrite the existing file - abort.
		          Return Error.Aborted
		        End If
		      End If
		    Next i
		    
		    ' At this point, we are moving a file to a valid destination folder and we are sure there is 
		    ' not a file at this destination with the same name. All that's left to do is move the file.
		    #If TargetWindows
		      Return WindowsMoveFile(source, destination)
		    #Else
		      Return UnixMoveFile(source, destination)
		    #EndIf
		    
		  End If
		  
		  ' Move a folder
		  ' -------------
		  If source.Directory Then
		    
		    ' Does destination contain a folder with the same name as `source`?
		    count = destination.Count
		    For i = 1 To count
		      item = destination.Item(i)
		      If item.Directory And item.Name = source.Name Then
		        ' Destination contains an identically named folder. Should we overwrite?
		        If overwrite Then ' Yes.
		          Try
		            If item.ReallyDelete(safeMode) <> 0 Then Return Error.UnableToDeleteFolder
		            Exit
		          Catch err
		            If safeMode Then
		              Return Error.AttemptToDeleteProtectedFolderItem
		            Else
		              Return Error.UnableToDeleteFolder
		            End If
		          End Try
		        Else ' Do not overwrite the existing folder - abort.
		          Return Error.Aborted
		        End If
		      End If
		    Next i
		    
		    ' At this point, we are moving a folder to a valid destination folder and we are sure there is 
		    ' not a folder at this destination with the same name. All that's left to do is move the folder.
		    #If TargetWindows
		      Return WindowsMoveFolder(source, destination)
		    #Else
		      Return UnixMoveFolder(source, destination)
		    #EndIf
		    
		  End If
		  
		  ' If we've got here something went wrong.
		  Return Error.Unknown
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ReallyDelete(Extends what As FolderItem, safeMode As Boolean = True) As Integer
		  Return ReallyDelete(what, safeMode)
		End Function
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ReallyDelete(what As FolderItem, safeMode As Boolean = True) As Integer
		  ' Returns an error code if it fails, or zero if the folder was deleted successfully.
		  
		  If Not mInitialised Then Initialise
		  
		  ' Do NOT permit the deletion of important special folders if in safe mode.
		  If safeMode And protectedFolderItems.HasKey(what.NativePath) Then
		    Dim err As New RuntimeException
		    err.Message = "An attempt to delete the protected FolderItem `" + _
		    what.NativePath + "` was made. Deletion aborted."
		    Raise err
		  End If
		  
		  Dim returnCode, lastErr, itemCount As Integer
		  Dim files(), dirs() As FolderItem
		  
		  If what = Nil Or Not what.Exists() Then Return 0
		  
		  ' Is this a file?
		  If Not what.Directory Then
		    what.Delete
		    Return what.LastErrorCode
		  End If
		  
		  ' Collect the folder‘s contents first.
		  ' This is faster than collecting them in reverse order and deleting them right away.
		  itemCount = what.Count
		  For i As Integer = 1 To itemCount
		    Dim f As FolderItem
		    f = what.TrueItem(i)
		    If f <> Nil Then
		      If f.Directory Then
		        dirs.Append(f)
		      Else
		        files.Append(f)
		      End If
		    End If
		  Next
		  
		  ' Now delete the files.
		  For Each f As FolderItem In files
		    f.Delete
		    lastErr = f.LastErrorCode ' Check if an error occurred.
		    If lastErr <> 0 Then
		      ' Return the error code if any. This will cancel the deletion.
		      Return lastErr
		    End If
		  Next
		  
		  Redim files(-1) ' Free the memory used by the files array before we enter recursion.
		  
		  ' Now delete the directories.
		  For Each f As FolderItem In dirs
		    lastErr = f.ReallyDelete(safeMode)
		    If lastErr <> 0 Then
		      ' Return the error code if any. This will cancel the deletion.
		      Return lastErr
		    End If
		  Next
		  
		  If returnCode = 0 Then
		    ' We‘re done without error, so the folder should be empty and we can delete it.
		    what.Delete
		    returnCode = what.LastErrorCode
		  End If
		  
		  Return returnCode
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub SetupProtectedFiles()
		  ' Initialises the Dictionary that stores the FolderItems that must never be deleted by the ReallyDelete
		  ' method. 
		  ' Which locations are protected depends upon the platform that the app is currently running on.
		  
		  ' The following locations are protected on:
		  ' Windows:
		  ' ApplicationData, Applications, Desktop, Documents, Extensions, Favourites, Fonts, 
		  ' Movies, Music, Pictures, Printers, SharedApplicationData, SharedDocuments, System, UserHome, Windows
		  
		  ' macOS: 
		  ' ApplicationData, Applications, Bin, Desktop, Documents, Etc, Favourites, Fonts, Home, 
		  ' Library, Mount, Movies, Music, Pictures, Preferences, Printers, SBin, SharedApplicationData, 
		  ' SharedDocuments, SharedPreferences, System, UserBin, UserHome, UserLibrary, UsersBin
		  
		  ' Linux:
		  ' ApplicationData, Bin, Desktop, Documents, Etc, Home, Library, Mount, Movies, Music, Pictures, 
		  ' SBin, UserBin, UserHome, UserLibrary, UsersBin
		  
		  protectedFolderItems = New Dictionary
		  
		  #If TargetWindows
		    protectedFolderItems.Value(SpecialFolder.ApplicationData.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Applications.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Desktop.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Documents.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Extensions.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Favorites.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Fonts.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Movies.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Music.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Pictures.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Printers.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.SharedApplicationData.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.SharedDocuments.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.System.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.UserHome.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Windows.NativePath) = True
		  #ElseIf TargetMacOS
		    protectedFolderItems.Value(SpecialFolder.ApplicationData.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Applications.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Bin.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Desktop.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Documents.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Etc.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Favorites.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Fonts.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Home.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Library.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Mount.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Movies.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Music.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Pictures.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Preferences.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Printers.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.SBin.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.SharedApplicationData.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.SharedDocuments.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.SharedPreferences.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.System.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.UserBin.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.UserHome.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.UserLibrary.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.UserSBin.NativePath) = True
		  #Else
		    protectedFolderItems.Value(SpecialFolder.ApplicationData.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Bin.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Desktop.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Documents.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Etc.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Home.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Library.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Mount.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Movies.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Music.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.Pictures.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.SBin.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.UserBin.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.UserHome.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.UserLibrary.NativePath) = True
		    protectedFolderItems.Value(SpecialFolder.UserSBin.NativePath) = True
		  #EndIf
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h1
		Protected Function ToString(Extends e As FileSystem.Error) As String
		  Select Case e
		  Case Error.Aborted
		    Return "Aborted"
		  Case Error.AttemptToDeleteProtectedFolderItem
		    Return "Attempt to delete protected FolderItem"
		  Case Error.CpError
		    Return "cp command error"
		  Case Error.DestinationDoesNotExist
		    Return "Destination does not exist"
		  Case Error.DestinationIsNil
		    Return "Destination is Nil"
		  Case Error.MoveError
		    Return "move command error"
		  Case Error.None
		    Return "None"
		  Case Error.SourceDoesNotExist
		    Return "Source does not exist"
		  Case Error.SourceIsNil
		    Return "Source is Nil"
		  Case Error.UnableToCreateDestinationFolder
		    Return "Unable to create destination folder"
		  Case Error.UnableToDeleteFile
		    Return "Unable to delete file"
		  Case Error.UnableToDeleteFolder
		    Return "Unable to delete folder"
		  Case Error.Unknown
		    Return "Unknown"
		  Case Error.XcopyDiskWriteError
		    Return "xcopy disk write error"
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function UnixCopyFile(file As FolderItem, destination As FolderItem) As Error
		  ' macOS and Linux only.
		  ' Copies the `source` file to the `destination` folder using the shell and the `cp` command.
		  ' `source` is the file to copy.
		  ' `destination` specifies the folder that will become the parent of `source`.
		  
		  ' The method assumes that checks have already been made for the following conditions:
		  ' `source` <> Nil and `source` exists
		  ' `destination` <> Nil and `destination` exists and `destination` does NOT contain an identically 
		  ' named file as `source`.
		  
		  ' Use cp to do the copy.
		  Dim s As New Shell
		  s.Mode = 0
		  Dim command As String = "cp " + kQuote + file.NativePath + kQuote + " " + _
		  kQuote + destination.NativePath + kQuote
		  s.Execute(command)
		  
		  ' Return cp's error code (if any).
		  If s.ErrorCode = 0 Then
		    Return Error.None
		  Else
		    Return Error.CpError
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function UnixCopyFolder(folder As FolderItem, destination As FolderItem) As Error
		  ' macOS and Linux only..
		  ' Copies the `source` folder to the `destination` folder using the shell and the `cp` command.
		  ' `source` is the folder to copy.
		  ' `destination` specifies the folder that will become the parent of `source`.
		  
		  ' The method assumes that checks have already been made for the following conditions:
		  ' `source` <> Nil and `source` exists
		  ' `destination` <> Nil and `destination` exists and `destination` is a folder and 
		  ' `destination` does NOT contain an identically named folder as `source`.
		  
		  ' Make sure there is NO trailing slash after the source path.
		  Dim sourcePath As String = folder.NativePath
		  If sourcePath.Right(1) = "/" Then sourcePath = sourcePath.Left(sourcePath.Len - 1)
		  
		  ' Make sure there IS a trailing slash at the end of the destination path.
		  Dim destinationPath As String = destination.NativePath
		  If destinationPath.Right(1) <> "/" Then destinationPath = destinationPath + "/"
		  
		  ' Use cp to do the copy.
		  Dim s As New Shell
		  s.Mode = 0
		  Dim command As String = "cp -R " + kQuote + sourcePath + kQuote + " " + kQuote + destinationPath + kQuote
		  s.Execute(command)
		  
		  ' Return cp's error code (if any).
		  If s.ErrorCode = 0 Then
		    Return Error.None
		  Else
		    Return Error.CpError
		  End If
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function UnixMoveFile(file As FolderItem, destination As FolderItem) As Error
		  ' macOS and Linux only.
		  ' Moves the `source` file to the `destination` folder using the shell and the `mv` command.
		  ' `source` is the file to move.
		  ' `destination` specifies the folder that will become the parent of `source`.
		  
		  ' The method assumes that checks have already been made for the following conditions:
		  ' `source` <> Nil and `source` exists
		  ' `destination` <> Nil and `destination` exists and `destination` does NOT contain an identically 
		  ' named file as `source`.
		  
		  ' To determine the destination path, we need to append the file's name to it.
		  Dim destinationPath As String = destination.NativePath
		  If destinationPath.Right(1) <> "/" Then destinationPath = destinationPath + "/"
		  destinationPath = destinationPath + file.Name
		  
		  ' Use `mv` to do the moving.
		  Dim s As New Shell
		  s.Mode = 0
		  Dim command As String = "mv -f " + kQuote + file.NativePath + kQuote + " " + _
		  kQuote + destinationPath + kQuote
		  s.Execute(command)
		  
		  ' Return mv's error code (if any).
		  If s.ErrorCode = 0 Then
		    Return Error.None
		  Else
		    Return Error.MoveError
		  End
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function UnixMoveFolder(folder As FolderItem, destination As FolderItem) As Error
		  ' macOS and Linux only..
		  ' Moves the `source` folder to the `destination` folder using the shell and the `mv` command.
		  ' `source` is the folder to move.
		  ' `destination` specifies the folder that will become the parent of `source`.
		  
		  ' The method assumes that checks have already been made for the following conditions:
		  ' `source` <> Nil and `source` exists
		  ' `destination` <> Nil and `destination` exists and `destination` is a folder and 
		  ' `destination` does NOT contain an identically named folder as `source`.
		  
		  ' Use `mv` to do the moving.
		  Dim s As New Shell
		  s.Mode = 0
		  Dim command As String = "mv -f " + kQuote + folder.NativePath + kQuote + " " + _
		  kQuote + destination.NativePath + kQuote
		  s.Execute(command)
		  
		  ' Return mv's error code (if any).
		  If s.ErrorCode = 0 Then
		    Return Error.None
		  Else
		    Return Error.MoveError
		  End
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function WindowsCopyFile(file As FolderItem, destination As FolderItem) As Error
		  ' Windows-only.
		  ' Copies the `source` file to the `destination` folder using the shell and the `xcopy` command.
		  ' `source` is the file to copy.
		  ' `destination` specifies the folder that will become the parent of `source`.
		  
		  ' The method assumes that checks have already been made for the following conditions:
		  ' `source` <> Nil and `source` exists
		  ' `destination` <> Nil and `destination` exists and `destination` does NOT contain an identically 
		  ' named file as `source`.
		  
		  ' Use xcopy to do the copy.
		  Dim s As New Shell
		  s.Mode = 0
		  Dim command As String = "xcopy " + kQuote + file.NativePath + kQuote + " " + _
		  kQuote + destination.NativePath + kQuote + " /i /y"
		  s.Execute(command)
		  
		  ' Return xcopy's error code (if any).
		  Select Case s.ErrorCode
		  Case 5
		    Return Error.XcopyDiskWriteError
		  Else
		    Return Error.None
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function WindowsCopyFolder(folder As FolderItem, destination As FolderItem) As Error
		  ' Windows-only.
		  ' Copies the `source` folder to the `destination` folder using the shell and the `xcopy` command.
		  ' `source` is the folder to copy.
		  ' `destination` specifies the folder that will become the parent of `source`.
		  
		  ' The method assumes that checks have already been made for the following conditions:
		  ' `source` <> Nil and `source` exists
		  ' `destination` <> Nil and `destination` exists and `destination` is a folder and 
		  ' `destination` does NOT contain an identically named folder as `source`.
		  
		  ' We need to create a folder at the destination with the same name as the source folder.
		  Dim d As FolderItem = destination.Child(folder.Name)
		  Try
		    d.CreateAsFolder
		    If d.LastErrorCode <> FolderItem.NoError Then Return Error.UnableToCreateDestinationFolder
		  Catch err
		    Return Error.UnableToCreateDestinationFolder
		  End Try
		  
		  ' Ensure that there is no trailing slash in the source folder's path.
		  Dim sourcePath As String = folder.NativePath
		  If sourcePath.Right(1) = "\" Then sourcePath = sourcePath.Left(sourcePath.Len - 1)
		  
		  ' Use xcopy to do the copy.
		  Dim s As New Shell
		  s.Mode = 0
		  Dim command As String = "xcopy " + kQuote + sourcePath + kQuote + " " + _
		  kQuote + d.NativePath + kQuote + " /i /e /s /y"
		  s.Execute(command)
		  
		  ' Return xcopy's error code (if any).
		  Select Case s.ErrorCode
		  Case 5
		    Return Error.XcopyDiskWriteError
		  Else
		    Return Error.None
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function WindowsMoveFile(file As FolderItem, destination As FolderItem) As Error
		  ' Windows-only.
		  ' Moves the `source` file to the `destination` folder using the shell and the `move` command.
		  ' `source` is the file to move.
		  ' `destination` specifies the folder that will become the parent of `source`.
		  
		  ' The method assumes that checks have already been made for the following conditions:
		  ' `source` <> Nil and `source` exists
		  ' `destination` <> Nil and `destination` exists and `destination` does NOT contain an identically 
		  ' named file as `source`.
		  
		  ' Use the `move` command to actually move the file.
		  Dim s As New Shell
		  s.Mode = 0
		  Dim command As String = "move /Y " + kQuote + file.NativePath + kQuote + " " + _
		  kQuote + destination.NativePath + kQuote
		  s.Execute(command)
		  
		  ' Return move's error code (if any).
		  If s.ErrorCode = 0 Then
		    Return Error.None
		  Else
		    Return Error.MoveError
		  End
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function WindowsMoveFolder(folder As FolderItem, destination As FolderItem) As Error
		  ' Windows-only.
		  ' Moves the `source` folder to the `destination` folder using the shell and the `move` command.
		  ' `source` is the folder to move.
		  ' `destination` specifies the folder that will become the parent of `source`.
		  
		  ' The method assumes that checks have already been made for the following conditions:
		  ' `source` <> Nil and `source` exists
		  ' `destination` <> Nil and `destination` exists and `destination` is a folder and 
		  ' `destination` does NOT contain an identically named folder as `source`.
		  
		  ' Make sure that the source folder path does NOT have a trailing slash.
		  Dim sourcePath As String = folder.NativePath
		  If sourcePath.Right(1) = "\" Then sourcePath = sourcePath.Left(sourcePath.Len - 1)
		  
		  ' Use the `move` command to actually move the folder.
		  Dim s As New Shell
		  s.Mode = 0
		  Dim command As String = "move /Y " + kQuote + sourcePath + kQuote + " " + _
		  kQuote + destination.NativePath + kQuote
		  s.Execute(command)
		  
		  ' Return move's error code (if any).
		  If s.ErrorCode = 0 Then
		    Return Error.None
		  Else
		    Return Error.MoveError
		  End
		End Function
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mInitialised As Boolean = False
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected protectedFolderItems As Dictionary
	#tag EndProperty

	#tag Property, Flags = &h1
		Protected safeMode As Boolean = True
	#tag EndProperty


	#tag Constant, Name = kQuote, Type = String, Dynamic = False, Default = \"\"", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kVersionBug, Type = Double, Dynamic = False, Default = \"0", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kVersionMajor, Type = Double, Dynamic = False, Default = \"1", Scope = Protected
	#tag EndConstant

	#tag Constant, Name = kVersionMinor, Type = Double, Dynamic = False, Default = \"0", Scope = Protected
	#tag EndConstant


	#tag Enum, Name = Error, Type = Integer, Flags = &h1
		Aborted
		  AttemptToDeleteProtectedFolderItem
		  CpError
		  DestinationDoesNotExist
		  DestinationIsNil
		  MoveError
		  None
		  SourceDoesNotExist
		  SourceIsNil
		  UnableToCreateDestinationFolder
		  UnableToDeleteFile
		  UnableToDeleteFolder
		  Unknown
		XcopyDiskWriteError
	#tag EndEnum


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			Type="String"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
		#tag EndViewProperty
	#tag EndViewBehavior
End Module
#tag EndModule
