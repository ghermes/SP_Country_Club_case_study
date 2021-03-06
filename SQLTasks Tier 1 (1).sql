/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

Answer: SELECT `name`, `membercost` 
FROM `Facilities` 
WHERE `membercost` > 0

/* Q2: How many facilities do not charge a fee to members? */

Answer: SELECT COUNT(`name`) as free_facilities 
FROM `Facilities` 
WHERE `membercost` = 0

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

Answer: SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
Where membercost > 0
And monthlymaintenance/5 > membercost

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

Answer: SELECT *
FROM Facilities
Where facid in (1, 5)

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

Answer: SELECT name, monthlymaintenance, (monthlymaintenance > 100) as 'expensive', (monthlymaintenance < 100) as 'cheap'
FROM Facilities

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

Answer: SELECT surname, firstname 
FROM `Members`
Where memid=(SELECT max(memid) From `Members`)

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

Answer: SELECT f.name, concat(surname, ',', ' ', firstname) as member
FROM Bookings as b
INNER Join Facilities as f
on b.facid = f.facid
INNER Join Members as m 
on b.memid = m.memid
Where b.facid in (0,1)
Order by member

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

Answer: SELECT f.name as facility, concat(surname, ',', ' ', firstname) as member, CASE WHEN firstname = 'GUEST' THEN guestcost * slots ELSE membercost * slots END AS cost 
FROM Bookings as b
INNER Join Facilities as f
on b.facid = f.facid
INNER Join Members as m 
on b.memid = m.memid
Where starttime >= '2012-09-14' AND starttime < '2012-09-15'
AND CASE WHEN firstname = 'GUEST' THEN guestcost * slots ELSE membercost * slots END > 30
Order by cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

Answer: SELECT subquery. member as member, subquery.cost as cost, subquery.facility as facility 
From (
    Select concat(surname, ',', ' ', firstname) as member, CASE WHEN firstname = 'GUEST' THEN guestcost * slots ELSE membercost * slots END AS cost, f.name as facility
    FROM Bookings as b
    INNER Join Facilities as f
    on b.facid = f.facid
    INNER Join Members as m
    on b.memid = m.memid
    Where starttime >= '2012-09-14' AND starttime < '2012-09-15' 
    AND CASE WHEN firstname = 'GUEST' THEN guestcost * slots ELSE membercost * slots END > 30
) as subquery
Order by cost DESC

/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

Answer:  SELECT subquery.facility as facility, (subquery.member_revenue + subquery.guest_revenue) as revenue
FROM (Select (b.slots*f.membercost) as member_revenue, (b.slots*f.guestcost) as guest_revenue, f.name as facility
    From Bookings as b
    INNER Join Facilities as f
    on b.facid = f.facid
     ) as subquery
Group by 1
Having revenue < 1000
Order by revenue

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

Answer: Select subquery.member as member, CASE WHEN subquery.recommendedby = subquery.memid THEN subquery.member ELSE null END AS recommender
From (
    Select (surname, ',', ' ', firstname) as member, recommendedby, memid
    From Members
) as subquery
Order by member

/* Q12: Find the facilities with their usage by member, but not guests */

Answer: SELECT subquery.facility as facility, CASE WHEN memid BETWEEN 1 AND 37 THEN member ELSE null END AS user; 
FROM (
    Select (surname, ',', ' ', firstname) as member, f.name as facility. memid
    From Bookings as b 
    INNER Join Facilities as f
    on b.facid = f.facid
    INNER Join Members
    on b.memid = m.memid
) as subquery

/* Q13: Find the facilities usage by month, but not guests */

Answer: SELECT f.name as Facility, MONTHNAME(starttime) as Month   
FROM Bookings as b
INNER Join Facilities as f
on b.facid = f.facid
Order by b.starttime
