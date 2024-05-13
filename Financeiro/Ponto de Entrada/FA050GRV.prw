#INCLUDE "Totvs.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Rwmake.ch"

/*/{Protheus.doc} FA050GRV
    O ponto de entrada FA050GRV sera utilizado apos a gravacao de todos os dados (na inclusão do título) e antes da sua contabilização.
@type function
@author Elvis Siqueira
@since 29/04/2024
@Link https://tdn.totvs.com/display/public/mp/FA050GRV+-+Grava+dados+--+11855
/*/
User Function FA050GRV()
    Local aAreaE2  := SE2->(FWGetArea())
    Local _cAlias  := GetNextAlias()
    Local cWhere   := ""
    Local cParcela := ""

    If SE2->(FieldPos("E2_XSEQ")) > 0
       
        cWhere += "% "
        cWhere += "    E2_PREFIXO = '" +SE2->E2_PREFIXO+  "' "
        cWhere += "AND E2_NUM     = '" +SE2->E2_NUM+      "' "
        cWhere += "AND E2_NATUREZ = '" +SE2->E2_NATUREZ+  "' "
        cWhere += "AND E2_FORNECE = '" +SE2->E2_FORNECE+  "' "
        cWhere += "AND E2_LOJA    = '" +SE2->E2_LOJA+     "' "
        cWhere += "%"

        BeginSql Alias _cAlias  
            SELECT MAX(E2_PARCELA) AS ULT_PARC
            FROM
                %table:SE2% 
            WHERE
                E2_FILIAL  = %xFilial:SE2%
                AND %Exp:cWhere%
                AND %notDel%
        EndSql

        IF (_cAlias)->(!Eof())
            cParcela := Soma1(Alltrim((_cAlias)->(ULT_PARC)))
        EndIF 

        (_cAlias)->(DbCloseArea())

        If Empty(SE2->E2_XSEQ)
            RecLock("SE2",.F.)
                SE2->E2_XSEQ := Str(Val(GETSXENUM("SE2","E2_XSEQ"))) + cParcela
            SE2->(MsUnlock())
        EndIF 

    EndIF 
    
    FWRestArea(aAreaE2)
Return
