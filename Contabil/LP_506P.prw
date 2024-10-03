#Include 'totvs.ch'

User Function LP_506P(_cChave)
	Local _nRet         := 0
	Local _aGetArea     := FwGetArea()
	Public _nPisCtb		:= 0
    // Indice 7
    // E5_FILIAL, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_CLIFOR, E5_LOJA
	// EZ_FILIAL, EZ_PREFIXO, EZ_NUM   , EZ_PARCELA. EZ_TIPO, EZ_CLIFOR, EZ_LOJA

	dbSelectArea('SEZ')
	dbSetOrder(4)
	dbSeek(_cChave)
	if Found()
		While !eof() .and. SEZ->(EZ_FILIAL + EZ_PREFIXO + EZ_NUM + EZ_PARCELA + EZ_TIPO + EZ_CLIFOR + EZ_LOJA) == _cChave
			if alltrim(SEZ->EZ_TIPO)=='NF'
				_nRet := SEZ->EZ_XPIS
			Endif
			Skip
			Loop
		Enddo
	Endif
	_nPisCtb := _nRet
	FWRestArea(_aGetArea)
Return(_nRet)

