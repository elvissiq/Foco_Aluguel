#INCLUDE 'totvs.ch'

/*/{Protheus.doc} VALFINREC
@type function
@version 
@author TOTVS Nordeste
@since 06/11/2023
@return
/*/

User Function VALFINREC()

Processa({|| xProcessa()}, "Integrando Registros...")

Return 

Static Function xProcessa()
    Local oExcel
    Local nAtual := 0
    Local aTamLin
    Local nContP,nContL
    Local cArq 

    cArq := tFileDialog( "Arquivo de planilha Excel (*.xlsx) | Todos tipos (*.*)",,,, .F., /*GETF_MULTISELECT*/)
    oExcel	:= YExcel():new(,cArq)

    DBSelectArea("SE1")
    SE1->(DBSetOrder(1))

    For nContP := 1 To oExcel:LenPlanAt()	        //Ler as Planilhas
        oExcel:SetPlanAt(nContP)		            //Informa qual a planilha atual
        ConOut("Planilha:"+oExcel:GetPlanAt("2"))	//Nome da Planilha
        aTamLin	:= oExcel:LinTam() 		            //Linha inicio e fim da linha
        For nContL := aTamLin[1] To aTamLin[2]

            aTamCol	:= oExcel:ColTam(nContL)

            nAtual++
            IncProc("Gravando alteração " + cValToChar(nAtual) + " de " + cValToChar(aTamLin[2]) + "...")
            
            If aTamCol[1] > 0
                SE1->(DBGoTop())
                IF SE1->(MsSeek(Pad(oExcel:GetValue(nContL,1),TamSX3("E1_FILIAL")[1])+;
                                Pad(oExcel:GetValue(nContL,2),TamSX3("E1_PREFIXO")[1])+;
                                Pad(oExcel:GetValue(nContL,3),TamSX3("E1_NUM")[1])+;
                                Pad(oExcel:GetValue(nContL,4),TamSX3("E1_PARCELA")[1])+;
                                Pad(oExcel:GetValue(nContL,5),TamSX3("E1_TIPO")[1])))
                 
                 RecLock("SE1",.F.)
                  SE1->E1_VALOR  := oExcel:GetValue(nContL,6)
                  SE1->E1_SALDO  := oExcel:GetValue(nContL,6)
                  SE1->E1_VLCRUZ := oExcel:GetValue(nContL,6)
                 SE1->(MsUnLock())  
                
                Else 
                    FWAlertError("Linha "+cValToChar(nContL),"Não Posicionou!")
                EndIF 
            EndIf
        
        Next
    Next 

    oExcel:Close()

Return
