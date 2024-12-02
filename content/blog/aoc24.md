---
title: Advent of Code 2024 in SQLite
date: 2024-12-02
params:
  lastUpdated: 2024-12-02
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
  <li><a href="#day01">Day 01</a>
</ul>

</section>

<hr>

<section id="day01">

## Day 01

[Read the Day 01 description here.](https://adventofcode.com/2024/day/1)

I've been having fun solving puzzles like [Project Euler][pe] in SQLite
for a while now. So that's where I decided to start with this year's
Advent of Code.

[pe]: https://projecteuler.net

<details>
<summary>[Click to read my full solution in one piece.]</summary>
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

Part 1:

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

Day 01 was pretty easy to solve in SQLite. I don't expect that to
continue for very long. SQLite's recursive CTEs can make for some pretty
interesting implementations -- [just see here][outlandish] -- but in my
experience it is difficult to model problems that don't like being
solved in polynomial time. So we'll see how long this will last.

[outlandish]: https://sqlite.org/lang_with.html#outlandish_recursive_query_examples

Until tomorrow!

</section>
