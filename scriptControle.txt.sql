-- 1
create database GestClub
go
use GestClub
go
create table Club(
NomClub varchar(30) primary key,
Capacite int,
Lieu varchar(50),
Region varchar(30),
Tarif money
)
create table Activite(
NomClub varchar(30),
Libelle varchar(50),
Prix money,
primary key(NomClub,Libelle),
constraint fk_NomClub_Club foreign key(NomClub) references Club(NomClub)
)
create table Client(
IdClt int primary key identity(10,10),
Nom varchar(20),
Prenom varchar(20),
Ville varchar(30),
Region varchar(30),
Solde money
)
create table Sejour(
IdClt int,
NomClub varchar(30),
Debut date,
nbPlaces int,
primary key(IdClt,NomClub,Debut),
constraint fk_IdClt_Client foreign key(IdClt) references Client(IdClt),
constraint fk_NomClubSejour_Club foreign key(NomClub) references Club(NomClub)
)
insert into Club values('Toubkal',350,'Marrakech','Maroc',1200)

insert into Activite values('Toubkal','Ski',150),('Toubkal','Marche',120)

insert into Client values('Gogg','Philipes','Londres','Europe',5246.5)
insert into Client values('Pascal','Blais','Paris','Europe',6763)
insert into Client values('Kerouac','Jack','NewYork','Amerique',9812)

insert into Sejour values(20,'Toubkal','03/08/2021',4)

-- 2
alter table Club add constraint tarif_positif Check(Tarif>0)

-- 3
select * from Club
where Region='Maroc'
order by NomClub asc

--4 
select * from Client
where Region='Europe'

-- 5
create procedure sp_afficherListReservation(@nomClub varchar(30))
as
begin
  select * from Sejour where NomClub=@nomClub
end

exec sp_afficherListReservation 'Toubkal'

-- 6
create procedure sp_afficherNomPrenomClient(@idClt int)
as
begin
  select Nom,Prenom from Client where IdClt=@idClt
end

exec sp_afficherNomPrenomClient 20

-- 7
create procedure sp_dimineurLePrix
as
begin
  update Activite set Prix=Prix-((Prix*5)/100)
end

exec sp_dimineurLePrix

-- 8

create function Activites(@nomClub varchar(30))
returns varchar(1000)
as
begin
  declare @ListActivite varchar(1000)
  set @ListActivite=''
  declare @Libelle varchar(50)
  declare MonCursor cursor for select Libelle from Activite
  open MonCursor
  fetch next from MonCursor into @Libelle
  while @@FETCH_STATUS=0
    begin
       set @ListActivite+=CONCAT(@Libelle,',')
	   fetch next from MonCursor into @Libelle
    end
  close MonCursor
  deallocate MonCursor
  print @ListActivite
end

-- 9
create view AfficherNombreClientParRegion 
as
(
select Region,Count(IdClt) 'Nombre Client' from Client
group by Region
)
select * from AfficherNombreClientParRegion 

-- 10

create procedure Actualiser(@pourcentage int,@nomClub varchar(30))
as
begin
  -- augmenter le tarif du club
  update Club set Tarif=Tarif+((Tarif*@pourcentage)/100) where NomClub=@nomClub
  --augmenter le prix de chacune de ses activites 
  update Activite set Prix=Prix+((Prix*@pourcentage)/100) where NomClub=@nomClub
end

exec Actualiser 5,'Toubkal'


-- 11

create trigger tr_afterInsertSejour
on Sejour
for insert
as
begin
   declare @SoldeClt money
   declare @TarifTotal money
   select @SoldeClt=Solde,@TarifTotal=(nbPlaces*Tarif) from inserted I join Client C on I.IdClt=C.IdClt
   join Club Cl on Cl.NomClub=I.NomClub
   if(@SoldeClt<@TarifTotal)
     begin
	   RaisError('le solde est insuffisant',16,1)
	   Rollback
	 end
end

insert into Sejour values(10,'Toubkal',GETDATE(),1)

-- 12

create trigger tr_afterInsertClient
on Client
for insert
as
begin
  if((select Solde from inserted)<3000)
  begin
    RaisError('Le solde doit etre superieur de 3000',16,1)
	Rollback
  end
end



insert into Client values('Boutissante','Issam','Tidili','Maroc',2000)






