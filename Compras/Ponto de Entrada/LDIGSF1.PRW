/* 
 @author JO�O CAMPELO (TOTVS NORDESTE)
 Objetivo: Facilitar a inclus�o da linha digitavel pelo time do financeiro
 Com este fonte,o c�digo de barras do boleto poder� ser preenchida diretamente no documento de entrada 
*/

User Function MT103SE2()

	Private aRet:= {} // Customiza��es desejadas para adi��o do campo no grid de informa��es


	If  MsSeek("E2_LINDIG")   // LINHA DIGIT�VEL

		aAdd(aRet,{ TRIM(X3Titulo()),;
					SX3->X3_CAMPO,;
					SX3->X3_PICTURE,;
					SX3->X3_TAMANHO,;
					SX3->X3_DECIMAL,;
					"",SX3->X3_USADO,;
					SX3->X3_TIPO,;
					SX3->X3_F3,;
					SX3->X3_CONTEXT,;
					SX3->X3_CBOX,;
					SX3->X3_RELACAO, ".T."}) 

	EndIf 

	If  MsSeek("E2_CODBAR")   // C�DIGO DE BARRAS 

		aAdd(aRet,{ TRIM(X3Titulo()),;
					SX3->X3_CAMPO,;
					SX3->X3_PICTURE,;
					SX3->X3_TAMANHO,;
					SX3->X3_DECIMAL,;
					"",SX3->X3_USADO,;
					SX3->X3_TIPO,;
					SX3->X3_F3,;
					SX3->X3_CONTEXT,;
					SX3->X3_CBOX,;
					SX3->X3_RELACAO, ".T."}) 

	EndIf 

Return (aRet)


/*/{Protheus.doc} User Function SF1100I
Ponto de entrada acionado para complementar a grava��o na tabela dos t�tulos financeiros a pagar;
/*/
User Function MT100GE2()

	Local nOpc := PARAMIXB[2]
	Local aHeadSE2:= PARAMIXB[3]
 	Local nLin:= PARAMIXB[4]
 	Local aParcelas:= PARAMIXB[5]
	Local nPosBar := Ascan(aHeadSE2,{|x| Alltrim(x[2]) == 'E2_CODBAR'})
	Local nPosLin := Ascan(aHeadSE2,{|x| Alltrim(x[2]) == 'E2_LINDIG'})
	Local aAreaSE2 := SE2->(GetArea())

	DbSelectArea('SE2')

		If nOpc == 1 // Inclusao
			RecLock("SE2",.F.)
				Replace SE2->E2_CODBAR with aParcelas[nLin][nPosBar]
				Replace SE2->E2_LINDIG with aParcelas[nLin][nPosLin]
				Replace SE2->E2_HIST with _cOBSNFAd
			MsUnLock()
        EndIf
			
	RestArea(aAreaSE2)

Return()
