-- ==========================================
-- 데이터 타입 & 연산/함수 치트시트
-- 정수/실수/문자/ENUM/BLOB + 비교/논리/패턴/형변환/날짜함수
-- ==========================================


-- ------------------------------------------
-- 1. 정수 타입 (INT 계열)
-- ------------------------------------------
-- 기본 개념: 컴퓨터 데이터의 최소 단위는 bit(비트).
--  - 8bit = 1byte
--  - 8bit 로 표현 가능한 값의 개수: 2^8 = 256개 (0~255)
--  - 부호 있는 정수(signed)는 1비트를 부호(+)·(-) 표현에 사용 → -128 ~ 127 범위 표현
--    (2의 보수 개념, 2^7 = 128)

-- 1) TINYINT
--   - 1 byte 사용
--   - 대략 -128 ~ 127 범위 (signed 기준)
--   - UNSIGNED 사용 시 0 ~ 255 범위
--
-- 2) INT
--   - 4 byte 사용
--   - 약 -21억 ~ +21억 (대략 40억 개 숫자 범위)
--
-- 3) BIGINT
--   - 8 byte 사용
--   - 매우 큰 정수 범위 표현 가능하지만, 용량이 크므로
--     "정말로 큰 숫자가 필요한 경우"에만 사용하는 것이 좋다.

-- UNSIGNED
--   - "부호 없는 정수"로, 음수 없이 0 ~ 최대 양수 범위를 확장.
--   - 예) TINYINT UNSIGNED : 0 ~ 255


-- 예시: author 테이블에 age 컬럼 추가 (0~255 세 범위)
ALTER TABLE author
ADD COLUMN age TINYINT UNSIGNED;


-- ------------------------------------------
-- 2. 정수 타입 변경 시 FK 제약 주의
-- ------------------------------------------
-- 예시 상황: author.id, post.author_id, post.id 를 BIGINT 로 변경
--   - FK(FOREIGN KEY) 제약조건 때문에 바로 타입 변경이 안 되는 경우 발생

-- 1) FK 삭제 선행
ALTER TABLE post
DROP FOREIGN KEY fk_post_author;  -- 실제 FK 이름에 맞게 수정 필요

-- 2) 타입 변경 (부모/자식 컬럼 타입 일치)
ALTER TABLE author
MODIFY COLUMN id BIGINT;

ALTER TABLE post
MODIFY COLUMN author_id BIGINT;

ALTER TABLE post
MODIFY COLUMN id BIGINT;

-- 3) 타입 변환 완료 후 FK 다시 추가
ALTER TABLE post
ADD CONSTRAINT fk_post_author
FOREIGN KEY (author_id)
REFERENCES author(id);


-- ------------------------------------------
-- 3. 실수 / 소수 타입 (DECIMAL)
-- ------------------------------------------
-- DECIMAL(m, d), 부동소수점
--   - m : 전체 자리수 (정수부 + 소수부)
--   - d : 소수부 자리수
--   - 예) DECIMAL(4,1) → 총 4자리 중 소수 1자리 (###.# 형태)

-- 예시: 키(신장) 컬럼 추가
ALTER TABLE author
ADD COLUMN height DECIMAL(4, 1);

-- 자리수에 맞게 insert
INSERT INTO author (id, name, email, height)
VALUES (7, '홍길동3', 'sss@naver.com', 173.5);

-- 자리수 넘치게 insert → 소수부가 d 자리 기준으로 반올림되어 저장
INSERT INTO author (id, name, email, height)
VALUES (8, '홍길동4', 'test@naver.com', 173.5555);


-- ------------------------------------------
-- 4. 문자 / BLOB / ENUM
-- ------------------------------------------

-- 4-1) 문자 타입
--  - CHAR(m)   : 고정 길이 문자열 (항상 m자리를 차지, 짧으면 공백으로 채움)
--  - VARCHAR(m): 가변 길이 문자열 (실제 길이만큼 저장), 메모리 기반 저장
--  - TEXT      : 긴 텍스트(길이 큰 가변 문자열), 스토리지 기반 저장
--  - LONGTEXT  : 매우 긴 텍스트

-- 실습 예시:
-- 주민등록번호(길이 고정) 추가
ALTER TABLE author
ADD COLUMN id_number CHAR(16);

-- 자기소개(길이 가변, 비교적 긴 텍스트) 추가
ALTER TABLE author
ADD COLUMN self_introduction TEXT;

-- 선택 기준:
--  - 길이가 딱 정해진 짧은 단어, 빈번히 조회되는 데이터   → CHAR 또는 VARCHAR
--  - 장문 텍스트                 → TEXT 또는 LONGTEXT
--  - 그 외 대부분의 문자열      → VARCHAR


-- 4-2) BLOB (Binary Large Object)
--  - 이미지, 파일 등의 이진 데이터를 저장하기 위한 타입.
--  - 실무에서는 보통 파일 자체를 BLOB 으로 저장하기보다는,
--    파일은 스토리지에 저장하고, "파일 경로/URL" 을 VARCHAR 로 저장하는 방식이 일반적.

-- 예시: 프로필 이미지 컬럼 추가 (이미지 바이너리 직접 저장)
ALTER TABLE author
ADD COLUMN profile_image LONGBLOB;

-- 예시: 파일 로딩 (MySQL LOAD_FILE 함수 이용, 실제 사용 시 권한/경로 설정 필요)
INSERT INTO author (id, name, email, profile_image)
VALUES (9, 'blob', 'blob@naver.com', LOAD_FILE('C:\\\\test.jpg'));


-- 4-3) ENUM
--  - 허용 가능한 값의 집합을 미리 지정하는 타입.
--  - 컬럼명 ENUM('값1', '값2', ...)
--  - DEFAULT 속성 부여 가능

-- 예시: role 컬럼 추가 (admin 또는 user)
ALTER TABLE author
ADD COLUMN role ENUM('admin', 'user');

-- NOT NULL + 기본값 지정
ALTER TABLE author
MODIFY COLUMN role ENUM('admin', 'user')
NOT NULL DEFAULT 'user';

-- ENUM 에 지정된 값 insert (정상)
INSERT INTO author (id, name, email, role)
VALUES (11, 'admin', 'admin@naver.com', 'admin');

-- ENUM에 없는 값 insert → 에러
INSERT INTO author (id, name, email, role)
VALUES (12, 'super-admin', 'super-admin@naver.com', 'super-admin');

-- role 을 생략하고 insert (NOT NULL + DEFAULT 'user' 인 경우)
INSERT INTO author (id, name, email)
VALUES (13, 'no-role', 'no-role@xxx.com');


-- ------------------------------------------
-- 5. 날짜/시간 타입 및 패턴
-- ------------------------------------------

-- 날짜 타입은 문자열 형식으로 입력/수정/조회하는 경우가 많다.

-- 1) DATE : YYYY-MM-DD  (연-월-일)
-- 2) DATETIME : YYYY-MM-DD HH:MM:SS (연-월-일 시:분:초)

-- DATETIME + DEFAULT CURRENT_TIMESTAMP 패턴은 실무에서 매우 흔함.
-- 예시:
CREATE TABLE post (
    id           BIGINT AUTO_INCREMENT PRIMARY KEY,
    title        VARCHAR(255),
    created_time DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- ------------------------------------------
-- 6. 비교 연산자 / NULL / BETWEEN / IN
-- ------------------------------------------

-- 기본 비교:
--  =   : 같음
--  !=, <> : 다름
--  <, <=, >, >= : 크기 비교

-- NULL 관련:
--  IS NULL, IS NOT NULL
--  주의: NULL 은 공백('')과 다름.

-- 예시:
SELECT * FROM author
WHERE email IS NULL;

SELECT * FROM author
WHERE email IS NOT NULL;


-- BETWEEN
--  BETWEEN min AND max
--  min 이상, max 이하 (min, max 포함)

SELECT * FROM author
WHERE id >= 2 AND id <= 4;

SELECT * FROM author
WHERE id BETWEEN 2 AND 4;


-- IN / NOT IN
SELECT * FROM author
WHERE id IN (2, 3, 4);

SELECT * FROM post
WHERE author_id NOT IN (1, 2);

-- IN 을 동적으로 쓰고 싶으면 서브쿼리 활용:
-- 예) WHERE id IN (SELECT ...)


-- ------------------------------------------
-- 7. 논리 연산자 (AND / OR / NOT)
-- ------------------------------------------

-- AND / &&(앰퍼샌드)
SELECT * FROM author
WHERE name = '홍길동'
  AND email = 'abc@naver.com';

SELECT * FROM author
WHERE name = '홍길동'
  && email = 'abc@naver.com';

-- OR / ||
SELECT * FROM author
WHERE name = '홍길동'
   OR email = 'abc@naver.com';

SELECT * FROM author
WHERE name = '홍길동'
   || email = 'abc@naver.com';

-- NOT / !
SELECT * FROM author
WHERE NOT (name = '홍길동');

SELECT * FROM author
WHERE !(name = '홍길동');


-- ------------------------------------------
-- 8. 검색 패턴 (LIKE / REGEXP)
-- ------------------------------------------

-- LIKE : 와일드카드 기반 패턴 검색
--  - % : 임의의 길이(0자 이상)의 문자열
-- 예)
--  'h%'   : h 로 시작
--  '%h'   : h 로 끝남
--  '%h%'  : 중간에 h 를 포함

SELECT * FROM post
WHERE title LIKE 'h%';

SELECT * FROM post
WHERE title LIKE '%h';

SELECT * FROM post
WHERE title LIKE '%h%';

-- NOT LIKE 도 가능
SELECT * FROM post
WHERE title NOT LIKE '%test%';


-- REGEXP(Regular Expression) : 정규표현식 기반 패턴 검색
-- 예) 영문 소문자 패턴
SELECT * FROM author
WHERE name REGEXP '^[a-z]+$';

-- 예) 한글 패턴
SELECT * FROM author
WHERE name REGEXP '^[가-힣]+$';

-- NOT REGEXP 도 가능
SELECT * FROM author
WHERE name NOT REGEXP '^[가-힣]+$';


-- ------------------------------------------
-- 9. 타입 변환 (CAST) / 날짜 포맷 (DATE_FORMAT)
-- ------------------------------------------

-- 9-1) CAST 함수
--  CAST(a AS type)
--  - 문자열/숫자 등을 특정 타입으로 변환할 때 사용. DATE_FORMAT보다 유연함

-- 예) 숫자를 DATE 로 변환
SELECT CAST(20200101 AS DATE);      -- 2020-01-01

-- 예) 문자열을 정수로 변환, 그냥 UNSIGNED를 사용하는걸로 
SELECT CAST('12' AS UNSIGNED);
SELECT CAST('12' AS INT);

-- 예) 숫자를 DATE 로 변환
SELECT CAST(20251121 AS DATE);

-- 예) 문자열을 DATE 로 변환
SELECT CAST('20251121' AS DATE);

-- 예) created_time 의 시(hour) 부분만 숫자로 뽑기
--   date_format(created_time, '%H') 는 문자열 → 이를 UNSIGNED 로 캐스팅
SELECT CAST(DATE_FORMAT(created_time, '%H') AS UNSIGNED) AS hour_value
FROM post;


-- 9-2) DATE_FORMAT 함수
--  DATE_FORMAT(date, format) : 날짜/시간을 특정 형식의 문자열로 변환
--  자주 사용되는 포맷 문자:
--   %Y : 연도(4자리)
--   %m : 월(2자리)
--   %d : 일(2자리)
--   %H : 시(00-23)
--   %i : 분
--   %s : 초

-- 예)
SELECT DATE_FORMAT('2020-01-01', '%Y-%m-%d');     -- '2020-01-01'

-- created_time 을 'YYYY-MM-DD' 문자열로 조회
SELECT DATE_FORMAT(created_time, '%Y-%m-%d') AS created_date
FROM post;

-- created_time 을 'HH:MM:SS' 문자열로 조회
SELECT DATE_FORMAT(created_time, '%H:%i:%s') AS created_time_str
FROM post;

-- 활용 예: 연도만 조건으로 사용
SELECT *
FROM post
WHERE DATE_FORMAT(created_time, '%Y') = '2025';

-- 11월 데이터만 조회
SELECT *
FROM post
WHERE DATE_FORMAT(created_time, '%m') = '01';

-- 또는 캐스팅과 함께 활용 (숫자로 비교)
SELECT *
FROM post
WHERE CAST(DATE_FORMAT(created_time, '%m') AS UNSIGNED) = 1;


-- ------------------------------------------
-- 10. 날짜 범위 조회 패턴 (실무에서 매우 중요)
-- ------------------------------------------

-- 2025년 11월에 등록된 게시글 조회 (예시 1: 문자열 패턴)
SELECT *
FROM post
WHERE created_time LIKE '2025-11%';

-- 2025-11-01 ~ 2025-11-19 까지의 데이터 조회 (포함 범위 정확히 지정)
--  → "종료일 다음날 0시" 를 기준으로 '<' 비교하는 패턴을 외워두는 게 좋다.

SELECT *
FROM post
WHERE created_time >= '2025-11-01'
  AND created_time <  '2025-11-20';

-- 위 쿼리는:
--  - 2025-11-01 00:00:00 이상
--  - 2025-11-20 00:00:00 미만
-- 즉, 1일부터 19일 23:59:59 까지를 모두 포함.

-- 잘못 사용하기 쉬운 패턴 예:
--  created_time <= '2025-11-19'
-- → 뒤에 시간이 '2025-11-19 23:59:59' 로 들어갈지,
--   '2025-11-19 00:00:00' 으로 들어갈지 혼동이 생길 수 있음.
--   따라서 실무에서는 보통:
--     >= 시작일 AND < 종료일_다음날
--   패턴으로 기억하는 것이 안전하다.