'Tests if file exists at UNC path

Function FileExists(fullPath As String) As Boolean
    If Not Dir(fullPath, vbDirectory) = vbNullString Then FileExists = True
End Function
