-- ==========================================
-- SQL 인덱스 치트시트
-- ==========================================


-- ------------------------------------------
-- 1. 인덱스 기본 개념
-- ------------------------------------------
-- PK, FK, UNIQUE 제약조건을 만들 때
-- 해당 컬럼에 인덱스가 자동 생성됨.
--
-- 별도로도 인덱스를 추가할 수 있음.
-- 인덱스를 통해 데이터 조회 성능이 크게 개선됨.

-- ------------------------------------------
-- 2. 인덱스 조회 및 삭제
-- ------------------------------------------

-- 테이블의 인덱스 목록 조회
SHOW INDEX FROM [테이블명];

-- 인덱스 삭제 (기본 PK 인덱스는 삭제 불가/권장하지 않음)
ALTER TABLE [테이블명]
DROP INDEX [인덱스명];


-- ------------------------------------------
-- 3. 인덱스 생성
-- ------------------------------------------

-- 단일 컬럼 인덱스 생성
CREATE INDEX [인덱스명]
ON [테이블명] ([컬럼명]);

-- 예) author 테이블의 name 컬럼 인덱스 생성
CREATE INDEX name_index ON author(name);

-- 복합 인덱스 생성 (여러 컬럼 동시에)
CREATE INDEX [인덱스명]
ON [테이블명] ([컬럼1], [컬럼2]);

-- 예) name, age 컬럼을 하나의 복합 인덱스로 생성
CREATE INDEX name_age_index ON author(name, age);

-- 복합 인덱스는 두 컬럼 모두 조건에 포함되어야 효율적으로 사용됨.


-- ------------------------------------------
-- 4. 인덱스 성능 테스트 예시
-- ------------------------------------------

-- 인덱스 생성 전과 후 성능 비교
-- author 테이블 생성 예시 (인덱스 없는 경우)
CREATE TABLE author_no_index (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255),
    name VARCHAR(255)
);

-- author 테이블 생성 예시 (email에 UNIQUE 인덱스 존재)
CREATE TABLE author_with_index (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE,
    name VARCHAR(255)
);

-- 인덱스 생성 전후에 수십만 건 데이터 삽입 후
-- 동일 쿼리를 실행하면, 실행 시간이 크게 감소함 (ex: 709ms → 340ms)

-- (+추가) 대용량 데이터 집합 인서트 + 테스트 프로시저
DELIMITER //

CREATE PROCEDURE insert_authors()
BEGIN
    DECLARE i INT DEFAULT 1;
    DECLARE email VARCHAR(100);
    DECLARE batch_size INT DEFAULT 10000; -- 한 번에 삽입할 행 수
    DECLARE max_iterations INT DEFAULT 100; -- 전체 반복 횟수 (예: 1,000,000건)
    DECLARE iteration INT DEFAULT 1;

    WHILE iteration <= max_iterations DO
        START TRANSACTION;

        WHILE i <= iteration * batch_size DO
            SET email = CONCAT('bradkim', i, '@naver.com');
            INSERT INTO author (email) VALUES (email);
            SET i = i + 1;
        END WHILE;

        COMMIT;

        SET iteration = iteration + 1;

        -- 각 트랜잭션 후 0.1초 지연 (부하 완화)
        DO SLEEP(0.1);
    END WHILE;
END //

DELIMITER ;


-- ------------------------------------------
-- 인덱스 요약
-- ------------------------------------------
-- - 인덱스는 검색 속도를 획기적으로 개선하므로 필수적
-- - 기본 키(PK), 외래 키(FK), 유니크 제약조건 생성 시 자동 생성
-- - 추가로 자주 조회되는 컬럼에 별도 인덱스 생성 권장
-- - 복합 인덱스는 연관된 컬럼 여러 개에 대해 생성 가능하지만
--   모두 조건에 포함돼야 효과적
-- - 대용량 데이터 삽입 후 인덱스 생성 및 성능 테스트가 중요
