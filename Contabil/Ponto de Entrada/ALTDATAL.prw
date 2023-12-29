#Include "TOTVS.CH"

/*/{Protheus.doc} CT102DLG

Ponto de entrada executado ap�s montagem da tela de Lan�amentos Cont�beis Autom�ticos, antes de ativar a janela (dialog).

@type function
@author TOTVS NORDESTE
@since 28/12/2023

@history 
/*/
User Function ALTDATAL()
    Local dDataLanc := paramixb[1]
    Local cRotina   := paramixb[2]
    
    Public lAglut   

    If Empty(cRotina)
        lAglut := .T.
    EndIF 

Return dDataLanc
