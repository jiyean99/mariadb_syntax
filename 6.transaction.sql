-- ==========================================
-- 트랜잭션 치트시트
-- ==========================================


-- ------------------------------------------
-- 1. 트랜잭션 기본 개념 & 사용 패턴
-- ------------------------------------------
-- - 여러 개의 쿼리를 "하나의 작업 단위"로 묶어서
--   전부 성공하면 COMMIT, 하나라도 실패하면 ROLLBACK 하는 것.
-- - GUI 툴에서 auto-commit 이 켜져 있으면,
--   각 쿼리마다 자동으로 commit 이 되어왔던 것.

-- 트랜잭션용 컬럼 예시 추가 (작성 글 수)
ALTER TABLE author ADD COLUMN post_count INT DEFAULT 0;

-- 기본 트랜잭션 패턴
--   1) auto-commit OFF (툴에서 설정)
--   2) START TRANSACTION;
--   3) 여러 DML 실행
--   4) 문제가 없으면 COMMIT;
--      문제가 있으면 ROLLBACK;

-- 예) post 글 생성 + author.post_count 증가를 한 트랜잭션으로 처리
START TRANSACTION;

-- 글쓴이의 글 개수 +1
UPDATE author
SET post_count = post_count + 1
WHERE id = 2;

-- post 에 글 생성 (FK 위반 시 실패)
-- FK 제약 때문에 실패하는 값 예: author_id = 100 (없는 id)
-- INSERT INTO post (title, contents, author_id)
-- VALUES ('hello~', 'hello world', 100);

-- 정상 예: 존재하는 author_id 사용
INSERT INTO post (title, contents, author_id)
VALUES ('hello~', 'hello world', 2);

COMMIT;

-- * 위 두 작업 중 하나라도 실패하면,
--   전체를 ROLLBACK 시키는 것이 트랜잭션의 목적.