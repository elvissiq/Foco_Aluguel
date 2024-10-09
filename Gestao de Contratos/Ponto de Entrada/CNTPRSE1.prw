#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "TBICONN.CH"
#Include "TopConn.ch"

/*/{Protheus.doc} CNTPRSE1
    Programa Fonte
        CNTA100.PRW
    Function CN100CTit - Fun��o chamada na gera��o dos t�tulos financeiro de previs�o do contrato.
                         Executado na grava��o do SE1, permite alterar e preencher campos espec�ficos.

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
