#INCLUDE "Totvs.ch"

/*/{Protheus.doc} User Function MT100GE2
Ponto de entrada acionado para complementar a gravação na tabela dos títulos financeiros a pagar;
/*/
User Function MT100GE2()

	Local nOpc 		:= PARAMIXB[2]
	Local aHeadSE2	:= PARAMIXB[3]
 	Local nLin 		:= PARAMIXB[4]
 	Local aParcelas	:= PARAMIXB[5]
	Local nPosBar 	:= Ascan(aHeadSE2,{|x| Alltrim(x[2]) == 'E2_CODBAR'})
	Local nPosLin 	:= Ascan(aHeadSE2,{|x| Alltrim(x[2]) == 'E2_LINDIG'})
	Local nPosFor 	:= Ascan(aHeadSE2,{|x| Alltrim(x[2]) == 'E2_FORMPAG'})
	Local cFormPag  := IIF(SubStr(aParcelas[nLin][nPosLin],1,3) == '341','30','31')
	Local aAreaSE2 	:= SE2->(GetArea())

	DbSelectArea('SE2')

		If nOpc == 1 // Inclusao
			RecLock("SE2",.F.)
				Replace SE2->E2_CODBAR with aParcelas[nLin][nPosBar]
				Replace SE2->E2_LINDIG with aParcelas[nLin][nPosLin]
				Replace SE2->E2_HIST with _cOBSNFAd
				If !Empty(aParcelas[nLin][nPosFor])
					Replace SE2->E2_FORMPAG with aParcelas[nLin][nPosFor]
				ElseIF !Empty(aParcelas[nLin][nPosLin])
					Replace SE2->E2_FORMPAG with cFormPag
				EndIF 
			MsUnLock()
        EndIf
			
	RestArea(aAreaSE2)

Return()
