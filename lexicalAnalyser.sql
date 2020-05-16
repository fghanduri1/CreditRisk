

#InComplete Pre-Processing

USE EmpTitles as db1
USE Loan as db2
GO

  regex period                { <[.]> }
    regex underscore            { <[_]> }
    regex plus-sign             { <[+]> }
    regex minus-sign            { <[-]> }
    regex sign                  { <+plus-sign +minus-sign> }
    regex left-paren            { <[(]> }
    regex right-paren           { <[)]> }
    regex colon                 { <[:]> }
    regex semicolon             { <[;]> }
    regex comma                 { <[,]> }
    regex solidus               { <[/]> }

   rule generic-statement {
       <keyword>
       [ <compound-statement>
        || [   <regular-identifier>
             | <keyword>
             | <quoted-label>
             | <variable>
             | <compound-statement>
             | <period>
             | <literal>
             | <left-paren>
             | <right-paren>
             | <comma>
             | <operator-symbol>
             | <comment>
           ]
       ]*
    }



   SET QUOTED_IDENTIFIER ON
   GO
   SET ANSI_NULLS ON
   GO

   CREATE FUNCTION FUNC_LEVENSHTEIN(@s nvarchar(4000), @t nvarchar(4000), @d int)
   RETURNS int
   AS
   BEGIN
     DECLARE @sl int, @tl int, @i int, @j int, @sc nchar, @c int, @c1 int,
       @cv0 nvarchar(4000), @cv1 nvarchar(4000), @cmin int
     SELECT @sl = LEN(@s), @tl = LEN(@t), @cv1 = '', @j = 1, @i = 1, @c = 0
     WHILE @j <= @tl
       SELECT @cv1 = @cv1 + NCHAR(@j), @j = @j + 1
     WHILE @i <= @sl
     BEGIN
       SELECT @sc = SUBSTRING(@s, @i, 1), @c1 = @i, @c = @i, @cv0 = '', @j = 1, @cmin = 4000
       WHILE @j <= @tl
       BEGIN
         SET @c = @c + 1
         SET @c1 = @c1 - CASE WHEN @sc = SUBSTRING(@t, @j, 1) THEN 1 ELSE 0 END
         IF @c > @c1 SET @c = @c1
         SET @c1 = UNICODE(SUBSTRING(@cv1, @j, 1)) + 1
         IF @c > @c1 SET @c = @c1
         IF @c < @cmin SET @cmin = @c
         SELECT @cv0 = @cv0 + NCHAR(@c), @j = @j + 1
       END
       IF @cmin > @d BREAK
       SELECT @cv1 = @cv0, @i = @i + 1
     END
     RETURN CASE WHEN @cmin <= @d AND @c <= @d THEN @c ELSE -1 END
   END
   GO




#Complete Pre-Processing

   USE EmpTitles as db1
   USE Loan as db2
   GO

   SELECT *
   FROM db1 title
   LEFT JOIN db2 employability
   ON (LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(db1.title,' ',''),'-',''),'''','')))
    = LTRIM(RTRIM(REPLACE(REPLACE(REPLACE(db2.employability,' ',''),'-',''),'''',''))))
   AND ( db1.title LIKE '%'+db2.employability+'%'
        OR db2.employability LIKE '%'+db1.title+'%')
