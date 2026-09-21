create database if not exists Mutual_Fund;

use Mutual_Fund;

CREATE TABLE clients (
    client_id INT PRIMARY KEY,
    client_name VARCHAR(50),
    pan_card VARCHAR(10),
    join_date DATE
);

CREATE TABLE mutual_funds (
    fund_id INT PRIMARY KEY,
    fund_name VARCHAR(20),
    amc_name VARCHAR(20),
    category VARCHAR(10),
    risk_level VARCHAR(10)
);

CREATE TABLE transactions (
    transaction_id INT PRIMARY KEY,
    client_id INT,
    FOREIGN KEY (client_id)
        REFERENCES clients (client_id),
    fund_id INT,
    FOREIGN KEY (fund_id)
        REFERENCES mutual_funds (fund_id),
    transaction_date DATE,
    transaction_type VARCHAR(10),
    amount DECIMAL(10 , 2 ),
    status VARCHAR(10)
);

alter table mutual_funds modify fund_name VARCHAR(100);

alter table mutual_funds modify amc_name VARCHAR(50);

INSERT INTO clients (client_id, client_name, pan_card, join_date) VALUES
(1, 'Ramesh Kumar', 'ABCDE1234F', '2025-01-15'),
(2, 'Priya Sharma', 'VWXYZ5678G', '2025-02-10'),
(3, 'Amit Desai', NULL, '2025-03-01'), 
(4, 'Sneha Patil', 'HJKLM9012P', '2025-03-15'),
(5, 'Vikram Singh', NULL, '2025-04-20'), 
(6, 'Neha Gupta', 'QWERT3456K', '2025-05-05'),
(7, 'Rahul Joshi', 'ZXCVB7890L', '2025-06-12'), 
(8, 'Anjali Verma', 'POIUY0987M', '2025-07-22');

INSERT INTO mutual_funds (fund_id, fund_name, amc_name, category, risk_level) VALUES
(101, 'Parag Parikh Flexi Cap Fund', 'PPFAS AMC', 'Equity', 'High'),
(102, 'SBI Liquid Fund', 'SBI AMC', 'Debt', 'Low'),
(103, 'HDFC Balanced Advantage Fund', 'HDFC AMC', 'Hybrid', 'Moderate'),
(104, 'Nippon India Small Cap Fund', 'Nippon AMC', 'Equity', 'Very High'),
(105, 'ICICI Prudential Bluechip Fund', 'ICICI AMC', 'Equity', 'High'),
(106, 'Kotak Corporate Bond Fund', 'Kotak AMC', 'Debt', 'Low');

INSERT INTO transactions (transaction_id, client_id, fund_id, transaction_date, transaction_type, amount, status) VALUES
(1001, 1, 101, '2026-01-05', 'Lumpsum', 25000.00, 'Completed'),
(1002, 2, 103, '2026-01-10', 'SIP', 10000.00, 'Completed'),
(1003, 3, 102, '2026-01-15', 'Lumpsum', 40000.00, 'Completed'),
(1004, 4, 104, '2026-02-05', 'SIP', 5000.00, 'Completed'),
(1005, 5, 105, '2026-02-10', 'SIP', 15000.00, 'Failed'), 
(1006, 6, 106, '2026-02-15', 'SIP', 5000.00, 'Completed'),
(1007, 1, 104, '2026-03-01', 'Lumpsum', 15000.00, 'Completed'),
(1008, 2, 103, '2026-03-10', 'Lumpsum', 50000.00, 'Completed'),
(1009, 3, 101, '2026-03-15', 'SIP', 10000.00, 'Failed'), 
(1010, 4, 105, '2026-04-05', 'SIP', 15000.00, 'Completed'),
(1011, 8, 102, '2026-04-10', 'SIP', 5000.00, 'Failed'), 
(1012, 1, 103, '2026-05-01', 'SIP', 5000.00, 'Failed'), 
(1013, 2, 101, '2026-05-15', 'Lumpsum', 30000.00, 'Completed'),
(1014, 4, 106, '2026-06-10', 'SIP', 2000.00, 'Failed'),
(1015, 6, 104, '2026-07-05', 'SIP', 5000.00, 'Completed'),
(1016, 5, 102, '2026-08-01', 'Lumpsum', 10000.00, 'Failed');

-- Task 1 - The AUM Aggregator

SELECT 
    m.category, SUM(t.amount) AS AUM
FROM
    mutual_funds m
        LEFT JOIN
    transactions t ON m.fund_id = t.fund_id
WHERE
    status = 'Completed'
GROUP BY category
HAVING SUM(t.amount) > 50000.00
ORDER BY AUM DESC;

-- Task 2 - The KYC Compliance Audit (NOT EXISTS)

SELECT 
    c.client_name,
    COALESCE(c.pan_card, 'KYC Pending') AS pan_status
FROM
    clients c
WHERE
    NOT EXISTS( SELECT 
            1
        FROM
            transactions t
        WHERE
            c.client_id = t.client_id
                AND t.status = 'Completed');
                
-- Task 2 - The KYC Compliance Audit (NOT IN)
                
SELECT 
    client_name, COALESCE(pan_card, 'KYC Pending') AS pan_status
FROM
    clients
WHERE
    client_id NOT IN (SELECT 
            client_id
        FROM
            transactions
        WHERE
            status = 'Completed');
            
-- Task 3 - The AMC Leaderboard

with fund_data as(
select m.amc_name,
m.fund_name,
sum(t.amount) as total_revenue,
dense_rank() over(partition by m.amc_name order by sum(t.amount) desc ) as amc_rank
from transactions t
inner join mutual_funds m ON t.fund_id = m.fund_id
where t.status ='Completed'
group by m.amc_name,
m.fund_name)
select amc_name,fund_name,total_revenue
from fund_data
where amc_rank=1;

-- Task 4 - The Category Whales (VIP Clients)

with adv_portfolio as(
select m.category,
c.client_name,
sum(t.amount) as total_revenue,
dense_rank() over(partition by m.category order by sum(t.amount) desc) as cat_rank
from mutual_funds m
inner join transactions t
on t.fund_id = m.fund_id
inner join clients c
on c.client_id = t.client_id
where t.status ='Completed'
group by m.category,
c.client_name)
select category,
client_name,
total_revenue
from adv_portfolio
where cat_rank=1;