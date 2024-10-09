#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} MT100RTX
    Programa Fonte
        CNTXFUN.PRX
    Function CNTAvalGCT - Função chamada na gravação do título financeiro durante a confirmação do documento de entrada.
                          Executado na gravação do documento de entrada.
    CNTGERSE2 - Manipulação do Titulo a Pagar gerado para o SIGAGCT ( < PARAMIXB> ) --> Nil
    @type function
    @version 
    @author TOTVS Nordeste
    @since 06/12/2023
    @return
/*/

User Function CNTGERSE2
    Local _aArea     := FWGetArea()
	Local _aAreaSE2  := SE2->(FWGetArea())
    Local cNumContr  := PARAMIXB[1,1,1]
    
    DBSelectArea("CN9")
    IF CN9->(MsSeek(FWxFilial("CN9")+cNumContr))
        IF CN9->(FIELDPOS("CN9_XFORMP"))
            SE2->E2_FORMPAG := CN9->CN9_XFORMP
        EndIF 
    EndIF 
    
    //CNF_CONTRA
    //CNF_PARCEL
    //CNF_COMPET
    
    FWRestArea(_aAreaSE2)
	FWRestArea(_aArea)
Return
