VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_StratDB"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database

'Open the add officer form
Private Sub AddOfficer_Button_Click()
    DoCmd.OpenForm "AddOfficer"
End Sub

'Delete the highlighted officer
Private Sub DeleteOfficerButton_Click()

    DoCmd.SetWarnings False     'disables popups for sql queries
    
    'store officer info
    OfficerStr = "SELECT LastName, FirstName, Unit, Rank, YearGroup, LeaderRole, CareerField " & _
                "FROM Officers WHERE Alias = '" & Me.Officer_List.Value & "'"
    Set OfficerRecord = CurrentDb.OpenRecordset(OfficerStr)
    
    'if info for the officer is found
    If OfficerRecord.RecordCount > 0 Then
    
        'store rank information for the officer
        RankStr = "SELECT OfficerGrade " & _
                    "FROM Ranks WHERE Rank = '" & OfficerRecord!Rank & "'"
        Set RankRecord = CurrentDb.OpenRecordset(RankStr)
    
        'store strat  information for the officer
        CurrentStratStr = "SELECT StratificationFactor, Rank, StratBy, StratDate " & _
                        "FROM Officers_Stratifications " & _
                        "WHERE Officer = '" & Me.Officer_List.Value & "'"
        Set CurrentStratRS = CurrentDb.OpenRecordset(CurrentStratStr)
        
        If CurrentStratRS.RecordCount > 0 Then
            'roll back strats for officers ranked worse than the current one
            StratUpdate = "UPDATE Officers_Stratifications " & _
                            "SET Rank = Rank - 1 " & _
                            "WHERE StratificationFactor = '" & CurrentStratRS!StratificationFactor & "' " & _
                            "AND Rank > " & CurrentStratRS!Rank
            DoCmd.RunSQL StratUpdate
            
            'delete the current officers strat
            StratDelete = "DELETE FROM Officers_Stratifications " & _
                        "WHERE Officer = '" & Me.Officer_List.Value & "'"
            DoCmd.RunSQL StratDelete
        End If
        
        'reduce denominators affected by the current officer
        StratDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                "Denominator = Denominator - 1 WHERE " & _
                                "StratificationFactor = '" & OfficerRecord!Rank & "' OR " & _
                                "StratificationFactor = '" & OfficerRecord!Rank & "/" & OfficerRecord!YearGroup & "' OR " & _
                                "StratificationFactor = '" & RankRecord!OfficerGrade & "' OR " & _
                                "StratificationFactor = '" & OfficerRecord!LeaderRole & "' OR " & _
                                "StratificationFactor = 'Overall' OR " & _
                                "StratificationFactor = 'Officer' OR " & _
                                "StratificationFactor = '" & OfficerRecord!CareerField & "'"
        DoCmd.RunSQL StratDenomUpdate
        
        'reduce qualification denominator if necessary
        InstructorQualStr = "SELECT Qualification " & _
                        "FROM Officers_Qualifications " & _
                        "WHERE Officer = '" & Me.Officer_List & "' " & _
                        "AND Qualification = 'Instructor'"
        If CurrentDb.OpenRecordset(InstructorQualStr).RecordCount > 0 Then
            QualDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                "Denominator = Denominator - 1 WHERE " & _
                                "StratificationFactor = 'Instructor' OR " & _
                                "StratificationFactor = 'Instructor " & OfficerRecord!CareerField & "'"
            DoCmd.RunSQL QualDenomUpdate
        End If
        
        'reduce qualification denominator if necessary
        WeaponsDirQualStr = "SELECT Qualification " & _
                        "FROM Officers_Qualifications " & _
                        "WHERE Officer = '" & Me.Officer_List & "' " & _
                        "AND Qualification = 'WeaponsDirector'"
                    
        If CurrentDb.OpenRecordset(WeaponsDirQualStr).RecordCount > 0 Then
            QualDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                "Denominator = Denominator - 1 WHERE " & _
                                "StratificationFactor = 'WeaponsDirector'"
            DoCmd.RunSQL QualDenomUpdate
        End If
        
        'reduce qualification denominator if necessary
        MCCQualStr = "SELECT Qualification " & _
                        "FROM Officers_Qualifications " & _
                        "WHERE Officer = '" & Me.Officer_List & "' " & _
                        "AND Qualification = 'MissionCrewCommander'"
        If CurrentDb.OpenRecordset(MCCQualStr).RecordCount > 0 Then
            QualDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                "Denominator = Denominator - 1 WHERE " & _
                                "StratificationFactor = 'MissionCrewCommander'"
            DoCmd.RunSQL QualDenomUpdate
        End If
        
        'reduce qualification denominator if necessary
        SeniorDirQualStr = "SELECT Qualification " & _
                        "FROM Officers_Qualifications " & _
                        "WHERE Officer = '" & Me.Officer_List & "' " & _
                        "AND Qualification = 'SeniorDirector'"
                    
        If CurrentDb.OpenRecordset(SeniorDirQualStr).RecordCount > 0 Then
            QualDenomUpdate = "UPDATE Stratifications_Denominators SET " & _
                                "Denominator = Denominator - 1 WHERE " & _
                                "StratificationFactor = 'SeniorDirector'"
            DoCmd.RunSQL QualDenomUpdate
            
        End If
        
        'delete the record for the current officer
        OfficerDelete = "DELETE FROM Officers " & _
                "WHERE Alias = '" & Me.Officer_List.Value & "'"
        DoCmd.RunSQL OfficerDelete
        
        'refresh the officer list
        Me.Requery
        Me.Refresh
        
        DoCmd.SetWarnings True      'enables popups for sql queries
    End If
    
End Sub

'Open the edit officer form
Private Sub EditOfficer_Button_Click()
    
    'Close the edit officer form if its already open
    If CurrentProject.AllForms("EditOfficer").IsLoaded = True Then
        DoCmd.Close acForm, "EditOfficer"
    End If

    'Make sure an officer is selected
    If Len(Me.Officer_List.Value) > 0 Then
        DoCmd.OpenForm "EditOfficer", , , , , , Me.Officer_List
        
    End If
End Sub

Private Sub Form_Open(Cancel As Integer)
    DoCmd.SetWarnings False     'disables popups for sql queries
    
    'Ensures YearGroup gets updated when the database is opened
    YearInsertStr = "INSERT INTO YearGroups(YearGroup) " & _
                    "VALUES (" & Year(Date) & ")"
    DoCmd.RunSQL YearInsertStr
    
    DoCmd.SetWarnings True      'enables popups for sql queries
End Sub

'Open the edit officer form
Private Sub Strat_Button_Click()

    'Close the strat officer form if its already open
    If CurrentProject.AllForms("StratOfficer").IsLoaded = True Then
        DoCmd.Close acForm, "StratOfficer"
    End If
    
    'Make sure an officer is selected
    If Len(Me.Officer_List.Value) > 0 Then
        DoCmd.OpenForm "StratOfficer", , , , , , Me.Officer_List
        
    End If
End Sub

'Open a strat report
Private Sub ViewStrat_Button_Click()
    DoCmd.OpenReport "Strat_Report", acViewPreview
End Sub
