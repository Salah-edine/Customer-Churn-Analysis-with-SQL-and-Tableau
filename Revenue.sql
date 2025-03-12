SET sql_mode = '';

-- First option
WITH cts As (
SELECT
student_id,
min(purchase_date) as 'first_purchase_date'
FROM purchases 
GROUP BY student_id
ORDER BY student_id)
SELECT
    p.purchase_id,
    p.student_id,
	CASE
		WHEN p.subscription_type = 0 THEN 'monthly'
        WHEN p.subscription_type = 2 THEN 'annual'
        WHEN p.subscription_type = 3 THEN 'lifetime'
    END as subscription_type, 
    p.refund_id, 
    min(purchase_date) as 'first_purchase_date', 
    p.purchase_date as 'current_purchase_date',
    p.price,
    CASE
		WHEN c.first_purchase_date = p.purchase_date THEN 'new'
        ELSE 'recurring'
    END as 'revenue_type',
    CASE
		WHEN p.refunded_date is NULL then 'revenue'
        ELSE 'refund'
    END as refunds, 
    s.student_country
FROM 
	purchases p  
JOIN
	students s
using (student_id)
JOIN cts c ON c.student_id = p.student_id
GROUP BY p.purchase_id
ORDER by p.student_id, p.purchase_date;


-- Second option 


SELECT
p.purchase_id,
p.student_id,
CASE
		WHEN p.subscription_type = 0 THEN 'monthly'
        WHEN p.subscription_type = 2 THEN 'annual'
        WHEN p.subscription_type = 3 THEN 'lifetime'
    END as subscription_type,
 p.refund_id,
p.purchase_date as 'current_date_purchased',
min(p2.purchase_date) as 'first_date_purchased',
p.price,
    CASE
		WHEN min(p2.purchase_date) = p.purchase_date THEN 'new'
        ELSE 'recurring'
    END as 'revenue_type',
    CASE
		WHEN p.refunded_date is NULL then 'revenue'
        ELSE 'refund'
    END as refunds,
s.student_country
FROM purchases p
LEFT JOIN purchases p2 USING(student_id) 
JOIN students s USING(student_id)
GROUP BY p.purchase_id
ORDER BY student_id, p.purchase_date;
  
