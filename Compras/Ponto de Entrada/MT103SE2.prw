#INCLUDE "Totvs.ch"

/*/{Protheus.doc} MT103SE2
    
    Este ponto de entrada tem o objetivo de possibilitar a adição de campos 
    ao aCols de informações do título financeiro gravado para o documento de entrada, 
    para as opções de visualização, inclusão e exclusão do documento.
    
    Ex.: Permite adicionar o campo de Vencimento Original ao aCols de informações 
         quando visualizar ou excluir o documento.
    
    Localização: Function NfeFldFin() - Função responsável pelo tratamento do 
                 folder financeiro no documento de entrada.
                 
    @type  User Function
    @author TOTVS Nodeste (Elvis Siqueira)
    @since 29/04/2024
    @param PARAMIXB[1], PARAMIXB[2]
    @return Array
    @see https://tdn.totvs.com/pages/releaseview.action?pageId=6085675
/*/

User Function MT103SE2
    Local aRet:= {}
    Local aCampos := {"E2_LINDIG","E2_CODBAR","E2_FORMPAG"}
    Local nY 

    For nY := 1 To Len(aCampos)
        aAdd(aRet,{ GetSX3Cache(aCampos[nY], "X3_TITULO") ,;
                    GetSX3Cache(aCampos[nY], "X3_CAMPO")  ,;
                    GetSX3Cache(aCampos[nY], "X3_PICTURE"),;
                    GetSX3Cache(aCampos[nY], "X3_TAMANHO"),;
                    GetSX3Cache(aCampos[nY], "X3_DECIMAL"),;
                    "",;
                    GetSX3Cache(aCampos[nY], "X3_USADO")  ,;
                    GetSX3Cache(aCampos[nY], "X3_TIPO")   ,;
                    GetSX3Cache(aCampos[nY], "X3_F3")     ,;
                    GetSX3Cache(aCampos[nY], "X3_CONTEXT"),;
                    GetSX3Cache(aCampos[nY], "X3_CBOX")   ,;
                    GetSX3Cache(aCampos[nY], "X3_RELACAO"),;
                    ".T."})
    Next nY

Return (aRet)
