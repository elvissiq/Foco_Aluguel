#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} zConsSQL
Função para executar comandos SQL no Protheus
@author TOTVS Nordeste (Elvis Siqueira)
@since 06/11/2023
@version 1.0
/*/
User Function zConsSQL
    Local aArea   := GetArea()
    Local oDialog := Nil
    Local cConsSQLM := ""

    oDialog := FWDialogModal():New()

    oDialog:SetBackground( .T. ) 
    oDialog:SetTitle( 'SQL' )
    oDialog:setSubTitle( 'Execução de Queries SQL' )
    oDialog:SetSize( 500, 800 )
    oDialog:EnableFormBar( .T. )
    oDialog:SetCloseButton( .T. )
    oDialog:SetEscClose( .T. )
    oDialog:CreateDialog()
    oDialog:CreateFormBar()
    oDialog:AddButton('Confirmar' , { || IIF(zConsSQL(cConsSQLM),IIF(FWAlertYesNo("Deseja encerrar ?"),oDialog:DeActivate(),),)}, 'Confirmar' ,,.T.,.F.,.T.,)
    oDialog:addCloseButton(Nil, "Fechar")

    oPanel := oDialog:GetPanelMain()

    oSay1 := TSay():New(17,5,{|| 'Query' },oPanel,,,,,,.T.,,,50,70,,,,,,.T.)
             @ 17,70 GET cConsSQLM MEMO SIZE 600,400 OF oPanel PIXEL

oDialog:Activate()
RestArea(aArea)

Return

Static Function zConsSQL(pConsSQLM)
	Local cQry := pConsSQLM
    Local nStatus := 0
    Local lRet 

    TCLink()
        nStatus := TCSqlExec(cQry)
        If (nStatus < 0)
         FWAlertError(TCSQLError(),"Houve um erro na tentativa do Update.")
         lRet := .F.
        Else 
         FWAlertSuccess("Update executado com sucesso.","Sucesso!")
         lRet := .T.
        Endif
    TCUnlink()

Return lRet
