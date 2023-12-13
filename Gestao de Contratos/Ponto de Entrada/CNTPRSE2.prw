#INCLUDE 'TOTVS.CH'

/*/{Protheus.doc} CNTPRSE2
    Programa Fonte
        CNTA100.PRW
    Function CN100CTit - Função chamada na geração dos títulos financeiro de previsão do contrato.
                         Executado na gravação do SE2, permite alterar e preencher campos específicos.

    @type function
    @version 
    @author TOTVS Nordeste
    @since 06/12/2023
    @return
/*/

User Function CNTPRSE2
    Local _aArea     := FWGetArea()
	Local _aAreaSE2  := SE2->(FWGetArea())




    FWRestArea(_aAreaSE2)
	FWRestArea(_aArea)
Return
