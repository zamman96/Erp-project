<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!-- 메뉴에서 상품 추가 -->
<div class="modal fade" id="menuModal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header row align-items-center justify-content-between">
			<div>
				<h4 class="modal-title">상품 추가</h4>
			</div>
			<div>
				<button type="button" class="btn btn-default" data-dismiss="modal">닫기</button>
			</div>
   		</div>
      <div class="modal-body">
      <div class="wrap">
      <!-- 가맹점주 선택 -->
      	<div class="cont" style="display: flex;flex-direction: row; align-items: end;">
			<!-- 검색 조건 시작 -->
			<div class="search-wrap">
				<!-- 유형 검색조건 -->
				<div class="search-cont">
					<p class="search-title">유형</p>
					<div class="select-custom w-100">
					<select name="menuType" id="menuTypeModal">
							<option value="" selected>전체</option>
							<option value="MENU02">단품</option>
							<option value="MENU03">사이드</option>
							<option value="MENU04">음료</option>
						</select>
					</div>
				</div>
				<!-- 판매유형 검색조건 -->
				<div class="search-cont">
					<p class="search-title">판매 유형</p>
						<div class="select-custom w-100">
						<select name="ntslType" id="ntslTypeModal">
							<option value="" selected>전체</option>
							<c:forEach var="ntsl" items="${ntsl}">
								<option value="${ntsl.comNo}">
								${ntsl.comNm}</option>
							</c:forEach>
						</select>
					</div>
				</div>
				<!-- 텍스트 검색조건 -->
				<div class="search-cont">
					<p class="search-title">메뉴명</p>
					<div class="search-input-btn">
						<input type="text" id="menuNmModal" name="menuNm" placeholder="키워드를 입력하세요"> 
						<button type="button" id="searchBtnMenu" class="search-btn"></button>
					</div>
				</div>
			</div>
<!-- 			<button class="btn btn-default" style="height: 44px;" id="searchBtnMenu">검색 <span class="icon material-symbols-outlined">search</span></button> -->
      </div>
		<!-- 검색 조건 끝 -->
		<div class="cont">
		<!-- 테이블 분류 시작 -->
		<div class="table-wrap">
				<div class="tap-wrap">
					<div class="tap-cont tap-conts active">
						<span class="tap-title">전체</span>
						<span class="bge bge-default" id="tap-all"></span>
					</div>
					<div data-type='MENU02' class="tap-cont tap-conts" >
						<span class="tap-title">단품</span>
						<span class="bge bge-warning" id="tap-menu02"></span>
					</div>
					<div data-type='MENU03' class="tap-cont tap-conts" >
						<span class="tap-title">사이드</span>
						<span class="bge bge-danger" id="tap-menu03"></span>
					</div>
					<div data-type='MENU04' class="tap-cont tap-conts" >
						<span class="tap-title">음료</span>
						<span class="bge bge-info" id="tap-menu04"></span>
					</div>
				</div>
			<!-- 테이블 분류 끝 -->
		<!-- 테이블 시작 -->
		<table class="table-default">
					<thead>
						<tr>
							<th class="center" style="width: 10%;">번호</th>
							<th class="center sort sort-menu active" data-sort="menuNm">
								상품명
								<div class="sort-icon" style="width: 30%;">
									<div class="sort-arrow">
									  <span class="sort-asc active">▲</span>
									  <span class="sort-desc">▼</span>
									</div>
								</div>
							</th>
							<th class="center sort sort-menu" data-sort="menuType" style="width: 20%;">
								유형
								<div class="sort-icon">
									<div class="sort-arrow">
									  <span class="sort-asc">▲</span>
									  <span class="sort-desc">▼</span>
									</div>
								</div>
							</th>
							<th class="center sort sort-menu" data-sort="menuAmt" style="width: 20%;">
								단가
								<div class="sort-icon">
									<div class="sort-arrow">
									  <span class="sort-asc">▲</span>
									  <span class="sort-desc">▼</span>
									</div>
								</div>
							</th>
							<th class="center sort sort-menu" data-sort="ntslType" style="width: 20%;">
								판매 유형
								<div class="sort-icon">
									<div class="sort-arrow">
									  <span class="sort-asc">▲</span>
									  <span class="sort-desc">▼</span>
									</div>
								</div>
							</th>
						</tr>
					</thead>
					<tbody id="table-body" class="table-error">
					</tbody>
				</table>
				<div class="pagination-wrap">
					<div class="pagination" id="menupage">
					</div>
				</div>
			</div>
		<!-- 테이블 끝 -->
		</div>
      	</div>
      	<!-- 선택 끝 -->
      </div>
<!--       <div class="modal-footer"></div> -->
    </div>
  </div>
</div>
<!-- 가맹점주 모달창 끝 -->