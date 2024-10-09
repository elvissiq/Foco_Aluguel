#include "Protheus.ch"
/*************************************************************************************|
|Ponto de Entrada: MT103IPC()                                                         |
|-------------------------------------------------------------------------------------|
|Localização: ao lançar um documento de entrada a partir de um pedido de compras irá  |
| carregar a descrição do produto                                                     |
|-------------------------------------------------------------------------------------|
|*************************************************************************************/
User Function MT103IPC
	Local aArea     := GetArea()
    Local nPosCod   := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="D1_COD" })
    Local nPosCampo := aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="D1_XDESC" })
    Local nAtual    := 0
    
    //Percorrendo os acols
    For nAtual := 1 To Len(aCols)
        aCols[nAtual][nPosCampo] := Posicione('SB1', 1, FWxFilial('SB1')+aCols[nAtual][nPosCod], "B1_DESC")
    Next
     
    RestArea(aArea)

Return 
