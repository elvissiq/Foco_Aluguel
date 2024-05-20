//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "TBICONN.CH"

Static cFieldNo  := "Z4_ANO;Z4_MES;Z4_NATUREZ;Z4_DEBITO;Z4_CREDITO;"

//----------------------------------------------------------------------
/*/{PROTHEUS.DOC} FFINF003
FUNÇÃO FFINF003 - Tela para cadastro do orçamento diario
@VERSION PROTHEUS 12
@SINCE 18/05/24
/*/
//----------------------------------------------------------------------

User Function FFINF003()
    Local aArea   := GetArea()
    Local oBrowse

    Private aRotina := {}

    aRotina := MenuDef()

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("SZ3")
    oBrowse:SetDescription("Orçamento Financeiro")

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
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.FFINF003' OPERATION 3 ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.FFINF003' OPERATION 4 ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.FFINF003' OPERATION 2 ACCESS 0 //OPERATION 2
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.FFINF003' OPERATION 5 ACCESS 0 //OPERATION 5
    
Return aRot

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Desc:  Criação do modelo de dados MVC                               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/

Static Function ModelDef()
    Local oModel
    Local oStrMaster := FWFormStruct(1, 'SZ3')
    Local oStrGrid := FWFormStruct(1, 'SZ4')

    oStrMaster:AddTrigger("Z3_MES" ,"Z3_MES", {||.T.},{|| fnGeraGrid() })

	oModel := MPFormModel():New('FFINF3M',/*bPre*/, /*bPost*/, /*bCommit*/, /*bCancel*/)
	oModel:AddFields('SZ3MASTER',/*cOwner*/ ,oStrMaster)
    oModel:AddGrid('SZ4GRID','SZ3MASTER',oStrGrid,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
    
    oModel:SetRelation('SZ4GRID',{{'Z4_FILIAL','xFilial("SZ4")'},;
                                  {'Z4_ANO','Z3_ANO'},;
                                  {'Z4_MES','Z3_MES'},;
                                  {'Z4_NATUREZ','Z3_NATUREZ'},;
                                  {'Z4_DEBITO','Z3_DEBITO'},;
                                  {'Z4_CREDITO','Z3_CREDITO'};
                                  }, SZ4->(IndexKey(1)))
                                   
	oModel:SetPrimaryKey({'Z3_FILIAL','Z3_ANO', 'Z3_MES', 'Z3_NATUREZ', 'Z3_DEBITO', 'Z3_CREDITO' }) 

Return oModel

/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Desc:  Criação da visão MVC                                         |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/

Static Function ViewDef()
    Local oView
    Local oModel := FWLoadModel('FFINF003')
    Local oStrMaster := FWFormStruct(2, 'SZ3')
    Local oStrGrid := FWFormStruct(2, 'SZ4', {|cCampo| !(Alltrim(cCampo) $ cFieldNo)})

    oView := FWFormView():New()
    oView:SetModel(oModel)

    oView:AddField('VIEW_CAB' ,oStrMaster ,'SZ3MASTER')
    oView:AddGrid('VIEW_GRID' ,oStrGrid ,'SZ4GRID')
    
    oView:CreateHorizontalBox('CABEC', 30)
    oView:CreateHorizontalBox('GRID', 70)
    
    oView:SetOwnerView( 'VIEW_CAB'	, 'CABEC')
    oView:SetOwnerView( 'VIEW_GRID'	, 'GRID')
    
    oView:SetCloseOnOk({||.T.})

Return oView

/*---------------------------------------------------------------------*
 | Func:  fnGeraGrid()                                                 |
 | Desc:  Preenche os dias do mês no Grid                              |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function fnGeraGrid()
    Local oModel := FWModelActive()
    Local oView  := FWViewActive()
    Local oModelMaster := oModel:GetModel("SZ3MASTER")
    Local oModelGrid := oModel:GetModel("SZ4GRID")
    Local dDataIni   := FirstDate(CToD("01/"+oModelMaster:GetValue("Z3_MES")+"/"+oModelMaster:GetValue("Z3_ANO")))
    Local dDataFim   := LastDate(dDataIni)
    Local aDiasMes   := {}
    Local cMesRet    := oModelMaster:GetValue("Z3_MES")
    Local nY

    aAdd(aDiasMes,dDataIni)
    For nY := 1 To DateDiffDay(dDataIni,dDataFim) 
        aAdd(aDiasMes,dDataIni+nY)
    Next
    
    oModelGrid:ClearData(.T.)

    For nY := 1 To Len(aDiasMes)
        
        IF nY > 1
            oModelGrid:AddLine()
        EndIF 

        oModelGrid:LoadValue("Z4_ANO"     , oModelMaster:GetValue("Z3_ANO") )
        oModelGrid:LoadValue("Z4_MES"     , oModelMaster:GetValue("Z3_MES") )
        oModelGrid:LoadValue("Z4_NATUREZ" , oModelMaster:GetValue("Z3_NATUREZ") )
        oModelGrid:LoadValue("Z4_DEBITO"  , oModelMaster:GetValue("Z3_DEBITO") )
        oModelGrid:LoadValue("Z4_CREDITO" , oModelMaster:GetValue("Z3_CREDITO") )
        oModelGrid:LoadValue("Z4_DIA"     , aDiasMes[nY] )

        oView:Refresh("VIEW_GRID")
    
    Next

    oModelGrid:GoLine(1)
    oView:Refresh("VIEW_GRID")
    //oView:SetNoDeleteLine('VIEW_GRID')
    //oView:SetNoInsertLine('VIEW_GRID')

Return (cMesRet)
