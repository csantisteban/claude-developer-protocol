# SQL

## Overview

Standards for all SQL files, including queries, stored procedures, DDL, and migrations.

The baseline is the **SQL Style Guide by Simon Holywell**:
https://www.sqlstyle.guide

This file defines only the rules that differ from or extend the Holywell baseline.
When in doubt, the Holywell guide is the authority.

---

## Rules That Override Holywell

### No rule overrides defined.

Document project-specific exceptions here as they are identified.

---

## Rules That Match Holywell (Key Reminders)

These Holywell rules are highlighted because they are commonly missed:

### Reserved Words

Always uppercase reserved keywords. Never use vendor-specific keywords when an
ANSI SQL equivalent exists:

```sql
-- bad
select first_name from staff where id = 1;

-- good
SELECT first_name
  FROM staff
 WHERE id = 1;
```

### River Alignment

Right-align root keywords so they form a consistent vertical boundary — the
"river" — down the middle of the query. Column names and values align left of
the river:

```sql
-- bad
SELECT a.title, a.release_date
FROM albums AS a
WHERE a.title = 'Charcoal Lane'

-- good
SELECT a.title,
       a.release_date
  FROM albums AS a
 WHERE a.title = 'Charcoal Lane';
```

### Naming

- `snake_case` only — no `camelCase`, no `PascalCase`
- No descriptive prefixes: never `tbl_`, `sp_`, `vw_`
- Table names are collective or plural (prefer `staff` over `employees`)
- Column names are always singular
- Use uniform suffixes where applicable: `_id`, `_date`, `_status`, `_total`,
  `_name`, `_num`, `_seq`, `_tally`, `_size`, `_addr`

```sql
-- bad
tblUsers, UserList, spGetUser, employeeId, orderDates

-- good
user, staff, order, employee_id, order_date
```

### Aliases

Always use the `AS` keyword. Alias should derive from the first letter of each
word in the object name. Append a number if there is a collision:

```sql
-- bad
SELECT s.first_name, s2.first_name
  FROM staff s
  JOIN students s2 ON s2.mentor_id = s.staff_num;

-- good
SELECT s.first_name, st.first_name
  FROM staff AS s
  JOIN students AS st
    ON st.mentor_id = s.staff_num;
```

### Joins

Use `JOIN` (not `INNER JOIN`) for simple joins — place it before the river.
Use `INNER JOIN`, `LEFT JOIN`, etc. for explicit intent — indent them to the
right of the river:

```sql
-- simple join — before the river
SELECT r.last_name
  FROM riders AS r
  JOIN bikes AS b
    ON r.bike_vin_num = b.vin_num;

-- explicit join — indented to the right of the river
SELECT r.last_name
  FROM riders AS r
       INNER JOIN bikes AS b
       ON r.bike_vin_num = b.vin_num
          AND b.engine_tally > 2;
```

### Subqueries

Subqueries must be indented to the right of the river and their closing
parenthesis aligned with the opening one:

```sql
SELECT r.last_name,
       (SELECT MAX(YEAR(championship_date))
          FROM champions AS c
         WHERE c.last_name = r.last_name
           AND c.confirmed = 'Y') AS last_championship_year
  FROM riders AS r
 WHERE r.last_name IN
       (SELECT c.last_name
          FROM champions AS c
         WHERE YEAR(c.championship_date) > '2008'
           AND c.confirmed = 'Y');
```

### `AND` / `OR` Placement

Always place `AND` and `OR` at the start of the line, aligned to the river:

```sql
-- bad
WHERE a.title = 'Charcoal Lane' OR
      a.title = 'The New Danger'

-- good
 WHERE a.title = 'Charcoal Lane'
    OR a.title = 'The New Danger'
```

### Dates and Times

Always store dates and times in ISO 8601 format: `YYYY-MM-DDTHH:MM:SS.SSSSS`

### Comments

Use `--` for inline comments. Use `/* ... */` for block comments:

```sql
SELECT file_hash  -- stored ssdeep hash
  FROM file_system
 WHERE file_name = '.vimrc';

/* Recalculate totals after the batch import */
UPDATE order_summary
   SET order_total = (SELECT SUM(line_total) FROM order_line WHERE order_id = order_summary.order_id);
```

---

## What Claude Must Not Do

- Do not use `camelCase` or `PascalCase` for any identifier
- Do not use descriptive prefixes: no `tbl_`, `sp_`, `vw_`, `fn_`
- Do not omit the `AS` keyword in aliases
- Do not use vendor-specific syntax when ANSI SQL is available
- Do not place `AND` or `OR` at the end of a line
- Do not store dates outside of ISO 8601 format
- Do not right-align values — keywords right-align, values left-align
