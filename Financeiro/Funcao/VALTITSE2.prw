#INCLUDE "Totvs.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Rwmake.ch"

/*/{Protheus.doc} VALTITSE2
    Valida se o título já existe na SE2 para o mesmo fornecedor
@type function
@author Elvis Siqueira
@since 08/05/2024
/*/
User Function VALTITSE2()
    Local _cAlias := GetNextAlias()
    Local lRet    := .T.
    Local cWhere  := ""
       
    cWhere += "% "
    cWhere += "    E2_NUM LIKE '%" +Alltrim(M->E2_NUM)+"%' "
    cWhere += "AND E2_PARCELA = '" +M->E2_PARCELA+  "' "
    cWhere += "AND E2_FORNECE = '" +M->E2_FORNECE+  "' "
    cWhere += "AND E2_LOJA    = '" +M->E2_LOJA+     "' "
    cWhere += "%"

    BeginSql Alias _cAlias  
        SELECT E2_NUM
        FROM
            %table:SE2% 
        WHERE
            E2_FILIAL  = %xFilial:SE2%
            AND %Exp:cWhere%
            AND %notDel%
    EndSql

    IF !Empty((_cAlias)->E2_NUM)
        lRet := .F.
        FWAlertError("Já existe um título com o mesmo número incluído para este fornecedor.",;
                     "Título duplicado.")
    EndIF 

    (_cAlias)->(DbCloseArea())

Return lRet
