#INCLUDE "Totvs.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Rwmake.ch"

/*/{Protheus.doc} VALNFSF1
    Valida se a NF já existe na SF1 para o mesmo fornecedor
@type function
@author Elvis Siqueira
@since 29/04/2024
/*/
User Function VALNFSF1(cCampo)
    Local _cAlias := GetNextAlias()
    Local lRet    := .T.
    Local cWhere  := ""
       
    cWhere += "% "
    cWhere += "    F1_DOC LIKE '%" +Alltrim(STr(Val(cNFiscal)))+"%' "
    cWhere += "AND F1_SERIE = '" +cSerie+  "' "
    cWhere += "AND F1_FORNECE = '" +cA100For+  "' "
    cWhere += "AND F1_LOJA    = '" +cLoja+     "' "
    cWhere += "%"

    BeginSql Alias _cAlias  
        SELECT F1_DOC
        FROM
            %table:SF1% 
        WHERE
            F1_FILIAL  = %xFilial:SF1%
            AND %Exp:cWhere%
            AND %notDel%
    EndSql

    IF !Empty((_cAlias)->F1_DOC) .and. !Empty(M->&(cCampo))
        lRet := .F.
        FWAlertError("Já existe uma Nota Fiscal com o mesmo número incluído para este fornecedor.",;
                     "Nota Fiscal duplicada.")
    EndIF 

    (_cAlias)->(DbCloseArea())

Return lRet
