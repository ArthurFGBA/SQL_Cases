create database Excelsior
default character set utf8mb4
default collate utf8mb4_general_ci;

create table Cliente (
ID_cli int not null auto_increment,
nome_cli varchar(30),
primary key(ID_cli)
);
create table Produto(
COD_prod int not null auto_increment,
Descrição varchar(20),
Preço decimal(6,2),
primary key(COD_prod)
); 
create table Venda(
ID_cli int not null,
COD_prod int not null,
Quantidade int not null,
primary key(ID_cli, COD_prod), foreign key (ID_cli) references Cliente(ID_cli), foreign key (COD_prod) references Produto(COD_prod)
);

insert into cliente(ID_cli,nome_cli) values (1,"Ana"), (2,"Pedro"), (3,"Tânia"), (4,"Mária"),(5,"João");
insert into produto(COD_prod,Descrição,preço) values (1,"ProdutoA",10.00), (2,"ProdutoB",2.00), (3,"ProdutoC",4.00), (4,"ProdutoD",5.00);
insert into venda(ID_cli,COD_prod,Quantidade) values (3,1,1), (1,2,8), (2,2,5), (1,3,1), (4,3,10), (2,1,1);

Select* from produto;
Select nome_cli from cliente;
select descrição from produto, venda, cliente where (nome_cli="Pedro") and (cliente.ID_cli= venda.ID_cli) and (produto.COD_prod=venda.COD_prod);
select* from produto order by preço desc;
select nome_cli from cliente,venda where (cliente.ID_cli=venda.ID_cli) and (venda.Quantidade>2 and venda.Quantidade<10);
select max(venda.Quantidade),descrição from venda, produto where (venda.COD_prod=produto.COD_prod);

Create view Venda_desc as (Select * from venda inner join produto having produto.preço>3)

Select * from Venda_desc