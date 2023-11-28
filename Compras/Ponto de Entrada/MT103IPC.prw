#include "Protheus.ch"
/*************************************************************************************|
|Ponto de Entrada: MT103IPC()                                                         |
|-------------------------------------------------------------------------------------|
|Localização: ao lançar um documento de entrada a partir de um pedido de compras irá  |
| carregar a descrição do produto                                                     |
|-------------------------------------------------------------------------------------|
|*************************************************************************************/
User Function MT103IPC

Local _nItem   := PARAMIXB[1]
Local _nPosCod := AsCan(aHeader,{|x|Alltrim(x[2])=="D1_COD"})
Local _nPosDes := AsCan(aHeader,{|x|Alltrim(x[2])=="D1_XDESC"})
Local _cDesc   := Posicione( "SB1", 1, FWxFilial("SB1") + aCols[nItem, nPosProd], "B1_DESC" )
   
	If _nPosCod > 0 .And. _nItem > 0
		aCols[_nItem,_nPosDes] := _cDesc
	Endif

Return
