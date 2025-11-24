-- ==========================================
-- 제약조건 치트시트
-- ==========================================


-- ------------------------------------------
-- 0. 제약조건 개념 요약
-- ------------------------------------------
-- PK (PRIMARY KEY)
--  - 행을 유일하게 식별하는 컬럼(들).
--  - NOT NULL + UNIQUE 성격을 동시에 가짐.
--  - 한 테이블에 하나만 존재.
--
-- FK (FOREIGN KEY)
--  - 다른 테이블의 PK(또는 UNIQUE) 를 참조하는 컬럼.
--  - 테이블 간 관계(참조 무결성)를 보장.
--
-- NOT NULL
--  - 해당 컬럼에 NULL 을 허용하지 않음.
--
-- UNIQUE
--  - 해당 컬럼 값이 테이블 내에서 중복될 수 없음.
--  - NULL 은 DB 종류에 따라 여러 개 허용될 수 있음(MySQL은 가능).


-- ------------------------------------------
-- 1. NOT NULL / UNIQUE (컬럼 수준)
-- ------------------------------------------

-- NOT NULL 은 컬럼 정의를 "덮어쓰기(modify)"로 추가/제거할 수 있다.
-- UNIQUE는 "덮어쓰기(modify)"로 추가만 가능하다.
-- (PK, FK, UNIQUE는 이렇게 단순 modify 로 제거 불가)

-- 예시 테이블
CREATE TABLE author (
    id    INT AUTO_INCREMENT PRIMARY KEY,
    name  VARCHAR(255),
    email VARCHAR(255)
);


-- 1) NOT NULL 제약 조건 추가
--    alter table [테이블명]
--    modify column [컬럼명] [타입] not null;
ALTER TABLE author
MODIFY COLUMN name VARCHAR(255) NOT NULL;

-- 2) NOT NULL 제약 조건 제거
--    not null 을 빼고 컬럼을 다시 정의(덮어쓰기)
ALTER TABLE author
MODIFY COLUMN name VARCHAR(255);


-- 3) NOT NULL + UNIQUE 동시에 추가
--    컬럼 정의에 not null unique 를 함께 기술
ALTER TABLE author
MODIFY COLUMN email VARCHAR(255) NOT NULL UNIQUE;

-- ※ UNIQUE 제거는 PK/FK처럼 "제약조건 이름으로 drop" 하거나
--    인덱스에서 삭제해야 하는 경우가 있어 다소 번거롭다.
--    (MySQL에서는 UNIQUE 제약이 내부적으로 UNIQUE INDEX 로 구현되기 때문)


-- ------------------------------------------
-- 2. PRIMARY KEY (PK) 제약조건
-- ------------------------------------------

-- PK는 보통 테이블 생성 시 함께 정의하는 경우가 많다.
-- CREATE TABLE 시:
--   - 컬럼 옆에 PRIMARY KEY
--   - 또는 테이블 제약조건으로 PRIMARY KEY (컬럼명들)

-- 예시: 테이블 생성 시 PK 지정
DROP TABLE IF EXISTS post;

CREATE TABLE post (
    id        INT AUTO_INCREMENT,
    author_id INT,
    title     VARCHAR(255),
    content   TEXT,
    PRIMARY KEY (id)        -- 테이블 제약조건으로 PK 지정
);


-- 1) PK 제약조건 추가 (ALTER TABLE)
--    alter table [테이블명]
--    add constraint [pk명] primary key ([pk컬럼]);
--
--  - [pk명]은 제약조건 이름 (예: pk_post_id)
--  - 이미 데이터가 있는 경우, 중복/NULL 이 있으면 에러 발생.

ALTER TABLE post
ADD CONSTRAINT pk_post_id PRIMARY KEY (id);


-- 2) PK 제약조건 삭제
--    alter table [테이블명] drop primary key;
--
--  - PK 는 이름을 직접 지정하지 않아도 DROP PRIMARY KEY 로 제거.
--  - PK 컬럼/구성은 describe, information_schema 로 확인 후 작업.

ALTER TABLE post
DROP PRIMARY KEY;


-- ------------------------------------------
-- 3. FOREIGN KEY (FK) 제약조건
-- ------------------------------------------

-- 예시: author(id) 를 참조하는 post.author_id 에 FK 추가

-- 테이블 구조 (단순 예시)
DROP TABLE IF EXISTS post;
DROP TABLE IF EXISTS author;

CREATE TABLE author (
    id    INT AUTO_INCREMENT PRIMARY KEY,
    name  VARCHAR(255) NOT NULL
);

CREATE TABLE post (
    id        INT AUTO_INCREMENT PRIMARY KEY,
    author_id INT,
    title     VARCHAR(255)
);


-- 1) FK 제약조건 추가
--    alter table [테이블명]
--    add constraint [fk명]
--    foreign key ([제약컬럼])
--    references [참조테이블]([참조컬럼]);

ALTER TABLE post
ADD CONSTRAINT fk_post_author
FOREIGN KEY (author_id)
REFERENCES author(id);


-- 2) FK 제약조건 삭제
--    alter table [테이블명]
--    drop foreign key [fk명];

ALTER TABLE post
DROP FOREIGN KEY fk_post_author;


-- 3) ON DELETE / ON UPDATE 옵션 추가
--    참조 대상이 삭제/변경될 때 자식 테이블에서의 동작을 정의.

-- 대표 옵션:
--  - ON DELETE SET NULL    : 부모가 삭제되면 자식 FK 컬럼을 NULL 로 설정
--  - ON UPDATE CASCADE     : 부모 PK 가 변경되면 자식도 함께 변경
--  - (그 외 RESTRICT, NO ACTION, CASCADE 등)

ALTER TABLE post
ADD CONSTRAINT fk_post_author
FOREIGN KEY (author_id)
REFERENCES author(id)
ON DELETE SET NULL
ON UPDATE CASCADE;


-- ------------------------------------------
-- 4. 제약조건 추가/삭제 정리표 (요약용 주석)
-- ------------------------------------------

-- PK (PRIMARY KEY)
--  추가:
--    - CREATE TABLE 시 테이블 제약조건:
--        PRIMARY KEY (pk컬럼)
--    - 또는 ALTER TABLE:
--        alter table [테이블명]
--        add constraint [pk명] primary key ([pk컬럼]);
--
--  삭제:
--    - alter table [테이블명] drop primary key;

-- FK (FOREIGN KEY)
--  추가:
--    - CREATE TABLE 시:
--        constraint [fk명]
--        foreign key ([fk컬럼]) references [참조테이블]([참조컬럼])
--    - 또는 ALTER TABLE:
--        alter table [테이블명]
--        add constraint [fk명]
--        foreign key ([fk컬럼])
--        references [참조테이블]([참조컬럼])
--        [on delete ... on update ...];
--
--  삭제:
--    - alter table [테이블명]
--      drop foreign key [fk명];

-- NOT NULL
--  추가/수정 (덮어쓰기):
--    alter table [테이블명]
--    modify column [컬럼명] [타입] [기타제약] not null;
--
--  제거 (덮어쓰기):
--    alter table [테이블명]
--    modify column [컬럼명] [타입] [기타제약];

-- UNIQUE
--  추가:
--    - 컬럼 정의에 unique 키워드:
--        [컬럼명] [타입] not null unique
--    - 또는 테이블 제약조건:
--        constraint [uq명] unique ([컬럼명들])
--
--  삭제:
--    - 보통 UNIQUE INDEX 를 drop 하는 방식으로 제거
--      (DB/툴에 따라 방식 상이. MySQL에선 show index 로 이름 확인 후 drop index 사용 등)

-- ------------------------------------------
-- 5. 컬럼 옵션(제약조건이라기보다는 설정 옵션)
-- ------------------------------------------

-- 1) DEFAULT 값 지정
--  - 거의 모든 컬럼 타입에 설정 가능
--  - 자주 사용하는 예:
--    - 기본 문자열 지정: DEFAULT 'anonymous'
--    - ENUM 의 기본값 지정
--    - DATETIME / TIMESTAMP 의 현재시각 지정: DEFAULT CURRENT_TIMESTAMP

-- 예) name 컬럼에 기본값 'anonymous' 지정
ALTER TABLE author
MODIFY COLUMN name VARCHAR(255) DEFAULT 'anonymous';

-- 예) ENUM 타입 기본값 지정은 아래에서 다룸


-- 2) AUTO_INCREMENT
--  - 숫자 타입에서 많이 사용
--  - 값을 명시적으로 넣지 않으면, 테이블 내 가장 큰 값보다 1 증가된 값 자동 입력
--  - PK 에 주로 붙임

-- 예) id 컬럼에 AUTO_INCREMENT 옵션 추가
ALTER TABLE author
MODIFY COLUMN id INT AUTO_INCREMENT;


-- 3) UUID 사용

-- UUID는 128비트 (16진수 32자 + 하이픈 포함 36자) 고유 식별자
--  - ex) '550e8400-e29b-41d4-a716-446655440000'

-- 예) post 테이블에 user_id 컬럼 추가, 기본값은 UUID 함수 호출 결과
ALTER TABLE post
ADD COLUMN user_id CHAR(36) DEFAULT (UUID());

-- UUID는 숫자가 아닌 16진수 문자열(알파벳 a~f 포함) 형태임