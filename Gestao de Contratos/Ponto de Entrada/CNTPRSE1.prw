#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "TBICONN.CH"
#Include "TopConn.ch"

/*/{Protheus.doc} CNTPRSE1
    Programa Fonte
        CNTA100.PRW
    Function CN100CTit - Função chamada na geração dos títulos financeiro de previsão do contrato.
                         Executado na gravação do SE1, permite alterar e preencher campos específicos.

    @type function
    @version 
    @author TOTVS Nordeste
    @since 07/10/2024
    @return
/*/

User Function CNTPRSE1
    Local _aArea := FWGetArea()

    If !Empty(CNZ->CNZ_CC)
        SE1->E1_CCUSTO := CNZ->CNZ_CC
    EndIF 

	FWRestArea(_aArea)
Return
