# lua-xml-parser
Parser para XML escrito a mão inteiramente em Lua apenas para aprendizagem.

### Bugs conhecidos
* Ao encontrar `<` dentro do objeto XML ele para a leitura do texto interno ao objeto.
* Suporta somente texto interno ou objeto XML interno, ambos não são interpretados.
* Não libera erros caso os objetos não sejam devidamente finalizados.

### Performance
Para tratar os arquivos possui uma performance excelente, entretanto devido a precária implementação de objetos em Lua a instanciação de cada classe é muito custosa e acaba abalando a performance.
