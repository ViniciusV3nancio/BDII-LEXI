-- 1 Criando o Banco de Dados Fatec --

/* Professor, creio que ouve alguma coisa que não prestei atenção na instalação do meu management studio e parece que ele ficou divido em partes,
uma ficou no meu SSD 'C:' e outra no meu HD 'D:' e por isso o caminho de onde fiz o backup das databases e os filenames primary e secondary,
espero que isso não incomode o senhor. */ 

Create Database FatecSRListaDeExerciciosII
On Primary
(Name = 'FatecSRListaDeExerciciosII-Data',
FileName = 'D:\SQL\MSSQL16.MSSQLSERVER\MSSQL\DATA\FatecSRListaDeExerciciosII-Data.MDF',
Size = 20 MB,
MaxSize = 1024 MB,
FileGrowth = 10 MB),

(Name = 'FatecSRListaDeExerciciosII-Data1',
FileName = 'D:\SQL\MSSQL16.MSSQLSERVER\MSSQL\DATA\FatecSRListaDeExerciciosII-Data1.NDF',
Size = 40 MB,
MaxSize = 1024 MB,
FileGrowth = 40 MB),

Filegroup Secondary
(Name = 'FatecSRListaDeExerciciosII-Data2',
FileName = 'D:\SQL\MSSQL16.MSSQLSERVER\MSSQL\DATA\FatecSRListaDeExerciciosII-Data2.NDF',
Size = 80 MB,
MaxSize = 2048 MB, 
Filegrowth = 25%)

Log On
(Name = 'FatecSRListaDeExerciciosII-Log1',
FileName = 'D:\SQL\MSSQL16.MSSQLSERVER\MSSQL\DATA\FatecSRListaDeExerciciosII-Log1.LDF',
Size = 100 MB,
MaxSize = Unlimited,  
Filegrowth = 20 MB),
(Name = 'FatecSRListaDeExerciciosII-Log2',
Filename = 'D:\SQL\MSSQL16.MSSQLSERVER\MSSQL\DATA\FatecSRListaDeExerciciosII-Log2.LDF',
Size = 100 MB,
MaxSize = 2048,
FileGrowth = 10 MB)
Go

-- Entrando no Banco --
Use FatecSRListaDeExerciciosII
Go

-- a) Criando a tabela de produtos --
Create Table Produtos
(CodProduto Int Primary Key,
FornecedorProduto Int Not Null,
QntProduto Int Null,
VlrProduto Int Null)
Go

-- b) Criando a tabela de fornecedores --
Create Table Fornecedores
(CodFornecedor Int Primary Key,
ProdutoFornecedor Int Not Null,
VlrProdutoCompra Int Null)
On [Secondary]
Go

-- c) Criando o SchemaFatec -- 
Create Schema SchemaFatec
Go
-- Criando a Tabela Clientes no SchemaFatec no Filegroup Secondary --
Create Table SchemaFatec.Clientes
(CodCliente Int Primary Key,
ContatoCliente Varchar(20) Not Null,
NomeCliente Varchar (50) Not Null)
On [Secondary]
Go

-- d) fazendo a relação entre a tabela de produtos e fornecedores --
Alter Table Fornecedores
Add Constraint FK_Produto_Fornecedor Foreign Key (CodFornecedor)  References Produtos (CodProduto)
Go

/*Professor, eu tive bastante dificuldade na estrutura de definição dos valores durante a inserção de dados, não no while ou o declare, 
mas dentro do "Values" */

-- e) Inserindo 1000 Linhas de Registros Lógicos nas Tabelas --
Declare @W Int = 1
While @W <= 1000
Begin 
Insert Into Produtos (CodProduto, FornecedorProduto, QntProduto, VlrProduto)
Values(@W,'' + CONVERT(Varchar(10),@W),
		Floor(Rand() * 100),
		Round(Rand() * 100, 2))
		Set @W = @W + 1
End
Go

Declare @W Int = 1
While @W <= 1000
Begin 
Insert Into Fornecedores (CodFornecedor, ProdutoFornecedor, VlrProdutoCompra)
Values(@W, @W, @W)
	Set @W = @W + 1
End
Go

Declare @W Int = 1
While @W <= 1000
Begin 
Insert Into SchemaFatec.Clientes (CodCliente, ContatoCliente, NomeCliente)
Values(@W, 'Contato ' + Convert(Varchar(10), @W),
			'Cliente ' + Convert(Varchar(10),@W))
	Set @W = @W + 1
End
Go

-- Parte 2 Manutenção --

-- 1 Criando um Indice NonClustered --

Create NonClustered Index IND_CodCliente On SchemaFatec.Clientes (CodCliente)
Go

-- 2 Tamanho usado em disco da tabela de clientes --

Exec sp_spaceused 'SchemaFatec.Clientes'
Go

-- 3 --

-- Criando a Tabela Vendas --
Create Table Vendas 
(CodigoVendas Int Identity (1,1) Not Null Primary Key,
ClienteCodigo Int Not Null,
VendedorCodigo Varchar(30) Not Null,
Quantidade SmallInt Not Null,
Valor Numeric(18,2) Not Null,
Data Date Default GetDate())
Go

-- A Inserindo a Massa de Dados na Tabela Vendas --
Declare @Texto Char(129), @Posicao TinyInt, @ContadorLinhas SmallInt

Set @Texto = '0123456789@ABCDEFGHIJKLMNOPQRSTUVWXYZ\_abcdefghijklmnopqrst
uvwxyzŽ••Ÿ¡ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖÙÚÛÜÝàáâãäåæçèéêëìíîïðñòóô
õöùúûüýÿ' -- Existem 130 caracteres neste texto -

Set @ContadorLinhas = Rand()*10000+1

While (@ContadorLinhas >= 1)
Begin 
Set @Posicao = Rand()*200

Insert Into Vendas (ClienteCodigo, VendedorCodigo, Quantidade, Valor, Data)
Values (@ContadorLinhas,

Concat(Substring(@Texto, @Posicao,1),Substring(@Texto,@Posicao+2,1),
Substring(@Texto,@Posicao+3,1)),
	Rand()*1000,
	Rand()*100+5,
	DateAdd(D, 1000 * Rand(), GetDate()))
Set @ContadorLinhas = @ContadorLinhas - 1
End

-- a) Identificando a quantidade de linhas de registro foram geradas --

Select Count(*) From Vendas
Go

-- Foram 6765 Linhas de Registro Geradas -- 

-- B) Identificando o espaço ocupado da tabela, referente a dados e indices --

Exec sp_spaceused 'Vendas'
Go

-- Dados = 240KB, Index Size = 24KB --

-- C) Identificando o tipo do indice criado para a tabela Vendas --

Select Name As 'Nome do Indice', Type_Desc As 'Tipo do Indice' 
From sys.indexes
Where Object_Id = Object_Id ('Vendas')
Go

-- D) Identificando a forma de ordenação dos dados utilizada na coluna Codigo Vendas --
Select I.Name, I.Type_Desc, Ic.Key_Ordinal, Ic.Is_Descending_Key 
From 
	sys.indexes I 
Inner Join
	sys.index_columns Ic On I.Object_Id = Ic.Object_Id And I.Index_Id = Ic.Index_Id 
Where 
	I.Object_Id = Object_Id('Vendas') 
	And Ic.Column_Id = ColumnProperty(Object_Id('Vendas'), 'CodigoVendas', 'ColumnId') 
Go

-- Parte 3 - Boas Práticas -- 


-- 1 - a) executando a query --

Select * From Vendas
Where Valor Between 5.03 And 6.75
Order By VendedorCodigo Desc, ClienteCodigo Desc, Data Desc
Go

-- b) Consultando os metadados das estatisticas -- 
Select Object_Name(a.Object_Id) As Objeto,
				a.Name, a.auto_created 
From sys.stats a
Where Object_Name (a.Object_Id) = 'Vendas'
Go

-- d) Mostrando o Histograma da _WA_Sys_00000005_5CD6CB2B

DBCC Show_Statistics ("Vendas",_WA_Sys_00000005_5CD6CB2B) With Histogram
Go

-- 7 - a) Qual Coluna é utilizada para armazenar a faixa de valores pertencente a estatistica  -- 
	-- a) RANGE_HI_KEY
--	-- b) Qual coluna é utilizada para calcular a média de linhas por faixa de valores -- 
	-- b) AVG_RANGE_ROWS
--  -- c) Qual coluna apresenta a quantidade exata de registros pertencente a cada faixa de valores --
	-- c) EQ_ROWS

-- 8 – Crie uma nova estatística denominada StatisticsQuantidade para coluna quantidade existente na tabela Vendas. --

-- Executando o Select aplicado a coluna Quantidade, fazendo uma nova estatistica seja criada para esta coluna -- 
Select * From Vendas
Where Quantidade Between 1 And 1000
Order By VendedorCodigo Desc, ClienteCodigo Desc, Data Desc
Go

-- Criando a estatistica -- 
Create Statistics [StatisticsQuantidade] On [Vendas] (Quantidade)
Go

-- Apresentando todos os dados da estatistica existente na coluna Quantidade -- 
Dbcc Show_Statistics ("Vendas", [StatisticsQuantidade])
Go

-- Parte 4 - Backup e Restauração --

-- 1 Alterando o modelo de recuperação do Banco de Dados para Simples --

Alter Database FatecSRListaDeExerciciosII
Set Recovery Simple
Go

-- 2 Realizando o procedimento de Backup Database -- 

Backup Database FatecSRListaDeExerciciosII
To Disk = 'D:\SQL\MSSQL16.MSSQLSERVER\MSSQL\Backup\Backup-Database-Simples-1.Bak'
With Init,
Stats = 5
Go

-- 3 Excluindo a tabela de fornecedores e de clientes -- 

Alter Table Fornecedores
Drop Constraint FK_Produto_Fornecedor
Go

Drop Table Fornecedores
Go

Drop Table SchemaFatec.Clientes
Go

-- 4 Realizando um novo processo de Backup Database  --

Backup Database FatecSRListaDeExerciciosII
To Disk = 'D:\SQL\MSSQL16.MSSQLSERVER\MSSQL\Backup\Backup-Database-Simples-2.Bak'
With Init,
Stats = 5
Go

-- 5 Na Lista de Exercícios diz que é para excluir a tabela de pedidos, mas ela não existe, imagino que seja a de vendas --

Drop Table Vendas
Go

-- 6 Realizando mais um procedimento de Backup Database  -- 
Backup Database FatecSRListaDeExerciciosII
To Disk = 'D:\SQL\MSSQL16.MSSQLSERVER\MSSQL\Backup\Backup-Database-Simples-3.Bak'
With Init,
Stats = 5
Go

-- 7 Restaurando o Banco Três vezes, porém as duas primeiras com "With NoRecovery" e somente a terceira com a opção "With Recovery" --

-- Desconectando do Banco -- 
Use Master
Go

-- 1° Restauração "With NoRecovery" --
Restore Database FatecSRListaDeExerciciosII
From Disk = 'D:\SQL\MSSQL16.MSSQLSERVER\MSSQL\Backup\Backup-Database-Simples-3.Bak'
With NoRecovery,
Replace,
Stats = 10
Go

-- 2° Restauração "With NoRecovery" -- 
Restore Database FatecSRListaDeExerciciosII
From Disk = 'D:\SQL\MSSQL16.MSSQLSERVER\MSSQL\Backup\Backup-Database-Simples-2.Bak'
With NoRecovery,
Replace,
Stats = 10
Go

-- 3° Restauração "With Recovery" -- 
Restore Database FatecSRListaDeExerciciosII
From Disk = 'D:\SQL\MSSQL16.MSSQLSERVER\MSSQL\Backup\Backup-Database-Simples-1.Bak'
With Recovery,
Replace,
Stats = 10
Go

-- 8 Verificando todas as tabelas que foram excluidas após o processo de Restore Database -- 
Use FatecSRListaDeExerciciosII
Go

Select * From Fornecedores
Go

Select * From Vendas
Go

Select * From SchemaFatec.Clientes
Go

