------------------------------------------------------------------------------------
-- Partition the payments Table by Month
------------------------------------------------------------------------------------
/* Automate monthly partition creation using a template table and dynamic SQL. */
/* Step 1: Convert payments to a Partitioned Table */

-- 1. Rename the original table (optional backup)
ALTER TABLE payments RENAME TO payments_backup;

-- 2. Recreate partitioned table
CREATE TABLE payments (
    id INT GENERATED ALWAYS AS IDENTITY,
    student_id INT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    course_id INT NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    amount NUMERIC(10, 2) NOT NULL,
    payment_date TIMESTAMP NOT NULL,
    PRIMARY KEY (id, payment_date)
) PARTITION BY RANGE (payment_date);


/* Step 2: Manually Create One Partition (Template Example) */
CREATE TABLE payments_2025_04 PARTITION OF payments
FOR VALUES FROM ('2025-04-01 00:00:00') TO ('2025-05-01 00:00:00');

/* Step 3:  Insert Sample Data (It auto-routes to the correct partition) */
INSERT INTO payments (student_id, course_id, amount, payment_date)
VALUES (1, 37, 59.99, '2025-04-15'),
       (2, 2, 75.00, '2025-04-10'),
       (3, 19, 20.00, '2025-04-05');

/* Step 4: Querying Works Normally (with performance boost) */
-- Only scans March 2025 partition
SELECT * FROM payments WHERE payment_date >= '2025-04-01' AND payment_date < '2025-05-01';

/* Step 5: Monitoring */
SELECT inhrelid::regclass AS partition
FROM pg_inherits
WHERE inhparent = 'payments'::regclass;

------------------------------------------------------------------------------------
-- Create a Function to Generate Monthly Partitions Automatically
------------------------------------------------------------------------------------
/* Step 1: Create a Function to Generate Monthly Partitions */
CREATE OR REPLACE FUNCTION create_payment_partition(month_timestamp TIMESTAMP WITHOUT TIME ZONE)
RETURNS void AS $$
DECLARE
    month_start DATE := DATE_TRUNC('month', month_timestamp)::DATE;
    month_end DATE := (DATE_TRUNC('month', month_timestamp) + INTERVAL '1 month')::DATE;
    partition_name TEXT := FORMAT('payments_%s', TO_CHAR(month_start, 'YYYY_MM'));
BEGIN
    EXECUTE FORMAT('
        CREATE TABLE IF NOT EXISTS %I PARTITION OF payments
        FOR VALUES FROM (%L) TO (%L)',
        partition_name,
        month_start,
        month_end
    );
END;
$$ LANGUAGE plpgsql;

/* Step 2: Use the Function to Create Partitions for a Date Range */
DO $$
DECLARE
    current_month TIMESTAMP := DATE_TRUNC('month', CURRENT_DATE);
    months_ahead INT := 6;
BEGIN
    FOR i IN 0..months_ahead LOOP
        PERFORM create_payment_partition(current_month + (i || ' month')::INTERVAL);
    END LOOP;
END;
$$;

-- Insert test payment
INSERT INTO payments (student_id, course_id, amount, payment_date)
VALUES (1, 2, 49.99, '2025-08-15 12:10:25');

-- Only scans August 2025 partition
SELECT * FROM payments WHERE payment_date >= '2025-08-01' AND payment_date < '2025-09-01';

-- Check it's routed correctly
SELECT tableoid::regclass, * FROM payments;