#INCLUDE "Totvs.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Rwmake.ch"

/*/{Protheus.doc} NATSEZLOAD

    Ponto de entrada para carregar regra de rateio especifica no Contas a Receber.

@type function
@author Elvis Siqueira
@since 26/01/2024
/*/

User Function NATSEZLOAD()
    Local oExcel
    Local nValor := ParamIxb[4]
    Local aRet := {}
    Local aTamLin := {}
    Local nPercen := 0
    Local nTotVal := 0
    Local nContP,nContL
    Local cArq 

    cArq := tFileDialog( "Arquivo de planilha Excel (*.xlsx) | Todos tipos (*.*)",,,, .F., /*GETF_MULTISELECT*/)
    oExcel	:= YExcel():new(,cArq)

    For nContP := 1 To oExcel:LenPlanAt()	        //Ler as Planilhas
        oExcel:SetPlanAt(nContP)		            //Informa qual a planilha atual
        ConOut("Planilha:"+oExcel:GetPlanAt("2"))	//Nome da Planilha
        aTamLin	:= oExcel:LinTam() 		            //Linha inicio e fim da linha
        For nContL := aTamLin[1] To aTamLin[2]
            If nContL > 1 .AND. ( ValType(oExcel:GetValue(nContL,2)) != "U" .OR. ValType(oExcel:GetValue(nContL,3)) != "U" )
                aTamCol	:= oExcel:ColTam(nContL)    //Coluna inicio e fim
                If aTamCol[1] > 0                   //Se a linha tem algum valor

                    If !Empty(oExcel:GetValue(nContL,3))
                        nPercen := oExcel:GetValue(nContL,3)
                    Else
                        nPercen := (( oExcel:GetValue(nContL,2) / nValor ) * 100)
                    EndIf 

                    aAdd(aRet,{ Alltrim(oExcel:GetValue(nContL,1)),;      //Centro de Custo
                                oExcel:GetValue(nContL,2),;               //Vlr. Movim.
                                nPercen,;                                 //Perc. Distr.
                                Alltrim(oExcel:GetValue(nContL,4)),;      //Conta Contabil
                                Alltrim(oExcel:GetValue(nContL,5)),;      //Item Contabil
                                Alltrim(oExcel:GetValue(nContL,6)),;      //Classe Valor
                                0,;  // PIS CC 
                                0,;  // COFINS CC
                                "SZE",;                                   //Alias WT
                                0,;                                       //Recno WT
                                .F.})
                                                          
                    nTotVal += oExcel:GetValue(nContL,2)    
                EndIf
            EndIf
        Next

        If nValor < nTotVal
           aRet[Len(aRet)][02] := aRet[Len(aRet)][02] - (nTotVal - nValor)
        elseIf nValor > nTotVal
            aRet[Len(aRet)][02] := aRet[Len(aRet)][02] - (nValor - nTotVal)
        EndIf   

    Next

    oExcel:Close()

Return(aRet)
