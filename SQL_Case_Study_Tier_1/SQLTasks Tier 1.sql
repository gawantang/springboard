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

SELECT name, membercost 
FROM `Facilities` 
WHERE membercost = 0;

These facilities are the badminton court, table tennis, snooker table, and pool table.

/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT(name) 
FROM `Facilities` 
WHERE membercost = 0;

4 facilties do not charge a fee to members

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance 
FROM Facilities 
WHERE membercost <> 0 
	AND membercost < (0.2 * monthlymaintenance);

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM Facilities 
WHERE facid IN (1,5);


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
	CASE 
		WHEN monthlymaintenance > 100 THEN 'Expensive'
		ELSE 'Cheap'
	END as price_cat
FROM Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM `Members` 
WHERE joindate = (
    SELECT MAX(joindate)
    	FROM Members
    );
# can't just do WHERE joindate = MAX(joindate) because aggregate functions like MAX() can't be used directly in WHERE clauses. The subquery lets you first calculate the maximum date, then use that value for comparison.


 ************** Run following questions through python  **************

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

draft code:

Attempt 1:
    # the clause - SELECT CONCAT(firstname,' ', surname) AS full_name
    # works in MySQL but not in SQLite
    # My permission level doesn't seem to allow nested queries such as the one below and returns a 403 error
    SELECT DISTINCT firstname || ' ' || surname AS unique_full_name
    FROM Members 
    WHERE memid IN 
    	(SELECT memid
         FROM Bookings
         WHERE facid IN
    		(SELECT facid 
    		FROM Facilities
    		WHERE name LIKE 'Tennis%'))
    ORDER BY surname, firstname;

# Attempt 2:
    # try splitting into two queries
    SELECT facid FROM Facilities WHERE name LIKE 'Tennis%';
    
    SELECT DISTINCT firstname || ' ' || surname AS unique_full_name
    FROM Members 
    WHERE memid IN 
        (SELECT memid 
         FROM Bookings 
         WHERE facid IN (0, 1))
    ORDER BY unique_full_name;

# Attempt 3:
    # even a single subquery doesn't work, try using JOIN
    SELECT DISTINCT firstname || ' ' || surname AS unique_full_name, f.name
    FROM Members m
    JOIN Bookings b ON m.memid = b.memid
    JOIN Facilities f ON b.facid = f.facid
         WHERE f.name LIKE 'Tennis%'
    ORDER BY unique_full_name;

# Attempt 4
    # I could not combine the first name and surname. Using CONCAT triggered a 403 access error.
    # and using the || symbols returned a zero value, as if the || symbols were interpretted incorrectly.
    
    SELECT DISTINCT firstname, surname, f.name
    FROM Members m
    JOIN Bookings b ON m.memid = b.memid
    JOIN Facilities f ON b.facid = f.facid
    WHERE f.name LIKE 'Tennis%'
    ORDER BY surname, firstname;

    # note that DISTINCT works on an entire row of data, removing any duplicates of firstname and surname
    # no need to add parentheses around those field names

From David: *** doesn't work, throws 403 error
                SELECT f.name AS facility_name, 
                CONCAT(m.firstname, ' ', m.surname) AS member_name, cost.total_cost
                FROM Bookings b
                JOIN Facilities f ON b.facid = f.facid
                JOIN Members m ON b.memid = m.memid
                JOIN 
                        (SELECT 
                            bookid, 
                                (CASE 
                                    WHEN b.memid = 0 THEN f.guestcost * b.slots  
                                    ELSE f.membercost * b.slots  
                                END) AS total_cost
                            FROM Bookings b
                        JOIN Facilities f ON b.facid = f.facid
                        ) cost ON b.bookid = cost.bookids
                WHERE b.starttime LIKE '2012-09-14%'  
                AND cost.total_cost > 30  -- Filtering bookings that exceed $30
                ORDER BY cost.total_cost DESC;


From the TA: **** works except for the name combination part

                SELECT
                    firstname || ' ' || surname AS member,
                    name AS facility,
                    cost
                FROM (
                    SELECT
                        firstname,
                        surname,
                        name,
                        CASE
                            WHEN firstname = 'GUEST' THEN guestcost * slots
                            ELSE membercost * slots
                        END AS cost,
                        starttime
                    FROM Members
                    INNER JOIN Bookings ON Members.memid = Bookings.memid
                    INNER JOIN Facilities ON Bookings.facid = Facilities.facid
                ) AS inner_table
                WHERE starttime >= '2012-09-14'
                  AND starttime < '2012-09-15'
                  AND cost > 30
                ORDER BY Member

# testing double pipe syntax
SELECT DISTINCT firstname || ' ' || surname AS unique_full_name
    FROM Members m

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

final:
    SELECT name, firstname, surname,
        CASE
            WHEN firstname = 'GUEST' THEN (guestcost * slots)
            ELSE (membercost * slots)
        END AS cost
    FROM Bookings AS b
    LEFT JOIN Facilities AS f ON f.facid = b.facid
    LEFT JOIN Members as m USING (memid) 
    WHERE b.starttime BETWEEN '2012-09-14 00:00:00' AND '2012-09-14 23:59:59'
    HAVING cost > 30;




/* Q9: This time, produce the same result as in Q8, but using a subquery. */

Attempt 1: this resulted in an error code 403
    SELECT name, firstname, surname,
        CASE
            WHEN firstname = 'GUEST' THEN (guestcost * slots)
            ELSE (membercost * slots)
        END AS cost
    FROM Bookings
    WHERE starttime BETWEEN '2012-09-14 00:00:00' AND '2012-09-14 23:59:59' 
        AND facid IN
            (SELECT name, membercost, guestcost, facid
            FROM Facilities
            WHERE facid IN
                (SELECT memid, starttime, slots
                FROM Bookings))
    HAVING cost > 30;

Attempt 2: still running into error code 403
    # the following query will run fine if the WHERE clause is removed
    # the WHERE clause works fine if it's not combined with the entire query
    # possibly a permissions issue that prevents subqueries in combination with WHERE and HAVING?

    SELECT 
        (SELECT name 
        FROM Facilities 
        WHERE facid = b.facid) AS name,
        (SELECT firstname 
        FROM Members 
        WHERE memid = b.memid) AS firstname,
        (SELECT surname 
        FROM Members 
        WHERE memid = b.memid) AS surname,
        AND 
        (CASE
            WHEN (SELECT firstname FROM Members WHERE memid = b.memid) = 'GUEST' 
            THEN (SELECT guestcost FROM Facilities WHERE facid = b.facid) * b.slots
            ELSE (SELECT membercost FROM Facilities WHERE facid = b.facid) * b.slots
        END AS cost)>30
    FROM Bookings b

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

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */


/* Q12: Find the facilities with their usage by member, but not guests */


/* Q13: Find the facilities usage by month, but not guests */

