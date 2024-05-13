#INCLUDE "Totvs.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Rwmake.ch"

/*/{Protheus.doc} FA050INC
    O ponto de entrada FA050INC - ser� executado na valida��o da Tudo Ok na inclus�o do contas a pagar.
@type function
@author Elvis Siqueira
@since 29/04/2024
@Link https://tdn.totvs.com/pages/releaseview.action?pageId=6071109
/*/

User Function FA050INC()
    Local lRet := .T.

    If (Empty(M->E2_CCD) .Or. Empty(M->E2_CCC)) .And. Alltrim(FunName()) == "FINA050/FINA750"
        LRet := .F.
        FWAlertError("Para inclus�o de t�tulo a pagar � obrigat�rio o preenchimento do campo Centro de Custo",;
                     "Centro de Custo Obrigatorio")
    EndIF 

Return lRet
