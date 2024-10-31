USE StackOverflowPartitioned

-- Stworzenie filegroupów dla lat 2008-2013
ALTER DATABASE StackOverflowPartitioned
ADD FILEGROUP [FG_2008];
ALTER DATABASE StackOverflowPartitioned
ADD FILEGROUP [FG_2009];
ALTER DATABASE StackOverflowPartitioned
ADD FILEGROUP [FG_2010];
ALTER DATABASE StackOverflowPartitioned
ADD FILEGROUP [FG_2011];
ALTER DATABASE StackOverflowPartitioned
ADD FILEGROUP [FG_2012];
ALTER DATABASE StackOverflowPartitioned
ADD FILEGROUP [FG_2013];

-- Dodanie plików do filegroupów w nowej lokalizacji
ALTER DATABASE StackOverflowPartitioned
ADD FILE 
(
	NAME = 'Comments_2008',
	FILENAME = 'C:\databases\StackOverflowPartitioned\Comments_2008.ndf',
	SIZE = 5MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5MB
) TO FILEGROUP [FG_2008];

ALTER DATABASE StackOverflowPartitioned
ADD FILE 
(
	NAME = 'Comments_2009',
	FILENAME = 'C:\databases\StackOverflowPartitioned\Comments_2009.ndf',
	SIZE = 5MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5MB
) TO FILEGROUP [FG_2009];

ALTER DATABASE StackOverflowPartitioned
ADD FILE 
(
	NAME = 'Comments_2010',
	FILENAME = 'C:\databases\StackOverflowPartitioned\Comments_2010.ndf',
	SIZE = 5MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5MB
) TO FILEGROUP [FG_2010];

ALTER DATABASE StackOverflowPartitioned
ADD FILE 
(
	NAME = 'Comments_2011',
	FILENAME = 'C:\databases\StackOverflowPartitioned\Comments_2011.ndf',
	SIZE = 5MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5MB
) TO FILEGROUP [FG_2011];

ALTER DATABASE StackOverflowPartitioned
ADD FILE 
(
	NAME = 'Comments2_2012',
	FILENAME = 'C:\databases\StackOverflowPartitioned\Comments_2012.ndf',
	SIZE = 5MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5MB
) TO FILEGROUP [FG_2012];

ALTER DATABASE StackOverflowPartitioned
ADD FILE 
(
	NAME = 'Comments2_2013',
	FILENAME = 'C:\databases\StackOverflowPartitioned\Comments_2013.ndf',
	SIZE = 5MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 5MB
) TO FILEGROUP [FG_2013];






-- Funkcja partycjonowania dla lat 2008-2013
CREATE PARTITION FUNCTION pf_Comments_byYear (DATETIME)
AS RANGE RIGHT FOR VALUES ('2009-01-01', '2010-01-01', '2011-01-01', '2012-01-01', '2013-01-01');


-- Schemat partycjonowania dla filegroupów 2008-2013
CREATE PARTITION SCHEME ps_Comments_byYear
AS PARTITION pf_Comments_byYear
TO ([FG_2008], [FG_2009], [FG_2010], [FG_2011], [FG_2012], [FG_2013]);



-- Stworzenie nowej tabeli korzystającej z partycjonowania
CREATE TABLE [dbo].[Comments_partitioned] (
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CreationDate] [datetime] NOT NULL,
	[PostId] [int] NOT NULL,
	[Score] [int] NULL,
	[Text]  nvarchar(700) NOT NULL,
	[UserId] [int] NULL,
 CONSTRAINT [PK_Comments2_partitioned_Id] PRIMARY KEY CLUSTERED 
(
	[Id] ASC, [CreationDate]
) ON ps_Comments_byYear(CreationDate)
) ON ps_Comments_byYear(CreationDate);

-- Przeniesienie danych do nowej tabeli
INSERT INTO [dbo].[Comments_partitioned] ([CreationDate], [PostId], [Score], [Text], [UserId])
SELECT [CreationDate], [PostId], [Score], [Text], [UserId]
FROM [dbo].[Comments];


-- Sprawdzenie liczby wierszy w każdej partycji
SELECT 
    p.partition_number AS PartitionNumber,
    prv.value AS PartitionRangeBoundary,
    ps.name AS PartitionSchemeName,
    pf.name AS PartitionFunctionName,
    SUM(pss.row_count) AS RowsInPartition
FROM sys.partitions p
JOIN sys.objects o ON p.object_id = o.object_id
JOIN sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
JOIN sys.partition_schemes ps ON i.data_space_id = ps.data_space_id
JOIN sys.partition_functions pf ON ps.function_id = pf.function_id
LEFT JOIN sys.partition_range_values prv ON pf.function_id = prv.function_id AND p.partition_number = prv.boundary_id
JOIN sys.dm_db_partition_stats pss ON p.partition_id = pss.partition_id
WHERE o.name = 'Comments_partitioned' -- Nazwa twojej partycjonowanej tabeli
AND p.index_id IN (0, 1)   -- Partycje dla tabeli heap lub z indeksem klastrowym
GROUP BY p.partition_number, prv.value, ps.name, pf.name
ORDER BY p.partition_number;

