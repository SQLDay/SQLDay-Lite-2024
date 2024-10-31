USE StackOverflowPartitioned


DROP TABLE IF EXISTS dbo.Comments_Temp

CREATE TABLE dbo.Comments_Temp (
    Id INT IDENTITY(1,1) NOT NULL,
    CreationDate DATETIME NOT NULL,
    PostId INT NOT NULL,
    Score INT NULL,
    Text NVARCHAR(700) NOT NULL,
    UserId INT NULL,
    CONSTRAINT PK_Comments_Temp PRIMARY KEY CLUSTERED (Id ASC, CreationDate)
) ON FG_2012;  -- Umieszczamy na tym samym filegroupie


-- rozkład danych w tabeli
SELECT YEAR([CreationDate]) as CommentYear,
COUNT(*) as NumberOfComents   
FROM [dbo].[Comments_partitioned]
GROUP BY YEAR([CreationDate])
ORDER BY YEAR([CreationDate])

--przesuwamy dane z 2012 roku do tabeli tymczasowej
ALTER TABLE dbo.Comments_partitioned
SWITCH PARTITION 5 TO dbo.Comments_Temp;

-- sprawdzmy czy partycje zostały zamienine
SELECT YEAR([CreationDate]) as CommentYear,
COUNT(*) as NumberOfComents   
FROM [dbo].[Comments_partitioned]
GROUP BY YEAR([CreationDate])
ORDER BY YEAR([CreationDate])

-- rozkład danych w tabeli tymczasowej
SELECT YEAR([CreationDate]) as CommentYear,
COUNT(*) as NumberOfComents   
FROM [dbo].Comments_Temp
GROUP BY YEAR([CreationDate])
ORDER BY YEAR([CreationDate])

DROP TABLE dbo.Comments_Temp;




--szczególny przypadek TRUNCATE gdzie możemy "filtrować" wiersze poprzez wskazanie partycji
TRUNCATE TABLE [dbo].[Comments_partitioned]
WITH (PARTITIONS (1, 3 TO 5));
GO