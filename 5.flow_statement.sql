-- ==========================================
-- SQL 흐름 제어 치트시트
-- ==========================================

-- ------------------------------------------
-- 1. CASE 문 기본 구조
-- ------------------------------------------

-- CASE 문은 "조건에 따라 다른 결과를 반환"할 때 사용하는 흐름 제어 구문

-- 기본 형태 1: 단순 CASE (비교식)
-- CASE 비교대상
--   WHEN 값1 THEN 결과1
--   WHEN 값2 THEN 결과2
--   ...
--   ELSE 기본결과
-- END

-- 기본 형태 2: 검색 CASE (복잡 조건 가능)
-- CASE
--   WHEN 조건1 THEN 결과1
--   WHEN 조건2 THEN 결과2
--   ...
--   ELSE 기본결과
-- END

-- ------------------------------------------
-- 2. 예시: author 테이블에서
--    name 컬럼 값에 따라 다른 문자열 반환
-- ------------------------------------------

SELECT id,
    CASE
        WHEN name IS NULL THEN '익명사용자'
        WHEN name = 'hong' THEN '홍길동'
        WHEN name = 'hong2' THEN '홍길동2'
        ELSE name
    END AS name
FROM author;

-- ------------------------------------------
-- 3. CASE 문 활용 팁
-- ------------------------------------------

-- 3-1) 조건은 WHEN 다음에 올 수 있으며 여러 조건 사용 가능
-- 3-2) ELSE는 선택 사항
-- 3-3) CASE 문 자체가 SQL 표현식이므로 SELECT, WHERE, ORDER BY 등 다양한 절에서 사용 가능

-- 예) WHERE 절에서 CASE 활용 (특정 조건에 따른 필터링)
SELECT *
FROM post
WHERE
  CASE 
    WHEN status = 'published' THEN 1
    ELSE 0
  END = 1;

-- 예) ORDER BY 절에서 CASE 활용 (특정 값 우선 정렬)
SELECT *
FROM author
ORDER BY
  CASE
    WHEN name = '홍길동' THEN 1
    ELSE 2
  END,
  name;

-- ------------------------------------------
-- 4. IF 함수 (MySQL 전용, 간단 조건 처리)
-- ------------------------------------------

-- IF(조건, 참일 때 값, 거짓일 때 값)
SELECT id,
    IF(name IS NULL, '익명사용자', name) AS name
FROM author;

-- ------------------------------------------
-- 5. IFNULL / COALESCE 함수 (NULL 처리 전용)
-- ------------------------------------------

-- IFNULL(expr1, expr2) : expr1 이 NULL 이면 expr2 반환
SELECT id,
    IFNULL(name, '익명사용자') AS name
FROM author;

-- COALESCE(expr1, expr2, ..., exprN) (수업시간 내 내용 X)
--  - 여러 인자 중 NULL 이 아닌 첫 번째 인자 반환
SELECT id,
    COALESCE(name, '익명사용자', '대체값') AS name
FROM author;

-- ------------------------------------------
-- 6. 흐름 제어 함수 요약
-- ------------------------------------------
-- CASE         : 조건별 다른 값 반환 (복잡 조건 가능)
-- IF           : 단순 조건 처리 (MySQL 전용)
-- IFNULL       : NULL 여부 검사 및 기본값 반환
-- COALESCE     : 여러 값 중 첫 NULL 아닌 값을 반환
