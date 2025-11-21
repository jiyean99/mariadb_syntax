-- ==========================================
-- DDL 치트시트
-- ==========================================


-- ------------------------------------------
-- 1. 스키마(Database) 생성 / 조회 / 삭제 / 선택
-- ------------------------------------------

-- 1) 스키마 생성
--    create database [스키마명];
-- 예) myapp 이라는 스키마 생성
CREATE DATABASE myapp;

-- 2) 스키마 목록 조회
--    show databases;
SHOW DATABASES;

-- 3) 스키마 삭제
--    drop database [스키마명];
-- 주의: 안의 모든 테이블/데이터가 함께 삭제됨
DROP DATABASE myapp;

-- 4) 스키마 선택 (이후 작업 대상 DB 지정)
--    use [스키마명];
USE myapp;

-- 5) 현재 선택된 스키마의 테이블 목록 조회
--    show tables;
-- 반드시 use 로 스키마를 먼저 선택해야 한다.
SHOW TABLES;


-- ------------------------------------------
-- 2. 문자 인코딩 확인 & 변경
-- ------------------------------------------

-- 1) 서버 문자셋 확인
--    show variables like 'character_set_server';
SHOW VARIABLES LIKE 'character_set_server';

-- 2) DB 기본 문자셋 변경 (utf8mb4 권장)
--    ALTER DATABASE [DB명] DEFAULT CHARACTER SET = utf8mb4;
ALTER DATABASE myapp DEFAULT CHARACTER SET = utf8mb4;


-- ------------------------------------------
-- 3. 테이블 생성 / 구조 조회 / 데이터 조회
-- ------------------------------------------

-- 1) 테이블 생성 기본 형식
--    CREATE TABLE 테이블이름 (
--      필드이름1 필드타입1 [제약조건],
--      필드이름2 필드타입2 [제약조건],
--      ...
--      [테이블 제약조건]  -- PK, FK 등
--    );
--
-- 예) 회원 테이블 생성
CREATE TABLE member (
    id        INT AUTO_INCREMENT PRIMARY KEY,     -- 기본 키
    email     VARCHAR(100) NOT NULL UNIQUE,      -- 이메일, 중복 불가
    name      VARCHAR(50)  NOT NULL,             -- 이름
    created_at DATETIME     DEFAULT NOW(),        -- 생성 일시
    foreign key(author_id) references author(id)
);

-- 2) 테이블 구조(컬럼 정보) 조회
--    describe [테이블명];
DESCRIBE member;

-- 3) 테이블 데이터 전체 조회
--    select * from [테이블명];
SELECT * FROM member;

-- 4) 테이블 생성 DDL 조회 (실제 create문 확인용, 자주 안 씀)
--    show create table [테이블명];
SHOW CREATE TABLE member;


-- ------------------------------------------
-- 4. 제약조건 / 인덱스 조회
-- ------------------------------------------

-- 1) information_schema를 이용한 제약조건 조회
--    select * 
--    from information_schema.key_column_usage
--    where table_name = '테이블명';
SELECT *
FROM information_schema.key_column_usage
WHERE table_name = 'member';

-- 2) 인덱스 조회 (PK/UK 등 제약도 함께 보이는 경우가 많음)
--    show index from [테이블명];
SHOW INDEX FROM member;


-- ------------------------------------------
-- 5. 테이블 이름/컬럼 구조 변경 (ALTER TABLE)
-- ------------------------------------------

-- 1) 테이블 이름 변경
--    alter table [기존테이블명] rename [새테이블명];
ALTER TABLE member RENAME member_user;

-- 2) 컬럼 추가
--    alter table [테이블명]
--    add column [컬럼명] [타입] [제약조건];
--
-- 예) age 컬럼 추가
ALTER TABLE member_user
ADD COLUMN age INT DEFAULT 0;

-- 3) 컬럼 삭제
--    alter table [테이블명]
--    drop column [컬럼명];
ALTER TABLE member_user
DROP COLUMN age;

-- 4) 컬럼명 변경
--    alter table [테이블명]
--    change column [기존컬럼명] [새컬럼명] [타입] [제약조건];
--
-- 예) name → full_name 으로 이름 변경
ALTER TABLE member_user
CHANGE COLUMN name full_name VARCHAR(50) NOT NULL;

-- 5) 컬럼 타입/제약조건 변경 (이름은 그대로)
--    alter table [테이블명]
--    modify column [컬럼명] [새타입] [새제약조건];
--
-- 예) email 길이 확장
ALTER TABLE member_user
MODIFY COLUMN email VARCHAR(200) NOT NULL UNIQUE;


-- ------------------------------------------
-- 6. 테이블 삭제 (DROP TABLE)
-- ------------------------------------------

-- 1) 기본 삭제
--    drop table [테이블명];
-- 테이블이 존재하지 않으면 에러 발생.
DROP TABLE member_user;

-- 2) 조건부 삭제
--    drop table if exists [테이블명];
-- 테이블이 없으면 에러 없이 그냥 넘어감.
DROP TABLE IF EXISTS member_user;

-- * 차이점 정리
--   - drop table [테이블명];
--       → 대상 테이블이 없으면 에러가 나고,
--         그 뒤에 이어지는 쿼리 실행이 중단될 수 있음.
--
--   - drop table if exists [테이블명];
--       → 존재할 때만 삭제하고, 없으면 에러 없이 통과.
--         여러 DDL/DML을 한 번에 실행하는 스크립트에서
--         중간에 "이미 없는 테이블" 때문에 전체가 실패하는 일을
--         방지하기 위해 if exists 를 자주 사용한다.