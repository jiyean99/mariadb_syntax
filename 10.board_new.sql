-- ==========================================
-- 다중 테이블 관계 설계 & 연관 데이터 처리 치트시트
-- ==========================================


-- ------------------------------------------
-- 1. 테이블 구조 설계 (1:1, 1:N, N:M 관계)
-- ------------------------------------------

-- 1) 회원 테이블 (author)
CREATE TABLE author (
    id       BIGINT AUTO_INCREMENT PRIMARY KEY,
    email    VARCHAR(255) NOT NULL UNIQUE,
    name     VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL
);

-- 2) 주소 테이블 (author : address = 1:1 관계 → author_id UNIQUE)
CREATE TABLE address (
    id        BIGINT AUTO_INCREMENT PRIMARY KEY,
    country   VARCHAR(255) NOT NULL,
    city      VARCHAR(255) NOT NULL,
    street    VARCHAR(255) NOT NULL,
    author_id BIGINT       NOT NULL UNIQUE,
    FOREIGN KEY (author_id) REFERENCES author(id)
);

-- 3) 게시글 테이블 (post)
CREATE TABLE post (
    id       BIGINT AUTO_INCREMENT PRIMARY KEY,
    title    VARCHAR(255) NOT NULL,
    contents VARCHAR(3000)
);

-- 4) 연결 테이블 (author : post = N:M 관계)
-- 첫 번째 방식 (별도 id 컬럼)
CREATE TABLE author_post_list (
    id        BIGINT AUTO_INCREMENT PRIMARY KEY,
    author_id BIGINT NOT NULL,
    post_id   BIGINT NOT NULL,
    FOREIGN KEY (author_id) REFERENCES author(id),
    FOREIGN KEY (post_id)   REFERENCES post(id)
);

-- 두 번째 방식 (복합 PK, 권장)
CREATE TABLE author_post_list (
    author_id BIGINT NOT NULL,
    post_id   BIGINT NOT NULL,
    PRIMARY KEY (author_id, post_id),
    FOREIGN KEY (author_id) REFERENCES author(id),
    FOREIGN KEY (post_id)   REFERENCES post(id)
);


-- ------------------------------------------
-- 2. 데이터 삽입 패턴
-- ------------------------------------------

-- 회원 가입 + 주소 생성
INSERT INTO author(email, name, password)
VALUES ('hong1@naver.com', 'hong1', 'hong1');

-- author 조회 후 id 확인 (실무에서는 LAST_INSERT_ID() 또는 프로시저 권장)
SELECT * FROM author; -- id = 3 확인

INSERT INTO address(country, city, street, author_id)
VALUES ('korea', 'seoul', 'nowon', 3);


-- 글쓰기 + 참여자 연결
INSERT INTO post(title, contents)
VALUES ('hong hi', 'hong hi ...');

SELECT * FROM post; -- post_id = 2 확인

INSERT INTO author_post_list(author_id, post_id)
VALUES (3, 2);

-- ※ 최초 생성자는 INSERT, 추후 참여자는 UPDATE로 진행


-- ------------------------------------------
-- 3. 데이터 조회 (N:M 관계 조인)
-- ------------------------------------------

-- 제목, 내용, 글쓴이 이름 조회 (중복 제거)
SELECT DISTINCT p.title, p.contents, a.name
FROM post p
INNER JOIN author_post_list a_p_l ON p.id = a_p_l.post_id
INNER JOIN author a ON a_p_l.author_id = a.id;


-- ------------------------------------------
-- 4. 동적 처리 시 고려사항
-- ------------------------------------------

-- 1) LAST_INSERT_ID() 사용
-- INSERT 후 자동 생성된 ID를 바로 가져옴
INSERT INTO author(email, name, password) VALUES (...);
INSERT INTO address(country, city, street, author_id) 
VALUES ('korea', 'seoul', 'nowon', LAST_INSERT_ID());

-- 2) 프로시저 사용 (권장)
-- 트랜잭션 + 예외 처리 + 동적 ID 처리

-- 3) 락킹 고려
-- 동시성 문제 발생 시 SELECT FOR UPDATE 등 사용


-- ------------------------------------------
-- 5. 관계 요약
-- ------------------------------------------
-- - author : address = 1:1 (author_id UNIQUE 제약)
-- - author : post = N:M (연결 테이블 author_post_list)
-- - 연결 테이블 복합 PK 권장 (author_id, post_id)
-- - 조회 시 3개 테이블 조인 (post → author_post_list → author)
-- - DISTINCT로 중복 제거 필수 (N:M 관계 특성상 발생)

-- ------------------------------------------
-- + 정리
-- ------------------------------------------
-- N:M 관계는 반드시 연결 테이블 필요
-- 1:1 관계는 FK에 UNIQUE 제약 추가
-- 연결 테이블은 복합 PK 권장 (중복 방지)
-- 다중 조인은 alias 필수
-- N:M 조회 시 DISTINCT로 중복 제거