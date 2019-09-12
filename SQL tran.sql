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
insert into trace values('GDE0003', 1, 'GVE', 'GVE','D', '04/09/2019')

--select *from trace
--select x.idCamion,x.noMov ,x.fecha,x.estatus from
--(select idCamion, max(noMov) as noMov from trace group by idCamion) as f inner join trace as x on x.noMov=f.noMov and x.idCamion = f.idCamion where estatus='D'

--set transaction level isolation read committed
--begin tran-
--	select * from trace with updlock 

--	rollback tran
--go


--drop proc GetAvailableTruck 
go
create proc GetAvailableTruck(@tam varchar, @fecha date , @ubica varchar(4))
as
begin
	
set transaction isolation level read committed
begin tran
	declare @truck table(idCamion varchar(7) not null,
	noMov int,
	sedeOrigen varchar(3) not null,
	sedeUbica varchar(3) not null,
	estatus char not null,
	fecha date default GetDate())
	declare @lastMove int
	--declare @ubica varchar(3)
	--select @ubica ='GVE'
	select * from trace with (updlock) where sedeUbica = @ubica
	insert into @truck select top 1 x.idCamion, x.noMov +1, x.sedeOrigen, @ubica, 'V', GETDATE() from
	trace  as x
	inner join (select idCamion, max(noMov) as noMov from trace group by idCamion) as f    on x.noMov=f.noMov and x.idCamion = f.idCamion where estatus='D'
	select * from @truck
	if  exists (select 1 from @truck)
		begin
			insert into trace select * from @truck
			commit tran
 		end
	else
		begin 
			--Error raiseerror camion no disponible
			raiserror('No existen camiones', 16, 1)
			rollback tran
		end
end
go
exec GetAvailableTruck 'GDE' ,'12/09/2019' ,  'GVE' 
	
select * from trace
