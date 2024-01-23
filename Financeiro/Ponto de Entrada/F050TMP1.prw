#INCLUDE "Totvs.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Rwmake.ch"

/*/{Protheus.doc} FFIN001
    O Ponto de Entrada está presente nas funções F050EscRat (definindo se é rateio ou pré-configurado) 
    e CtbRatFin (rateio de Contas a Pagar no Contabilidade Gerencial(SIGACTB).
@type function
@author Elvis Siqueira
@since 31/10/2023
/*/

User Function F050TMP1()
    Local nOrig := ParamIxb[9]
    Local oExcel
    Local aTamLin
    Local nContP,nContL
    Local cArq

    If nOrig <> 2
        Return
    EndIF 

    cArq := tFileDialog( "Arquivo de planilha Excel (*.xlsx) | Todos tipos (*.*)",,,, .F., /*GETF_MULTISELECT*/)
    oExcel	:= YExcel():new(,cArq)

    For nContP := 1 To oExcel:LenPlanAt()	        //Ler as Planilhas
        oExcel:SetPlanAt(nContP)		            //Informa qual a planilha atual
        ConOut("Planilha:"+oExcel:GetPlanAt("2"))	//Nome da Planilha
        aTamLin	:= oExcel:LinTam() 		            //Linha inicio e fim da linha
        For nContL := aTamLin[1] To aTamLin[2]
            If nContL > 1 .AND. ( ValType(oExcel:GetValue(nContL,3)) != "U" .OR. ValType(oExcel:GetValue(nContL,4)) != "U" )
                aTamCol	:= oExcel:ColTam(nContL)    //Coluna inicio e fim
                If aTamCol[1] > 0                   //Se a linha tem algum valor
                    
                    Reclock("TMP",.T.)              //Alteração do alias "TMP1" para "TMP" para a rotina de rateio
                        CTJ_DEBITO := Alltrim(oExcel:GetValue(nContL,1))        //Conta Contabil Debito
                        CTJ_CREDIT := Alltrim(oExcel:GetValue(nContL,2))        //Conta Contabil Credito
                        CTJ_PERCEN := oExcel:GetValue(nContL,3)                 //Percentual Ratear
                        CTJ_VALOR  := oExcel:GetValue(nContL,4)                 //Valor Ratear
                        CTJ_HIST   := Alltrim(oExcel:GetValue(nContL,5))        //Historico Rateio
                        CTJ_CCD    := Alltrim(oExcel:GetValue(nContL,6))        //Centro de Custo Debito
                        CTJ_CCC    := Alltrim(oExcel:GetValue(nContL,7))        //Centro de Custo Credito
                        CTJ_ITEMD  := Alltrim(oExcel:GetValue(nContL,8))        //Item Contabil Debito
                        CTJ_ITEMC  := Alltrim(oExcel:GetValue(nContL,9))        //Item Contabil Credito
                    MSUNLOCK()
                EndIf
            EndIf
        Next
    Next

    oExcel:Close()

Return
