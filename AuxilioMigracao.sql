-- Esse script substitui a migração 20190909180000 do Risk Manager e deve ser executada pelo ManagementStudio caso a migração dê timeout.

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AppMessage]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[AppMessageContent]
(
	[MessageValues] [nvarchar](max) NULL,
	[Oid] [uniqueidentifier] NOT NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END

IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'MessageContent'
          AND Object_ID = Object_ID(N'[dbo].[AppMessage]'))
BEGIN
	ALTER TABLE [AppMessage] Add [MessageContent] UniqueIdentifier NULL;
End;

if( exists (select top 1 Oid from AppMessageContent) )
	TRUNCATE TABLE [AppMessageContent];
IF  OBJECT_ID(N'tempdb..#MessagesHashes') IS NOT NULL
DROP TABLE [#MessagesHashes];
    
PRINT FORMAT(GETDATE(), 'HH:mm:ss.fff' ) + ': Criando hashes de mensagens...';
select * into [#MessagesHashes]
from ( select max(Oid) as amOid, max(mcOid) as mcOid, MessageHash 
		from (select Oid, NEWID() mcOid, Convert( NVARCHAR(32), HASHBYTES('MD5',[MessageValues]), 2) MessageHash
				from [AppMessage] where GCRecord is null and SentOn>=dateadd(DD, -30, GETDATE())) a
		group by MessageHash) t

PRINT FORMAT(GETDATE(), 'HH:mm:ss.fff' ) + ': Preenchendo tabela de mensagens...';
insert into AppMessageContent (Oid, MessageValues)
select mh.mcOid, MessageValues
from [#MessagesHashes] mh, [AppMessage] am
where am.Oid = mh.amOid

PRINT FORMAT(GETDATE(), 'HH:mm:ss.fff' ) + ': Atualizando apontamentos da tabela de mensagens para a nova tabela...';
update [AppMessage]
set MessageContent = mh.mcOid
from [#MessagesHashes] mh
where mh.MessageHash = Convert( NVARCHAR(32), HASHBYTES('MD5',[AppMessage].[MessageValues]), 2)
and AppMessage.SentOn>=dateadd(DD, -30, GETDATE())

DROP TABLE [#MessagesHashes]

PRINT FORMAT(GETDATE(), 'HH:mm:ss.fff' ) + ': Copiando registros para a tabela temporária...';
select [Oid], [Text], [Module], [Recipient], [SentOn], [IsRead], [ObjectType], [MessageContent] 
into [AppMessageTemp]
from [AppMessage]
where GCRecord Is null
and MessageContent is not null

PRINT FORMAT(GETDATE(), 'HH:mm:ss.fff' ) + ': Removendo AppMessage...';
DROP TABLE [AppMessage]

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[AppMessage]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[AppMessage](
	[Oid] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[Text] [nvarchar](2000) NULL,
	[Module] [int] NULL,
	[Recipient] [uniqueidentifier] NULL,
	[SentOn] [datetime] NULL,
	[IsRead] [bit] NULL,
	[OptimisticLockField] [int] NULL,
	[GCRecord] [int] NULL,
	[ObjectType] [int] NULL,
	[MessageContent] [uniqueidentifier] NULL,
	CONSTRAINT [PK_AppMessage] PRIMARY KEY CLUSTERED 
(
	[Oid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
END

PRINT FORMAT(GETDATE(), 'HH:mm:ss.fff' ) + ': Copiando registros de volta para a tabela AppMessage...';
INSERT INTO [AppMessage] ([Text], [Module], [Recipient], [SentOn], [IsRead], [ObjectType], [MessageContent])
SELECT Left([Text], 2000), [Module], [Recipient], [SentOn], [IsRead], [ObjectType], [MessageContent] From [AppMessageTemp] order by Oid

DROP TABLE [AppMessageTemp]

PRINT FORMAT(GETDATE(), 'HH:mm:ss.fff' ) + ': Recriando índices e constraints da AppMessage...';
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[AppMessage]') AND name = N'iGCRecord_AppMessage')
Begin
PRINT FORMAT(GETDATE(), 'HH:mm:ss.fff' ) + ': Recriando índice iGCRecord_AppMessage...';
CREATE NONCLUSTERED INDEX [iGCRecord_AppMessage] ON [dbo].[AppMessage]
(
	[GCRecord] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
End;

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[AppMessage]') AND name = N'iObjectType_AppMessage')
Begin
PRINT FORMAT(GETDATE(), 'HH:mm:ss.fff' ) + ': Recriando índice iObjectType_AppMessage...';
CREATE NONCLUSTERED INDEX [iObjectType_AppMessage] ON [dbo].[AppMessage]
(
	[ObjectType] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
End;

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[AppMessage]') AND name = N'iRecipient_AppMessage')
Begin
PRINT FORMAT(GETDATE(), 'HH:mm:ss.fff' ) + ': Recriando índice iRecipient_AppMessage...';
CREATE NONCLUSTERED INDEX [iRecipient_AppMessage] ON [dbo].[AppMessage]
(
	[Recipient] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY];
End;

IF EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[AppMessage]') AND name = N'NonClusteredIndex-20190806-154412')
Begin
	PRINT FORMAT(GETDATE(), 'HH:mm:ss.fff' ) + ': Renomeando índice AppMessage.NonClusteredIndex-20190806-154412 para SentOn-NonClustered...';
    EXEC sp_rename 
            @objname = N'dbo.AppMessage.NonClusteredIndex-20190806-154412',
            @newname = N'SentOn-NonClustered' ,
            @objtype = N'INDEX';
End;

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[AppMessage]') AND name = N'SentOn-NonClustered')
Begin
PRINT FORMAT(GETDATE(), 'HH:mm:ss.fff' ) + ': Recriando índice SentOn-NonClustered...';
    CREATE NONCLUSTERED INDEX [SentOn-NonClustered] ON [dbo].[AppMessage]
    (
	    [SentOn] ASC
    )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
End;
