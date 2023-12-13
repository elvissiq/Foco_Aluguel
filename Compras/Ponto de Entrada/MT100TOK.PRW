#INCLUDE "Protheus.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  SF1100I    º Autor ³ Elvis Siqueira     º Data ³  23/11/2023 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Valida campos do fornecedor no documento de entrada        º±±
±±º          ³ Preenche observação para o financeiro                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Foco Aluguel                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function MT100TOK()
	
	Local oDialog    := Nil 
	Local _lOk       := ParamIxb[1]
	Local _aArea     := GetArea()
	Local _aAreaSD1  := SD1->(GetArea())
	Local _lDupl     := .F.
	Local lConfirm   := .F.
	Local _lRet      := .T.
	Local nPosTes    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TES"})
	Local nI

	Public _cOBSNFAd := Space(GetSX3Cache("E2_HIST"   ,"X3_TAMANHO"))

	If _lOk .and. Funname() == "MATA103"
		For nI:=1 to Len(aCols)
			If Posicione('SF4',1,xFilial("SF4")+aCols[nI,nPosTes],"F4_DUPLIC") == "S"
				_lDupl := .T.
				Exit
			Endif
		End
	EndIF

	If _lDupl
		DEFINE MSDIALOG _oDlg FROM  35,37 TO 160,483 TITLE OemToAnsi("Histórico Financeiro") PIXEL  //
		@ 11, 7 SAY OemToAnsi("Histórico Financeiro:") SIZE 80, 7 OF _oDlg PIXEL  //
		@ 21, 7 MSGET _cOBSNFAd SIZE 200,10 OF _oDlg PIXEL
		Define SButton From 40,020 Type 1 Of _oDlg Enable Action (lConfirm:=.T.,_oDlg:End())
		ACTIVATE MSDIALOG _oDlg Centered
	Endif

	RestArea(_aAreaSD1)
	RestArea(_aArea)
Return(_lRet)
