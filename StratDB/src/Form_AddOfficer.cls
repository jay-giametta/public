VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_AddOfficer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database

Private Sub AddButton_Click()

    'Ensure all fields are filled in
    If IsNull(Me.FirstName_Text.Value) Then
        MsgBox ("The First Name field cannot be blank.")
    ElseIf IsNull(Me.LastName_Text.Value) Then
        MsgBox ("The Last Name field cannot be blank.")
    ElseIf IsNull(Me.Unit_Combo.Value) Then
        MsgBox ("The Unit field cannot be blank.")
    ElseIf IsNull(Me.Rank_Combo.Value) Then
        MsgBox ("The Rank field cannot be blank.")
    ElseIf IsNull(Me.YearGroup_Combo.Value) Then
        MsgBox ("The Year Group field cannot be blank.")
    ElseIf IsNull(Me.LeaderRole_Combo.Value) Then
        MsgBox ("The Leadership Role field cannot be blank.")
    ElseIf IsNull(Me.CareerField_Combo.Value) Then
        MsgBox ("The Career Field field cannot be blank.")
        
    'No error continue
    Else
        DoCmd.SetWarnings False     'disables popups for sql queries
        
        'Insert the officer record
        Alias = Me.FirstName_Text & "." & Me.LastName_Text & "." & Format(Date, "dd.mm.yy")
        OfficerInsert = "INSERT INTO Officers (Alias, FirstName, LastName, Unit, Rank, YearGroup, LeaderRole, CareerField) " & _
                    "VALUES ('" & Alias & "', '" & Me.FirstName_Text & "', '" & _
                    Me.LastName_Text & "', '" & Me.Unit_Combo & "', '" & Me.Rank_Combo & "', " & Me.YearGroup_Combo & _
                    ", '" & Me.LeaderRole_Combo & "', '" & Me.CareerField_Combo & "')"
        DoCmd.RunSQL OfficerInsert
        
        If Me.InstructorQual_Check = True Then
            'Update qualification denominators
            QualDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                "Denominator = Denominator + 1 WHERE " & _
                                "StratificationFactor = 'Instructor' OR " & _
                                "StratificationFactor = 'Instructor " & Me.CareerField_Combo & "'"
            DoCmd.RunSQL QualDenomUpdate
                           
            'Insert qualification record
            QualInsert = "INSERT INTO Officers_Qualifications (Officer, Qualification) " & _
                    "VALUES ('" & Alias & "', 'Instructor')"
            DoCmd.RunSQL QualInsert
        End If
        
        If Me.WeaponsQual_Check = True Then
            'Update qualification denominators
            QualDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                "Denominator = Denominator + 1 WHERE " & _
                                "StratificationFactor = 'WeaponsDirector'"
            DoCmd.RunSQL QualDenomUpdate
            
            'Insert qualification record
            QualInsert = "INSERT INTO Officers_Qualifications (Officer, Qualification) " & _
                    "VALUES ('" & Alias & "', 'WeaponsDirector')"
            DoCmd.RunSQL QualInsert
        End If
        
        If Me.MCCQual_Check = True Then
            'Update qualification denominators
            QualDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                "Denominator = Denominator + 1 WHERE " & _
                                "StratificationFactor = 'MissionCrewCommander'"
            DoCmd.RunSQL QualDenomUpdate
            
            'Insert qualification record
            QualInsert = "INSERT INTO Officers_Qualifications (Officer, Qualification) " & _
                    "VALUES ('" & Alias & "', 'MissionCrewCommander')"
            DoCmd.RunSQL QualInsert
        End If
        
        If Me.SeniorQual_Check = True Then
            'Update qualification denominators
            QualDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                "Denominator = Denominator + 1 WHERE " & _
                                "StratificationFactor = 'SeniorDirector'"
            DoCmd.RunSQL QualDenomUpdate
            
            'Insert qualification record
            QualInsert = "INSERT INTO Officers_Qualifications (Officer, Qualification) " & _
                    "VALUES ('" & Alias & "', 'SeniorDirector')"
            DoCmd.RunSQL QualInsert
        End If
        
        'Lookup the grade of the officer rank
        OfficerGradeStr = "SELECT OfficerGrade FROM Ranks " & _
                            "WHERE Rank = '" & Me.Rank_Combo & "'"
        Set OfficerGradeRS = CurrentDb.OpenRecordset(OfficerGradeStr)
        
        'Update denominators that the officer is assigned to
        StratDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                            "Denominator = Denominator + 1 WHERE " & _
                            "StratificationFactor = '" & Me.Rank_Combo & "' OR " & _
                            "StratificationFactor = '" & Me.Rank_Combo & "/" & Me.YearGroup_Combo & "' OR " & _
                            "StratificationFactor = '" & OfficerGradeRS!OfficerGrade & "' OR " & _
                            "StratificationFactor = '" & Me.LeaderRole_Combo & "' OR " & _
                            "StratificationFactor = 'Overall' OR " & _
                            "StratificationFactor = 'Officer' OR " & _
                            "StratificationFactor = '" & Me.CareerField_Combo & "'"
        DoCmd.RunSQL StratDenomUpdate
        
        DoCmd.SetWarnings True      'disables popups for sql queries
        
        'Refresh main window on exit
        StratDB.Form_StratDB.Requery
        StratDB.Form_StratDB.Refresh
        
        'Close the form
        DoCmd.Close
        
    End If

End Sub
