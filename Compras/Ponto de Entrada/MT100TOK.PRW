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
	
	Local oDialog   := Nil 
	Local _lOk      := ParamIxb[1]
	Local _aArea    := GetArea()
	Local _aAreaSD1 := SD1->(GetArea())
	Local _lDupl    := .F.
	Local cBanco    := Space(GetSX3Cache("A2_BANCO"  ,"X3_TAMANHO"))
	Local cAgencia  := Space(GetSX3Cache("A2_AGENCIA","X3_TAMANHO"))
	Local cConta    := Space(GetSX3Cache("A2_NUMCON" ,"X3_TAMANHO"))
	Local cDigto    := Space(GetSX3Cache("A2_DVCTA"  ,"X3_TAMANHO"))
	Local lConfirm  := .F.
	Local _lRet     := .T.
	Local nPosTes   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TES"})
	Local nI

	Public _cOBSNFAd := Space(GetSX3Cache("E2_HIST"   ,"X3_TAMANHO"))

	DBSelectArea("SA2")
	SA2->(DBSetOrder(1))
	IF SA2->(MSSeek(FWxFilial("SA2")+cA100For+cLoja))
		If Empty(SA2->A2_BANCO) .Or. Empty(SA2->A2_AGENCIA) .Or. Empty(SA2->A2_NUMCON) .Or. Empty(SA2->A2_DVCTA)
			If APMsgYesNo('Identificado a falta de preenchimento dos campos "Banco, Agencia e Conta" no cadastro do fornecedor. Deseja atualizar agora ?',;
					   'Campos "Banco, Agencia e Conta"')

				oDialog := FWDialogModal():New()
				oDialog:SetBackground( .T. ) 
				oDialog:SetTitle( 'Banco, Agencia e Conta' )
				oDialog:SetSize( 130, 150 )
				oDialog:EnableFormBar( .T. )
				oDialog:SetCloseButton( .F. )
				oDialog:SetEscClose( .F. )
				oDialog:CreateDialog()
				oDialog:CreateFormBar()
				oDialog:AddButton('Confirmar' , { || oDialog:DeActivate()}, 'Confirmar' ,,.T.,.F.,.T.,)
				oPanel := oDialog:GetPanelMain()

				oSay1  := TSay():New(17,5,{|| "Banco: "},oPanel,,,,,,.T.,,,50,70,,,,,,.T.)
				@ 15,30 MSGET cBanco SIZE 030,009 OF oPanel PIXEL 
				oSay2  := TSay():New(32,5,{|| "Agencia: "},oPanel,,,,,,.T.,,,50,70,,,,,,.T.)
				@ 30,30 MSGET cAgencia SIZE 030,009 OF oPanel PIXEL 
				oSay2  := TSay():New(47,5,{|| "Conta: "},oPanel,,,,,,.T.,,,50,70,,,,,,.T.)
				@ 45,30 MSGET cConta SIZE 030,009 OF oPanel PIXEL 
				oSay2  := TSay():New(62,5,{|| "Dig. CC: "},oPanel,,,,,,.T.,,,50,70,,,,,,.T.)
				@ 60,30 MSGET cDigto SIZE 030,009 OF oPanel PIXEL 
				oDialog:Activate()

				RecLock("SA2",.F.)
					SA2->A2_BANCO := cBanco
					SA2->A2_AGENCIA := cAgencia
					SA2->A2_NUMCON := cConta
					SA2->A2_DVCTA := cDigto
				SA2->(MsUnLock())
			EndIf 

			DBSelectArea("F72")
			F72->(DBSetOrder(1))
			IF !F72->(MSSeek(FWxFilial("F72")+cA100For+cLoja))
				If APMsgYesNo('Identificado a falta de preenchimento da chave PIX no cadastro do fornecedor. Deseja atualizar agora ?',;
						'Chave PIX')
					
					FA885ChPix()
				
				EndIf
			EndIF  
		EndIf 

	EndIF 

	If _lOk .and. Funname() == "MATA103"
		For nI:=1 to Len(aCols)
			If Posicione('SF4',1,xFilial("SF4")+aCols[nI,nPosTes],"F4_DUPLIC") == "S"
				_lDupl := .T.
				Exit
			Endif
		End
		If _lDupl
			DEFINE MSDIALOG _oDlg FROM  35,37 TO 160,483 TITLE OemToAnsi("Histórico Financeiro") PIXEL  //
			@ 11, 7 SAY OemToAnsi("Histórico Financeiro:") SIZE 80, 7 OF _oDlg PIXEL  //
			@ 21, 7 MSGET _cOBSNFAd SIZE 200,10 OF _oDlg PIXEL
			Define SButton From 40,020 Type 1 Of _oDlg Enable Action (lConfirm:=.T.,_oDlg:End())
			ACTIVATE MSDIALOG _oDlg Centered
		Endif
	Endif

	RestArea(_aAreaSD1)
	RestArea(_aArea)
Return(_lRet)
