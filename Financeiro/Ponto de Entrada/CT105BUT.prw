#INCLUDE "Totvs.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "Rwmake.ch"

/*/{Protheus.doc} CT105BUT
    O objetivo deste ponto de entrada é adicionar novos botões à tela de Lançamentos Contábeis - CTBA105.
@type function
@author Elvis Siqueira
@since 26/01/2024
@Link https://tdn.totvs.com/pages/releaseview.action?pageId=185731524
/*/

User Function CT105BUT()
    Local aArea      := FWGetArea()  
    Local aBotao     := ParamIXB
    Local cQry       := ""
    Local _cAlias    := GetNextAlias()
    Local nQtdCC     := 0
    Local nValTit    := SE1->E1_VALOR
    Local nValPIS    := Round( nValTit * ( SuperGetMV("MV_TXPIS",.F.,1.65) / 100 ), 2 )
    Local nValCOF    := Round( nValTit * ( SuperGetMV("MV_TXCOFIN",.F.,7.60) / 100 ), 2 )
    Local nValPISAux := nValPIS
    Local nValCOFAux := nValCOF
    Local nValPISTMP := 0
    Local nValCOFTMP := 0
    Local lMultNat   := SE1->E1_MULTNAT = '1'
    Local nUltLinPIS := ""
    Local nUltLinCOF := ""

    If Alltrim(FunName()) $ ("FINA040/FINA740")
        
        If lMultNat

            cQry := " SELECT * FROM "+RetSQLName("SEZ")+" SEZ "           + CRLF
            cQry += " WHERE "                                             + CRLF
            cQry += "       SEZ.D_E_L_E_T_ <> '*' "                       + CRLF
            cQry += "   AND SEZ.EZ_FILIAL    = '"+FWxFilial("SEZ")+"' "   + CRLF
            cQry += "   AND SEZ.EZ_PREFIXO   = '"+SE1->E1_PREFIXO+"' "    + CRLF
            cQry += "   AND SEZ.EZ_NUM       = '"+SE1->E1_NUM+"' "        + CRLF
            cQry += "   AND SEZ.EZ_PARCELA   = '"+SE1->E1_PARCELA+"' "    + CRLF
            cQry += "   AND SEZ.EZ_TIPO      = '"+SE1->E1_TIPO+"' "       + CRLF
            cQry += "   AND SEZ.EZ_CLIFOR    = '"+SE1->E1_CLIENTE+"' "    + CRLF
            cQry += "   AND SEZ.EZ_LOJA      = '"+SE1->E1_LOJA+"' "       + CRLF
            cQry += "   AND SEZ.EZ_RECPAG    = 'R' "                      + CRLF

            dbUseArea(.T.,"TOPCONN", TCGenQry(,,cQry),_cAlias, .F., .T.)

            (_cAlias)->(DBGoTOP())
            Count To nQtdCC
            
            (_cAlias)->(DbCloseArea())

            If nQtdCC > 0 
                
                nValPIS := Round((nValPIS / nQtdCC), 2)
                nValCOF := Round((nValCOF / nQtdCC), 2) 

                DBSelectArea("TMP")
                TMP->(DBGoTop())
                
                    While !TMP->(EOF())

                        If SubSTR(TMP->(CT2_HIST),1,12) $ ("PIS APURACAO")
                            nUltLinPIS := TMP->(CT2_LINHA)
                            If TMP->(CT2_VALOR) != nValPIS
                                TMP->(CT2_VALOR) := nValPIS
                                nValPISTMP += nValPIS
                            EndIF 
                        ElseIF SubSTR(TMP->(CT2_HIST),1,15) $ ("COFINS APURACAO")
                            nUltLinCOF := TMP->(CT2_LINHA)
                            If TMP->(CT2_VALOR) != nValCOF
                                TMP->(CT2_VALOR) := nValCOF
                                nValCOFTMP += nValCOF
                            EndIF 
                        EndIF

                    TMP->(DBSkip())
                    EndDo 

                    If nValPISTMP != nValPISAux
                        TMP->(DBGoTop())
                        While !TMP->(EOF())
                            If  TMP->(CT2_LINHA) == nUltLinPIS
                                TMP->(CT2_VALOR) := ( nValPIS - (nValPISTMP - nValPISAux) )
                            EndIF
                        TMP->(DBSkip())
                        EndDo 
                    EndIF 

                    If nValCOFTMP != nValCOFAux
                        TMP->(DBGoTop())
                        While !TMP->(EOF())
                            If  TMP->(CT2_LINHA) == nUltLinCOF
                                TMP->(CT2_VALOR) := ( nValCOF - (nValCOFTMP - nValCOFAux) )
                            EndIF
                        TMP->(DBSkip())
                        EndDo 
                    EndIF 

                TMP->(DBGoTop())
            
            EndIF 

        EndIF 
    
    EndIF 

    FWRestArea(aArea)

Return aBotao
