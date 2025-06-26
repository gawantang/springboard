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


************** The remaining questions were through python due to issues using the PHPmyAdmin portal. 
************** Please refer to the ipynb notebook  


