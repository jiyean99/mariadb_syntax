#!/bin/bash
# ==========================================
# Redis 치트시트 (redis_commands_cheatsheet.sh)
# String/List/Set/ZSet/Hash + 실전 활용 패턴
# ==========================================

# ------------------------------------------
# 1. STRING 자료구조
# ------------------------------------------
# SET [key] [value] : 기본 저장 (덮어쓰기)
SET user:email:1 "hong@naver.com"
SET user:email:2 "kim@naver.com"

# SET [key] [value] NX : 존재하지 않을 때만 설정
SET user:email:3 "lee@naver.com" NX

# GET [key] : 값 조회
GET user:email:1

# SET [key] [value] EX [초] : TTL 설정
SET session:1 "token123" EX 1800  # 30분 후 자동 삭제

# DEL [key] : 키 삭제
DEL user:email:1

# FLUSHDB : 전체 DB 키 삭제
FLUSHDB

# redis String 자료 구조 실전 활용
# (1) 좋아요 기능 구현 → 동시성 이슈 해결
SET likes:posting:1 0     # redis는 기본적으로 모든 key, value가 문자열. 따라서 0으로 세팅해도 내부적으로 "0"으로 저장(연산가능)
INCR likes:posting:1      # +1
DECR likes:posting:1      # -1

SET stock:product:1 100

# (2) 재고 관리 기능 구현 → 동시성 이슈 해결
SET stock:product:1 100
DECR stock:product:1      # 재고 감소 (INCR: 증가)

# (3) 로그인 성공 시 토큰 저장 → 빠른 성능
SET user:1:refresh_token adcdxxxxxx ex 1800 # 30분 지나면 로그아웃 됨

# (4) 데이터 캐싱 → 빠른 성능
set member:info:1 "{\"name\":\"hong\", \"email\":\"hong@daum.net\", \"age\":30}" ex 1000

# ------------------------------------------
# 2. LIST (Double-Ended Queue)
# ------------------------------------------
# LPUSH/RPUSH [key] [value] : 좌/우측 추가
LPUSH students "kim1"
RPUSH user:1:recent:product "apple"
RPUSH user:1:recent:product "banana"

# LRANGE [key] [start] [end] : 범위 조회
LRANGE students 0 -1          # 전체


# LPOP/RPOP [key] : 좌/우측 꺼내기 (삭제)
RPOP students

# LLEN [key] : 길이
LLEN students

# redis list 자료 구조 실전 활용
# (1) 웹사이트 최근 방문 → 중요하나 임시성이 강한 데이터 (사실 zset을 쓰는게 적절함)

# (2) 최근 살펴본 상품 리스트 (상품이 중복될 우려가 있어 zset을 쓰는게 적절함)
RPUSH user:1:recent:product apple
RPUSH user:1:recent:product banana
RPUSH user:1:recent:product orange
RPUSH user:1:recent:product melon
RPUSH user:1:recent:product mango

LRANGE user:1:recent:product -3 -1  # 최근 본 상품 목록 3개 조회

# ------------------------------------------
# 3. SET (중복없음, 순서없음)
# ------------------------------------------
# SADD [key] [member] : 멤버 추가
SADD memberlist "m1"
SADD memberlist "m2"
SADD memberlist "m3"
SADD memberlist "m3"  # 중복 무시

# SMEMBERS [key] : 전체 조회
SMEMBERS memberlist

# SCARD [key] : 개수
SCARD memberlist

# SISMEMBER [key] [member] : 존재 여부
SISMEMBER likes:posting:1 "abc@naver.com"

# SREM [key] [member] : 제거
SREM likes:posting:1 "abc@naver.com"

# redis set 자료 구조 실전 활용
# (1) 좋아요 (중복 방지)
SCARD likes:posting:1                     # 좋아요 개수
SADD likes:posting:1 "abc@naver.com"      # 좋아요 추가
SREM likes:posting:1 "abc@naver.com"      # 좋아요 취소
SISMEMBER likes:posting:1 "abc@naver.com" # 좋아요 눌렀는지 안눌렀는지 확인

# (2) 매일 방문자 수 계산

# ------------------------------------------
# 4. ZSET (Sorted Set)
# ------------------------------------------
# ZADD [key] [score] [member] : 점수+멤버 추가
ZADD user:1:recent:product 151400 "apple"
ZADD user:1:recent:product 151401 "banana"

# ZRANGE [key] [start] [end] : 오름차순
ZRANGE user:1:recent:product -3 -1

# ZREVRANGE [key] [start] [end] [WITHSCORES] : 내림차순
ZREVRANGE user:1:recent:product 0 2 WITHSCORES

# redis zset 자료 구조 실전 활용
# (1) 최근 살펴본 상품 목록
ZADD user:1:recent:product 151400 apple
ZADD user:1:recent:product 151401 banana
ZADD user:1:recent:product 151402 orange
ZADD user:1:recent:product 151403 melon
ZADD user:1:recent:product 151404 mango
ZADD user:1:recent:product 151405 melon # 값이 똑같으면 03초꺼는 없어지고(중복제거) score만 업데이트 됨
# 최근 본 상품 3개 조회
ZRANGE user:1:recent:product -3 -1 # orange, mango, melon 출력
ZREVRANGE user:1:recent:product 0 2 # melon, mango, orange 출력 -> 우리가 의도한 상황

# (2) 주식, 코인 등 실시간 시세 저장

# ------------------------------------------
# 5. HASH (객체 저장)
# ------------------------------------------
# HSET [key] [field] [value] : 필드 설정
HSET member:info:1 name "hong" email "hong@daum.net" age 30

# HGET [key] [field] : 필드 조회
HGET member:info:1 name

# HGETALL [key] : 전체 조회
HGETALL member:info:1

# HINCRBY [key] [field] [increment] : 숫자 증가
HINCRBY member:info:1 age 1

# ------------------------------------------
# 6. 실전 활용 패턴 요약
# ------------------------------------------
# ✅ 좋아요: INCR (String) | SET (중복방지)
# ✅ 재고관리: DECR (String)
# ✅ 세션/토큰: SET EX (TTL)
# ✅ 캐싱: SET EX (JSON)
# ✅ 최근방문/상품: RPUSH/LRANGE (List) | ZADD/ZREVRANGE (ZSet)
# ✅ 중복체크: SISMEMBER (Set)

# ------------------------------------------
# 7. Redis 고급 기능
# ------------------------------------------
# Pub/Sub : 실시간 알림/채팅 (메시지 저장 X, 빠름)
# Streams : 메시지 저장+전파 (Kafka 대안, 안정성 위주)

# ------------------------------------------
# 8. 아키텍처
# ------------------------------------------
# Replica : 읽기 복제
# Cluster : 샤딩

# ------------------------------------------
# 정리
# ------------------------------------------
# String: 카운터/캐싱/세션
# List: 최근 목록 (FIFO/LIFO)
# Set: 중복방지 집계
# ZSet: 순위/타임라인
# Hash: 객체 저장
