#INCLUDE "Totvs.ch"
#Include "TOPCONN.ch"
#Include "TBICONN.ch"

 /*/{Protheus.doc} F240AFIL
    
    Função para importação do Contas a Receber e Contas a Pagar
    
    @type User Function
    @author TOTVS Nordeste (Elvis Siqueira)
    @since 06/12/2023
    @version 1.0
    @param Nil
    @return Nil
/*/
User Function IMPFIN
    Local aTab := {"SE1 - Contas a Receber","SE2 - Contas a Pagar","SE5 - Movimentação Bancaria "}
    Local aTpMov := {"3 - Pagar", "4 - Receber", "5 - Excluir"}
    Local cTpMov := ""
    Local oDialog, oPanel, oTSay, oCombo, oDlg

    Private cTabela := ""
    Private nOption := ""

    oDialog := FWDialogModal():New()
    oDialog:SetBackground( .T. ) 
    oDialog:SetTitle( 'Selecione a tabela abaixo:' )
    oDialog:SetSize( 140, 250 )
    oDialog:EnableFormBar( .T. )
    oDialog:SetCloseButton( .F. )
    oDialog:SetEscClose( .F. )
    oDialog:CreateDialog()
    oDialog:CreateFormBar()
    oDialog:AddCloseButton(Nil, "Confirmar")

    oPanel := oDialog:GetPanelMain()

        oTSay  := TSay():New(10,5,{|| "Tabela: "},oPanel,,,,,,.T.,,,50,70,,,,,,.T.)
        oCombo := TComboBox():New(29,28,{|u|iif(PCount()>0,cTabela:=u,cTabela)},aTab,100,20,oDlg,,{||},,,,.T.,,,,,,,,,'cTabela')
    
        oTSay  := TSay():New(30,5, {|| "Observações da Rotina: "},oPanel,,,,,,.T.,,,200,50,,,,,,.T.)
        oTSay  := TSay():New(40,5, {|| "Está rotina irá utilizar como chave os indices abaixo: "},oPanel,,,,,,.T.,,,200,50,,,,,,.T.)
        oTSay  := TSay():New(48,20,{|| 'SE1 - Contas a Receber (CNPJ/CPF)'},oPanel,,,,,,.T.,,,200,50,,,,,,.T.)
        oTSay  := TSay():New(56,20,{|| 'SE2 - Contas a Pagar (CNPJ/CPF e CODIGO)'},oPanel,,,,,,.T.,,,200,50,,,,,,.T.)
        oTSay  := TSay():New(64,20,{|| 'SE5 - Movimentação Bancaria ()'},oPanel,,,,,,.T.,,,200,50,,,,,,.T.)
        oTSay  := TSay():New(76,5, {|| 'Os campos sitados acima deverão constar no arquivo para que seja possível o posicionamento no registro.'},oPanel,,,,,,.T.,,,200,50,,,,,,.T.)

    oDialog:Activate()

    cTabela := SubStr( cTabela, 1, At('-', cTabela) - 2)

    If cTabela == "SE5"
        oDialog := Nil
        oPanel  := Nil
        oTSay   := Nil
        oCombo  := Nil
        oDlg    := Nil

        oDialog := FWDialogModal():New()
        oDialog:SetBackground( .T. ) 
        oDialog:SetTitle( 'Selecione o Tipo de Movimentação' )
        oDialog:SetSize( 100, 170 )
        oDialog:EnableFormBar( .T. )
        oDialog:SetCloseButton( .F. )
        oDialog:SetEscClose( .F. )
        oDialog:CreateDialog()
        oDialog:CreateFormBar()
        oDialog:AddCloseButton(Nil, "Confirmar")

        oPanel := oDialog:GetPanelMain()

            oTSay  := TSay():New(10,5,{|| "Tipo de Movimentação: "},oPanel,,,,,,.T.,,,50,70,,,,,,.T.)
            oCombo := TComboBox():New(35,50,{|u|iif(PCount()>0,cTpMov:=u,cTpMov)},aTpMov,100,20,oDlg,,{||},,,,.T.,,,,,,,,,'cTpMov')

        oDialog:Activate()

        nOption := Val(SubStr( cTpMov, 1, At('-', cTpMov) - 2))
    EndIF 

    Processa({|| xProcessa()}, "Integrando Registros...")

Return

Static Function xProcessa()
    Local aRegistro  := {}
    Local aCabeca    := {}
    Local aFieldsX3  := {}
    Local aRetX3     := {}
    Local aLogAuto   := {}
    Local aErro      := {}
    Local nAtual     := 0
    Local nFim       := 0
    Local nPosField1 := 0
    Local nPosField2 := 0
    Local nPosField3 := 0
    Local cArq       := ""
    Local cLinha     := ""
    Local cTipoX3    := ""
    Local cQry       := ""
    Local cQryInsert := ""
    Local cLogErro   := ""
    Local __cAlias   := "TMP"+FWTimeStamp(1)
    Local nStatus    := 0
    Local dDtBaseAx  := dDataBase
    Local nY, cDado

    Private oModel := Nil
    Private lMSHelpAuto := .T.
    Private lAutoErrNoFile := .T.
    Private lMsErroAuto := .F.
    Private aRotina := {}

    cArq := TFileDialog( "CSV Files (*.csv) | Arquivo texto (*.txt)",,,, .F., /*GETF_MULTISELECT*/ )

    If !File(cArq)
        Return
    EndIf

    FT_FUSE(cArq)
    nFim := FT_FLASTREC()
    ProcRegua(nFim)
    FT_FGOTOP()

    While !FT_FEOF()
            
        nAtual++
        IncProc("Gravando alteração " + cValToChar(nAtual) + " de " + cValToChar(nFim) + "...")

        cLinha := FT_FREADLN()
                
        If !Empty(cLinha)
            aRegistro := {}
            aRegistro := Separa(cLinha,";",.T.)
            
        If Empty(aCabeca)
        
        cQry := " SELECT SX3.X3_CAMPO, SX3.X3_TITULO " 
        cQry += " FROM "+ RetSqlName("SX3") +" SX3 "
        cQry += " WHERE SX3.D_E_L_E_T_ <> '*' "
        cQry += " AND	SX3.X3_ARQUIVO  = '"+cTabela+"' " 
        cQry += " ORDER BY X3_ORDEM "
        cQry := ChangeQuery(cQry)
        IF Select(__cAlias) <> 0
            (__cAlias)->(DbCloseArea())
        EndIf
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),__cAlias,.T.,.T.)

        While!(__cAlias)->(EOF())

            aAdd(aFieldsX3,{Alltrim((__cAlias)->X3_CAMPO),Alltrim((__cAlias)->X3_TITULO)})

        (__cAlias)->(DBSkip())
        EndDo

        IF Select(__cAlias) <> 0
            (__cAlias)->(DbCloseArea())
        EndIf

        For nY := 1 To Len(aRegistro)
            nPosField1 := aScan(aFieldsX3, {|x| AllTrim(x[2]) == Alltrim(aRegistro[nY])})
            If !Empty(nPosField1)
            aRegistro[nY] := aFieldsX3[nPosField1,1]
            EndIf 
        Next nY

        aCabeca := aClone(aRegistro)
        
        Else 

        For nY := 1 To Len(aRegistro)
            aRetX3  := TamSX3(aCabeca[nY])
            If Len(aRetX3) > 0
            cTipoX3 := aRetX3[3]
            //Converte de Caracter para o tipo do campo da SX3
            If cTipoX3 == "N"
                aRegistro[nY] := {aCabeca[nY], Val(Pad(StrTran(aRegistro[nY],",","."), TamSx3(aCabeca[nY])[1])),Nil} //Converte p/ Númerico
            ElseIf cTipoX3 == "D"
                aRegistro[nY] := {aCabeca[nY], CToD(aRegistro[nY]),Nil} //Converte p/ Data
            ElseIf cTipoX3 $ ('C,M')
                aRegistro[nY] := {aCabeca[nY], Pad(aRegistro[nY], TamSx3(aCabeca[nY])[1]),Nil} //Não converte
            EndIf
            ElseIF aCabeca[nY] == "CNPJ/CPF" .OR. aCabeca[nY] == "CODIGO"
            cDado := aRegistro[nY]
            aRegistro[nY] := {aCabeca[nY], cDado, Nil}
            EndIf                 
        Next nY
            
        Do Case 
            Case cTabela == "SE1"
            DBSelectArea("SA1")
            nPosField1 := aScan(aRegistro, {|x| AllTrim(Upper(x[1])) == "CNPJ/CPF"})
            nPosField2 := aScan(aRegistro, {|x| AllTrim(Upper(x[1])) == "CODIGO"})
            
                If nPosField1 > 0 .AND. IIF(nPosField1 > 0, !Empty(aRegistro[nPosField1,2]), .F.)
                    SA1->(DBSetOrder(3))//A1_FILIAL+A1_CGC
                    If SA1->(MSseek(FWxFilial("SA1")+aRegistro[nPosField1,2]))

                        aAdd(aRegistro,{"E1_CLIENTE",SA1->A1_COD ,Nil})
                        aAdd(aRegistro,{"E1_LOJA"   ,SA1->A1_LOJA,Nil})

                        Begin Transaction
                            lMsErroAuto := .F.
                            MSExecAuto({|x,y| FINA040(x,y)}, aRegistro, 3)
                            
                            If lMsErroAuto
                                aErro := {}
                                For nY := 1 To Len(aRegistro)
                                    aAdd(aErro,Alltrim(aRegistro[nY,2]))
                                Next nY
                                aLogAuto := GetAutoGRLog()
                                cLogErro := ""
                                For nY := 1 To Len(aLogAuto)
                                    cLogErro += aLogAuto[nY]
                                Next nY
                                
                                    TCLink()
                                        cQryInsert := " INSERT INTO " + RetSqlName("XXE") 
                                        cQryInsert += " ( XXE_ID,   " 
                                        cQryInsert += " XXE_ADAPT,  "
                                        cQryInsert += " XXE_FILE,   " 
                                        cQryInsert += " XXE_LAYOUT, "
                                        cQryInsert += " XXE_DESC,   "
                                        cQryInsert += " XXE_DATE,   "
                                        cQryInsert += " XXE_TIME,   "
                                        cQryInsert += " XXE_TYPE,   "
                                        cQryInsert += " XXE_ERROR,  "
                                        cQryInsert += " XXE_USRID,  "
                                        cQryInsert += " XXE_USRNAM, "
                                        cQryInsert += " XXE_COMPLE, "
                                        cQryInsert += " XXE_ORIGIN, "
                                        cQryInsert += " XXE_IDOPER, "
                                        cQryInsert += " XXE_XML )   "
                                        cQryInsert += " VALUES (    "
                                        cQryInsert += " '"+XXEProx()+"',"
                                        cQryInsert += " '"+FunName()+"',"
                                        cQryInsert += " '"+cArq+"',"
                                        cQryInsert += " '"+cTabela+"',"
                                        cQryInsert += " '"+FWX2Nome(cTabela)+"',"
                                        cQryInsert += " '"+DToS(dDataBase)+"',"
                                        cQryInsert += " '"+Time()+"',"
                                        cQryInsert += " '2',"
                                        cQryInsert += " '"+cLogErro+"',"
                                        cQryInsert += " '"+__cUserID+"',"
                                        cQryInsert += " '"+cUserName+"',"
                                        cQryInsert += " '"+cLogErro+"',"
                                        cQryInsert += " '"+cValToChar(nAtual)+"-"+cValToChar(nFim)+"',"
                                        cQryInsert += " '"+FWTimeStamp(1)+"',"
                                        cQryInsert += " '"+ArrTokStr(aErro, ";")+"')"
                                        nStatus := TCSqlExec(cQryInsert)
                                    TCUnlink()
                                    DisarmTransaction()                       
                            EndIf
                        End Transaction
                    Else
                        aErro := {}
                        For nY := 1 To Len(aRegistro)
                            aAdd(aErro,Alltrim(aRegistro[nY,2]))
                        Next nY
                        
                        Begin Transaction
                            TCLink()
                                cQryInsert := " INSERT INTO " + RetSqlName("XXE") 
                                cQryInsert += " ( XXE_ID,   " 
                                cQryInsert += " XXE_ADAPT,  "
                                cQryInsert += " XXE_FILE,   " 
                                cQryInsert += " XXE_LAYOUT, "
                                cQryInsert += " XXE_DESC,   "
                                cQryInsert += " XXE_DATE,   "
                                cQryInsert += " XXE_TIME,   "
                                cQryInsert += " XXE_TYPE,   "
                                cQryInsert += " XXE_ERROR,  "
                                cQryInsert += " XXE_USRID,  "
                                cQryInsert += " XXE_USRNAM, "
                                cQryInsert += " XXE_COMPLE, "
                                cQryInsert += " XXE_ORIGIN, "
                                cQryInsert += " XXE_IDOPER, "
                                cQryInsert += " XXE_XML )   "
                                cQryInsert += " VALUES (    "
                                cQryInsert += " '"+XXEProx()+"',"
                                cQryInsert += " '"+FunName()+"',"
                                cQryInsert += " '"+cArq+"',"
                                cQryInsert += " '"+cTabela+"',"
                                cQryInsert += " '"+FWX2Nome(cTabela)+"',"
                                cQryInsert += " '"+DToS(dDataBase)+"',"
                                cQryInsert += " '"+Time()+"',"
                                cQryInsert += " '2',"
                                cQryInsert += " 'Cliente não encontrado.',"
                                cQryInsert += " '"+__cUserID+"',"
                                cQryInsert += " '"+cUserName+"',"
                                cQryInsert += " 'Cliente não encontrado.',"
                                cQryInsert += " '"+cValToChar(nAtual)+"-"+cValToChar(nFim)+"',"
                                cQryInsert += " '"+FWTimeStamp(1)+"',"
                                cQryInsert += " '"+ArrTokStr(aErro, ";")+"')"
                                nStatus := TCSqlExec(cQryInsert)
                            TCUnlink()
                            DisarmTransaction()
                        End Transactin

                    EndIF 
                ElseIF nPosField2 > 0 .AND. IIF(nPosField2 > 0, !Empty(aRegistro[nPosField2,2]), .F.)
                    
                    cQry := " SELECT A1_COD, A1_LOJA " 
                    cQry += " FROM "+ RetSqlName("SA1") +" SA1 "
                    cQry += " WHERE SA1.D_E_L_E_T_ <> '*' "
                    cQry += " AND	SA1.A1_COD  = '"+aRegistro[nPosField2,2]+"' " 
                    cQry := ChangeQuery(cQry)
                    IF Select(__cAlias) <> 0
                        (__cAlias)->(DbCloseArea())
                    EndIf
                    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),__cAlias,.T.,.T.)

                    SA1->(DBSetOrder(1))//A1_FILIAL+A1_COD+A1_LOJA
                    If SA1->(MSseek(FWxFilial("SA1")+(__cAlias)->(A1_COD)+(__cAlias)->(A1_LOJA)))
                
                        aAdd(aRegistro,{"E1_CLIENTE",SA1->A1_COD ,Nil})
                        aAdd(aRegistro,{"E1_LOJA"   ,SA1->A1_LOJA,Nil})

                        Begin Transaction
                            lMsErroAuto := .F.
                            MSExecAuto({|x,y| FINA040(x,y)}, aRegistro, 3)
                            
                            If lMsErroAuto
                                aErro := {}
                                For nY := 1 To Len(aRegistro)
                                    aAdd(aErro,Alltrim(aRegistro[nY,2]))
                                Next nY 
                                aLogAuto := GetAutoGRLog()
                                cLogErro := ""
                                For nY := 1 To Len(aLogAuto)
                                    cLogErro += aLogAuto[nY]
                                Next nY
                                                            
                                Begin Transaction
                                    TCLink()
                                        cQryInsert := " INSERT INTO " + RetSqlName("XXE") 
                                        cQryInsert += " ( XXE_ID,   " 
                                        cQryInsert += " XXE_ADAPT,  "
                                        cQryInsert += " XXE_FILE,   " 
                                        cQryInsert += " XXE_LAYOUT, "
                                        cQryInsert += " XXE_DESC,   "
                                        cQryInsert += " XXE_DATE,   "
                                        cQryInsert += " XXE_TIME,   "
                                        cQryInsert += " XXE_TYPE,   "
                                        cQryInsert += " XXE_ERROR,  "
                                        cQryInsert += " XXE_USRID,  "
                                        cQryInsert += " XXE_USRNAM, "
                                        cQryInsert += " XXE_COMPLE, "
                                        cQryInsert += " XXE_ORIGIN, "
                                        cQryInsert += " XXE_IDOPER, "
                                        cQryInsert += " XXE_XML )   "
                                        cQryInsert += " VALUES (    "
                                        cQryInsert += " '"+XXEProx()+"',"
                                        cQryInsert += " '"+FunName()+"',"
                                        cQryInsert += " '"+cArq+"',"
                                        cQryInsert += " '"+cTabela+"',"
                                        cQryInsert += " '"+FWX2Nome(cTabela)+"',"
                                        cQryInsert += " '"+DToS(dDataBase)+"',"
                                        cQryInsert += " '"+Time()+"',"
                                        cQryInsert += " '2',"
                                        cQryInsert += " '"+cLogErro+"',"
                                        cQryInsert += " '"+__cUserID+"',"
                                        cQryInsert += " '"+cUserName+"',"
                                        cQryInsert += " '"+cLogErro+"',"
                                        cQryInsert += " '"+cValToChar(nAtual)+"-"+cValToChar(nFim)+"',"
                                        cQryInsert += " '"+FWTimeStamp(1)+"',"
                                        cQryInsert += " '"+ArrTokStr(aErro, ";")+"')"
                                        nStatus := TCSqlExec(cQryInsert)
                                    TCUnlink()
                                    DisarmTransaction()
                                End Transactin
                                
                            EndIf
                        End Transaction
                    Else 
                        aErro := {}
                        For nY := 1 To Len(aRegistro)
                            aAdd(aErro,Alltrim(aRegistro[nY,2]))
                        Next nY
                                            
                        Begin Transaction
                            TCLink()
                                cQryInsert := " INSERT INTO " + RetSqlName("XXE") 
                                cQryInsert += " ( XXE_ID,   " 
                                cQryInsert += " XXE_ADAPT,  "
                                cQryInsert += " XXE_FILE,   " 
                                cQryInsert += " XXE_LAYOUT, "
                                cQryInsert += " XXE_DESC,   "
                                cQryInsert += " XXE_DATE,   "
                                cQryInsert += " XXE_TIME,   "
                                cQryInsert += " XXE_TYPE,   "
                                cQryInsert += " XXE_ERROR,  "
                                cQryInsert += " XXE_USRID,  "
                                cQryInsert += " XXE_USRNAM, "
                                cQryInsert += " XXE_COMPLE, "
                                cQryInsert += " XXE_ORIGIN, "
                                cQryInsert += " XXE_IDOPER, "
                                cQryInsert += " XXE_XML )   "
                                cQryInsert += " VALUES (    "
                                cQryInsert += " '"+XXEProx()+"',"
                                cQryInsert += " '"+FunName()+"',"
                                cQryInsert += " '"+cArq+"',"
                                cQryInsert += " '"+cTabela+"',"
                                cQryInsert += " '"+FWX2Nome(cTabela)+"',"
                                cQryInsert += " '"+DToS(dDataBase)+"',"
                                cQryInsert += " '"+Time()+"',"
                                cQryInsert += " '2',"
                                cQryInsert += " 'Cliente não encontrado.',"
                                cQryInsert += " '"+__cUserID+"',"
                                cQryInsert += " '"+cUserName+"',"
                                cQryInsert += " 'Cliente não encontrado.',"
                                cQryInsert += " '"+cValToChar(nAtual)+"-"+cValToChar(nFim)+"',"
                                cQryInsert += " '"+FWTimeStamp(1)+"',"
                                cQryInsert += " '"+ArrTokStr(aErro, ";")+"')"
                                nStatus := TCSqlExec(cQryInsert)
                            TCUnlink()
                            DisarmTransaction()
                        End Transactin

                    EndIF
                    
                    IF Select(__cAlias) <> 0
                        (__cAlias)->(DbCloseArea())
                    EndIf
                EndIf 
            
            Case cTabela == "SE2"
            
            DBSelectArea("SA2")
            nPosField1 := aScan(aRegistro, {|x| AllTrim(Upper(x[1])) == "CNPJ/CPF"})
            nPosField2 := aScan(aRegistro, {|x| AllTrim(Upper(x[1])) == "CODIGO"})
            
                If nPosField1 > 0 .AND. IIF(nPosField1 > 0, !Empty(aRegistro[nPosField1,2]), .F.)
                    SA2->(DBSetOrder(3))//A2_FILIAL+A2_CGC
                    If SA2->(MSseek(FWxFilial("SA2")+aRegistro[nPosField1,2]))
                
                        aAdd(aRegistro,{"E2_FORNECE",SA2->A2_COD ,Nil})
                        aAdd(aRegistro,{"E2_LOJA"   ,SA2->A2_LOJA,Nil})
                        
                        nPosField3 := aScan(aRegistro, {|x| AllTrim(Upper(x[1])) == "E2_NOMFOR"})
                        If nPosField3 > 0
                            aAdd(aRegistro,{"E2_NOMFOR" ,aRegistro[nPosField3,2],Nil})
                        EndIF
                        nPosField3 := aScan(aRegistro, {|x| AllTrim(Upper(x[1])) == "E2_FORBCO"})
                        If nPosField3 > 0
                            aAdd(aRegistro,{"E2_FORBCO" ,aRegistro[nPosField3,2],Nil})
                        EndIF 
                        
                        nPosField3 := aScan(aRegistro, {|x| AllTrim(Upper(x[1])) == "E2_FORAGE"})
                        If nPosField3 > 0
                            aAdd(aRegistro,{"E2_FORAGE" ,aRegistro[nPosField3,2],Nil})
                        EndIF 
                        
                        nPosField3 := aScan(aRegistro, {|x| AllTrim(Upper(x[1])) == "E2_FORCTA"})
                        If nPosField3 > 0
                            aAdd(aRegistro,{"E2_FORCTA" ,aRegistro[nPosField3,2],Nil})
                        EndIF 
                        
                        nPosField3 := aScan(aRegistro, {|x| AllTrim(Upper(x[1])) == "E2_FCTADV"})
                        If nPosField3 > 0
                            aAdd(aRegistro,{"E2_FCTADV" ,aRegistro[nPosField3,2],Nil})
                        EndIF 
                        

                        Begin Transaction
                            lMsErroAuto := .F.
                            MSExecAuto({|x,y| FINA050(x,y)}, aRegistro, 3)
                            
                            If lMsErroAuto
                                aErro := {}
                                For nY := 1 To Len(aRegistro)
                                    aAdd(aErro,Alltrim(aRegistro[nY,2]))
                                Next nY
                                aLogAuto := GetAutoGRLog()
                                cLogErro := ""
                                For nY := 1 To Len(aLogAuto)
                                    cLogErro += aLogAuto[nY]
                                Next nY
                                                            
                                TCLink()
                                    cQryInsert := " INSERT INTO " + RetSqlName("XXE") 
                                    cQryInsert += " ( XXE_ID,   " 
                                    cQryInsert += " XXE_ADAPT,  "
                                    cQryInsert += " XXE_FILE,   " 
                                    cQryInsert += " XXE_LAYOUT, "
                                    cQryInsert += " XXE_DESC,   "
                                    cQryInsert += " XXE_DATE,   "
                                    cQryInsert += " XXE_TIME,   "
                                    cQryInsert += " XXE_TYPE,   "
                                    cQryInsert += " XXE_ERROR,  "
                                    cQryInsert += " XXE_USRID,  "
                                    cQryInsert += " XXE_USRNAM, "
                                    cQryInsert += " XXE_COMPLE, "
                                    cQryInsert += " XXE_ORIGIN, "
                                    cQryInsert += " XXE_IDOPER, "
                                    cQryInsert += " XXE_XML )   "
                                    cQryInsert += " VALUES (    "
                                    cQryInsert += " '"+XXEProx()+"',"
                                    cQryInsert += " '"+FunName()+"',"
                                    cQryInsert += " '"+cArq+"',"
                                    cQryInsert += " '"+cTabela+"',"
                                    cQryInsert += " '"+FWX2Nome(cTabela)+"',"
                                    cQryInsert += " '"+DToS(dDataBase)+"',"
                                    cQryInsert += " '"+Time()+"',"
                                    cQryInsert += " '2',"
                                    cQryInsert += " '"+cLogErro+"',"
                                    cQryInsert += " '"+__cUserID+"',"
                                    cQryInsert += " '"+cUserName+"',"
                                    cQryInsert += " '"+cLogErro+"',"
                                    cQryInsert += " '"+cValToChar(nAtual)+"-"+cValToChar(nFim)+"',"
                                    cQryInsert += " '"+FWTimeStamp(1)+"',"
                                    cQryInsert += " '"+ArrTokStr(aErro, ";")+"')"
                                    nStatus := TCSqlExec(cQryInsert)
                                TCUnlink()
                                DisarmTransaction()
                            EndIf
                        End Transaction
                    Else
                        aErro := {}
                        For nY := 1 To Len(aRegistro)
                            aAdd(aErro,Alltrim(aRegistro[nY,2]))
                        Next nY
                                            
                        Begin Transaction
                            TCLink()
                                cQryInsert := " INSERT INTO " + RetSqlName("XXE") 
                                cQryInsert += " ( XXE_ID,   " 
                                cQryInsert += " XXE_ADAPT,  "
                                cQryInsert += " XXE_FILE,   " 
                                cQryInsert += " XXE_LAYOUT, "
                                cQryInsert += " XXE_DESC,   "
                                cQryInsert += " XXE_DATE,   "
                                cQryInsert += " XXE_TIME,   "
                                cQryInsert += " XXE_TYPE,   "
                                cQryInsert += " XXE_ERROR,  "
                                cQryInsert += " XXE_USRID,  "
                                cQryInsert += " XXE_USRNAM, "
                                cQryInsert += " XXE_COMPLE, "
                                cQryInsert += " XXE_ORIGIN, "
                                cQryInsert += " XXE_IDOPER, "
                                cQryInsert += " XXE_XML )   "
                                cQryInsert += " VALUES (    "
                                cQryInsert += " '"+XXEProx()+"',"
                                cQryInsert += " '"+cArq+"',"
                                cQryInsert += " '"+cTabela+"',"
                                cQryInsert += " '"+FunName()+"',"
                                cQryInsert += " '"+FWX2Nome(cTabela)+"',"
                                cQryInsert += " '"+DToS(dDataBase)+"',"
                                cQryInsert += " '"+Time()+"',"
                                cQryInsert += " '2',"
                                cQryInsert += " 'Fornecedor não encontrado.',"
                                cQryInsert += " '"+__cUserID+"',"
                                cQryInsert += " '"+cUserName+"',"
                                cQryInsert += " 'Fornecedor não encontrado.',"
                                cQryInsert += " '"+cValToChar(nAtual)+"-"+cValToChar(nFim)+"',"
                                cQryInsert += " '"+FWTimeStamp(1)+"',"
                                cQryInsert += " '"+ArrTokStr(aErro, ";")+"')"
                                nStatus := TCSqlExec(cQryInsert)
                            TCUnlink()
                            DisarmTransaction()
                        End Transactin

                    EndIF
                ElseIF nPosField2 > 0 .AND. SA2->(FieldPos("A2_XCOD")) > 0 .AND. IIF(nPosField2 > 0, !Empty(aRegistro[nPosField2,2]), .F.)
                    
                    cQry := " SELECT A2_COD, A2_LOJA " 
                    cQry += " FROM "+ RetSqlName("SA2") +" SA2 "
                    cQry += " WHERE SA2.D_E_L_E_T_ <> '*' "
                    cQry += " AND	SA2.A2_XCOD  = '"+aRegistro[nPosField2,2]+"' " 
                    cQry := ChangeQuery(cQry)
                    IF Select(__cAlias) <> 0
                        (__cAlias)->(DbCloseArea())
                    EndIf
                    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),__cAlias,.T.,.T.)

                    SA2->(DBSetOrder(1))//A2_FILIAL+A2_COD+A2_LOJA
                    If SA2->(MSseek(FWxFilial("SA2")+(__cAlias)->(A2_COD)+(__cAlias)->(A2_LOJA)))
                
                        aAdd(aRegistro,{"E2_FORNECE",SA2->A2_COD ,Nil})
                        aAdd(aRegistro,{"E2_LOJA"   ,SA2->A2_LOJA,Nil})
                        
                        nPosField3 := aScan(aRegistro, {|x| AllTrim(Upper(x[1])) == "E2_NOMFOR"})
                        If nPosField3 > 0
                            aAdd(aRegistro,{"E2_NOMFOR" ,aRegistro[nPosField3,2],Nil})
                        EndIF
                        nPosField3 := aScan(aRegistro, {|x| AllTrim(Upper(x[1])) == "E2_FORBCO"})
                        If nPosField3 > 0
                            aAdd(aRegistro,{"E2_FORBCO" ,aRegistro[nPosField3,2],Nil})
                        EndIF 
                        
                        nPosField3 := aScan(aRegistro, {|x| AllTrim(Upper(x[1])) == "E2_FORAGE"})
                        If nPosField3 > 0
                            aAdd(aRegistro,{"E2_FORAGE" ,aRegistro[nPosField3,2],Nil})
                        EndIF 
                        
                        nPosField3 := aScan(aRegistro, {|x| AllTrim(Upper(x[1])) == "E2_FORCTA"})
                        If nPosField3 > 0
                            aAdd(aRegistro,{"E2_FORCTA" ,aRegistro[nPosField3,2],Nil})
                        EndIF 
                        
                        nPosField3 := aScan(aRegistro, {|x| AllTrim(Upper(x[1])) == "E2_FCTADV"})
                        If nPosField3 > 0
                            aAdd(aRegistro,{"E2_FCTADV" ,aRegistro[nPosField3,2],Nil})
                        EndIF

                        Begin Transaction
                            lMsErroAuto := .F.
                            MSExecAuto({|x,y| FINA050(x,y)}, aRegistro, 3)
                            
                            If lMsErroAuto
                                aErro := {}
                                For nY := 1 To Len(aRegistro)
                                    aAdd(aErro,Alltrim(aRegistro[nY,2]))
                                Next nY 
                                aLogAuto := GetAutoGRLog()
                                cLogErro := ""
                                For nY := 1 To Len(aLogAuto)
                                    cLogErro += aLogAuto[nY]
                                Next nY
                                
                                TCLink()
                                    cQryInsert := " INSERT INTO " + RetSqlName("XXE") 
                                    cQryInsert += " ( XXE_ID,   " 
                                    cQryInsert += " XXE_ADAPT,  "
                                    cQryInsert += " XXE_FILE,   " 
                                    cQryInsert += " XXE_LAYOUT, "
                                    cQryInsert += " XXE_DESC,   "
                                    cQryInsert += " XXE_DATE,   "
                                    cQryInsert += " XXE_TIME,   "
                                    cQryInsert += " XXE_TYPE,   "
                                    cQryInsert += " XXE_ERROR,  "
                                    cQryInsert += " XXE_USRID,  "
                                    cQryInsert += " XXE_USRNAM, "
                                    cQryInsert += " XXE_COMPLE, "
                                    cQryInsert += " XXE_ORIGIN, "
                                    cQryInsert += " XXE_IDOPER, "
                                    cQryInsert += " XXE_XML )   "
                                    cQryInsert += " VALUES (    "
                                    cQryInsert += " '"+XXEProx()+"',"
                                    cQryInsert += " '"+FunName()+"',"
                                    cQryInsert += " '"+cArq+"',"
                                    cQryInsert += " '"+cTabela+"',"
                                    cQryInsert += " '"+FWX2Nome(cTabela)+"',"
                                    cQryInsert += " '"+DToS(dDataBase)+"',"
                                    cQryInsert += " '"+Time()+"',"
                                    cQryInsert += " '2',"
                                    cQryInsert += " '"+cLogErro+"',"
                                    cQryInsert += " '"+__cUserID+"',"
                                    cQryInsert += " '"+cUserName+"',"
                                    cQryInsert += " '"+cLogErro+"',"
                                    cQryInsert += " '"+cValToChar(nAtual)+"-"+cValToChar(nFim)+"',"
                                    cQryInsert += " '"+FWTimeStamp(1)+"',"
                                    cQryInsert += " '"+ArrTokStr(aErro, ";")+"')"
                                    nStatus := TCSqlExec(cQryInsert)
                                TCUnlink()
                                DisarmTransaction()
                            EndIf
                        End Transaction
                    Else 
                        aErro := {}
                        For nY := 1 To Len(aRegistro)
                            aAdd(aErro,Alltrim(aRegistro[nY,2]))
                        Next nY
                        
                        Begin Transaction
                            TCLink()
                                cQryInsert := " INSERT INTO " + RetSqlName("XXE") 
                                cQryInsert += " ( XXE_ID,   " 
                                cQryInsert += " XXE_ADAPT,  "
                                cQryInsert += " XXE_FILE,   " 
                                cQryInsert += " XXE_LAYOUT, "
                                cQryInsert += " XXE_DESC,   "
                                cQryInsert += " XXE_DATE,   "
                                cQryInsert += " XXE_TIME,   "
                                cQryInsert += " XXE_TYPE,   "
                                cQryInsert += " XXE_ERROR,  "
                                cQryInsert += " XXE_USRID,  "
                                cQryInsert += " XXE_USRNAM, "
                                cQryInsert += " XXE_COMPLE, "
                                cQryInsert += " XXE_ORIGIN, "
                                cQryInsert += " XXE_IDOPER, "
                                cQryInsert += " XXE_XML )   "
                                cQryInsert += " VALUES (    "
                                cQryInsert += " '"+XXEProx()+"',"
                                cQryInsert += " '"+FunName()+"',"
                                cQryInsert += " '"+cArq+"',"
                                cQryInsert += " '"+cTabela+"',"
                                cQryInsert += " '"+FWX2Nome(cTabela)+"',"
                                cQryInsert += " '"+DToS(dDataBase)+"',"
                                cQryInsert += " '"+Time()+"',"
                                cQryInsert += " '2',"
                                cQryInsert += " 'Fornecedor não encontrado.',"
                                cQryInsert += " '"+__cUserID+"',"
                                cQryInsert += " '"+cUserName+"',"
                                cQryInsert += " 'Fornecedor não encontrado.',"
                                cQryInsert += " '"+cValToChar(nAtual)+"-"+cValToChar(nFim)+"',"
                                cQryInsert += " '"+FWTimeStamp(1)+"',"
                                cQryInsert += " '"+ArrTokStr(aErro, ";")+"')"
                                nStatus := TCSqlExec(cQryInsert)
                            TCUnlink()
                            DisarmTransaction()
                        End Transactin

                    EndIF
                    
                    IF Select(__cAlias) <> 0
                        (__cAlias)->(DbCloseArea())
                    EndIf

                EndIf
            
            Case cTabela == "SE5"
                
                nPosField1 := aScan(aRegistro, {|x| AllTrim(Upper(x[1])) == "E5_DATA"})
                If !Empty(nPosField1)
                    dDataBase := aRegistro[nPosField1,2]
                Else 
                    dDataBase := dDtBaseAx
                EndIF

                Begin Transaction
                    lMsErroAuto := .F.
                    MSExecAuto({|x,y,z| FINA100(x,y,z)},0,aRegistro,nOption)
                    
                    If lMsErroAuto
                        aErro := {}
                        For nY := 1 To Len(aRegistro)
                            aAdd(aErro,Alltrim(aRegistro[nY,2]))
                        Next nY
                        aLogAuto := GetAutoGRLog()
                        cLogErro := ""
                        For nY := 1 To Len(aLogAuto)
                            cLogErro += aLogAuto[nY]
                        Next nY
                        
                            TCLink()
                                cQryInsert := " INSERT INTO " + RetSqlName("XXE") 
                                cQryInsert += " ( XXE_ID,   " 
                                cQryInsert += " XXE_ADAPT,  "
                                cQryInsert += " XXE_FILE,   " 
                                cQryInsert += " XXE_LAYOUT, "
                                cQryInsert += " XXE_DESC,   "
                                cQryInsert += " XXE_DATE,   "
                                cQryInsert += " XXE_TIME,   "
                                cQryInsert += " XXE_TYPE,   "
                                cQryInsert += " XXE_ERROR,  "
                                cQryInsert += " XXE_USRID,  "
                                cQryInsert += " XXE_USRNAM, "
                                cQryInsert += " XXE_COMPLE, "
                                cQryInsert += " XXE_ORIGIN, "
                                cQryInsert += " XXE_IDOPER, "
                                cQryInsert += " XXE_XML )   "
                                cQryInsert += " VALUES (    "
                                cQryInsert += " '"+XXEProx()+"',"
                                cQryInsert += " '"+FunName()+"',"
                                cQryInsert += " '"+cArq+"',"
                                cQryInsert += " '"+cTabela+"',"
                                cQryInsert += " '"+FWX2Nome(cTabela)+"',"
                                cQryInsert += " '"+DToS(dDataBase)+"',"
                                cQryInsert += " '"+Time()+"',"
                                cQryInsert += " '2',"
                                cQryInsert += " '"+cLogErro+"',"
                                cQryInsert += " '"+__cUserID+"',"
                                cQryInsert += " '"+cUserName+"',"
                                cQryInsert += " '"+cLogErro+"',"
                                cQryInsert += " '"+cValToChar(nAtual)+"-"+cValToChar(nFim)+"',"
                                cQryInsert += " '"+FWTimeStamp(1)+"',"
                                cQryInsert += " '"+ArrTokStr(aErro, ";")+"')"
                                nStatus := TCSqlExec(cQryInsert)
                            TCUnlink()
                            DisarmTransaction()                       
                    EndIf
                End Transaction
            
                dDataBase := dDtBaseAx
            EndCase

        EndIf     
    Endif
    FT_FSKIP()
    EndDo

    FT_FUSE()
Return

//====================================================================================================================\
/*/{Protheus.doc}XXEProx
  ====================================================================================================================
	@description
	Retorna o próximo número para a tabela XXE
/*/
//===================================================================================================================\
Static Function XXEProx()

	Local cRet := StrZero(0,10)
	Local cQry := ''
	Local cAli := GetNextAlias()

	cQry+= " SELECT MAX(XXE_ID) XXE_ID "
	cQry+= " FROM " + RetSqlTab('XXE')
	cQry+= " WHERE " + RetSqlCond('XXE')

	cQry:= ChangeQuery(cQry)

	If Select(cAli) <> 0
		(cAli)->(DbCloseArea())
	EndIf

	dbUseArea(.T.,'TOPCONN', TCGenQry(,,cQry),cAli, .F., .T.)

	If (cAli)->(!Eof())
		cRet:= (cAli)->XXE_ID
	EndIf

	If Select(cAli) <> 0
		(cAli)->(DbCloseArea())
	EndIf

	cRet:= Soma1(cRet)

Return ( cRet )
