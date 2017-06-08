'Imports signature blocks from a SQL database to the current word document

Sub SQLSignaturesConnect()
    On Error Resume Next
    Err.Clear


    'Add input box and prompt for person's initials
    Dim sPrompt
    sPrompt = "Please enter person's initials"
    Dim sTitle
    sTitle = "Name"
    Dim sDefault
    sDefault = ""
    Dim sPerson
    sPerson = InputBox(sPrompt, sTitle, sDefault)
    sPerson = LCase(sPerson)


    'Connects to the signatures View
    txtSQL = "SELECT * FROM dbo.signatures WHERE Initials = " & "'" & sPerson & "'" & ""

    'Connect to SQL database and execute SQL statement
    Set dbConnect = CreateObject("ADODB.Connection")
    dbConnect.Open "Driver={SQL Server};Server=MYSERVER\SQLEXPRESS;Database=Signatures;User Id=UserID;Password=MyPassword;"

    Set rs = dbConnect.Execute(txtSQL)

    txtPersonid = rs.Fields.Item("Initials")
        
    If Err.Number = 3021 Then
        txtError = Err.Number
        MsgBox "You typed " & sPerson & ".  This person does not exist."
        Exit Sub
    End If

    'Assign signature from the view to variable
    txtSignature = rs.Fields.Item("Signature")

    'Insert to Word doc
    Selection.TypeText txtSignature

End Sub
