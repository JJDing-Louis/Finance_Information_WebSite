--選單資料
create table dbo.RefContextType
(
    Name nvarchar(100)              not null
        primary key,
    Value  nvarchar(50)             not null,
    Description   nvarchar(50)      not null
)
go

--排程執行模式
create table dbo.RefScheduleExcuteMode
(
    Name nvarchar(100)              not null
        primary key,
    Value  nvarchar(50)             ,
    Description   nvarchar(50)      
)
go

