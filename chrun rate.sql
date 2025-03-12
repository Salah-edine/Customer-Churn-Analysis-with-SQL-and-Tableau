
SET sql_mode = '';

WITH active_users AS (
SELECT
a.month,
COUNT(DISTINCT student_id) active_users,
SUM(COUNT(distinct student_id)) OVER(ORDER BY a.month)  sum_active_users
FROM(
SELECT
student_id,
DATE_FORMAT(subscription_period_start, '%Y-%m') AS month,
subscription_type
FROM subscriptions
WHERE
        cancelled_date IS NULL AND 
        next_charge_date >= DATE_FORMAT(subscription_period_start, '%Y-%m-01')
ORDER BY student_id, month) a
GROUP BY a.month
ORDER BY a.month),
expired_users As(
SELECT
a.month as end_month,
IF(b.end_month IS NULL, 0,COUNT(distinct b.student_id)) AS  ended_users
FROM
active_users a
LEFT JOIN(
SELECT
student_id,
DATE_FORMAT(end_date, '%Y-%m') AS end_month,
subscription_type
FROM subscriptions
WHERE end_date IS NOT NULL and cancelled_date is null
GROUP BY student_id) b ON a.month = b.end_month
GROUP BY a.month),
cancelled_users As(
SELECT
a.month as cancelled_month,
IF(c.cancelled_month IS NULL, 0,COUNT(distinct c.student_id)) AS  cancel_users
FROM
active_users a
LEFT JOIN(
SELECT
student_id,
DATE_FORMAT(cancelled_date , '%Y-%m') AS cancelled_month,
subscription_type
FROM subscriptions
WHERE  cancelled_date IS NOT NULL
GROUP BY student_id) c ON a.month = c.cancelled_month
GROUP BY a.month)
SELECT
a.month,
a.active_users,
a.sum_active_users,
c.cancel_users,
e.ended_users,
ROUND(((c.cancel_users + e.ended_users) / a.sum_active_users) *100, 2) As churn_rate ,
ROUND((c.cancel_users / a.sum_active_users) *100, 2)  As active_chrun_rate,
ROUND((e.ended_users / a.sum_active_users) *100, 2)  As passive_chrun_rate
FROM 
active_users a
LEFT JOIN cancelled_users c ON a.month = c.cancelled_month
LEFT JOIN expired_users e ON a.month = e.end_month
;


