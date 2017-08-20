VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Form_StratOfficer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Compare Database

'Public variables
Dim Alias                       'officer being stratted
Dim OfficerRecord As Recordset  'query results for current officer
Dim RankRecord As Recordset     'query results for current officer rank
Dim CurrentStratRS As Recordset 'query results for previous officer strat

Private Sub SaveButton_Click()
    
    DoCmd.SetWarnings False     'disables popups for sql queries
    
    'don't save if no strat is chosen
    If IsNull(Me.Strat_OptionGrp.Value) Then
        MsgBox "Choose a strat to save."
        
    'do this if a strat is chosen
    Else
        Dim StratFactor     'factor used to strat officer
        Dim Rank            'strat rank for the given factor
        Dim Denom           'denominator for the given factor
        
        'get the factor/rank/denom for the selected strat
        Select Case Me.Strat_OptionGrp.Value
            Case 1
                StratFactor = OfficerRecord!Rank
                Rank = Me.RankStrat_Text.Value
                Denom = Replace(Me.RankStratDenom_Label.Caption, "/ ", "")
            Case 2
                StratFactor = OfficerRecord!Rank & "/" & OfficerRecord!YearGroup
                Rank = Me.RankYearStrat_Text.Value
                Denom = Replace(Me.RankYearStratDenom_Label.Caption, "/ ", "")
            Case 3
                StratFactor = RankRecord!OfficerGrade
                Rank = Me.OfficerGradeStrat_Text.Value
                Denom = Replace(Me.OfficerGradeStratDenom_Label.Caption, "/ ", "")
            Case 4
                StratFactor = OfficerRecord!LeaderRole
                Rank = Me.LeaderRoleStrat_Text.Value
                Denom = Replace(Me.LeaderRoleStratDenom_Label.Caption, "/ ", "")
            Case 5
                StratFactor = "Overall"
                Rank = Me.OverallStrat_Text.Value
                Denom = Replace(Me.OverallStratDenom_Label.Caption, "/ ", "")
            Case 6
                StratFactor = "Officer"
                Rank = Me.OfficerStrat_Text.Value
                Denom = Replace(Me.OfficerStratDenom_Label.Caption, "/ ", "")
            Case 7
                StratFactor = OfficerRecord!CareerField
                Rank = Me.CareerStrat_Text.Value
                Denom = Replace(Me.CareerStratDenom_Label.Caption, "/ ", "")
            Case 8
                StratFactor = "Instructor " & OfficerRecord!CareerField
                Rank = Me.InstructorCareerStrat_Text.Value
                Denom = Replace(Me.InstructorCareerStratDenom_Label.Caption, "/ ", "")
            Case 9
                StratFactor = "Instructor"
                Rank = Me.InstructorStrat_Text.Value
                Denom = Replace(Me.InstructorStratDenom_Label.Caption, "/ ", "")
            Case 10
                StratFactor = "WeaponsDirector"
                Rank = Me.WeaponsDirStrat_Text.Value
                Denom = Replace(Me.WeaponsDirStratDenom_Label.Caption, "/ ", "")
            Case 11
                StratFactor = "SeniorDirector"
                Rank = Me.SeniorDirStrat_Text.Value
                Denom = Replace(Me.SeniorDirStratDenom_Label.Caption, "/ ", "")
            Case 12
                StratFactor = "MissionCrewCommander"
                Rank = Me.MCCStrat_Text.Value
                Denom = Replace(Me.MCCStratDenom_Label.Caption, "/ ", "")
        End Select
        
        'update strats for old strat factor when current is changed
        'currently rolls all officers ranked worse than the current down one rank to avoid gaps
        If CurrentStratRS.RecordCount > 0 Then
            If CurrentStratRS!StratificationFactor <> StratFactor Then
                'roll back ranks
                StratUpdateStr = "UPDATE Officers_Stratifications " & _
                                "SET Rank = Rank - 1 " & _
                                "WHERE StratificationFactor = '" & CurrentStratRS!StratificationFactor & "' " & _
                                "AND Rank > " & CurrentStratRS!Rank
                DoCmd.RunSQL StratUpdateStr
            
                'delete old strat
                StratDeleteStr = "DELETE FROM Officers_Stratifications " & _
                                "WHERE Officer = '" & Alias & "'"
                DoCmd.RunSQL StratDeleteStr
            End If
        End If
                 
        'insert new strat info and delete old
        StratInsertStr = "INSERT INTO Officers_Stratifications (Officer, StratificationFactor, Rank, StratBy, StratDate) " & _
            "VALUES ('" & Alias & "', '" & StratFactor & "', " & Rank & ", '" & Environ("USERNAME") & "', '" & Date & "')"
        DoCmd.RunSQL StratInsertStr
        
        'delete old strat denominator (might not be one)
        DenomDeleteStr = "DELETE FROM Stratifications_Denominators " & _
                    "WHERE StratificationFactor = '" & StratFactor & "'"
        DoCmd.RunSQL DenomDeleteStr
        
        'insert new strat denominator
        DenomInsertStr = "INSERT INTO Stratifications_Denominators (StratificationFactor, Denominator) " & _
            "VALUES ('" & StratFactor & "', " & Denom & ")"
        DoCmd.RunSQL DenomInsertStr
        
        DoCmd.SetWarnings True      'reenable warnings after queries
    
        'update the view on the main form
        StratDB.Form_StratDB.Requery
        StratDB.Form_StratDB.Refresh
        
        'close the StratOfficer form
        DoCmd.Close
    
    End If

End Sub

Private Sub Form_Open(Cancel As Integer)

    'store officer info in public variables
    Alias = Me.OpenArgs

    OfficerStr = "SELECT LastName, FirstName, Unit, Rank, YearGroup, LeaderRole, CareerField " & _
                "FROM Officers WHERE Alias = '" & Alias & "'"
    Set OfficerRecord = CurrentDb.OpenRecordset(OfficerStr)
    
    'make sure that an officer selection was passed to the form
    If OfficerRecord.RecordCount > 0 Then
        'fill in officer info text fields
        Me.LastName_Text.Value = OfficerRecord!LastName
        Me.FirstName_Text.Value = OfficerRecord!FirstName
        Me.Unit_Combo.Value = OfficerRecord!Unit
        Me.Rank_Combo.Value = OfficerRecord!Rank
        Me.YearGroup_Combo.Value = OfficerRecord!YearGroup
        Me.LeaderRole_Combo.Value = OfficerRecord!LeaderRole
        Me.CareerField_Combo.Value = OfficerRecord!CareerField
           
        'hide strats based on leadership role
        If OfficerRecord!LeaderRole = "Other" Then
            Me.LeaderRoleStratDenom_Label.Visible = False
            Me.LeaderRoleStrat_Label.Visible = False
            Me.LeaderRoleStrat_Option.Visible = False
            Me.LeaderRoleStrat_Text.Visible = False
        End If
        
        'hide strats based on career field
        If OfficerRecord!CareerField = "Other" Then
            Me.CareerStratDenom_Label.Visible = False
            Me.CareerStrat_Label.Visible = False
            Me.CareerStrat_Text.Visible = False
            Me.CareerStrat_Option.Visible = False
            
            Me.InstructorCareerStratDenom_Label.Visible = False
            Me.InstructorCareerStrat_Label.Visible = False
            Me.InstructorCareerStrat_Text.Visible = False
            Me.InstructorCareerStrat_Option.Visible = False
        End If
        
        'check for qualification
        InstructorQualStr = "SELECT Qualification " & _
                            "FROM Officers_Qualifications " & _
                            "WHERE Officer = '" & Alias & "' " & _
                            "AND Qualification = 'Instructor'"
        'qualification is present
        If CurrentDb.OpenRecordset(InstructorQualStr).RecordCount > 0 Then
            'check the qualification box
            Me.InstructorQual_Check.Value = True
        'qualification not present
        Else
            'hide strats based on qual
            Me.InstructorStratDenom_Label.Visible = False
            Me.InstructorStrat_Label.Visible = False
            Me.InstructorStrat_Text.Visible = False
            Me.InstructorStrat_Option.Visible = False
            
            Me.InstructorCareerStratDenom_Label.Visible = False
            Me.InstructorCareerStrat_Label.Visible = False
            Me.InstructorCareerStrat_Text.Visible = False
            Me.InstructorCareerStrat_Option.Visible = False
        
        End If
        
        'check for qualification
        MCCQualStr = "SELECT Qualification " & _
                        "FROM Officers_Qualifications " & _
                        "WHERE Officer = '" & Alias & "' " & _
                        "AND Qualification = 'MissionCrewCommander'"
        'qualification is present
        If CurrentDb.OpenRecordset(MCCQualStr).RecordCount > 0 Then
            'check the qualification box
            Me.MCCQual_Check.Value = True
        'qualification not present
        Else
            'hide strats based on qual
            Me.MCCStratDenom_Label.Visible = False
            Me.MCCStrat_Label.Visible = False
            Me.MCCStrat_Option.Visible = False
            Me.MCCStrat_Text.Visible = False
            
        End If
        
        'check for qualification
        SeniorDirQualStr = "SELECT Qualification " & _
                            "FROM Officers_Qualifications " & _
                            "WHERE Officer = '" & Alias & "' " & _
                            "AND Qualification = 'SeniorDirector'"
        'qualification is present
        If CurrentDb.OpenRecordset(SeniorDirQualStr).RecordCount > 0 Then
            'check the qualification box
            Me.SeniorQual_Check.Value = True
        'qualification not present
        Else
            'hide strats based on qual
            Me.SeniorDirStratDenom_Label.Visible = False
            Me.SeniorDirStrat_Label.Visible = False
            Me.SeniorDirStrat_Option.Visible = False
            Me.SeniorDirStrat_Text.Visible = False
            
        End If
        
        'check for qualification
        WeaponsDirQualStr = "SELECT Qualification " & _
                            "FROM Officers_Qualifications " & _
                            "WHERE Officer = '" & Alias & "' " & _
                            "AND Qualification = 'WeaponsDirector'"
        'qualification is present
        If CurrentDb.OpenRecordset(WeaponsDirQualStr).RecordCount > 0 Then
            'check the qualification box
            Me.WeaponsQual_Check.Value = True
        'qualification not present
        Else
            'hide strats based on qual
            Me.WeaponsDirStratDenom_Label.Visible = False
            Me.WeaponsDirStrat_Label.Visible = False
            Me.WeaponsDirStrat_Option.Visible = False
            Me.WeaponsDirStrat_Text.Visible = False
            
        End If
        
        'Lookup OfficerGrade
        RankStr = "SELECT OfficerGrade " & _
                    "FROM Ranks WHERE Rank = '" & OfficerRecord!Rank & "'"
        Set RankRecord = CurrentDb.OpenRecordset(RankStr)
        
        'Update available strat labels
        Me.RankStrat_Label.Caption = OfficerRecord!Rank & " Total:"
        Me.RankYearStrat_Label.Caption = OfficerRecord!Rank & "/" & OfficerRecord!YearGroup & ":"
        Me.OfficerGradeStrat_Label.Caption = RankRecord!OfficerGrade & ":"
        Me.LeaderRoleStrat_Label.Caption = OfficerRecord!LeaderRole & ":"
        Me.CareerStrat_Label.Caption = OfficerRecord!CareerField & ":"
        Me.InstructorCareerStrat_Label.Caption = "Instructor " & OfficerRecord!CareerField & ":"
        
        'Find the highest current rank for the given strat factor
        RankAvailableStr = "SELECT MAX(Rank) AS RankMax " & _
                            "FROM Officers_Stratifications WHERE StratificationFactor = '" & OfficerRecord!Rank & "'"
        Set RankAvailableRS = CurrentDb.OpenRecordset(RankAvailableStr)
        
        'stores the next available rank for the strat factor
        Dim RankAvailableInt
        
        'if there is no previous rank for the factor use 1
        If IsNull(RankAvailableRS!RankMax) Then
            RankAvailableInt = 1
        'if theres a previous rank use the next available
        Else
            RankAvailableInt = RankAvailableRS!RankMax + 1
        End If
        
        'change the value in the form text box
        Me.RankStrat_Text.Value = RankAvailableInt
        
        'calculate the strat denominator
        RankDenomStr = "SELECT Alias " & _
                        "FROM Officers WHERE Rank = '" & OfficerRecord!Rank & "'"
        Set RankDenomRS = CurrentDb.OpenRecordset(RankDenomStr)
        
        'show the value of the denominator
        If RankDenomRS.RecordCount > 0 Then
            RankDenomRS.MoveLast
            Me.RankStratDenom_Label.Caption = "/ " & RankDenomRS.RecordCount
        End If
        
        'Find the highest current rank for the given strat factor
        RankYearAvailableStr = "SELECT MAX(Rank) AS RankMax " & _
                            "FROM Officers_Stratifications WHERE StratificationFactor = '" & OfficerRecord!Rank & "/" & OfficerRecord!YearGroup & "'"
        Set RankYearAvailableRS = CurrentDb.OpenRecordset(RankYearAvailableStr)
        
        'stores the next available rank for the strat factor
        Dim RankYearAvailableInt
        
        'if there is no previous rank for the factor use 1
        If IsNull(RankYearAvailableRS!RankMax) Then
            RankYearAvailableInt = 1
        'if theres a previous rank use the next available
        Else
            RankYearAvailableInt = RankYearAvailableRS!RankMax + 1
        End If
        
        'change the value in the form text box
        Me.RankYearStrat_Text.Value = RankYearAvailableInt
        
        'calculate the strat denominator
        RankYearDenomStr = "SELECT Alias " & _
                        "FROM Officers WHERE Rank = '" & OfficerRecord!Rank & "' " & _
                        "AND YearGroup = " & OfficerRecord!YearGroup
        Set RankYearDenomRS = CurrentDb.OpenRecordset(RankYearDenomStr)
        
        'show the value of the denominator
        If RankYearDenomRS.RecordCount > 0 Then
            RankYearDenomRS.MoveLast
            Me.RankYearStratDenom_Label.Caption = "/ " & RankYearDenomRS.RecordCount
        End If
        
        'Find the highest current rank for the given strat factor
        OfficerGradeAvailableStr = "SELECT MAX(Rank) AS RankMax " & _
                            "FROM Officers_Stratifications WHERE StratificationFactor = '" & RankRecord!OfficerGrade & "'"
        Set OfficerGradeAvailableRS = CurrentDb.OpenRecordset(OfficerGradeAvailableStr)
        
        'stores the next available rank for the strat factor
        Dim OfficerGradeAvailableInt
        
        'if there is no previous rank for the factor use 1
        If IsNull(OfficerGradeAvailableRS!RankMax) Then
            OfficerGradeAvailableInt = 1
        'if theres a previous rank use the next available
        Else
            OfficerGradeAvailableInt = OfficerGradeAvailableRS!RankMax + 1
        End If
        
        'change the value in the form text box
        Me.OfficerGradeStrat_Text.Value = OfficerGradeAvailableInt
        
        'calculate the strat denominator
        OfficerGradeDenomStr = "SELECT Alias " & _
                                "FROM Officers INNER JOIN Ranks ON Officers.Rank = Ranks.Rank " & _
                                "WHERE Ranks.OfficerGrade = '" & RankRecord!OfficerGrade & "'"
        Set OfficerGradeDenomRS = CurrentDb.OpenRecordset(OfficerGradeDenomStr)
        
        'show the value of the denominator
        If OfficerGradeDenomRS.RecordCount > 0 Then
            OfficerGradeDenomRS.MoveLast
            Me.OfficerGradeStratDenom_Label.Caption = "/ " & OfficerGradeDenomRS.RecordCount
        End If
          
        'Find the highest current rank for the given strat factor
        LeaderRoleAvailableStr = "SELECT MAX(Rank) AS RankMax " & _
                            "FROM Officers_Stratifications WHERE StratificationFactor = '" & OfficerRecord!LeaderRole & "'"
        Set LeaderRoleAvailableRS = CurrentDb.OpenRecordset(LeaderRoleAvailableStr)
        
        'stores the next available rank for the strat factor
        Dim LeaderRoleAvailableInt
        
        'if there is no previous rank for the factor use 1
        If IsNull(LeaderRoleAvailableRS!RankMax) Then
            LeaderRoleAvailableInt = 1
        'if theres a previous rank use the next available
        Else
            LeaderRoleAvailableInt = LeaderRoleAvailableRS!RankMax + 1
        End If
        
        'change the value in the form text box
        Me.LeaderRoleStrat_Text.Value = LeaderRoleAvailableInt
        
        'calculate the strat denominator
        LeaderRoleDenomStr = "SELECT Alias " & _
                        "FROM Officers WHERE LeaderRole = '" & OfficerRecord!LeaderRole & "'"
        Set LeaderRoleDenomRS = CurrentDb.OpenRecordset(LeaderRoleDenomStr)
        
        'calculate the strat denominator
        If LeaderRoleDenomRS.RecordCount > 0 Then
            LeaderRoleDenomRS.MoveLast
            Me.LeaderRoleStratDenom_Label.Caption = "/ " & LeaderRoleDenomRS.RecordCount
        End If
        
        'Find the highest current rank for the given strat factor
        OverallAvailableStr = "SELECT MAX(Rank) AS RankMax " & _
                            "FROM Officers_Stratifications WHERE StratificationFactor = 'Overall'"
        Set OverallAvailableRS = CurrentDb.OpenRecordset(OverallAvailableStr)
        
        'stores the next available rank for the strat factor
        Dim OverallAvailableInt
        
        'if there is no previous rank for the factor use 1
        If IsNull(OverallAvailableRS!RankMax) Then
            OverallAvailableInt = 1
        'if theres a previous rank use the next available
        Else
            OverallAvailableInt = OverallAvailableRS!RankMax + 1
        End If
        Me.OverallStrat_Text.Value = OverallAvailableInt
        
        'Find the highest current rank for the given strat factor
        OfficerAvailableStr = "SELECT MAX(Rank) AS RankMax " & _
                            "FROM Officers_Stratifications WHERE StratificationFactor = 'Officer'"
        Set OfficerAvailableRS = CurrentDb.OpenRecordset(OfficerAvailableStr)
        
        'stores the next available rank for the strat factor
        Dim OfficerAvailableInt
        
        'if there is no previous rank for the factor use 1
        If IsNull(OfficerAvailableRS!RankMax) Then
            OfficerAvailableInt = 1
        'if theres a previous rank use the next available
        Else
            OfficerAvailableInt = OfficerAvailableRS!RankMax + 1
        End If
        
        'change the value in the form text box
        Me.OfficerStrat_Text.Value = OfficerAvailableInt
        
        OverallDenomStr = "SELECT Alias " & _
                        "FROM Officers"
        Set OverallDenomRS = CurrentDb.OpenRecordset(OverallDenomStr)
        
        'calculate the strat denominator
        If OverallDenomRS.RecordCount > 0 Then
            OverallDenomRS.MoveLast
            Me.OverallStratDenom_Label.Caption = "/ " & OverallDenomRS.RecordCount
            Me.OfficerStratDenom_Label.Caption = "/ " & OverallDenomRS.RecordCount
        End If
        
        'Find the highest current rank for the given strat factor
        CareerFieldAvailableStr = "SELECT MAX(Rank) AS RankMax " & _
                            "FROM Officers_Stratifications WHERE StratificationFactor = '" & OfficerRecord!CareerField & "'"
        Set CareerFieldAvailableRS = CurrentDb.OpenRecordset(CareerFieldAvailableStr)
        
        'stores the next available rank for the strat factor
        Dim CareerFieldAvailableInt
        
        'if there is no previous rank for the factor use 1
        If IsNull(CareerFieldAvailableRS!RankMax) Then
            CareerFieldAvailableInt = 1
        'if theres a previous rank use the next available
        Else
            CareerFieldAvailableInt = CareerFieldAvailableRS!RankMax + 1
        End If
        
        'change the value in the form text box
        Me.CareerStrat_Text.Value = CareerFieldAvailableInt
        
        'calculate the strat denominator
        CareerFieldDenomStr = "SELECT Alias " & _
                        "FROM Officers WHERE CareerField = '" & OfficerRecord!CareerField & "'"
        Set CareerFieldDenomRS = CurrentDb.OpenRecordset(CareerFieldDenomStr)
        
        'show the value of the denominator
        If CareerFieldDenomRS.RecordCount > 0 Then
            CareerFieldDenomRS.MoveLast
            Me.CareerStratDenom_Label.Caption = "/ " & CareerFieldDenomRS.RecordCount
        End If
        
        'Find the highest current rank for the given strat factor
        InstructorCareerAvailableStr = "SELECT MAX(Rank) AS RankMax " & _
                            "FROM Officers_Stratifications WHERE StratificationFactor = 'Instructor " & OfficerRecord!CareerField & "'"
        Set InstructorCareerAvailableRS = CurrentDb.OpenRecordset(InstructorCareerAvailableStr)
        
        'stores the next available rank for the strat factor
        Dim InstructorCareerAvailableInt
        
        'if there is no previous rank for the factor use 1
        If IsNull(InstructorCareerAvailableRS!RankMax) Then
            InstructorCareerAvailableInt = 1
        'if theres a previous rank use the next available
        Else
            InstructorCareerAvailableInt = InstructorCareerAvailableRS!RankMax + 1
        End If
        
        'change the value in the form text box
        Me.InstructorCareerStrat_Text.Value = InstructorCareerAvailableInt
        
        'calculate the strat denominator
        InstructorCareerFieldDenomStr = "SELECT Officer " & _
                        "FROM Officers_Qualifications " & _
                        "INNER JOIN  Officers ON Officers_Qualifications.Officer = Officers.Alias " & _
                        "WHERE Officers_Qualifications.Qualification = 'Instructor' " & _
                        "AND Officers.CareerField = '" & OfficerRecord!CareerField & "'"
        Set InstructorCareerFieldDenomRS = CurrentDb.OpenRecordset(InstructorCareerFieldDenomStr)
        
        'show the value of the denominator
        If InstructorCareerFieldDenomRS.RecordCount > 0 Then
            InstructorCareerFieldDenomRS.MoveLast
            Me.InstructorCareerStratDenom_Label.Caption = "/ " & InstructorCareerFieldDenomRS.RecordCount
        End If
        
        'Find the highest current rank for the given strat factor
        InstructorAvailableStr = "SELECT MAX(Rank) AS RankMax " & _
                            "FROM Officers_Stratifications WHERE StratificationFactor = 'Instructor'"
        Set InstructorAvailableRS = CurrentDb.OpenRecordset(InstructorAvailableStr)
        
        'stores the next available rank for the strat factor
        Dim InstructorAvailableInt
        
        'if there is no previous rank for the factor use 1
        If IsNull(InstructorAvailableRS!RankMax) Then
            InstructorAvailableInt = 1
        'if theres a previous rank use the next available
        Else
            InstructorAvailableInt = InstructorAvailableRS!RankMax + 1
        End If
        
        'change the value in the form text box
        Me.InstructorStrat_Text.Value = InstructorAvailableInt
        
        'calculate the strat denominator
        InstructorDenomStr = "SELECT Officer " & _
                        "FROM Officers_Qualifications " & _
                        "INNER JOIN  Officers ON Officers_Qualifications.Officer = Officers.Alias " & _
                        "WHERE Officers_Qualifications.Qualification = 'Instructor'"
        Set InstructorDenomRS = CurrentDb.OpenRecordset(InstructorDenomStr)
        
        'show the value of the denominator
        If InstructorDenomRS.RecordCount > 0 Then
            InstructorDenomRS.MoveLast
            Me.InstructorStratDenom_Label.Caption = "/ " & InstructorDenomRS.RecordCount
        End If
        
        'Find the highest current rank for the given strat factor
        WeaponsDirAvailableStr = "SELECT MAX(Rank) AS RankMax " & _
                            "FROM Officers_Stratifications WHERE StratificationFactor = 'WeaponsDirector'"
        Set WeaponsDirAvailableRS = CurrentDb.OpenRecordset(WeaponsDirAvailableStr)
        
        'stores the next available rank for the strat factor
        Dim WeaponsDirAvailableInt
        
        'if there is no previous rank for the factor use 1
        If IsNull(WeaponsDirAvailableRS!RankMax) Then
            WeaponsDirAvailableInt = 1
        'if theres a previous rank use the next available
        Else
            WeaponsDirAvailableInt = WeaponsDirAvailableRS!RankMax + 1
        End If
        
        'change the value in the form text box
        Me.WeaponsDirStrat_Text.Value = WeaponsDirAvailableInt
        
        'calculate the strat denominator
        WeaponsDirDenomStr = "SELECT Officer " & _
                        "FROM Officers_Qualifications " & _
                        "INNER JOIN  Officers ON Officers_Qualifications.Officer = Officers.Alias " & _
                        "WHERE Officers_Qualifications.Qualification = 'WeaponsDirector'"
        Set WeaponsDirDenomRS = CurrentDb.OpenRecordset(WeaponsDirDenomStr)
        
        'show the value of the denominator
        If WeaponsDirDenomRS.RecordCount > 0 Then
            WeaponsDirDenomRS.MoveLast
            Me.WeaponsDirStratDenom_Label.Caption = "/ " & WeaponsDirDenomRS.RecordCount
        End If
        
        'Find the highest current rank for the given strat factor
        SeniorDirAvailableStr = "SELECT MAX(Rank) AS RankMax " & _
                            "FROM Officers_Stratifications WHERE StratificationFactor = 'SeniorDirector'"
        Set SeniorDirAvailableRS = CurrentDb.OpenRecordset(SeniorDirAvailableStr)
        
        'stores the next available rank for the strat factor
        Dim SeniorDirAvailableInt
        
        'if there is no previous rank for the factor use 1
        If IsNull(SeniorDirAvailableRS!RankMax) Then
            SeniorDirAvailableInt = 1
        'if theres a previous rank use the next available
        Else
            SeniorDirAvailableInt = SeniorDirAvailableRS!RankMax + 1
        End If
        
        'change the value in the form text box
        Me.SeniorDirStrat_Text.Value = SeniorDirAvailableInt
        
        'calculate the strat denominator
        SeniorDirDenomStr = "SELECT Officer " & _
                        "FROM Officers_Qualifications " & _
                        "INNER JOIN  Officers ON Officers_Qualifications.Officer = Officers.Alias " & _
                        "WHERE Officers_Qualifications.Qualification = 'SeniorDirector'"
        Set SeniorDirDenomRS = CurrentDb.OpenRecordset(SeniorDirDenomStr)
        
        'show the value of the denominator
        If SeniorDirDenomRS.RecordCount > 0 Then
            SeniorDirDenomRS.MoveLast
            Me.SeniorDirStratDenom_Label.Caption = "/ " & SeniorDirDenomRS.RecordCount
        End If
        
        'Find the highest current rank for the given strat factor
        MCCAvailableStr = "SELECT MAX(Rank) AS RankMax " & _
                            "FROM Officers_Stratifications WHERE StratificationFactor = 'MissionCrewCommander'"
        Set MCCAvailableRS = CurrentDb.OpenRecordset(MCCAvailableStr)
        
        'stores the next available rank for the strat factor
        Dim MCCAvailableInt
        
        'if there is no previous rank for the factor use 1
        If IsNull(MCCAvailableRS!RankMax) Then
            MCCAvailableInt = 1
        'if theres a previous rank use the next available
        Else
            MCCAvailableInt = MCCAvailableRS!RankMax + 1
        End If
        
        'change the value in the form text box
        Me.MCCStrat_Text.Value = MCCAvailableInt
        
        'calculate the strat denominator
        MCCDenomStr = "SELECT Officer " & _
                        "FROM Officers_Qualifications " & _
                        "INNER JOIN  Officers ON Officers_Qualifications.Officer = Officers.Alias " & _
                        "WHERE Officers_Qualifications.Qualification = 'MissionCrewCommander'"
        Set MCCDenomRS = CurrentDb.OpenRecordset(MCCDenomStr)
        
        'show the value of the denominator
        If MCCDenomRS.RecordCount > 0 Then
            MCCDenomRS.MoveLast
            Me.MCCStratDenom_Label.Caption = "/ " & MCCDenomRS.RecordCount
        End If
        
        'lookup the officers current strat
        CurrentStratStr = "SELECT StratificationFactor, Rank, StratBy, StratDate " & _
                        "FROM Officers_Stratifications " & _
                        "WHERE Officer = '" & Alias & "'"
        Set CurrentStratRS = CurrentDb.OpenRecordset(CurrentStratStr)
        
        'if the officer is stratted select the current strat by default
        If CurrentStratRS.RecordCount > 0 Then
            Select Case CurrentStratRS!StratificationFactor
                Case CStr(OfficerRecord!Rank)
                    Me.RankStrat_Text.Value = CurrentStratRS!Rank
                    Me.Strat_OptionGrp.Value = 1
                Case OfficerRecord!Rank & "/" & OfficerRecord!YearGroup
                    Me.RankYearStrat_Text.Value = CurrentStratRS!Rank
                    Me.Strat_OptionGrp.Value = 2
                Case RankRecord!OfficerGrade
                    Me.OfficerGradeStrat_Text.Value = CurrentStratRS!Rank
                    Me.Strat_OptionGrp.Value = 3
                Case OfficerRecord!LeaderRole
                    Me.LeaderRoleStrat_Text.Value = CurrentStratRS!Rank
                    Me.Strat_OptionGrp.Value = 4
                Case "Overall"
                    Me.OverallStrat_Text.Value = CurrentStratRS!Rank
                    Me.Strat_OptionGrp.Value = 5
                Case "Officer"
                    Me.OfficerStrat_Text.Value = CurrentStratRS!Rank
                    Me.Strat_OptionGrp.Value = 6
                Case OfficerRecord!CareerField
                    Me.CareerStrat_Text.Value = CurrentStratRS!Rank
                    Me.Strat_OptionGrp.Value = 7
                Case "Instructor " & OfficerRecord!CareerField
                    Me.InstructorCareerStrat_Text.Value = CurrentStratRS!Rank
                    Me.Strat_OptionGrp.Value = 8
                Case "Instructor"
                    Me.InstructorStrat_Text.Value = CurrentStratRS!Rank
                    Me.Strat_OptionGrp.Value = 9
                Case "WeaponsDirector"
                    Me.WeaponsDirStrat_Text.Value = CurrentStratRS!Rank
                    Me.Strat_OptionGrp.Value = 10
                Case "SeniorDirector"
                    Me.SeniorDirStrat_Text.Value = CurrentStratRS!Rank
                    Me.Strat_OptionGrp.Value = 11
                Case "MissionCrewCommander"
                    Me.MCCStrat_Text.Value = CurrentStratRS!Rank
                    Me.Strat_OptionGrp.Value = 12
            End Select
            
            'display the officers current strat
            Me.LastStrat_Label.Caption = "Last Strat: #" & CurrentStratRS!Rank & _
                                            " " & CurrentStratRS!StratificationFactor & " by " & CurrentStratRS!StratBy & _
                                            " on " & CurrentStratRS!StratDate
        'if the officer isn't stratted
        Else
            'show that the officer hasn't been stratted
            Me.LastStrat_Label.Caption = "Last Strat: Never"
        End If
    'if no officer selection was passed to the form
    Else
        'close the form
        DoCmd.Close
    End If
End Sub
