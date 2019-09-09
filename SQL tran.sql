create database Transportistas
go
use Transportistas
go
drop table trace
create table trace(
	idCamion varchar(7) not null,
	noMov int,
	sedeOrigen varchar(3) not null,
	sedeUbica varchar(3) not null,
	estatus char not null,
	fecha date default GetDate(),
	primary key (idCamion, noMov desc)
)

go
insert into trace values('GDE0001', 1, 'CLN', 'CLN','D', '03/09/2019')
insert into trace values('GDE0001', 2, 'CLN', 'SR','V','03/09/2019')
insert into trace values('GDE0001', 3, 'CLN', 'GVE','F','03/09/2019')
insert into trace values('GDE0001', 4, 'CLN', 'GVE','S','03/09/2019')
insert into trace values('GDE0001', 5, 'CLN', 'GVE','D','05/09/2019')
insert into trace values('GDE0002', 2, 'GVE', 'GVE','V', '04/09/2019')

select *from trace
select x.idCamion,x.noMov ,x.fecha,x.estatus from
(select idCamion, max(noMov) as noMov from trace group by idCamion) as f inner join trace as x on x.noMov=f.noMov and x.idCamion = f.idCamion where estatus='D'

begin tran
	select top 1 x.idCamion from
	(select idCamion, max(noMov) as noMov from trace group by idCamion) as f inner join trace  as x with (updlock) on x.noMov=f.noMov and x.idCamion = f.idCamion where estatus='D'

go
	

create function GetAvailableTruck(@tam varchar, @fecha date , @ubica varchar(4))
returns varchar(7)
as
begin
	set transaction isolation level serializable
	begin tran 
		declare @idTruck varchar(7)
		select @idTruck = x.idCamion from
			(select idCamion, max(noMov) as noMov from trace group by idCamion) as f inner join trace as x on x.noMov=f.noMov and x.idCamion = f.idCamion where estatus='D' and x.sedeUbica = @ubica
return @idTruck
end