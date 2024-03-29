#INCLUDE 'totvs.ch'

/*/{Protheus.doc} MT100RTX

    Ponto-de-Entrada: MT100RTX - Manipula as informação na tela de rateio por centro de custo	

@type function
@version 
@author TOTVS Nordeste
@since 02/01/2024
@return
/*/

User Function MT100RTX()
    Local oExcel
    Local aColst  := {}
    Local aRet    := {} 
    Local nValor  := 0
    Local nPercen := 0
    Local nPosIt  := aScan( aHeader, { |x| AllTrim( x[2] ) == 'DE_ITEM' } )
    Local nPosPer := aScan( aHeader, { |x| AllTrim( x[2] ) == 'DE_PERC' } )
    Local nPosCC  := aScan( aHeader, { |x| AllTrim( x[2] ) == 'DE_CC' } )
    Local nPosCon := aScan( aHeader, { |x| AllTrim( x[2] ) == 'DE_CONTA' } )
    Local nPosItc := aScan( aHeader, { |x| AllTrim( x[2] ) == 'DE_ITEMCTA' } )
    Local aTamLin
    Local nContP,nContL
    Local nY, cArq 

    cArq := tFileDialog( "Arquivo de planilha Excel (*.xlsx) | Todos tipos (*.*)",,,, .F., /*GETF_MULTISELECT*/)
    oExcel	:= YExcel():new(,cArq)
    
    For nY := 1 To Len(aColSD1)
        nValor += aColSD1[nY,8] //Valor total do Item
    Next

    For nY := 1 To Len(PARAMIXB[2,1])
        aAdd(aColst,PARAMIXB[2,1,nY])
    Next 

        For nContP := 1 To oExcel:LenPlanAt()	        //Ler as Planilhas
            oExcel:SetPlanAt(nContP)		            //Informa qual a planilha atual
            ConOut("Planilha:"+oExcel:GetPlanAt("2"))	//Nome da Planilha
            aTamLin	:= oExcel:LinTam() 		            //Linha inicio e fim da linha
            For nContL := aTamLin[1] To aTamLin[2]
                If nContL > 1 .AND. ( ValType(oExcel:GetValue(nContL,3)) != "U" .OR. ValType(oExcel:GetValue(nContL,4)) != "U" )
                    aTamCol	:= oExcel:ColTam(nContL)    //Coluna inicio e fim
                    If aTamCol[1] > 0                   //Se a linha tem algum valor
                        
                        If !Empty(oExcel:GetValue(nContL,3))
                            nPercen := IIF(ValType(oExcel:GetValue(nContL,3)) != "N",Val(StrTran(oExcel:GetValue(nContL,3),",",".")),oExcel:GetValue(nContL,3))
                        Else
                            nPercen := (( IIF(ValType(oExcel:GetValue(nContL,4)) != "N",Val(StrTran(oExcel:GetValue(nContL,4),",",".")),oExcel:GetValue(nContL,4)) / nValor ) * 100)
                        EndIf  

                        aAdd(aRet,aClone(aColst))

                        aRet[(nContL-1),nPosIt]  := StrZero(nContL-1,2)
                        aRet[(nContL-1),nPosPer] := nPercen
                        aRet[(nContL-1),nPosCC]  := Alltrim(IIF(ValType(oExcel:GetValue(nContL,6)) == "C", oExcel:GetValue(nContL,6), AsString(oExcel:GetValue(nContL,6))))
                        aRet[(nContL-1),nPosCon] := Alltrim(IIF(ValType(oExcel:GetValue(nContL,1)) == "C", oExcel:GetValue(nContL,1), AsString(oExcel:GetValue(nContL,1))))
                        aRet[(nContL-1),nPosItc] := Alltrim(IIF(ValType(oExcel:GetValue(nContL,8)) == "C", oExcel:GetValue(nContL,8), AsString(oExcel:GetValue(nContL,8))))

                    EndIf
                EndIf
            Next
        Next 

    oExcel:Close()

Return aRet
