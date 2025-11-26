-- ==========================================
-- SQL JOIN 치트시트
-- JOIN / UNION / 서브쿼리 / GROUP BY / 집계 함수 정리
-- ==========================================


-- ------------------------------------------
-- 1. JOIN 개념
-- ------------------------------------------
-- JOIN은 여러 테이블에서 데이터를 결합하여 하나의 결과 집합으로 표현하는 방법.
-- 같은 키를 기준으로 연결하며,
-- 종류에 따라 결과가 달라짐.
--
-- 참고 예시 테이블:
-- author 테이블 : id (PK), name, email 등
-- post 테이블   : id (PK), author_id (FK), title, contents 등


-- ------------------------------------------
-- 1-1. INNER JOIN (교집합)
-- ------------------------------------------
-- 두 테이블 모두 조인 조건에 맞는 데이터만 결과에 포함.

-- case1: author 기준 inner join post
-- 글을 쓴 적 있는 글쓴이와 해당 글쓴이의 글 목록을 함께 조회
SELECT *
FROM author
INNER JOIN post ON author.id = post.author_id;

-- 약식 alias 사용
SELECT *
FROM author a
INNER JOIN post p ON a.id = p.author_id;

-- 필요한 컬럼만 명시해서 조회
SELECT a.*, p.*
FROM author a
INNER JOIN post p ON a.id = p.author_id;


-- case2: post 기준 inner join author
-- 글쓴이가 있는 글과 해당 글의 글쓴이를 함께 조회
SELECT *
FROM post
INNER JOIN author ON post.author_id = author.id;

-- alias 사용 예
SELECT *
FROM post p
INNER JOIN author a ON p.author_id = a.id;

-- 참고)
-- 글쓴이_ID가 NULL 이면 (즉, FK 값이 없는 경우) 결과에서 제외된다 (교집합 형태)


-- 글 전체 정보 & 글쓴이 이메일만 출력
SELECT p.*, a.email
FROM post p
INNER JOIN author a ON p.author_id = a.id;


-- ------------------------------------------
-- 1-2. LEFT JOIN (왼쪽 테이블 기준 전체 + 오른쪽 매칭 데이터)
-- ------------------------------------------
-- 왼쪽 테이블(A)의 모든 행이 결과에 포함,
-- 오른쪽 테이블(B)에 매칭되는 게 없으면 NULL 로 표시되는 외부 조인

-- case3: author 기준 left join post
-- 모든 글쓴이 표시 + 글 쓴 글이 있으면 함께 나옴
SELECT *
FROM author a
LEFT JOIN post p ON a.id = p.author_id;


-- case4: post 기준 left join author
-- 모든 글 목록 표시 + 글쓴이가 있으면 같이 조회
SELECT *
FROM post p
LEFT JOIN author a ON p.author_id = a.id;


-- ------------------------------------------
-- 1-3. RIGHT JOIN (오른쪽 테이블 기준 전체 + 왼쪽 매칭 데이터)
-- ------------------------------------------
-- RIGHT JOIN은 LEFT JOIN의 반대
-- 오른쪽 테이블(B)의 모든 행 포함 + 왼쪽 테이블(A)에서 매칭되는 데이터만 포함

-- 예)
SELECT *
FROM author a
RIGHT JOIN post p ON a.id = p.author_id;


-- ------------------------------------------
-- + 조인 요약 & 팁
-- ------------------------------------------
-- - INNER JOIN: 두 테이블에 모두 존재하는 공통된 데이터(교집합)
-- - LEFT JOIN: 왼쪽 테이블 전체 + 오른쪽 매칭 데이터, 없으면 NULL
-- - RIGHT JOIN: 오른쪽 테이블 전체 + 왼쪽 매칭 데이터
-- - FULL OUTER JOIN: 왼쪽/오른쪽 모두 포함, MySQL은 지원 안 함(유사 구현 필요)

-- - SELECT * 는 해당 테이블들의 모든 컬럼을 가져오기 때문에
--   alias (a.*, p.*) 명시해서 컬럼 충돌 방지 권장.

-- - 조인 순서(A INNER JOIN B 와 B INNER JOIN A) 는 결과는 같지만,
--   LEFT JOIN/RIGHT JOIN 은 결과가 달라진다 (출발 기준이 다르므로).


-- ------------------------------------------
-- 2. UNION (결과 행 결합)
-- ------------------------------------------

-- UNION은 두 SELECT 결과를 행 단위로 합침.
-- JOIN이 컬럼(종) 결합인 반면, UNION은 행(횡) 결합.

-- 조건:
--   - 두 SELECT의 컬럼 개수 및 타입이 같아야 함.
--   - 중복을 제거하려면 UNION (기본 중복 제거)
--   - 중복 포함하려면 UNION ALL 사용

-- 예)
SELECT 컬럼1, 컬럼2 FROM TABLE1
UNION
SELECT 컬럼1, 컬럼2 FROM TABLE2;

-- ------------------------------------------
-- 3. 서브쿼리 (Subquery)
-- ------------------------------------------

-- SELECT문 안에 또 다른 SELECT 를 포함한 쿼리.
-- JOIN과 비교할 때, 보통 JOIN이 성능 우수하지만 복잡한 경우 서브쿼리가 필요할 수 있음.
-- 서브쿼리 위치:
--   1) WHERE 절
--   2) FROM 절 (테이블 역할)
--   3) SELECT 절 (컬럼 계산용)

-- 예) WHERE 절 내 서브쿼리
-- 한번이라도 글쓴 적이 있는 AUTHOR 조회 (중복 제거)
SELECT DISTINCT a.*
FROM author a
INNER JOIN post p ON a.id = p.author_id;

-- 위 JOIN과 동일한 서브쿼리 풀이법
SELECT *
FROM author
WHERE id IN (
    SELECT author_id
    FROM post
);

-- 예) SELECT 절 위치 서브쿼리
-- 회원별 본인이 쓴 글 개수 출력 (email, post_count)
SELECT email,
       (SELECT COUNT(*)
        FROM post p
        WHERE p.author_id = a.id) AS post_count
FROM author a;

-- 예) FROM 절 위치 서브쿼리 (테이블 역할)
SELECT a.*
FROM (SELECT * FROM author) AS a;

-- ------------------------------------------
-- 4. GROUP BY (데이터 그룹화)
-- ------------------------------------------

-- 특정 컬럼을 기준으로 그룹화하여
-- 그룹별 통계/집계 수행을 위함.

-- 기본 사용법:
-- select 컬럼명1, 집계함수(...)
-- from 테이블명
-- group by 컬럼명1;

-- 예) 이름별 그룹화
SELECT name, COUNT(*)
FROM author
GROUP BY name;

-- 주의: GROUP BY 에 포함되지 않은 컬럼 SELECT 는 오류 가능
-- select id, count(*) from 테이블명 group by name; -- 오류

-- 예) 글쓴이 ID 별 그룹핑
SELECT author_id
FROM post
GROUP BY author_id;

-- 회원별 쓴 글 개수 출력 (작성 안 한 회원 제외)
SELECT author_id, COUNT(*) AS post_count
FROM post
GROUP BY author_id;

-- LEFT JOIN 활용, 0개 포함 조회
SELECT a.email, COUNT(p.id) AS post_count
FROM author a
LEFT JOIN post p ON a.id = p.author_id
GROUP BY a.email;

-- NULL 체크 포함 예시 (count 반영 조절)
SELECT a.email, IF(p.id IS NULL, 0, COUNT(*)) AS post_count
FROM author a
LEFT JOIN post p ON p.author_id = a.id
GROUP BY a.email;

-- ------------------------------------------
-- 5. 집계 함수 (Aggregate Functions)
-- ------------------------------------------

-- COUNT() : 행의 개수 세기
SELECT COUNT(*) FROM author;

-- SUM() : 특정 컬럼값의 합계
SELECT SUM(age) FROM author;

-- AVG() : 특정 컬럼값의 평균
SELECT AVG(age) FROM author;

-- ROUND() : 소수점 반올림
SELECT ROUND(AVG(age), 3) FROM author;

-- MIN() : 최솟값
SELECT MIN(age) FROM author;

-- MAX() : 최댓값
SELECT MAX(age) FROM author;

-- 예) 이름별 회원 수와 평균 나이 출력
SELECT name,
       COUNT(*) AS '동명이인 수',
       AVG(age) AS '동명이인의 평균 나이'
FROM author
GROUP BY name;

-- 예) 날짜별 게시글 수 출력 (NULL 제외)
SELECT DATE_FORMAT(created_time, '%Y-%m-%d') AS '날짜',
       COUNT(*) AS '게시글 수'
FROM post
WHERE created_time IS NOT NULL
GROUP BY DATE_FORMAT(created_time, '%Y-%m-%d');


-- ------------------------------------------
-- 6. HAVING 절 (그룹화 후 조건 지정)
-- ------------------------------------------

-- HAVING은 GROUP BY로 그룹화된 결과에 대한 조건을 지정할 때 사용.
-- WHERE는 "그룹화 전 전체 데이터"에 대한 조건,
-- HAVING은 "그룹화 후 집계된 결과"에 대한 조건.

-- 예) 글을 2번 이상 쓴 author_id 조회
SELECT author_id, COUNT(*)
FROM post
GROUP BY author_id
HAVING COUNT(*) >= 2;


-- ------------------------------------------
-- 7. 다중 컬럼 GROUP BY
-- ------------------------------------------

-- 여러 컬럼을 순차적으로 그룹핑
-- 먼저 첫 번째 컬럼 기준으로 그룹핑, 
-- 그 다음 두 번째 컬럼 기준으로 그룹핑 (그리고 그 결과 값 단위로 집계 수행)

-- 예) 작성자(author_id)별로, 같은 제목(title)의 글 몇 개 있는지 출력
SELECT author_id, title, COUNT(*)
FROM post
GROUP BY author_id, title;


-- ------------------------------------------
-- 8. 사용 시 주의점 및 팁
-- ------------------------------------------

-- - HAVING은 반드시 GROUP BY와 함께 사용
-- - HAVING에 조건을 지정할 때는 집계 함수(예: COUNT, SUM, AVG 등)를 직접 사용할 수 있음
-- - 다중 컬럼 GROUP BY는 그룹화 순서를 명확히 이해하고 쿼리를 작성