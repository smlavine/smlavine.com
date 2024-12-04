---
title: Advent of Code 2024 in SQLite
date: 2024-12-02
params:
  lastUpdated: 2024-12-04
---

Ho ho ho. Merry December.

Like lots of software people, I'm getting into [Advent of Code][aoc24]
this year. It's an opportunity to solve some fun puzzles, learn a new
programming language, dive deep into an old one, [or design your own
hyper-optimized language to speedrun the puzzles and get first place
every year.](https://blog.vero.site/post/noulith)

[aoc24]: https://adventofcode.com/2024/about

The possibilities are endless!

This page will grow to document my progress on AoC '24 as the month goes
on, including my solutions and some timely commentary.

[You can see all my solutions here.][git.sr.ht]

[git.sr.ht]: https://git.sr.ht/~smlavine/aoc24

Again, check out [the real thing][aoc24] if you're interested in solving
these things. Spoilers below.

<section id="toc">

## Table of Contents

<ul>
  <li><a href="#day01">Day 01: Historian Hysteria</a>
  <li><a href="#day02">Day 02: Red-Nosed Reports</a>
</ul>

</section>

<hr>

<section id="day01">

## Day 01: Historian Hysteria

[Read the Day 01 description here.](https://adventofcode.com/2024/day/1)

I've been having fun solving puzzles like [Project Euler][pe] in SQLite
for a while now. So that's where I decided to start with this year's
Advent of Code.

[pe]: https://projecteuler.net

Here's how I run my code and get the answer to the problem (using the
example data):

```
master$ pwd
/home/smlavine/Code/projects/aoc24/solutions/01
master$ ls
example.txt  input.txt  link.txt  solution.sql
master$ time sqlite3 < solution.sql
┌─────────────────────────┬───────────────────────────┐
│ total distance (part 1) │ similarity score (part 2) │
├─────────────────────────┼───────────────────────────┤
│ 11                      │ 31                        │
└─────────────────────────┴───────────────────────────┘

real    0m0.007s
user    0m0.006s
sys     0m0.001s
```

Day 01's problem was pretty easy, and actually lended itself pretty well
to some of the advantages of SQL/relational problem solving. Below is a
piecemeal breakdown of my solution.

```sql
-- Advent of Code 2024, Day 01 (parts 1 and 2).

-- Each "list column" is separated by three spaces. SQLite doesn't support
-- multi-char separators, so read in the input as if with two "empty columns".
.separator " "
CREATE TABLE input(col1, empty_col2, empty_col3, col4);
--.import example.txt input
.import input.txt input
```

Starting out solving problems in SQLite, you might be wondering how I'm
able to get the AoC input file into SQLite to begin with. Luckily,
[the SQLite Command Line Shell][sqlite-cli] has a few tricks to make
this easier -- namely the `.separator` and `.import` commands. In other
problems, like those in Project Euler, `.parameter` is very handy for
numeric input constants.

[sqlite-cli]: https://sqlite.org/cli.html

```sql
WITH
left_list(n, row_number) AS (
  SELECT col1, row_number() OVER (ORDER BY col1) AS row_number FROM input
),
right_list(n, row_number) AS (
  SELECT col4, row_number() OVER (ORDER BY col4) AS row_number FROM input
)
```

If you want a solution to make sense at all, you're going to want to use
CTEs.

Part 01 of the problem requires both "lists" to be sorted and compared
row-wise. Using this window function seemed the best way to do it, but
I'm not a master.

Expressing the sorted lists is pretty easy in SQL. An imperative
solution such as in C++ would also get the job done, and I can see how
the sorting expression here would map to C++. In an imperative solution,
you could also take advantage of greater control over input to read each
column of the list into sorted arrays as you go, not requiring sorting
as a discrete step.

In SQLite, once we get past the ugliness of reading in the columns,
sorting the tables is easy with a CTE for each list.

The final query of my solution has some boilerplate because I get both
parts of the problem in one go. Let's look at each part's subquery
individually.

### Part 1

```sql
  SELECT
    sum(abs(left_list.n - right_list.n))
  FROM
    left_list JOIN right_list
    ON left_list.row_number = right_list.row_number
```

With the input sorted, we can look at both items in each list by
limiting our `JOIN` to rows of the same place in each list. We simply
use `sum()` to get the "total distance" that the problem requests.

### Part 2

Part 2 is even simpler:

```sql
  SELECT
    sum(left_list.n)
  FROM
    left_list JOIN right_list
    ON left_list.n = right_list.n
```

At first I was scratching my head about how to properly do the
multiplication step that is described in the problem, but then I
realized that the `JOIN` takes care of that when it finds the Cartesian
Product of the two lists. So, finding the total "similarity score" is as
simple as summing all the list entries that match.

### In closing

<details>
<summary>[Click here to read my complete solution.]</summary>
<dl>

```sql
-- Advent of Code 2024, Day 01 (parts 1 and 2).

-- Each "list column" is separated by three spaces. SQLite doesn't support
-- multi-char separators, so read in the input as if with two "empty columns".
.separator " "
CREATE TABLE input(col1, empty_col2, empty_col3, col4);
--.import example.txt input
.import input.txt input

WITH
left_list(n, row_number) AS (
  SELECT col1, row_number() OVER (ORDER BY col1) AS row_number FROM input
),
right_list(n, row_number) AS (
  SELECT col4, row_number() OVER (ORDER BY col4) AS row_number FROM input
)
SELECT (
  SELECT
    sum(abs(left_list.n - right_list.n))
  FROM
    left_list JOIN right_list
    ON left_list.row_number = right_list.row_number
) AS "total distance (part 1)",
(
  SELECT
    sum(left_list.n)
  FROM
    left_list JOIN right_list
    ON left_list.n = right_list.n
) AS "similarity score (part 2)";
```

</dl>
</details>

Day 01 was pretty easy to solve in SQLite. I don't expect that to
continue for very long. SQLite's recursive CTEs can make for some pretty
interesting implementations -- [just see here][outlandish] -- but in my
experience it is difficult to model problems that don't like being
solved in polynomial time. So we'll see how long this will last.

[outlandish]: https://sqlite.org/lang_with.html#outlandish_recursive_query_examples

Until tomorrow!

</section>

<section id="day02">

## Day 02: Red-Nosed Reports

[Read the Day 02 description here.](https://adventofcode.com/2024/day/2)

### Part 1

Reading the problem description for part 1, this seems easy enough to
hard-code based on a known amount of columns. Some exploratory data
analysis reveals that the problem input has differing amount of "levels"
per "report", but they don't vary too much:

```
$ sqlite3
-- Loading resources from /home/smlavine/.config/sqlite3/sqliterc
SQLite version 3.46.1 2024-08-13 09:16:08
Enter ".help" for usage hints.
Connected to a transient in-memory database.
Use ".open FILENAME" to reopen on a persistent database.
sqlite> create table input(line);
sqlite> .import input.txt input
sqlite> select count(*) from input;
┌──────────┐
│ count(*) │
├──────────┤
│ 1000     │
└──────────┘
sqlite> select length(line) - length(replace(line, ' ', '')) from input limit 5;
┌───────────────────────────────────────────────┐
│ length(line) - length(replace(line, ' ', '')) │
├───────────────────────────────────────────────┤
│ 5                                             │
│ 5                                             │
│ 5                                             │
│ 4                                             │
│ 7                                             │
└───────────────────────────────────────────────┘
sqlite> with spacecount(n) as ( select length(line) - length(replace(line, ' ', '')) from input )
   ...> select min(n), max(n) from spacecount;
┌────────┬────────┐
│ min(n) │ max(n) │
├────────┼────────┤
│ 4      │ 7      │
└────────┴────────┘
sqlite> with spacecount(n) as ( select length(line) - length(replace(line, ' ', '')) from input )
   ...> select n, count(n) from spacecount group by n;
┌───┬──────────┐
│ n │ count(n) │
├───┼──────────┤
│ 4 │ 244      │
│ 5 │ 253      │
│ 6 │ 239      │
│ 7 │ 264      │
└───┴──────────┘
```

(Syntax errors and Googling "how does a window function work again" omitted.)

So let's start by reading in each line as a "report". If a report
doesn't have enough levels to fill the row, then SQLite will fill that
level with a NULL. So far, very similar to what we had for yesterday's
puzzle:

```sql
.separator " "
CREATE TABLE reports(level1, level2, level3, level4, level5, level6, level7, level8);
.import example.txt reports
--.import input.txt reports

```

Before rushing into hard-coding a solution to part 1, let's think about
how to solve this programmatically.

<center>* * *</center>

Well, I slept on it, and I didn't think of a better way to do it. Hard
code best code baby.

But if we're going to hard code it, let's do it right. CTEs are great,
but their `UNION ALL` semantics are often awkward to work with if we
want anything other than a simple sequence. Behind the scenes, `.import`
simply `INSERT`s rows into our `reports` table. So let's add a new
relation `TABLE safe`, and [a trigger][trigger] that marks report IDs
that we (hard-codedly) check as "safe". Here's what our new input
processing code looks like:

[trigger]: https://sqlite.org/lang_createtrigger.html

```sql
-- Advent of Code 2024, Day 02 (part 1).

CREATE TABLE reports(
  level1 INTEGER,
  level2 INTEGER,
  level3 INTEGER,
  level4 INTEGER,
  level5 INTEGER,
  level6 INTEGER,
  level7 INTEGER,
  level8 INTEGER
);

CREATE TABLE safe(reports_id REFERENCES reports);
CREATE TRIGGER mark_safe AFTER INSERT ON reports
WHEN
  (
        ifnull(NEW.level1 - NEW.level2 BETWEEN -3 AND -1, true)
    AND ifnull(NEW.level2 - NEW.level3 BETWEEN -3 AND -1, true)
    AND ifnull(NEW.level3 - NEW.level4 BETWEEN -3 AND -1, true)
    AND ifnull(NEW.level4 - NEW.level5 BETWEEN -3 AND -1, true)
    AND ifnull(NEW.level5 - NEW.level6 BETWEEN -3 AND -1, true)
    AND ifnull(NEW.level6 - NEW.level7 BETWEEN -3 AND -1, true)
    AND ifnull(NEW.level7 - NEW.level8 BETWEEN -3 AND -1, true)
  )
  OR
  (
        ifnull(NEW.level1 - NEW.level2 BETWEEN 1 AND 3, true)
    AND ifnull(NEW.level2 - NEW.level3 BETWEEN 1 AND 3, true)
    AND ifnull(NEW.level3 - NEW.level4 BETWEEN 1 AND 3, true)
    AND ifnull(NEW.level4 - NEW.level5 BETWEEN 1 AND 3, true)
    AND ifnull(NEW.level5 - NEW.level6 BETWEEN 1 AND 3, true)
    AND ifnull(NEW.level6 - NEW.level7 BETWEEN 1 AND 3, true)
    AND ifnull(NEW.level7 - NEW.level8 BETWEEN 1 AND 3, true)
  )
BEGIN
  INSERT INTO safe VALUES (NEW.rowid);
END;
```

Three things you may notice:

- I modified the `reports` table to specify the INTEGER datatype for the
  levels of the report. [SQLite is flexibly typed,][flextype] but it
  will still attempt to convert input into the desired datatype when one
  is specified.
- If a level is missing, then subtracting it will result in a `NULL`.
  The `ifnull()` built-in function handles this nicely. For symmetry
  let's add that check to all subtractions.
- I am taking advantage of [SQLite's implicit `rowid` PRIMARY KEY
  definition][rowid]. This is a quirk, but it is helpful in this case.
  If I had to define an explicit INTEGER PRIMARY KEY, then that would
  make `.import`-ing the AoC input more difficult, as the input does not
  specify unique `rowid`s.

[flextype]: https://sqlite.org/flextypegood.html
[rowid]: https://sqlite.org/rowidtable.html

Adding in our import code that we used yesterday, we can confirm that we
receive the correct result for the example:

```sql
.separator " "
.import example.txt reports
--.import input.txt reports

SELECT reports_id AS "safe reports" FROM safe;
```

```
master$ sqlite3 < solution.sql
example.txt:1: expected 8 columns but found 5 - filling the rest with NULL
example.txt:2: expected 8 columns but found 5 - filling the rest with NULL
example.txt:3: expected 8 columns but found 5 - filling the rest with NULL
example.txt:4: expected 8 columns but found 5 - filling the rest with NULL
example.txt:5: expected 8 columns but found 5 - filling the rest with NULL
example.txt:6: expected 8 columns but found 5 - filling the rest with NULL
┌──────────────┐
│ safe reports │
├──────────────┤
│ 1            │
│ 6            │
└──────────────┘
```

Note the NULL warnings. That's expected. Thanks for the heads up though,
SQLite.

Switching out the `SELECT` to answer the question directly:

```sql
SELECT count(reports_id) AS "How many reports are safe?" FROM safe;
```

We get our example answer:

```
master$ sqlite3 < solution.sql 2>&-
┌────────────────────────────┐
│ How many reports are safe? │
├────────────────────────────┤
│ 2                          │
└────────────────────────────┘
```

Swapping out for my actual input set, I got the right answer!

```
master$ time sqlite3 < solution.sql 2>&-
┌────────────────────────────┐
│ How many reports are safe? │
├────────────────────────────┤
│ .......................... │
└────────────────────────────┘

real    0m0.008s
user    0m0.004s
sys     0m0.004s
```

### Part 2

As expected, part 2 adds a generalization that requires some
modification to our original solution. First, let's generalize our
safety table and trigger to store a value for every report, whether it
is safe or unsafe.

<details>
<summary>
  [Click to see the initial diff between part 1 and part 2.]
</summary>
<dl>

```diff
diff --git a/solutions/02/solution.sql b/solutions/02/solution.sql
index 891c4ab..811fff5 100644
--- a/solutions/02/solution.sql
+++ b/solutions/02/solution.sql
@@ -11,34 +11,36 @@ CREATE TABLE reports(
   level8 INTEGER
 );
 
-CREATE TABLE safe(reports_id REFERENCES reports);
-CREATE TRIGGER mark_safe AFTER INSERT ON reports
-WHEN
-  (
-        ifnull(NEW.level1 - NEW.level2 BETWEEN -3 AND -1, true)
-    AND ifnull(NEW.level2 - NEW.level3 BETWEEN -3 AND -1, true)
-    AND ifnull(NEW.level3 - NEW.level4 BETWEEN -3 AND -1, true)
-    AND ifnull(NEW.level4 - NEW.level5 BETWEEN -3 AND -1, true)
-    AND ifnull(NEW.level5 - NEW.level6 BETWEEN -3 AND -1, true)
-    AND ifnull(NEW.level6 - NEW.level7 BETWEEN -3 AND -1, true)
-    AND ifnull(NEW.level7 - NEW.level8 BETWEEN -3 AND -1, true)
-  )
-  OR
-  (
-        ifnull(NEW.level1 - NEW.level2 BETWEEN 1 AND 3, true)
-    AND ifnull(NEW.level2 - NEW.level3 BETWEEN 1 AND 3, true)
-    AND ifnull(NEW.level3 - NEW.level4 BETWEEN 1 AND 3, true)
-    AND ifnull(NEW.level4 - NEW.level5 BETWEEN 1 AND 3, true)
-    AND ifnull(NEW.level5 - NEW.level6 BETWEEN 1 AND 3, true)
-    AND ifnull(NEW.level6 - NEW.level7 BETWEEN 1 AND 3, true)
-    AND ifnull(NEW.level7 - NEW.level8 BETWEEN 1 AND 3, true)
-  )
+CREATE TABLE findings(reports_id REFERENCES reports, is_safe BOOLEAN);
+CREATE TRIGGER calculate_findings AFTER INSERT ON reports
 BEGIN
-  INSERT INTO safe VALUES (NEW.rowid);
+  INSERT INTO findings VALUES (
+    NEW.rowid,
+    (
+          ifnull(NEW.level1 - NEW.level2 BETWEEN -3 AND -1, true)
+      AND ifnull(NEW.level2 - NEW.level3 BETWEEN -3 AND -1, true)
+      AND ifnull(NEW.level3 - NEW.level4 BETWEEN -3 AND -1, true)
+      AND ifnull(NEW.level4 - NEW.level5 BETWEEN -3 AND -1, true)
+      AND ifnull(NEW.level5 - NEW.level6 BETWEEN -3 AND -1, true)
+      AND ifnull(NEW.level6 - NEW.level7 BETWEEN -3 AND -1, true)
+      AND ifnull(NEW.level7 - NEW.level8 BETWEEN -3 AND -1, true)
+    )
+    OR
+    (
+          ifnull(NEW.level1 - NEW.level2 BETWEEN 1 AND 3, true)
+      AND ifnull(NEW.level2 - NEW.level3 BETWEEN 1 AND 3, true)
+      AND ifnull(NEW.level3 - NEW.level4 BETWEEN 1 AND 3, true)
+      AND ifnull(NEW.level4 - NEW.level5 BETWEEN 1 AND 3, true)
+      AND ifnull(NEW.level5 - NEW.level6 BETWEEN 1 AND 3, true)
+      AND ifnull(NEW.level6 - NEW.level7 BETWEEN 1 AND 3, true)
+      AND ifnull(NEW.level7 - NEW.level8 BETWEEN 1 AND 3, true)
+    )
+  );
 END;
 
 .separator " "
 --.import example.txt reports
 .import input.txt reports
 
-SELECT count(reports_id) AS "How many reports are safe?" FROM safe;
+SELECT count(*) AS "How many reports are safe?" FROM findings WHERE is_safe;
+SELECT count(*) AS "How many reports are unssafe?" FROM findings WHERE NOT is_safe;
```

</dl>
</details>

Testing this with the example data, it checks out:

```
master$ sqlite3 < solution.sql 2>&-
┌────────────────────────────┐
│ How many reports are safe? │
├────────────────────────────┤
│ 2                          │
└────────────────────────────┘
┌───────────────────────────────┐
│ How many reports are unssafe? │
├───────────────────────────────┤
│ 4                             │
└───────────────────────────────┘
```

Cool. Now, let's look at the problem text describing "the Problem Dampener":

> The Problem Dampener...tolerate[s] a single bad level in what would otherwise be a safe report. It's like the bad level never happened!

To put it another way, for every unsafe report:

<table>
  <tr> <td>1 <td>2 <td>3 <td>4 <td>5 <td>6 <td>7 <td>8 </tr>
</table>

the following "dampened" reports must be checked for safety:

<table>
  <tr> <td>2 <td>3 <td>4 <td>5
       <td>6 <td>7 <td>8 <td><i>NULL</i>
  </tr>

  <tr> <td>1 <td>3 <td>4 <td>5
       <td>6 <td>7 <td>8 <td><i>NULL</i>
  </tr>

  <tr> <td>1 <td>2 <td>4 <td>5
       <td>6 <td>7 <td>8 <td><i>NULL</i>
  </tr>

  <tr> <td>1 <td>2 <td>3 <td>5
       <td>6 <td>7 <td>8 <td><i>NULL</i>
  </tr>

  <tr> <td>1 <td>2 <td>3 <td>4
       <td>6 <td>7 <td>8 <td><i>NULL</i>
  </tr>

  <tr> <td>1 <td>2 <td>3 <td>4
       <td>5 <td>7 <td>8 <td><i>NULL</i>
  </tr>

  <tr> <td>1 <td>2 <td>3 <td>4
       <td>5 <td>6 <td>8 <td><i>NULL</i>
  </tr>

  <tr> <td>1 <td>2 <td>3 <td>4
       <td>5 <td>6 <td>7 <td><i>NULL</i>
  </tr>
</table>

until we a) find one that is safe, or b) they are all unsafe.

We've already got a `TRIGGER` for calculating safety from a report.
Since we're now adding *more* reports to our data set after reading the
input, let's remove the `findings` table and add the "safety" metric to
the `reports` instead. Like with the missing levels, this will be added
to the table as `NULL` by `.import`, so we can take care of it in the
trigger. Here's our new `reports` table and trigger:

```sql
-- levels 1 through 8 will be read from input.
CREATE TABLE reports(
  l1 INTEGER, l2 INTEGER, l3 INTEGER, l4 INTEGER,
  l5 INTEGER, l6 INTEGER, l7 INTEGER, l8 INTEGER,
  -- A report can be based on itself -- i.e. if it is not the result of
  -- the "Problem Dampener". The trigger will set based_on_report to
  -- rowid for all reports that are read from the input.
  based_on_report INTEGER REFERENCES reports,
  -- Calculated by the trigger for all reports.
  is_safe BOOLEAN
);
CREATE TRIGGER complete_reports AFTER INSERT ON reports
BEGIN
  UPDATE reports
  SET
    based_on_report = ifnull(based_on_report, rowid),
    is_safe =
      (
            ifnull(NEW.l1 - NEW.l2 BETWEEN -3 AND -1, true)
        AND ifnull(NEW.l2 - NEW.l3 BETWEEN -3 AND -1, true)
        AND ifnull(NEW.l3 - NEW.l4 BETWEEN -3 AND -1, true)
        AND ifnull(NEW.l4 - NEW.l5 BETWEEN -3 AND -1, true)
        AND ifnull(NEW.l5 - NEW.l6 BETWEEN -3 AND -1, true)
        AND ifnull(NEW.l6 - NEW.l7 BETWEEN -3 AND -1, true)
        AND ifnull(NEW.l7 - NEW.l8 BETWEEN -3 AND -1, true)
      )
      OR
      (
            ifnull(NEW.l1 - NEW.l2 BETWEEN 1 AND 3, true)
        AND ifnull(NEW.l2 - NEW.l3 BETWEEN 1 AND 3, true)
        AND ifnull(NEW.l3 - NEW.l4 BETWEEN 1 AND 3, true)
        AND ifnull(NEW.l4 - NEW.l5 BETWEEN 1 AND 3, true)
        AND ifnull(NEW.l5 - NEW.l6 BETWEEN 1 AND 3, true)
        AND ifnull(NEW.l6 - NEW.l7 BETWEEN 1 AND 3, true)
        AND ifnull(NEW.l7 - NEW.l8 BETWEEN 1 AND 3, true)
      )
  WHERE rowid = NEW.rowid;
END;
```

We fill in the missing columns in `reports` by updating every row as
soon as it is added to the table.

Next, let's read in our input to determine initial safety, then query
the number of initially safe reports to answer part 1:

```sql
-- Read in the problem input.
.separator " "
.import example.txt reports
--.import input.txt reports

-- Get an initial count (part 1 and comparison with part 2).
SELECT count(*) AS "How many (initial) reports are safe? (part 1)"
FROM reports WHERE is_safe;
```

Now that we know which initial reports are unsafe, we can "dampen" them
and throw them back into the reports table to re-calculate the safety.
This is why we need that self-referential `based_on_report` foreign key:
to keep track of which reports are dampened.

```sql
-- Insert reports to be "dampened", based on initial reports.
INSERT INTO reports
  WITH retry(l1, l2, l3, l4, l5, l6, l7, l8, report_id) AS (
    SELECT l1, l2, l3, l4, l5, l6, l7, l8, based_on_report
    FROM reports WHERE NOT is_safe
  )
            SELECT l2, l3, l4, l5, l6, l7, l8, NULL, report_id, NULL FROM retry
  UNION ALL SELECT l1, l3, l4, l5, l6, l7, l8, NULL, report_id, NULL FROM retry
  UNION ALL SELECT l1, l2, l4, l5, l6, l7, l8, NULL, report_id, NULL FROM retry
  UNION ALL SELECT l1, l2, l3, l5, l6, l7, l8, NULL, report_id, NULL FROM retry
  UNION ALL SELECT l1, l2, l3, l4, l6, l7, l8, NULL, report_id, NULL FROM retry
  UNION ALL SELECT l1, l2, l3, l4, l5, l7, l8, NULL, report_id, NULL FROM retry
  UNION ALL SELECT l1, l2, l3, l4, l5, l6, l8, NULL, report_id, NULL FROM retry
  UNION ALL SELECT l1, l2, l3, l4, l5, l6, l7, NULL, report_id, NULL FROM retry
;
```

Now, we can query the final amount of distinct safe reports to find our
answer for part 2!

```sql
-- DISTINCT based_on_report is required because more than one dampened report
-- based on an initially unsafe input report could turn out to be safe.
SELECT count(DISTINCT based_on_report)
  AS "How many (initial + dampened) reports are safe? (part 2)"
FROM reports WHERE is_safe;
```

Putting it all together, here's what we get for the example input:

```
master$ sqlite3 < solution.sql 2>&-
┌───────────────────────────────────────────────┐
│ How many (initial) reports are safe? (part 1) │
├───────────────────────────────────────────────┤
│ 2                                             │
└───────────────────────────────────────────────┘
┌──────────────────────────────────────────────────────────┐
│ How many (initial + dampened) reports are safe? (part 2) │
├──────────────────────────────────────────────────────────┤
│ 4                                                        │
└──────────────────────────────────────────────────────────┘
```

That's correct! And it works for my real input too.

### In closing

<details>
<summary>[Click here to read my complete solution.]</summary>
<dl>

```sql
-- Advent of Code 2024, Day 02 (parts 1 and 2).

-- levels 1 through 8 will be read from input.
CREATE TABLE reports(
  l1 INTEGER, l2 INTEGER, l3 INTEGER, l4 INTEGER,
  l5 INTEGER, l6 INTEGER, l7 INTEGER, l8 INTEGER,
  -- A report can be based on itself -- i.e. if it is not the result of
  -- the "Problem Dampener". The trigger will set based_on_report to
  -- rowid for all reports read from the input.
  based_on_report INTEGER REFERENCES reports,
  -- Calculated by the trigger for all reports.
  is_safe BOOLEAN
);
CREATE TRIGGER complete_reports AFTER INSERT ON reports
BEGIN
  UPDATE reports
  SET
    based_on_report = ifnull(based_on_report, rowid),
    is_safe =
      (
            ifnull(NEW.l1 - NEW.l2 BETWEEN -3 AND -1, true)
        AND ifnull(NEW.l2 - NEW.l3 BETWEEN -3 AND -1, true)
        AND ifnull(NEW.l3 - NEW.l4 BETWEEN -3 AND -1, true)
        AND ifnull(NEW.l4 - NEW.l5 BETWEEN -3 AND -1, true)
        AND ifnull(NEW.l5 - NEW.l6 BETWEEN -3 AND -1, true)
        AND ifnull(NEW.l6 - NEW.l7 BETWEEN -3 AND -1, true)
        AND ifnull(NEW.l7 - NEW.l8 BETWEEN -3 AND -1, true)
      )
      OR
      (
            ifnull(NEW.l1 - NEW.l2 BETWEEN 1 AND 3, true)
        AND ifnull(NEW.l2 - NEW.l3 BETWEEN 1 AND 3, true)
        AND ifnull(NEW.l3 - NEW.l4 BETWEEN 1 AND 3, true)
        AND ifnull(NEW.l4 - NEW.l5 BETWEEN 1 AND 3, true)
        AND ifnull(NEW.l5 - NEW.l6 BETWEEN 1 AND 3, true)
        AND ifnull(NEW.l6 - NEW.l7 BETWEEN 1 AND 3, true)
        AND ifnull(NEW.l7 - NEW.l8 BETWEEN 1 AND 3, true)
      )
  WHERE rowid = NEW.rowid;
END;

-- Read in the problem input.
.separator " "
--.import example.txt reports
.import input.txt reports

-- Get an initial count (part 1 and comparison with part 2).
SELECT count(*) AS "How many (initial) reports are safe? (part 1)"
FROM reports WHERE is_safe;

-- Insert reports to be "dampened", based on initial reports.
INSERT INTO reports
  WITH retry(l1, l2, l3, l4, l5, l6, l7, l8, report_id) AS (
    SELECT l1, l2, l3, l4, l5, l6, l7, l8, based_on_report
    FROM reports WHERE NOT is_safe
  )
            SELECT l2, l3, l4, l5, l6, l7, l8, NULL, report_id, NULL FROM retry
  UNION ALL SELECT l1, l3, l4, l5, l6, l7, l8, NULL, report_id, NULL FROM retry
  UNION ALL SELECT l1, l2, l4, l5, l6, l7, l8, NULL, report_id, NULL FROM retry
  UNION ALL SELECT l1, l2, l3, l5, l6, l7, l8, NULL, report_id, NULL FROM retry
  UNION ALL SELECT l1, l2, l3, l4, l6, l7, l8, NULL, report_id, NULL FROM retry
  UNION ALL SELECT l1, l2, l3, l4, l5, l7, l8, NULL, report_id, NULL FROM retry
  UNION ALL SELECT l1, l2, l3, l4, l5, l6, l8, NULL, report_id, NULL FROM retry
  UNION ALL SELECT l1, l2, l3, l4, l5, l6, l7, NULL, report_id, NULL FROM retry
;

-- DISTINCT based_on_report is required because more than one dampened report
-- based on an initially unsafe input report could turn out to be safe.
SELECT count(DISTINCT based_on_report)
  AS "How many (initial + dampened) reports are safe? (part 2)"
FROM reports WHERE is_safe;
```

</dl>
</details>

Like Day 01, Day 02 was a lot of fun to solve. We explored some more
tricks of SQL/SQLite, including the power of `TRIGGER`s to perform
calculations on our input. It also exposes some drawbacks of using
SQLite to solve this type of problem:

- In both determining the difference between report levels and in
  determining the correct dampened levels, we must do the combinations
  ourselves, not programmatically. (At least, it's a lot easier to solve
  the problem this way.)
- When checking the dampened reports, we do not "exit early" as soon as
  we find a safe report. We could probably accomplish this by either
  rolling our dampened `INSERT` into the trigger, or with more verbose
  checking before each `INSERT` (as opposed to using `UNION ALL`s to do
  it in one go). In an imperative or robust functional language, it
  would be a lot more natural to express an early exit once we find a
  safe dampened report.
- Suppose a variation of this problem with either
    - A lot more levels per report, or
    - Multiple rounds of dampening. What would we do then? In that case,
      we probably *would* have to roll our dampened `INSERT`s into a
      trigger, and if we're dealing with a whole lot of levels per
      report then we might run into [the SQLite limit on recursive
      triggers.][recursive-triggers]

[recursive-triggers]: https://sqlite.org/limits.html#max_trigger_depth

But of course, those drawbacks don't make it less fun as a tool to solve
some Christmas problems.

Until tomorrow!

</section>
