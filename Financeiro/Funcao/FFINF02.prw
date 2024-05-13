//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "TBICONN.CH"

//----------------------------------------------------------------------
/*/{PROTHEUS.DOC} FFINF02
FUNÇÃO FFINF02 - Tela para consulta do fluxo de caixa
@VERSION PROTHEUS 12
@SINCE 07/05/24
/*/
//----------------------------------------------------------------------

User Function FFINF02()
    Local cFilQry   := Space(250)
    Local _cQry     := ""
    Local _cBanco   := ""
    Local _cAgenc   := ""
    Local _cConta   := ""
    Local oDialog, oPanel, oTSay, oTButton
    Local nY

	Private aDays := {}
    Private aBank := {}
    Private dDataIni  := FirstDate(dDataBase)
    Private dDataFim  := LastDate(dDataBase)
    Private cAliasSE1 := GetNextAlias()
    Private cAliasSE2 := GetNextAlias()
    Private cAliasSE5 := GetNextAlias()
    Private cAliasSE8 := GetNextAlias()

    oDialog := FWDialogModal():New()
    oDialog:SetBackground( .T. ) 
    oDialog:SetTitle( 'Parâmetros (Fluxo de Caixa)' )
    oDialog:SetSize( 150, 210 )
    oDialog:EnableFormBar( .T. )
    oDialog:SetCloseButton( .F. )
    oDialog:SetEscClose( .F. )
    oDialog:CreateDialog()
    oDialog:CreateFormBar()
    oDialog:AddCloseButton(Nil, "Confirmar")

    oPanel := oDialog:GetPanelMain()

        oTSay  := TSay():New(17,5,{|| "Data Inicio: "},oPanel,,,,,,.T.,,,50,70,,,,,,.T.)
        @ 13,35 MSGET dDataIni SIZE 050,011 OF oPanel PIXEL 
        oTSay  := TSay():New(17,100,{|| "Data Fim: "},oPanel,,,,,,.T.,,,50,70,,,,,,.T.)
        @ 13,125 MSGET dDataFim SIZE 050,011 OF oPanel PIXEL 
        oTSay  := TSay():New(35,5,{|| "Filial: "},oPanel,,,,,,.T.,,,50,70,,,,,,.T.)
        @ 32,25 MSGET cFilQry SIZE 160,011 OF oPanel PIXEL F3 "LJ782A"

		oTSay  := TSay():New(70,5,{|| "Selecione os bancos: "},oPanel,,,,,,.T.,,,50,70,,,,,,.T.) 
		oTButton := TButton():New( 055, 050, "Selecionar Banco",oPanel,{||SelectBank()}, 60,40,,,.F.,.T.,.F.,,.F.,,,.F. )

    oDialog:Activate()

    nCount := 0

    aAdd(aDays,dDataIni)
    For nY := 1 To DateDiffDay(dDataIni,dDataFim) 
        aAdd(aDays,dDataIni+nY)
    Next 

    _cQry := " SELECT E1_VENCREA, E1_XSEGREG, SUM(E1_VALOR) AS VALOR, E1_DEBITO, E1_CREDIT " 
    _cQry += " FROM "+ RetSqlName("SE1")
    _cQry += " WHERE D_E_L_E_T_ <> '*' "
    If !Empty(Alltrim(cFilQry))
    _cQry += " AND	E1_FILIAL  IN "+FormatIn(Alltrim(cFilQry),",")+" "
    EndIF 
    _cQry += " AND	E1_VENCREA BETWEEN '"+DToS(dDataIni)+"' AND '"+DToS(dDataFim)+"'
    _cQry += " GROUP BY E1_VENCREA, E1_XSEGREG, E1_DEBITO, E1_CREDIT "
    _cQry += " ORDER BY E1_VENCREA "
    _cQry := ChangeQuery(_cQry)
    IF Select(cAliasSE1) <> 0
        (cAliasSE1)->(DbCloseArea())
    EndIf
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cAliasSE1,.T.,.T.)

    _cQry := " SELECT SA2.A2_NOME, SE2.E2_HIST, SE2.E2_VENCREA, SE2.E2_NUM, SE2.E2_VALOR AS VALOR " 
    _cQry += " FROM "+ RetSqlName("SE2") + " SE2 "
    _cQry += " INNER JOIN "+ RetSqlName("SA2") + " SA2 ON SA2.A2_COD = SE2.E2_FORNECE AND SA2.A2_LOJA = SE2.E2_LOJA "
    _cQry += " WHERE SE2.D_E_L_E_T_ <> '*' "
    _cQry += " AND SA2.D_E_L_E_T_ <> '*' "
    If !Empty(Alltrim(cFilQry))
    _cQry += " AND	SE2.E2_FILIAL  IN "+FormatIn(Alltrim(cFilQry),",")+" "
    EndIF 
    _cQry += " AND	SE2.E2_VENCREA BETWEEN '"+DToS(dDataIni)+"' AND '"+DToS(dDataFim)+"'
    _cQry += " GROUP BY SA2.A2_NOME, SE2.E2_VENCREA, SE2.E2_HIST, SE2.E2_NUM, SE2.E2_VALOR "
    _cQry += " ORDER BY E2_VENCREA "
    _cQry := ChangeQuery(_cQry)
    IF Select(cAliasSE2) <> 0
        (cAliasSE2)->(DbCloseArea())
    EndIf
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cAliasSE2,.T.,.T.)

    If Len(aBank) > 0

        For nY := 1 To Len(aBank)
            _cBanco += IIF(nY > 1 , ";"+aBank[nY,1] , aBank[nY,1])
            _cAgenc += IIF(nY > 1 , ";"+aBank[nY,2] , aBank[nY,2])
            _cConta += IIF(nY > 1 , ";"+aBank[nY,3] , aBank[nY,3])
        Next
    
        _cQry := " SELECT SE5.E5_DATA, SA6.A6_NOME, SE5.E5_VALOR AS VALOR, SE5.E5_NATUREZ, SE5.E5_CREDITO, SE5.E5_DEBITO " 
        _cQry += " FROM "+ RetSqlName("SE5") + " SE5 "
        _cQry += " INNER JOIN "+ RetSqlName("SA6") + " SA6 "
        _cQry += " ON SA6.A6_COD = SE5.E5_BANCO AND SA6.A6_AGENCIA = SE5.E5_AGENCIA AND SA6.A6_NUMCON = SE5.E5_CONTA "
        _cQry += " WHERE SE5.D_E_L_E_T_ <> '*' "
        _cQry += " AND SA6.D_E_L_E_T_ <> '*' "
        If !Empty(Alltrim(cFilQry))
        _cQry += " AND	SE5.E5_FILIAL  IN "+FormatIn(Alltrim(cFilQry),",")+" "
        EndIF
        _cQry += " AND	SE5.E5_BANCO   IN "+FormatIn(_cBanco, ";")+" "
        _cQry += " AND	SE5.E5_AGENCIA IN "+FormatIn(_cAgenc, ";")+" "
        _cQry += " AND	SE5.E5_CONTA   IN "+FormatIn(_cConta, ";")+" "
        _cQry += " AND	SE5.E5_DATA BETWEEN '"+DToS(dDataIni)+"' AND '"+DToS(dDataFim)+"'
        _cQry += " AND	SE5.E5_ORIGEM = 'FINA100' "
        _cQry += " GROUP BY SE5.E5_DATA, SA6.A6_NOME, SE5.E5_VALOR, SE5.E5_NATUREZ, SE5.E5_CREDITO, SE5.E5_DEBITO "
        _cQry += " ORDER BY SE5.E5_DATA "
        _cQry := ChangeQuery(_cQry)
        IF Select(cAliasSE5) <> 0
            (cAliasSE5)->(DbCloseArea())
        EndIf
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cAliasSE5,.T.,.T.)


        _cQry := " SELECT SUM(E8_SALATUA) AS SALDO " 
        _cQry += " FROM "+ RetSqlName("SE8")
        _cQry += " WHERE D_E_L_E_T_ <> '*' "
        If !Empty(Alltrim(cFilQry))
        _cQry += " AND	E8_FILIAL  IN "+FormatIn(Alltrim(cFilQry),",")+" "
        EndIF
        _cQry += " AND	E8_BANCO   IN "+FormatIn(_cBanco, ";")+" "
        _cQry += " AND	E8_AGENCIA IN "+FormatIn(_cAgenc, ";")+" "
        _cQry += " AND	E8_CONTA   IN "+FormatIn(_cConta, ";")+" "
        _cQry += " AND	E8_DTSALAT = "+DToS(dDataIni-1)+" "
        _cQry := ChangeQuery(_cQry)
        IF Select(cAliasSE8) <> 0
            (cAliasSE8)->(DbCloseArea())
        EndIf
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cAliasSE8,.T.,.T.)

    EndIF 

    If !Empty(dDataIni) .AND. !Empty(dDataFim)
        FwMsgRun(NIL, {|| U_FFINR02()}, "Processando", "Gerando relatório...")
    EndIF 

    IF Select(cAliasSE1) <> 0
        (cAliasSE1)->(DbCloseArea())
    EndIf
    IF Select(cAliasSE2) <> 0
        (cAliasSE2)->(DbCloseArea())
    EndIf
    IF Select(cAliasSE5) <> 0
        (cAliasSE5)->(DbCloseArea())
    EndIf
    IF Select(cAliasSE8) <> 0
        (cAliasSE8)->(DbCloseArea())
    EndIf

Return 

/*/{Protheus.doc} SelectBank
Tela para seleção dos bancos
@type function
@return return_type, return_description
/*/
Static Function SelectBank
	Local aColsBrw  := {}
    Local aColsSX3  := {}
    Local _cQry     := ""
    Local cAliasQry := GetNextAlias()

	Private oMarkBrowse, oDialog, oPanel
    Private cAliasBrw := GetNextAlias()
	Private cMarca    := "X"
	Private oTabTMP   := FWTemporaryTable():New(cAliasBrw)
    Private aFields   := {}
    Private aTamanho  := MsAdvSize()
    Private nJanLarg  := aTamanho[5]
    Private nJanAltu  := aTamanho[6]

	AAdd(aColsBrw,{BuscarSX3('A6_COD'	 ,,aColsSX3), "TP_COD"    ,'C',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1}) // Codigo do Banco
	AAdd(aColsBrw,{BuscarSX3('A6_AGENCIA',,aColsSX3), "TP_AGENCIA",'C',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.F.,,,,,,,,1}) // Agencia do banco
	AAdd(aColsBrw,{BuscarSX3('A6_NUMCON' ,,aColsSX3), "TP_NUMCON" ,'C',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.T.,,,,,,,,1}) // Conta Corrente no Banco
	AAdd(aColsBrw,{BuscarSX3('A6_NOME'   ,,aColsSX3), "TP_NOME"   ,'D',aColsSX3[3],aColsSX3[4],aColsSX3[2],1,,.T.,,,,,,,,1}) // Nome do banco
    
    aAdd(aFields, {"TP_MARK"   ,"C",1,0})
    aAdd(aFields, {"TP_COD"    ,"C",FWTamSX3("A6_COD")[1]    ,FWTamSX3("A6_COD")[2]		,"Banco"		,"",""})
    aAdd(aFields, {"TP_AGENCIA","C",FWTamSX3("A6_AGENCIA")[1],FWTamSX3("A6_AGENCIA")[2]	,"Nro Agencia"	,"",""})
    aAdd(aFields, {"TP_NUMCON" ,"C",FWTamSX3("A6_NUMCON")[1] ,FWTamSX3("A6_NUMCON")[2]	,"Nro Conta"	,"",""})
	aAdd(aFields, {"TP_NOME"   ,"C",FWTamSX3("A6_NOME")[1]   ,FWTamSX3("A6_NOME")[2]	,"Nome Banco"	,"",""})

    oTabTMP:SetFields(aFields)
    oTabTMP:Create()

    _cQry := " SELECT A6_COD, A6_AGENCIA, A6_NUMCON, A6_DVCTA, A6_NOME  " 
    _cQry += " FROM "+ RetSqlName("SA6")
    _cQry += " WHERE D_E_L_E_T_ <> '*' "
    _cQry += " AND	A6_FILIAL = '"+FWxFilial('SA6')+"' "
    _cQry += " ORDER BY A6_COD "
    _cQry := ChangeQuery(_cQry)
    IF Select(cAliasQry) <> 0
        (cAliasQry)->(DbCloseArea())
    EndIf
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cAliasQry,.T.,.T.)

    While !(cAliasQry)->(Eof())
        If FwIsNumeric((cAliasQry)->A6_COD)
            RecLock(cAliasBrw,.T.)
                (cAliasBrw)->TP_COD		:= (cAliasQry)->A6_COD
                (cAliasBrw)->TP_AGENCIA := (cAliasQry)->A6_AGENCIA
                (cAliasBrw)->TP_NUMCON 	:= (cAliasQry)->A6_NUMCON
                (cAliasBrw)->TP_NOME	:= (cAliasQry)->A6_NOME
            MsUnlock(cAliasBrw)
        EndIF
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())
	(cAliasBrw)->(DbGoTop())

    oDialog := FWDialogModal():New()
    oDialog:SetBackground( .T. ) 
    oDialog:SetTitle( 'Tela para Marcação dos Bancos' )
    oDialog:SetSize( 300, 600 )
    oDialog:EnableFormBar( .T. )
    oDialog:SetCloseButton( .F. )
    oDialog:SetEscClose( .F. )
    oDialog:CreateDialog()
    oDialog:CreateFormBar()
    oDialog:AddButton('Confirmar' , { || fnBankMark() },,3,0)

    oPanel := oDialog:GetPanelMain()
        oMarkBrowse:= FWMarkBrowse():New()
        oMarkBrowse:SetDescription("Bancos")
        oMarkBrowse:SetFields(aColsBrw)
        oMarkBrowse:SetTemporary(.T.)
        oMarkBrowse:SetAlias(cAliasBrw)
        oMarkBrowse:SetFieldMark("TP_MARK")
        oMarkBrowse:SetMark(cMarca,cAliasBrw,"TP_MARK")
        oMarkBrowse:SetAllMark({ || oMarkBrowse:AllMark() })
        oMarkBrowse:SetWalkThru(.F.)
        oMarkBrowse:SetAmbiente(.F.)
        oMarkBrowse:SetUseFilter(.T.)
        oMarkBrowse:SetOwner(oPanel)
        oMarkBrowse:DisableReport()
        oMarkBrowse:DisableDetails()
        oMarkBrowse:Activate()
    oDialog:Activate()

	oTabTMP:Delete()
    oMarkBrowse:DeActivate()

Return

/*/{Protheus.doc} fnBankMark
Função que percorre os registros marcados da tela
/*/
Static Function fnBankMark()
    Local aArea  := FWGetArea()
    Local cMarca := oMarkBrowse:Mark()
    
    aBank := {}

    (cAliasBrw)->(DbGoTop())
    While ! (cAliasBrw)->(EoF())
      
        If oMarkBrowse:IsMark(cMarca)
           aAdd(aBank,{(cAliasBrw)->TP_COD,(cAliasBrw)->TP_AGENCIA,(cAliasBrw)->TP_NUMCON})
        EndIf
           
        (cAliasBrw)->(DbSkip())
    EndDo

    oDialog:DeActivate()

    FWRestArea(aArea)
Return
