--włączyć plan zapytań

--usuwanie danych z tabeli bez indeksów i klucza głównego
SET STATISTICS IO ON
DELETE [dbo].[CommentsHeap]
  WHERE CreationDate < '2010-01-01'; 
  -- 5sec
  -- memory grant 136 KB
  -- logical and physical reads?

--usuwanie danych gdy tabela ma indeksy
DELETE [dbo].[Comments2]
  WHERE CreationDate < '2010-01-01'; 
  -- 25sec
  -- memory grant 128 MB
  -- logical and physical reads?


SET STATISTICS IO OFF



--usuwanie w pętli
 DECLARE @Deleted_Rows INT;
 SET @Deleted_Rows = 1;


 WHILE (@Deleted_Rows > 0)
   BEGIN
    -- Delete some small number of rows at a time
      DELETE TOP (10000) [dbo].[Comments2] 
      WHERE CreationDate  < '2010-01-01'

   SET @Deleted_Rows = @@ROWCOUNT;
   CHECKPOINT;--czyścimy log transakcyjny

 END


--usuwanie z użyciem widoku
CREATE OR ALTER VIEW dbo.Comments_ToBeDeleted AS
    SELECT TOP 1000 [Id], 
	[CreationDate], 
	[PostId], 
	[Score], 
	[Text], 
	[UserId]
    FROM [dbo].[Comments2]
    ORDER BY CreationDate;
GO

