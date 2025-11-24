-- ------------------------------------------
-- 프로시저 + 트랜잭션 + 예외 처리 패턴 치트시트
-- ------------------------------------------
-- DELIMITER 로 프로시저 정의 범위 변경
DELIMITER //

CREATE PROCEDURE transaction_test()
BEGIN
    -- 에러(예외) 발생 시 자동으로 ROLLBACK 하고 종료하는 핸들러
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE author
    SET post_count = post_count + 1
    WHERE id = 2;

    -- 의도적으로 FK 위반 (없는 author_id = 100)
    INSERT INTO post (title, contents, author_id)
    VALUES ('프로시저 테스트', 'hello ...', 100);

    -- 위에서 에러가 나면 COMMIT 까지 도달하지 못하고
    -- HANDLER 에 의해 ROLLBACK 수행

    COMMIT;
END //

DELIMITER ;

-- 실행
CALL transaction_test();


-- ------------------------------------------
-- DB 트랜잭션 격리 수준(Isolation Level) 요약
-- ------------------------------------------
-- 1) READ UNCOMMITTED
--    - 커밋되지 않은 데이터도 읽을 수 있음.
--    - Dirty Read 발생 가능.
--
-- 2) READ COMMITTED
--    - 커밋된 데이터만 읽음.
--    - Dirty Read 방지.
--    - 하지만 Non-repeatable Read, Phantom Read 가능.
--
-- 3) REPEATABLE READ (MariaDB/MySQL 기본값)
--    - 한 트랜잭션 내에서 같은 쿼리는 항상 같은 결과(스냅샷) 반환.
--    - Dirty Read, Non-repeatable Read 방지.
--    - Phantom Read, Lost Update 문제는 여전히 조심해야 함(잠금/설계로 해결).
--
-- 4) SERIALIZABLE
--    - 트랜잭션들을 순차적으로 실행한 것과 같은 결과 보장.
--    - 동시성은 가장 낮고, 안전성은 가장 높음.


-- ------------------------------------------
-- 1. READ UNCOMMITTED 실습 개념 (Dirty Read)
-- ------------------------------------------
-- [transaction1 - GUI툴, auto commit 해제]
--   UPDATE author SET name = '김격리' WHERE id = 2;
--   (COMMIT 하지 않은 상태로 유지)
--
-- [transaction2 - 다른 세션]
--   SELECT * FROM author WHERE id = 2;
--
-- READ UNCOMMITTED 인 경우:
--   → transaction2 에서 아직 커밋 안 된 '김격리' 가 보임 (Dirty Read).
--
-- MariaDB / MySQL 의 기본(REPEATABLE READ)에서는 Dirty Read 가 발생하지 않음.


-- ------------------------------------------
-- 2. READ COMMITTED / REPEATABLE READ 개념 실습
-- ------------------------------------------
-- [transaction1 - GUI툴]
START TRANSACTION;
SELECT COUNT(*) FROM author;
DO SLEEP(15);
SELECT COUNT(*) FROM author;
COMMIT;

-- [transaction2 - 터미널]
INSERT INTO author (email) VALUES ('dbtest@naver.com');

-- READ COMMITTED 인 경우:
--   - transaction1 의 첫 번째 SELECT 시점 이후에
--     transaction2 가 INSERT 한 행이
--     두 번째 SELECT 에서는 보일 수도 있음.
--
-- REPEATABLE READ 인 경우:
--   - 하나의 트랜잭션 내에서는 "동일 쿼리 → 동일 결과"가 원칙이므로,
--     transaction1 의 두 번의 SELECT COUNT(*) 결과가 동일해야 함.


-- ------------------------------------------
-- 3. Lost Update 문제 & 배타락(SELECT ... FOR UPDATE)
-- ------------------------------------------

-- [문제 시나리오: concurrent_test1]  (lock 없이)
DELIMITER //

CREATE PROCEDURE concurrent_test1()
BEGIN
    DECLARE cnt INT;

    START TRANSACTION;

    -- 1) post 추가
    INSERT INTO post (title, author_id, contents)
    VALUES ('hello world', 2, 'ㅁㄴㅇㄹ');

    -- 2) 현재 post_count 읽기
    SELECT post_count INTO cnt
    FROM author
    WHERE id = 2;

    -- 3) 다른 트랜잭션이 끼어들 시간을 주기 위해 sleep
    DO SLEEP(15);

    -- 4) 읽어온 값 기반으로 +1 업데이트
    UPDATE author
    SET post_count = cnt + 1
    WHERE id = 2;

    COMMIT;
END //

DELIMITER ;

-- [transaction1] 에서 실행:
CALL concurrent_test1();

-- [transaction2] 에서 동시에:
SELECT post_count FROM author WHERE id = 2;

-- 두 트랜잭션이 같은 post_count 를 읽고
-- 서로 덮어써버리면, 실제로는 2번 증가해야 할 값이
-- 1번 증가만 반영되는 "Lost Update" 발생.


-- [해결 패턴: SELECT ... FOR UPDATE (배타적 잠금)]
DELIMITER //

CREATE PROCEDURE concurrent_test2()
BEGIN
    DECLARE cnt INT;

    START TRANSACTION;

    INSERT INTO post (title, author_id, contents)
    VALUES ('hello world', 2, 'ㅁㄴㅇㄹ22');

    -- 배타락: 이 행을 수정하려는 다른 트랜잭션을 대기 상태로 만듦
    SELECT post_count INTO cnt
    FROM author
    WHERE id = 2 FOR UPDATE;

    DO SLEEP(15);

    UPDATE author
    SET post_count = cnt + 1
    WHERE id = 2;

    COMMIT;
END //

DELIMITER ;

-- [transaction1]
CALL concurrent_test2();

-- [transaction2]
-- 아래 쿼리도 동일하게 "수정 의도"로 락을 걸면, transaction1 이 끝날 때까지 대기
SELECT post_count
FROM author
WHERE id = 2 FOR UPDATE;

-- 이때 transaction2 는 바로 결과가 나오지 않고,
-- 약 10초 이상 대기 후 결과가 나오는 것을 통해
-- "락에 의해 보호되고 있구나"를 확인할 수 있음.


-- ------------------------------------------
-- 4. SERIALIZABLE 개념 요약
-- ------------------------------------------
-- - 가장 높은 격리 수준.
-- - 트랜잭션들을 순차적으로 실행한 것과 같은 결과를 보장.
-- - 동시성이 크게 떨어질 수 있어,
--   정말 강력한 일관성이 필요한 경우에만 신중하게 사용.


-- ------------------------------------------
-- 5. 한 줄 요약
-- ------------------------------------------
-- - 트랜잭션: 여러 쿼리를 하나의 논리적 작업 단위로 묶어
--             ALL-or-NOTHING 으로 처리 (ACID).
-- - 격리 수준:
--   READ UNCOMMITTED  → Dirty Read 허용.
--   READ COMMITTED    → 커밋된 것만 읽음 (Non-repeatable/Phantom 가능).
--   REPEATABLE READ   → 같은 트랜잭션 내 조회 일관성 보장 (기본값). 
--   SERIALIZABLE      → 순차 실행과 동일한 결과, 동시성 최소.
-- - Lost Update 방지: SELECT ... FOR UPDATE 로 배타락을 걸어 해결.
