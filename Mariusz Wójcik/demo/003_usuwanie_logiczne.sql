USE StackOverflow


--Dodanie kolumny IsDeleted do tabeli 
ALTER TABLE [dbo].[CommentsLogical]
ADD IsDeleted BIT DEFAULT 0;


--jaką wartość ma kolumna isDeleted?
SELECT TOP 10
[Id], 
[CreationDate], 
[PostId], 
[Score], 
[Text], 
[UserId], 
[IsDeleted] 
FROM [dbo].[CommentsLogical]



--oznaczamy rok 2010 jako "usunięty"
UPDATE [dbo].[CommentsLogical]
SET IsDeleted = 1
WHERE YEAR(CreationDate) = '2010'


-- które lata są "usunięte"?
SELECT YEAR([CreationDate]) as CommentYear,
COUNT(*) as NumberOfComents   
FROM [dbo].[CommentsLogical]
WHERE IsDeleted = 1
GROUP BY YEAR([CreationDate])
ORDER BY YEAR([CreationDate])

--przywracanie "usuniętych wierszy"
UPDATE [dbo].[CommentsLogical]
SET IsDeleted = 0
WHERE YEAR(CreationDate) = '2010'


----------- columnstore

DELETE FROM [dbo].[CommentsColumnstore]
WHERE  YEAR(CreationDate) = '2010'

--aktualizacja columnstore 
ALTER INDEX IDX_CommentsColumnstore_Clustered ON [dbo].[CommentsColumnstore]
REORGANIZE WITH (COMPRESS_ALL_ROW_GROUPS = ON);


--sprawdzamy stan columnstore - pojawiły się "tombstone", zdealokowane row groupy zawierające usunięte wiersze
SELECT 
*
FROM sys.dm_db_column_store_row_group_physical_stats AS rg
WHERE object_id = OBJECT_ID('CommentsColumnstore');

--posprzątajmy tombstone
ALTER INDEX IDX_CommentsColumnstore_Clustered ON [dbo].[CommentsColumnstore]
REORGANIZE WITH (COMPRESS_ALL_ROW_GROUPS = ON);
