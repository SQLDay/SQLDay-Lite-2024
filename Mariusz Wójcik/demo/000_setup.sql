/*
pobrać bazę stack overflow https://www.brentozar.com/archive/2015/10/how-to-download-the-stack-overflow-database-via-bittorrent/
- przywrócić dwie kopie bazy :

		- zwróć uwagę że zmieniona jest nazwa z StackOverflow2013 na StackOverflow.

		- zmień compatibility level na SQL Server 2022 (wszystko powinno zadziałać na wersjach od 2012)

		- powtórz kroki i przywróć bazę jeszcze raz, tym razem nazywajać ją StackOverflowPartitioned

		- zmień compatibility level na SQL Server 2022 (lub co najmniej 2014)


*/
USE StackOverflow

--kopiujemy tabelkę 
DROP TABLE IF EXISTS [dbo].[Comments2]

SELECT * INTO [dbo].[Comments2] FROM [dbo].[Comments] -- ~32sec (zalezy od hardware)
GO



--dodajemy indeksy
ALTER TABLE [dbo].[Comments2] 
ADD CONSTRAINT [PK_Comments2_Id] PRIMARY KEY CLUSTERED ([Id] ASC) --28sec
GO

CREATE INDEX IX_CreationDate 
ON [dbo].[Comments2](CreationDate);

CREATE NONCLUSTERED INDEX [IX_PostId]
ON [dbo].[Comments2] ([PostId]);

CREATE NONCLUSTERED INDEX [IX_UserId]
ON [dbo].[Comments2] ([UserId]);

CREATE NONCLUSTERED INDEX [IX_all_in_one]
ON [dbo].[Comments2] ([UserId], [CreationDate], [PostId]);



-- rozkład danych w tabeli
SELECT YEAR([CreationDate]) as CommentYear,
COUNT(*) as NumberOfComents   
FROM [dbo].[Comments2]
GROUP BY YEAR([CreationDate])
ORDER BY YEAR([CreationDate])



--kopiujemy tabelkę ale bez indeksów
DROP TABLE IF EXISTS [dbo].[CommentsHeap]

SELECT * INTO [dbo].[CommentsHeap] FROM [dbo].[Comments] 
GO


--tworzymy tabelkę pod usuwanie logiczne
DROP TABLE IF EXISTS [dbo].[CommentsLogical]

SELECT * INTO [dbo].[CommentsLogical] FROM [dbo].[Comments] 
GO


--tworzymy tabelkę pod usuwanie logiczne z columnstore
DROP TABLE IF EXISTS [dbo].[CommentsColumnstore]

SELECT * INTO [dbo].[CommentsColumnstore] FROM [dbo].[Comments] 
GO

CREATE CLUSTERED COLUMNSTORE INDEX IDX_CommentsColumnstore_Clustered
ON [dbo].[CommentsColumnstore];
