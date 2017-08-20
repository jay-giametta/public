VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_EditOfficer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database

'Public variables
Dim Alias                       'officer being stratted
Dim OfficerRecord As Recordset  'query results for current officer

Private Sub SaveButton_Click()
    
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
    Else
    
        DoCmd.SetWarnings False     'disables popups for sql queries
        
        'Update denominators on changes
        If OfficerRecord!Rank <> Me.Rank_Combo Then
            'Lookup the officers previous rank
            OldRankStr = "SELECT OfficerGrade " & _
                "FROM Ranks WHERE Rank = '" & OfficerRecord!Rank & "'"
            Set OldRankRecord = CurrentDb.OpenRecordset(OldRankStr)
            
            'Lookup the currently selected rank
            NewRankStr = "SELECT OfficerGrade " & _
                "FROM Ranks WHERE Rank = '" & Me.Rank_Combo & "'"
            Set NewRankRecord = CurrentDb.OpenRecordset(NewRankStr)
            
            'Reduce the denominators of the old rank strats
            StratDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                    "Denominator = Denominator - 1 WHERE " & _
                                    "StratificationFactor = '" & OfficerRecord!Rank & "' OR " & _
                                    "StratificationFactor = '" & OfficerRecord!Rank & "/" & OfficerRecord!YearGroup & "' OR " & _
                                    "StratificationFactor = '" & OldRankRecord!OfficerGrade & "'"
            DoCmd.RunSQL StratDenomUpdate
            
            'Increase the denominators of the new rank strats
            StratDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                    "Denominator = Denominator + 1 WHERE " & _
                                    "StratificationFactor = '" & Me.Rank_Combo & "' OR " & _
                                    "StratificationFactor = '" & Me.Rank_Combo & "/" & Me.YearGroup_Combo & "' OR " & _
                                    "StratificationFactor = '" & NewRankRecord!OfficerGrade & "'"
            DoCmd.RunSQL StratDenomUpdate
            
        'If only the YearGroup is changed
        ElseIf OfficerRecord!YearGroup <> Me.YearGroup_Combo Then
            'Reduce the denominator of the old YearGroup strat
            StratDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                    "Denominator = Denominator - 1 WHERE " & _
                                    "StratificationFactor = '" & OfficerRecord!Rank & "/" & OfficerRecord!YearGroup & "'"
            DoCmd.RunSQL StratDenomUpdate
            
            'Increase the denominator of the new YearGroup strat
            StratDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                    "Denominator = Denominator + 1 WHERE " & _
                                    "StratificationFactor = '" & Me.Rank_Combo & "/" & Me.YearGroup_Combo & "'"
            DoCmd.RunSQL StratDenomUpdate
        End If
        
        'If the LeaderRole is changed
        If OfficerRecord!LeaderRole <> Me.LeaderRole_Combo Then
            'Reduce the denominator of the old LeaderRole strat
            StratDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                    "Denominator = Denominator - 1 WHERE " & _
                                    "StratificationFactor = '" & OfficerRecord!LeaderRole & "'"
            DoCmd.RunSQL StratDenomUpdate
            
            'Increase the denominator of the new LeaderRole strat
            StratDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                    "Denominator = Denominator + 1 WHERE " & _
                                    "StratificationFactor = '" & Me.LeaderRole_Combo & "'"
            DoCmd.RunSQL StratDenomUpdate
        End If
        
        'If the CareerField is changed
        If OfficerRecord!CareerField <> Me.CareerField_Combo Then
            'Reduce the denominator of the old CareerField strat
            StratDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                    "Denominator = Denominator - 1 WHERE " & _
                                    "StratificationFactor = '" & OfficerRecord!CareerField & "'"
            DoCmd.RunSQL StratDenomUpdate
            
            'Increase the denominator of the new LeaderRole strat
            StratDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                    "Denominator = Denominator + 1 WHERE " & _
                                    "StratificationFactor = '" & Me.CareerField_Combo & "'"
            DoCmd.RunSQL StratDenomUpdate
            
        End If
        
        'Check for instructor qualifications
        InstructorQualStr = "SELECT Qualification " & _
                    "FROM Officers_Qualifications " & _
                    "WHERE Officer = '" & Alias & "' " & _
                    "AND Qualification = 'Instructor'"
        
        'If the instructor box is checked
        If Me.InstructorQual_Check = True Then
            'If the officer already had the instructor qualification
            If CurrentDb.OpenRecordset(InstructorQualStr).RecordCount > 0 Then
                'If the officers CareerField changed
                If OfficerRecord!CareerField <> Me.CareerField_Combo Then
                    'Decrease the old Instructor CareerField strat
                    StratDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                        "Denominator = Denominator - 1 WHERE " & _
                                        "StratificationFactor = 'Instructor " & OfficerRecord!CareerField & "'"
                    DoCmd.RunSQL StratDenomUpdate
                    
                    'Increase the new Instructor CareerField strat
                    StratDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                        "Denominator = Denominator + 1 WHERE " & _
                                        "StratificationFactor = 'Instructor " & Me.CareerField_Combo & "'"
                    DoCmd.RunSQL StratDenomUpdate
                End If
            'If this is a new qualification
            Else
                'Update the qualifications table
                QualInsert = "INSERT INTO Officers_Qualifications (Officer, Qualification) " & _
                        "VALUES ('" & Alias & "', 'Instructor')"
                        
                DoCmd.RunSQL QualInsert
                
                'Increase the denominators for instructors
                QualDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                "Denominator = Denominator + 1 WHERE " & _
                                "StratificationFactor = 'Instructor' OR " & _
                                "StratificationFactor = 'Instructor " & Me.CareerField_Combo & "'"
                DoCmd.RunSQL QualDenomUpdate
            End If
        'If the instructor box isn't checked
        Else
            'but it was previously checked
            If CurrentDb.OpenRecordset(InstructorQualStr).RecordCount > 0 Then
                'delete instructor qualifications
                QualDelete = "DELETE FROM Officers_Qualifications " & _
                    "WHERE Officer = '" & Alias & "' " & _
                    "AND Qualification = 'Instructor'"
                DoCmd.RunSQL QualDelete
                
                'update instructor denominators
                QualDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                "Denominator = Denominator - 1 WHERE " & _
                                "StratificationFactor = 'Instructor' OR " & _
                                "StratificationFactor = 'Instructor " & Me.CareerField_Combo & "'"
                DoCmd.RunSQL QualDenomUpdate
            
            End If
        End If
        
        'check for qualification
        WeaponsDirQualStr = "SELECT Qualification " & _
                    "FROM Officers_Qualifications " & _
                    "WHERE Officer = '" & Alias & "' " & _
                    "AND Qualification = 'WeaponsDirector'"
        
        'if the qualification box is checked
        If Me.WeaponsQual_Check = True Then
            'if the qualification was checked before do nothing
            If CurrentDb.OpenRecordset(WeaponsDirQualStr).RecordCount > 0 Then
            'if the qualification wasn't checked
            Else
                'update qualification denominators
                QualDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                "Denominator = Denominator + 1 WHERE " & _
                                "StratificationFactor = 'WeaponsDirector'"
                DoCmd.RunSQL QualDenomUpdate
                
                'insert the new qualification record
                QualInsert = "INSERT INTO Officers_Qualifications (Officer, Qualification) " & _
                    "VALUES ('" & Alias & "', 'WeaponsDirector')"
                DoCmd.RunSQL QualInsert
            End If
        'if the qualification box isn't checked
        Else
            'but it was previously checked
            If CurrentDb.OpenRecordset(SeniorDirQualStr).RecordCount > 0 Then
                'update qualification denominators
                QualDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                "Denominator = Denominator - 1 WHERE " & _
                                "StratificationFactor = 'WeaponsDirector'"
                DoCmd.RunSQL QualDenomUpdate
                
                'delete the old qualification record
                QualDelete = "DELETE FROM Officers_Qualifications " & _
                        "WHERE Officer = '" & Alias & "' " & _
                        "AND Qualification = 'WeaponsDirector'"
                DoCmd.RunSQL QualDelete
            End If
            
        End If
        
        'check for qualification
        MCCQualStr = "SELECT Qualification " & _
                    "FROM Officers_Qualifications " & _
                    "WHERE Officer = '" & Alias & "' " & _
                    "AND Qualification = 'MissionCrewCommander'"
                    
        'if the qualification box is checked
        If Me.MCCQual_Check = True Then
            'if the qualification was checked before do nothing
            If CurrentDb.OpenRecordset(MCCQualStr).RecordCount > 0 Then
            'if the qualification wasn't checked
            Else
                'update qualification denominators
                QualDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                "Denominator = Denominator + 1 WHERE " & _
                                "StratificationFactor = 'MissionCrewCommander'"
                DoCmd.RunSQL QualDenomUpdate
                
                'insert the new qualification record
                QualInsert = "INSERT INTO Officers_Qualifications (Officer, Qualification) " & _
                    "VALUES ('" & Alias & "', 'MissionCrewCommander')"
                DoCmd.RunSQL QualInsert
            End If
        'if the qualification box is checked
        Else
            'but it was previously checked
            If CurrentDb.OpenRecordset(MCCQualStr).RecordCount > 0 Then
                'update qualification denominators
                QualDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                "Denominator = Denominator - 1 WHERE " & _
                                "StratificationFactor = 'MissionCrewCommander'"
                DoCmd.RunSQL QualDenomUpdate
                
                'delete the old qualification record
                QualDelete = "DELETE FROM Officers_Qualifications " & _
                        "WHERE Officer = '" & Alias & "' " & _
                        "AND Qualification = 'MissionCrewCommander'"
                DoCmd.RunSQL QualDelete
            End If
            
        End If
        
        'check for qualification
        SeniorDirQualStr = "SELECT Qualification " & _
                    "FROM Officers_Qualifications " & _
                    "WHERE Officer = '" & Alias & "' " & _
                    "AND Qualification = 'SeniorDirector'"
                    
        'if the qualification box is checked
        If Me.SeniorQual_Check = True Then
            'if the qualification was checked before do nothing
            If CurrentDb.OpenRecordset(SeniorDirQualStr).RecordCount > 0 Then
            'if the qualification wasn't checked
            Else
                'update qualification denominators
                QualDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                "Denominator = Denominator + 1 WHERE " & _
                                "StratificationFactor = 'SeniorDirector'"
                DoCmd.RunSQL QualDenomUpdate
            
                'insert the new qualification record
                QualInsert = "INSERT INTO Officers_Qualifications (Officer, Qualification) " & _
                    "VALUES ('" & Alias & "', 'SeniorDirector')"
                    
                DoCmd.RunSQL QualInsert
            End If
        'if the qualification box is checked
        Else
            'but it was previously checked
            If CurrentDb.OpenRecordset(SeniorDirQualStr).RecordCount > 0 Then
                'update qualification denominators
                QualDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                "Denominator = Denominator - 1 WHERE " & _
                                "StratificationFactor = 'SeniorDirector'"
                DoCmd.RunSQL QualDenomUpdate
                
                'delete the old qualification record
                QualDelete = "DELETE FROM Officers_Qualifications " & _
                    "WHERE Officer = '" & Alias & "' " & _
                    "AND Qualification = 'SeniorDirector'"
                DoCmd.RunSQL QualDelete
            End If
        End If
        
        'update the officer record based on the user provided info
        OfficerUpdate = "UPDATE Officers SET " & _
                        "FirstName = '" & Me.FirstName_Text & "', " & _
                        "LastName = '" & Me.LastName_Text & "', " & _
                        "Unit = '" & Me.Unit_Combo & "', " & _
                        "Rank = '" & Me.Rank_Combo & "', " & _
                        "YearGroup = " & Me.YearGroup_Combo & ", " & _
                        "LeaderRole = '" & Me.LeaderRole_Combo & "', " & _
                        "CareerField = '" & Me.CareerField_Combo & "' " & _
                        "WHERE Alias = '" & Alias & "'"
        DoCmd.RunSQL OfficerUpdate
        
        DoCmd.SetWarnings True      'disables popups for sql queries
        
        'Refresh the view on the main form
        StratDB.Form_StratDB.Requery
        StratDB.Form_StratDB.Refresh
        
        'Close the current form
        DoCmd.Close
        
    End If

End Sub

Private Sub Form_Open(Cancel As Integer)
    'Store officer information
    Alias = Me.OpenArgs
    OfficerStr = "SELECT LastName, FirstName, Unit, Rank, YearGroup, LeaderRole, CareerField " & _
                "FROM Officers WHERE Alias = '" & Alias & "'"
    Set OfficerRecord = CurrentDb.OpenRecordset(OfficerStr)
     
    'If the officer information was stored
    If OfficerRecord.RecordCount > 0 Then
        'Fill in input field with current info
        Me.LastName_Text.Value = OfficerRecord!LastName
        Me.FirstName_Text.Value = OfficerRecord!FirstName
        Me.Unit_Combo.Value = OfficerRecord!Unit
        Me.Rank_Combo.Value = OfficerRecord!Rank
        Me.YearGroup_Combo.Value = OfficerRecord!YearGroup
        Me.LeaderRole_Combo.Value = OfficerRecord!LeaderRole
        Me.CareerField_Combo.Value = OfficerRecord!CareerField
        
        'Fill in instructor qualification if it was previously chosen
        InstructorQualStr = "SELECT Qualification " & _
                            "FROM Officers_Qualifications " & _
                            "WHERE Officer = '" & Alias & "' " & _
                            "AND Qualification = 'Instructor'"
                    
        If CurrentDb.OpenRecordset(InstructorQualStr).RecordCount > 0 Then
            Me.InstructorQual_Check.Value = True
        End If
        
        'Fill in MCC qualification if it was previously chosen
        MCCQualStr = "SELECT Qualification " & _
                        "FROM Officers_Qualifications " & _
                        "WHERE Officer = '" & Alias & "' " & _
                        "AND Qualification = 'MissionCrewCommander'"
                    
        If CurrentDb.OpenRecordset(MCCQualStr).RecordCount > 0 Then
            Me.MCCQual_Check.Value = True
        End If
        
        'Fill in SD qualification if it was previously chosen
        SeniorDirQualStr = "SELECT Qualification " & _
                            "FROM Officers_Qualifications " & _
                            "WHERE Officer = '" & Alias & "' " & _
                            "AND Qualification = 'SeniorDirector'"
                    
        If CurrentDb.OpenRecordset(SeniorDirQualStr).RecordCount > 0 Then
            Me.SeniorQual_Check.Value = True
        End If
        
        'Fill in WD qualification if it was previously chosen
        WeaponsDirQualStr = "SELECT Qualification " & _
                            "FROM Officers_Qualifications " & _
                            "WHERE Officer = '" & Alias & "' " & _
                            "AND Qualification = 'WeaponsDirector'"
                    
        If CurrentDb.OpenRecordset(WeaponsDirQualStr).RecordCount > 0 Then
            Me.WeaponsQual_Check.Value = True
        End If
    'If there was a problem loading officer info
    Else
        'Close the form
        DoCmd.Close
    End If
    
End Sub
