-- ==========================================
-- MySQL VIEW 치트시트 (한글 지원 포함)
-- ==========================================

-- 1. VIEW 개념
-- - 실제 테이블을 참조하는 가상의 테이블
-- - SELECT만 가능 (INSERT, UPDATE, DELETE 제한적/불가)
-- - 사용 목적: 권한 분리, 복잡 쿼리 단순화, 재사용성 향상
-- - 한글 데이터 처리 가능 (서버와 DB, 클라이언트 인코딩 설정 필수)

-- 2. VIEW 생성
CREATE VIEW author_view AS
SELECT name, email
FROM author;

-- 3. VIEW 조회
SELECT * FROM author_view;

-- 4. VIEW 권한 부여
GRANT SELECT ON author_view TO 'crm'@'%';

-- 5. VIEW 삭제
DROP VIEW author_view;


-- ------------------------------------------
-- 6. 한글 지원을 위한 설정 팁
-- ------------------------------------------
-- 1) 데이터베이스 생성 시 문자셋 설정
--
-- CREATE DATABASE dbname DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 2) 테이블 생성 시 문자셋 설정
--
-- CREATE TABLE table_name (
--   ...
-- ) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- 3) MySQL 서버 설정 변경 (my.cnf 또는 my.ini)
-- [client]
-- default-character-set = utf8mb4
--
-- [mysql]
-- default-character-set = utf8mb4
--
-- [mysqld]
-- character-set-server = utf8mb4
-- collation-server = utf8mb4_unicode_ci
--
-- 변경 후 MySQL 서버 재시작 필요

-- 4) 클라이언트(터미널, IDE) 인코딩 UTF-8 설정 권장
