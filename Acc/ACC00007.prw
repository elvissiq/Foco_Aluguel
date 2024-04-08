#include "protheus.ch"

/*/{Protheus.doc} ACC00007
//Rotina que execução a criação de JSON.
@author Fernando Oliveira Feres
@since 26/10/2020
@version 1.0
@return nil, nil
/*/
user function ACC00007(oBrowse2, lDireto, aDados)

	Local oAccoread := ACCOREAD():New()
	Local lMsg := .F.
	Local aParamBox := {}
	Local aRet      := {}

	if !lDireto
		aAdd(aParamBox,{1, "Id De: "     , space(06)     , "", "", "ZKV" , "", 0, .F.})
		aAdd(aParamBox,{1, "Id Ate: "    , space(06)     , "", "", "ZKV" , "", 0, .F.})

		if ParamBox(aParamBox,"Informe o parametro",@aRet,,,,,,,"ACC00007", .T.)

			if MsgYesNo( "Deseja gerar o envio das partes Id de: " + aRet[1] + " até: " + aRet[2] + "?" )

				Begin Transaction
					oProcess := ACCProgress():New({|| lMsg := oAccoread:execInt(aRet, oProcess)},"Processando as informações")
					oProcess:Activate()
				end Transaction

				if lMsg
					//Refresh na tabela de Log e Dashboard
					oBrowse2:Refresh()
					MsgInfo("Concluído com sucesso!")
				endif
			else
				return
			endif
		endif
	else
		Begin Transaction
			oProcess := ACCProgress():New({|| lMsg := oAccoread:execInt(aDados, oProcess)},"Processando as informações")
			oProcess:Activate()
		end Transaction

		if lMsg
			//Refresh na tabela de Log e Dashboard
			oBrowse2:Refresh()
			MsgInfo("Concluído com sucesso!")
		endif
	endif

return

User Function SCHACCFY(aParams)
	Local _aParam   := aParams
	Local oAccoread := ACCOREAD():New()
	Local aDados    := {}
	Local cIdRet    := ""
	Local cLayout   := ""
	Local cFiliais  := ""
	Local lRet      := .F.

	RpcSetType(3)
	RpcSetEnv( _aParam[2], _aParam[3],,,"CTB",,,,,,)

	TLogConsole():Log("Starting integration to company "+_aParam[2]+" and branch "+_aParam[3], "SCHACCFY")

	cLayout   := _aParam[1]
	cFiliais  := _aParam[3] + "/"

	cData := Year2Str(Date()) + Month2Str(Date())
	cIdRet := oAccoread:LoadDados(cFiliais,cData,cLayout,.T.)

	If Valtype(cIdRet) == "L"
		Return
	End

	aadd(aDados, cIdRet)
	aadd(aDados, cIdRet)

	lRet := oAccoread:execInt(aDados,nil)

	If ( lRet )
		TLogConsole():Log("[SUCCESS] - Integration was done successfully...", "SCHACCFY")
	Else
		TLogConsole():Log("[ERROR] - Integration was not done successfully...", "SCHACCFY")
	EndIf

	RpcClearEnv()

	FREEOBJ( oAccoread )

Return
