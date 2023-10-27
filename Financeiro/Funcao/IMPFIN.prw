#INCLUDE "Totvs.ch"

 /*/{Protheus.doc} F240AFIL
    
    Função para importação do Contas a Receber e Contas a Pagar
    
    @type User Function
    @author TOTVS Nordeste (Elvis Siqueira)
    @since 25/10/2023
    @version 1.0
    @param Nil
    @return Nil
/*/
User Function IMPFIN
Local aTab := {"SE1 - Contas a Receber","SE2 - Contas a Pagar"}
Local oDialog, oPanel, oTSay, oCombo, oDlg

Private cTabela := ""

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
    oTSay  := TSay():New(76,5, {|| 'Os campos sitados acima deverão constar no arquivo para que seja possível o posicionamento no registro.'},oPanel,,,,,,.T.,,,200,50,,,,,,.T.)

oDialog:Activate()

cTabela := SubStr( cTabela, 1, At('-', cTabela) - 2)

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
Local cArq       := ""
Local cLinha     := ""
Local cTipoX3    := ""
Local cQry       := ""
Local cErro      := ""
Local cLogErro   := ""
Local __cAlias   := "TMP"+FWTimeStamp(1)
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
        
            If nPosField1 > 0
                SA1->(DBSetOrder(3))//A1_FILIAL+A1_CGC
                If SA1->(MSseek(FWxFilial("SA1")+aRegistro[nPosField1,2]))

                    aAdd(aRegistro,{"E1_CLIENTE",SA1->A1_COD ,Nil})
                    aAdd(aRegistro,{"E1_LOJA"   ,SA1->A1_LOJA,Nil})

                    Begin Transaction
                        lMsErroAuto := .F.
                        MSExecAuto({|x,y| FINA040(x,y)}, aRegistro, 3)
                        
                        If lMsErroAuto
                            DisarmTransaction()
                            aErro := {}
                            For nY := 1 To Len(aRegistro)
                                aAdd(aErro,aRegistro[nY,2])
                            Next nY
                            aLogAuto := GetAutoGRLog()
                            cLogErro := ""
                            For nY := 1 To Len(aLogAuto)
                                cLogErro += aLogAuto[nY]
                            Next nY
                            aAdd(aErro,cLogErro)
                            cErro += ArrTokStr(aErro, ";")+Chr(10)
                        EndIf
                    End Transaction
                Else
                    aErro := {}
                    For nY := 1 To Len(aRegistro)
                        aAdd(aErro,aRegistro[nY,2])
                    Next nY
                    aAdd(aErro,"")
                    aAdd(aErro,"")
                    aAdd(aErro,"Cliente não encontrado.")
                    cErro += ArrTokStr(aErro, ";")+Chr(10)
                EndIF 
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

                    Begin Transaction
                        lMsErroAuto := .F.
                        MSExecAuto({|x,y| FINA050(x,y)}, aRegistro, 3)
                        
                        If lMsErroAuto
                            DisarmTransaction()
                            aErro := {}
                            For nY := 1 To Len(aRegistro)
                                aAdd(aErro,aRegistro[nY,2])
                            Next nY
                            aLogAuto := GetAutoGRLog()
                            cLogErro := ""
                            For nY := 1 To Len(aLogAuto)
                                cLogErro += aLogAuto[nY]
                            Next nY
                            aAdd(aErro,cLogErro)
                            cErro += ArrTokStr(aErro, ";")+Chr(10)
                        EndIf
                    End Transaction
                Else
                    aErro := {}
                    For nY := 1 To Len(aRegistro)
                        aAdd(aErro,aRegistro[nY,2])
                    Next nY
                    aAdd(aErro,"")
                    aAdd(aErro,"")
                    aAdd(aErro,"Fornecedor não encontrado.")
                    cErro += ArrTokStr(aErro, ";")+Chr(10)
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

                    Begin Transaction
                        lMsErroAuto := .F.
                        MSExecAuto({|x,y| FINA050(x,y)}, aRegistro, 3)
                        
                        If lMsErroAuto
                            DisarmTransaction()
                            aErro := {}
                            For nY := 1 To Len(aRegistro)
                                aAdd(aErro,aRegistro[nY,2])
                            Next nY 
                            aLogAuto := GetAutoGRLog()
                            cLogErro := ""
                            For nY := 1 To Len(aLogAuto)
                                cLogErro += aLogAuto[nY]
                            Next nY
                            aAdd(aErro,cLogErro)
                            cErro += ArrTokStr(aErro, ";")+Chr(10)
                        EndIf
                    End Transaction
                Else 
                    aErro := {}
                    For nY := 1 To Len(aRegistro)
                        aAdd(aErro,aRegistro[nY,2])
                    Next nY
                    aAdd(aErro,"")
                    aAdd(aErro,"")
                    aAdd(aErro,"Fornecedor não encontrado.")
                    cErro += ArrTokStr(aErro, ";")+Chr(10)
                EndIF
                
                IF Select(__cAlias) <> 0
                    (__cAlias)->(DbCloseArea())
                EndIf

            EndIf
        
      EndCase
    EndIf     
  Endif
FT_FSKIP()
EndDo

FT_FUSE()

If !Empty(cErro)
  MemoWrite("C:\temp\LogErroImp"+cTabela+"_"+FWTimeStamp(1)+".txt", cErro)
EndIF

Return
