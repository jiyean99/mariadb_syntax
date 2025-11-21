-- ==========================================
-- DML 치트시트 (mysql_dml_cheatsheet.sql)
-- INSERT / UPDATE / DELETE / SELECT 요약 + 예시
-- ==========================================


-- ------------------------------------------
-- 1. INSERT : 데이터 삽입
-- ------------------------------------------
-- 기본 형태:
-- insert into [테이블명](컬럼1, 컬럼2, 컬럼3)
-- values(값1, 값2, 값3);
--
-- 문자열은 일반적으로 작은따옴표(') 사용.

-- 예) author 테이블에 데이터 1건 삽입
INSERT INTO author (name, email, age)
VALUES ('홍길동', 'hong@example.com', 30);

-- 실제 서비스에서는 개발자가 직접 값까지 박아서 쓰기보다는,
-- 애플리케이션 코드에서 "파라미터 바인딩" 형태로 많이 사용:

-- 예) 자바/JDBC, JPA, MyBatis 등에서 사용하는 형태(개념):
-- insert into author (name, email, age) values (?, ?, ?);
-- → ? 자리에는 런타임에 값이 바인딩됨.


-- ------------------------------------------
-- 2. UPDATE : 데이터 수정
-- ------------------------------------------
-- 기본 형태:
-- update [테이블명]
-- set [컬럼명1] = [변경할 값1],
--     [컬럼명2] = [변경할 값2]
-- where [조건절];

-- 예) name 이 '홍길동'인 사람의 email, age 변경
UPDATE author
SET email = 'hong2@example.com',
    age   = 31
WHERE name = '홍길동';


-- ------------------------------------------
-- 3. DELETE : 데이터 삭제
-- ------------------------------------------
-- 기본 형태:
-- delete from [테이블명] where [조건절];

-- 예) name 이 '홍길동'인 행 삭제
DELETE FROM author
WHERE name = '홍길동';

-- where 없이 delete from 테이블명; 을 쓰면
-- 테이블의 모든 데이터가 삭제되므로 매우 주의.


-- ------------------------------------------
-- 4. SELECT : 데이터 조회 (가장 많이 사용)
-- ------------------------------------------
-- 4-1) 기본 조회

-- 특정 컬럼만 조회
-- select [컬럼1], [컬럼2] from [테이블명];
SELECT name, email
FROM author;

-- 모든 컬럼 조회
-- select * from [테이블명];
SELECT *
FROM author;

-- 조건절(where) 사용
-- select * from [테이블명] where [조건절];
-- and, or, in, 비교(>, <, >=, <= 등) 모두 사용 가능.

-- 예) 나이가 30 이상인 author 조회
SELECT *
FROM author
WHERE age >= 30;

-- 예) IN 서브쿼리 사용
-- 특정 이름의 author 를 가진 post 조회
SELECT *
FROM post
WHERE author_id IN (
    SELECT id
    FROM author
    WHERE name = '홍길동'
);


-- 4-2) DISTINCT : 중복 제거

-- select distinct [컬럼명] from [테이블명];
-- 예) author 테이블에서 중복되지 않는 나이 목록 조회
SELECT DISTINCT age
FROM author;


-- 4-3) ORDER BY : 정렬

-- 기본형:
-- select * from [테이블명]
-- order by [컬럼명] [asc|desc];

-- asc : 오름차순 (기본값)
-- desc: 내림차순
-- 아무 정렬도 안 하면 보통 PK 기준 오름차순에 가깝게 보이지만,
-- "정렬이 보장된다"고 믿으면 안 됨 → order by 로 명시하는 습관.

-- 예) 이름 기준 내림차순 조회
SELECT *
FROM author
ORDER BY name DESC;

-- 여러 컬럼으로 정렬
-- select * from [테이블명]
-- order by [컬럼1] [조건], [컬럼2] [조건];
-- 먼저 컬럼1 기준으로 정렬 후, 값이 같은 경우 컬럼2 기준 정렬.

-- 예) 나이 오름차순, 같은 나이 내에서 이름 내림차순
SELECT *
FROM author
ORDER BY age ASC, name DESC;


-- 4-4) LIMIT : 결과 개수 제한

-- 기본형:
-- select * from [테이블명]
-- order by [컬럼] [조건]
-- limit [개수];

-- 예) 나이가 많은 순으로 상위 5명만 조회
SELECT *
FROM author
ORDER BY age DESC
LIMIT 5;


-- 4-5) 별칭(Alias) 사용

-- 컬럼에 별칭 주기:
-- select [컬럼1] as [별칭1], [컬럼2] as [별칭2]
-- from [테이블명];

-- 예) name 컬럼을 '이름' 이라는 별칭으로 조회
SELECT name AS '이름'
FROM author;

-- 테이블에 별칭 주기:
-- from [테이블명] as [별칭]
-- 또는 from [테이블명] [별칭]

-- 예) author 테이블에 a 라는 별칭 사용
SELECT a.name, a.email
FROM author AS a;

-- AS 생략 형태
SELECT a.name, a.email
FROM author a;

-- 여러 테이블 Join 시 alias 가 필수에 가깝게 자주 사용됨.


-- 4-6) NULL 조건 조회

-- 컬럼값이 NULL 인 행 조회:
-- select * from [테이블명] where [컬럼명] is null;
SELECT *
FROM author
WHERE email IS NULL;

-- 컬럼값이 NULL 이 아닌 행 조회:
-- select * from [테이블명] where [컬럼명] is not null;
SELECT *
FROM author
WHERE email IS NOT NULL;


-- ------------------------------------------
-- 5. DDL vs DML 개념 요약 (주석용)
-- ------------------------------------------

-- DDL (Data Definition Language) : "구조 정의" 중심
--  - create : 테이블/스키마 생성
--  - alter  : 구조(컬럼, 제약조건 등) 수정
--  - drop   : 테이블/스키마 삭제

-- DML (Data Manipulation Language) : "데이터 조작" 중심
--  - insert : 데이터 삽입
--  - update : 데이터 수정
--  - delete : 데이터 삭제
--  - select : 데이터 조회  ★ 개발자가 직접 가장 많이 쓰는 명령

-- (참고)
--  - show, describe 는 엄밀히 말하면 DDL/DML 과는 조금 결이 다른
--    "메타 정보 조회" 계열이어서, DML 분류에는 잘 넣지 않는다.
--  - 실무에서 개발자가 가장 자주 직접 타이핑하는 것은
--    select (조회) 구문이라고 보면 된다.
