#INCLUDE "Totvs.ch"

 /*/{Protheus.doc} F240AFIL
    
    O ponto de entrada F240AFIL, alteração do filtro que seleciona títulos a serem relacionados em borderô de pagamento.
    
    @type  Function
    @author TOTVS Nordeste (Elvis Siqueira)
    @since 09/10/2023
    @version 1.0
    @param Nil
    @return cRet (Caractere)
    @example
    @see https://tdn.totvs.com/display/public/PROT/DT_F240AFIL_permite_alterar_filtro_selecao_titulos
    /*/
User Function F240AFIL
Local cFiltro := PARAMIXB[1]

Private cFormPAG := Space(TAMSX3("E2_XFORMPA")[1])

    If APMsgYesNo("Deseja filtrar os títulos por Forma de Pagamento ?","Filtro")
        
        xPergunt() 

        cFiltro += " AND E2_XFORMPA = '" + Alltrim(cFormPAG) + "'"

    EndIF 
    

Return cFiltro

/* ============================================== /
  Perguntas para o Filtro
/ =============================================== */
Static Function xPergunt()
 
Local aArea      := GetArea()
Local oDialog    := Nil 

// Método responsável por criar a janela e montar os paineis.
oDialog := FWDialogModal():New()

// Métodos para configurar o uso da classe.
oDialog:SetBackground( .T. ) 
oDialog:SetTitle( 'Filtro' )
oDialog:SetSize( 100, 110 )
oDialog:EnableFormBar( .T. )
oDialog:SetCloseButton( .F. )
oDialog:SetEscClose( .F. )
oDialog:CreateDialog()
oDialog:CreateFormBar()
oDialog:AddButton('Confirmar' , { || oDialog:DeActivate()}, 'Confirmar' ,,.T.,.F.,.T.,)

// Capturar o objeto do FwDialogModal para alocar outros objetos se necessário.
oPanel := oDialog:GetPanelMain()

	oSay1  := TSay():New(17,5,{|| "Forma de Pagamento ? "},oPanel,,,,,,.T.,,,300,70,,,,,,.T.)
	@ 15,70 MSGET cFormPAG SIZE 030,009 OF oPanel F3 "05" PIXEL

oDialog:Activate()

RestArea(aArea)

Return
