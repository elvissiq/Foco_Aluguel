#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} CN100ANT
    Programa Fonte CNTA100.prw
        
    Ponto de Entrada localizado na confirmação do Adiantamento do Contrato.
    Este Ponto de Entrada permite gravar os campos customizados antes da gravação dos títulos referentes ao Adiantamento.

    @type function
    @version 
    @author TOTVS Nordeste
    @since 06/12/2023
    @return
/*/

User Function CN100ANT
    Local _aArea    := FWGetArea()
	Local _aAreaCN9 := CN9->(FWGetArea())
    Local _aAreaSE2 := SE2->(FWGetArea())
    Local cNumContr := Pad(PARAMIXB[3],FWTamSX3("CN9_NUMERO")[1])

    DBSelectArea("CN9")
    IF CN9->(MsSeek(FWxFilial("CN9")+cNumContr))
        IF CN9->(FIELDPOS("CN9_XFORMP"))
            RecLock("SE2",.F.)
                SE2->E2_FORMPAG := CN9->CN9_XFORMP
            SE2->(MsUnlock())
        EndIF
    EndIF

    FWRestArea(_aAreaSE2)
    FWRestArea(_aAreaCN9)
	FWRestArea(_aArea)
Return
