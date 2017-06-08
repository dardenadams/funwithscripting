'For use when dealing with large Access DBs or when lots of processing is necessary with each iteration
'Requires some UserForm setup first:
' - Create a new UserForm named 'Progress' 
' - Set the width to 224 and height as desired
' - Add a label named 'Percent' and set the default text to '0% Complete'
' - Add a panel named 'Panel'
' - Set height to 20 and width to 201
' - Add a label named 'Bar'
' - Set height to 20 and width to 1, then position it on top of Panel so that it is at the far left. 
'   Set color to blue. This will be the progress bar.

'***This code should be present in the Progress UserForm***:

Private Sub UserForm_Activate() 'Runs immediately when UserForm is opened
  Call reformatData(str_SOURCE_TABLE, str_DESTINATION_TABLE) 'Calls function that will do fun stuff

  Unload Me 'Quit UserForm on completion
End Sub

'***The Progress UserForm will utilize the following functions, preferably located in their own module***:

Function reformatData(srcTblName, dstTblName As String)
  
  Dim masterDb As DAO.Database 'Database we will import data TO
  Dim srcTbl As DAO.TableDef 'Table we will import data FROM
  Dim srcRcd As DAO.Recordset 'Recordset derivative of srcTbl
  
  Set masterDb = CurrentDb 'Import from/to currently opened DB
  Set srcTbl = masterDb.TableDefs(srcTblName) 'Use passed in table name as source
  Set srcRcd = srcTbl.OpenRecordset 'Open recordset for processing
  
  Dim counter as Long 'Counter for progress bar
  Dim curPct As Single 'Current percentage out of 100 for progress bar
  Dim totalRec As Single 'Total number of records in recordset for progress bar
  counter = 1
  totalRec = srcRcd.RecordCount
  
  'Iterate through records
  Do Until srcRcd.EOF
  
    '**Complex code that manipulates data from source then saves it to destination here**
    
    'Increment progress bar with each iteration
    counter = counter + 1
    pct = counter / (totalRec / 100) 'Calculate current percentage completion
    ProgressOnce pct 'Pass to incrementation function
    
    DoEvents 'Use DoEvents to prevent app from crashing
  Loop
  
End Function


Function ProgressOnce(pctComplete As Single)
  pctComplete = Round(pctComplete, 2) 'Clean up to 2 decimal places

  'Set the numerical percentage caption and the width using percentage from main function
  Progress.Percent.Caption = pctComplete & "% Completed"
  Progress.Bar.Width = pctComplete * 2
  
End Function
