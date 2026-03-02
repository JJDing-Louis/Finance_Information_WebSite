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

--排程執行模式
create table dbo.RefRr
(
    Name nvarchar(100)              not null
        primary key,
    Value  nvarchar(50)             ,
    Description   nvarchar(50)      
)
go


--排程設定檔
create table dbo.TB_SCHEDULE_CONFIGS
(
    scheduleName nvarchar(100)              not null
        primary key,
    scheduleOpt  nvarchar(50)               not null,
    modifyTime   datetime default getdate() not null,
    Status       nvarchar(10)               not null,
    scheduleUrl  nvarchar(500)              not null,
    scheduleMode nvarchar(500)              not null,
    mappingTable nvarchar(50)               not null
)
go

--API設定
create table dbo.WebCrawl_CONFIGS
(
    scheduleName        nvarchar(100) not null
        constraint PK__TB_API_C__AD5BFDB0CBB523A1
            primary key,
    Url              nvarchar(255),
    sendData            nvarchar(500),
    sendType            nvarchar(500),
    batchPath           nvarchar(500),
    batchFileName       nvarchar(500),
    dataReplaceRole     nvarchar(10),
    dataReplaceDayCount int,
    iscover             nvarchar,
    skipRow             int,
    skipEndRow          int
)
go


--API設定
create table dbo.TB_API_CONFIGS
(
    scheduleName        nvarchar(100) not null
        constraint PK__TB_API_C__AD5BFDB0CBB523A1
            primary key,
    apiUrl              nvarchar(255),
    sendData            nvarchar(500),
    sendType            nvarchar(500),
    batchPath           nvarchar(500),
    batchFileName       nvarchar(500),
    dataReplaceRole     nvarchar(10),
    dataReplaceDayCount int,
    iscover             nvarchar,
    skipRow             int,
    skipEndRow          int
)
go

--FTP設定
create table dbo.TB_FTP_CONFIGS
(
    scheduleName            nvarchar(100) not null
        primary key,
    ftpDomain               nvarchar(50)  not null,
    ftpAc                   nvarchar(50),
    ftpP                    nvarchar(500),
    ftpFileName             nvarchar(100),
    ftpPath                 nvarchar(500) not null,
    localPath               nvarchar(500) not null,
    localFileName           nvarchar(500),
    mappingType             nvarchar(50)  not null,
    fileNameReplaceRole     nvarchar(10),
    fileNameReplaceDayCount int,
    skipRow                 int,
    iscover                 nvarchar      not null,
    CustomCsvDelimiter      nvarchar(4),
    IsNeedExcelTitle        bit
)
go

-- 檔案設定
create table dbo.TB_FILE_CONFIGS
(
    ScheduleName        unknown,
    TempateFileName     unknown,
    FilePath            unknown,
    FileName            unknown,
    dataReplaceRole     unknown,
    dataReplaceDayCount unknown
)
go

--郵件設定
create table TB_MAIL_CONFIGS
(
    MAILSCRIPTNAME varchar(1000),
    CREATE_TIME    datetime     not null,
    MAILTO         varchar(500) not null,
    CCTO           varchar(500) not null,
    SUBJECT        varchar(1000),
    BODY           text,
    MODIFY_TIME    datetime,
    MailType       nvarchar(10),
    MailToName     varchar(100)
)
go

--Mapping設定
create table dbo.TB_MAPPING_CONFIGS
(
    scheduleName unknown,
    startLen     unknown,
    endLen       unknown,
    sourceCol    unknown,
    mappingCol   unknown,
    excelsheet   unknown,
    DocIndex     unknown,
    sort         unknown
)
go


--使用者設定
create table TUSER
(
    ID                nvarchar(200) not null,
    IsActive          bit,
    ADLogin           bit,
    Salt              nvarchar(50),
    EncryptPW         nvarchar(200),
    Extension         nvarchar(20),
    RID               nvarchar(1020),
    Email             nvarchar(250),
    UserName      nvarchar(50)
)
go

---發送郵件紀錄
create table dbo.SENDMAIL
(
    MAILID      nvarchar(36) not null
        primary key,
    CREATE_TIME datetime     not null,
    MAILTO      varchar(500) not null,
    CCTO        varchar(500),
    SUBJECT     varchar(1000),
    BODY        text,
    STATUS      varchar(30)  not null,
    MODIFY_TIME datetime,
    FILEPATH    text,
    ZIPP        varchar(1000),
    MailType    nvarchar(10),
    MailToName  varchar(100)
)
go
