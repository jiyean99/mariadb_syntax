-- ==========================================
-- MySQL 사용자 관리 치트시트
-- ==========================================


-- 1. 사용자 생성
-- 형식: CREATE USER '사용자명'@'호스트' IDENTIFIED BY '비밀번호';
-- '%' 는 모든 호스트 접속 허용 의미 (개발용 주로 사용, 보안 주의)
CREATE USER 'crm'@'%' IDENTIFIED BY 'test4321';


-- 2. 권한 부여
-- 특정 스키마, 테이블 단위로 권한 부여할 수 있음
GRANT SELECT ON [스키마명].[테이블명] TO 'crm'@'%';

-- 예시1: board.author 테이블에 SELECT 권한 부여
GRANT SELECT ON board.author TO 'crm'@'%';

-- 예시2: board 스키마 전체에 SELECT, INSERT 권한 부여
GRANT SELECT, INSERT ON board.* TO 'crm'@'%';

-- 예시3: 모든 권한(ALL PRIVILEGES) 부여 (주의: 관리자 권한)
GRANT ALL PRIVILEGES ON board.* TO 'crm'@'%';


-- 3. 권한 회수
-- 형식: REVOKE 권한 ON [스키마명].[테이블명] FROM '사용자명'@'호스트';
REVOKE SELECT ON [스키마명].[테이블명] FROM 'crm'@'%';


-- 4. 권한 조회
-- 특정 사용자가 가진 권한 확인
SHOW GRANTS FOR 'crm'@'%';


-- 5. 사용자 삭제
DROP USER 'crm'@'%';


-- ------------------------------------------
-- 권한 및 사용자 관리 팁
-- ------------------------------------------
-- - 사용자 계정은 '사용자명'@'호스트' 형태로 식별됨
-- - 호스트 지정에 따라 접속 가능한 IP나 도메인 범위를 제한 가능
-- - 권한은 최소 권한 원칙에 따라 필요한 권한만 부여하도록 권장됨
-- - ALL PRIVILEGES 는 모든 권한 부여로, 주의해서 사용해야 함
-- - 권한 변경 후에는 필요시 FLUSH PRIVILEGES; 를 실행하기도 함
