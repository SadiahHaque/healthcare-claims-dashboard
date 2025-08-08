#DATA CLEANING

-- CREATING STAGING TABLE

CREATE TABLE healthcare_claims_staging
LIKE healthcare_claims;

INSERT healthcare_claims_staging
SELECT * 
FROM healthcare_claims;

-- FIXING DATE TYPE

SELECT STR_TO_DATE(date_of_service, '%Y-%m-%d')
FROM healthcare_claims_staging
WHERE SUBSTRING(date_of_service, 5, 1) = '-';

SELECT STR_TO_DATE(date_of_service, '%d-%m-%Y')
FROM healthcare_claims_staging
WHERE SUBSTRING(date_of_service, 3, 1) = '-';

ALTER TABLE healthcare_claims_staging
ADD COLUMN clean_date_of_service DATE;

UPDATE healthcare_claims_staging
SET clean_date_of_service = STR_TO_DATE(date_of_service, '%Y-%m-%d')
WHERE SUBSTRING(date_of_service, 5, 1) = '-';

UPDATE healthcare_claims_staging
SET clean_date_of_service = STR_TO_DATE(date_of_service, '%d-%m-%Y')
WHERE SUBSTRING(date_of_service, 3, 1) = '-';

-- DROPPING THE OLD COLUMN
ALTER TABLE healthcare_claims_staging
DROP COLUMN date_of_service;

-- RENAMING THE NEW COLUMN
ALTER TABLE healthcare_claims_staging
CHANGE clean_date_of_service date_of_service DATE;



SELECT *
FROM healthcare_claims_staging;



-- STANDARDIZATION


# insurance_type

SELECT insurance_type
FROM healthcare_claims_staging
GROUP BY insurance_type;

SELECT insurance_type
FROM healthcare_claims_staging
GROUP BY insurance_type
HAVING insurance_type LIKE '%COM%';

UPDATE healthcare_claims_staging
SET insurance_type = 'Commercial'
WHERE insurance_type LIKE '%COM%';

UPDATE healthcare_claims_staging
SET insurance_type = 'Self-Pay'
WHERE insurance_type LIKE '%SELF%';

SELECT insurance_type
FROM healthcare_claims_staging
GROUP BY insurance_type
HAVING insurance_type LIKE '%CAR%';

UPDATE healthcare_claims_staging
SET insurance_type = 'Medicare'
WHERE insurance_type LIKE '%CAR%';

UPDATE healthcare_claims_staging
SET insurance_type = 'Medicaid'
WHERE insurance_type LIKE 'medicid';

UPDATE healthcare_claims_staging
SET insurance_type = 'Medicaid'
WHERE insurance_type LIKE 'medicade';

UPDATE healthcare_claims_staging
SET insurance_type = 'Medicaid'
WHERE insurance_type LIKE 'MEDICAID';


#claim_status

SELECT claim_status
FROM healthcare_claims_staging
group by claim_status;

UPDATE healthcare_claims_staging
SET claim_status = 'Denied'
WHERE claim_status LIKE '%DEN%';

UPDATE healthcare_claims_staging
SET claim_status = 'Under Review'
WHERE claim_status LIKE '%REV%';

UPDATE healthcare_claims_staging
SET claim_status = 'Paid'
WHERE claim_status LIKE '%PAID%';


#ar_status

SELECT ar_status
FROM healthcare_claims_staging
GROUP BY ar_status;

UPDATE healthcare_claims_staging
SET ar_status = 'Partially Paid'
WHERE ar_status LIKE '%PAID%';

UPDATE healthcare_claims_staging
SET ar_status = 'Denied'
WHERE ar_status LIKE '%DEN%';

UPDATE healthcare_claims_staging
SET ar_status = 'Closed'
WHERE ar_status LIKE '%CLO%';

UPDATE healthcare_claims_staging
SET ar_status = 'Open'
WHERE ar_status LIKE '%OP%';

UPDATE healthcare_claims_staging
SET ar_status = 'Pending'
WHERE ar_status LIKE '%PEN%';

UPDATE healthcare_claims_staging
SET ar_status = 'On Hold'
WHERE ar_status LIKE '%HOLD%';


#Excluding ar_status from final analysis due to inconsistencies and overlap with claim_status/outcome.

ALTER TABLE healthcare_claims_staging
DROP COLUMN ar_status;



-- CHECKING FOR NULLS

SELECT * 
FROM healthcare_claims_staging
WHERE claim_id IS NULL
OR provider_id IS NULL
OR patient_id IS NULL
OR date_of_service IS NULL
OR billed_amount IS NULL
OR procedure_code IS NULL
OR diagnosis_code IS NULL
OR allowed_amount IS NULL
OR paid_amount IS NULL 
OR insurance_type IS NULL
OR claim_status IS NULL
OR reason_code IS NULL
OR follow_up_required IS NULL
OR outcome IS NULL;

SELECT outcome, paid_amount, claim_status, allowed_amount
FROM healthcare_claims_staging
WHERE paid_amount IS NULL
AND outcome LIKE '%PAID%';


-- REPLACING NULL paid_amount WITH allowed_amount


UPDATE healthcare_claims_staging
SET paid_amount = allowed_amount
WHERE paid_amount IS NULL 
AND outcome LIKE '%PAID%'
;



-- CORRECTING CLAIM STATUS

SELECT claim_status, outcome, paid_amount
FROM healthcare_claims_staging
WHERE outcome = 'Denied'
AND claim_status LIKE '%PAID%'
AND paid_amount IS NULL
;

UPDATE healthcare_claims_staging
SET claim_status = 'Denied'
WHERE outcome = 'Denied'
AND paid_amount IS NULL;


-- CORRECTING OUTCOME

SELECT claim_status, outcome, allowed_amount, paid_amount, billed_amount
FROM healthcare_claims_staging
WHERE claim_status LIKE '%PAID%'
AND paid_amount IS NOT NULL
;

UPDATE healthcare_claims_staging
SET outcome =
	CASE
		WHEN paid_amount < billed_amount THEN 'Partially Paid'
        WHEN paid_amount = billed_amount THEN 'Paid'
	END
	WHERE paid_amount IS NOT NULL
    AND claim_status LIKE '%PAID%'
    AND outcome = 'Denied';


-- CORRECTING CELLS WHERE paid_amount > allowed_amount

SELECT*
FROM healthcare_claims_staging
WHERE paid_amount > allowed_amount;

UPDATE healthcare_claims_staging
SET paid_amount = allowed_amount
WHERE paid_amount > allowed_amount;
 



-- REPLACING NULLS IN diagnosis_code AND reason_code

UPDATE healthcare_claims_staging
SET diagnosis_code = 'Unknown'
WHERE diagnosis_code IS NULL;

UPDATE healthcare_claims_staging
SET reason_code = 'Unspecified'
WHERE reason_code IS NULL;






-- CHECKING FOR DUPLICATES

SELECT COUNT(DISTINCT claim_id)
FROM healthcare_claims_staging;


WITH CTE_DUPE AS
	(SELECT *,
	ROW_NUMBER() OVER (PARTITION BY claim_id, provider_id, patient_id, date_of_service, billed_amount, diagnosis_code, insurance_type) AS ROW_NUM
	FROM healthcare_claims_staging)
SELECT*
FROM CTE_DUPE
WHERE ROW_NUM > 1;

CREATE TABLE `healthcare_claims_staging_2` (
  `claim_id` varchar(20) DEFAULT NULL,
  `provider_id` varchar(20) DEFAULT NULL,
  `patient_id` varchar(20) DEFAULT NULL,
  `billed_amount` decimal(10,2) DEFAULT NULL,
  `procedure_code` varchar(10) DEFAULT NULL,
  `diagnosis_code` varchar(10) DEFAULT NULL,
  `allowed_amount` decimal(10,2) DEFAULT NULL,
  `paid_amount` decimal(10,2) DEFAULT NULL,
  `insurance_type` varchar(50) DEFAULT NULL,
  `claim_status` varchar(50) DEFAULT NULL,
  `reason_code` varchar(255) DEFAULT NULL,
  `follow_up_required` varchar(10) DEFAULT NULL,
  `outcome` varchar(50) DEFAULT NULL,
  `date_of_service` date DEFAULT NULL,
  `ROW_NUM` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;



INSERT INTO healthcare_claims_staging_2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY claim_id, provider_id, patient_id, date_of_service, billed_amount, diagnosis_code, insurance_type) 
FROM healthcare_claims_staging;


SELECT*
FROM healthcare_claims_staging_2
WHERE ROW_NUM > 1;


DELETE 
FROM healthcare_claims_staging_2
WHERE ROW_NUM > 1;

ALTER TABLE healthcare_claims_staging_2
DROP COLUMN ROW_NUM;

SELECT COUNT(claim_id)
FROM healthcare_claims_staging_2;




#EDA

-- DESCRIPTIVE ANALYSIS

SELECT 
    AVG(billed_amount), 
    MAX(billed_amount), 
    MIN(billed_amount),
    COUNT(*) 
FROM healthcare_claims_staging;



-- CLAIM STATUS ANALYSIS
SELECT claim_status, COUNT(*) AS total_claims
FROM healthcare_claims_staging_2
GROUP BY claim_status;

SELECT SUM(
		CASE WHEN claim_status = 'Denied' THEN 1 ELSE 0
        END) / COUNT(*) AS claim_denial_rate
FROM healthcare_claims_staging_2;






-- CLAIM STATUS AND OUTCOME

SELECT claim_status, outcome, COUNT(*)
FROM healthcare_claims_staging
GROUP BY claim_status, outcome;

SELECT outcome, COUNT(*)
FROM healthcare_claims_staging
GROUP BY outcome;




-- INSURANCE TYPE ANALYSIS

SELECT insurance_type, SUM(paid_amount) AS total_paid
FROM healthcare_claims_staging
GROUP BY insurance_type;

SELECT SUM(
		CASE WHEN claim_status = 'Denied' THEN 1 ELSE 0
        END) / COUNT(*) AS claim_denial_rate
FROM healthcare_claims_staging_2;

SELECT insurance_type,
       SUM(CASE WHEN claim_status = 'Denied' THEN 1 ELSE 0 END) / COUNT(*) AS denial_rate
FROM healthcare_claims_staging
GROUP BY insurance_type;




-- PROCEDURE ANALYSIS

SELECT procedure_code, AVG(paid_amount) AS avg_paid
FROM healthcare_claims_staging
GROUP BY procedure_code
ORDER BY avg_paid DESC;

SELECT procedure_code, SUM(billed_amount) AS total_billed
FROM healthcare_claims_staging
GROUP BY procedure_code
ORDER BY total_billed DESC;





-- TRENDS

SELECT MONTH(date_of_service) ,COUNT(*) AS monthly_claim_count
FROM healthcare_claims_staging_2
GROUP BY MONTH(date_of_service)
ORDER BY MONTH(date_of_service) ASC;

SELECT MONTH(date_of_service) ,SUM(paid_amount) AS total_paid
FROM healthcare_claims_staging_2
GROUP BY MONTH(date_of_service)
ORDER BY MONTH(date_of_service) ASC;





-- TOTAL PAID VS. BILLED AMOUNT

SELECT SUM(paid_amount) / SUM(billed_amount) AS payment_ratio
FROM healthcare_claims_staging;


SELECT insurance_type, SUM(paid_amount) / SUM(billed_amount) AS payment_ratio
FROM healthcare_claims_staging
GROUP BY insurance_type;


