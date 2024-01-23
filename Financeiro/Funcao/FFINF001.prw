//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "TBICONN.CH"

//----------------------------------------------------------------------
/*/{PROTHEUS.DOC} FFINF001
FUNÇÃO FFINF001 - Tela para cadastro da Segregação de Clientes
@VERSION PROTHEUS 12
@SINCE 05/01/24
/*/
//----------------------------------------------------------------------

User Function FFINF001()

Local aArea   := GetArea()
Local oBrowse

Private aRotina := {}

aRotina := MenuDef()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("SZ2")
oBrowse:SetDescription("Segregacao de Clientes")

oBrowse:Activate()
 
RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Desc:  Criação do Menu de Opções                                    |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/

Static Function MenuDef()
Local aRot := {}
     
    //Adicionando opções
    ADD OPTION aRot TITLE 'Incluir'          ACTION 'VIEWDEF.FFINF001' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'          ACTION 'VIEWDEF.FFINF001' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Visualizar'       ACTION 'VIEWDEF.FFINF001' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Excluir'          ACTION 'VIEWDEF.FFINF001' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
    
Return aRot

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Desc:  Criação do modelo de dados MVC                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/

Static Function ModelDef()
Local oModel
Local oStrMaster := FWFormStruct(1, 'SZ2')

	oModel := MPFormModel():New('FFINFM',/*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)
	oModel:AddFields('SZ2MASTER',/*cOwner*/ ,oStrMaster)
  
	oModel:SetPrimaryKey({})

Return oModel

/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Desc:  Criação da visão MVC                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/

Static Function ViewDef()
Local oView
Local oModel     := FWLoadModel('FFINF001')
Local oStrMaster := FWFormStruct(2, 'SZ2')
oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_CAB' ,oStrMaster ,'SZ2MASTER')
oView:CreateHorizontalBox('CABEC', 100)
oView:SetOwnerView( 'VIEW_CAB'	, 'CABEC')
oView:SetCloseOnOk({||.T.})

Return oView
