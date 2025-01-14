<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<link rel="stylesheet" href="/resources/css/global/common.css">
<link rel="stylesheet" href="/resources/hdofc/css/member.css">
<script src="/resources/js/jquery-3.6.0.js"></script>

<!-- 
로그인 안했을 때 principal.MemberVO 에서 오류 발생
 -->
<sec:authorize access="isAuthenticated()">
	<!-- 로그인 한(isAuthenticated()) 사용자 정보 -->
	<sec:authentication property="principal.MemberVO" var="user"/>
</sec:authorize>

<%--
	@fileName    : selectMemberList.jsp
	@programName : 회원관리 리스트 화면
	@description : 회원관리 리스트 화면
	@author      : 김 현 빈
	@date        : 2024. 10. 10
--%>

<script type="text/javascript">
$(document).ready(function() {
	select2Custom();
	
	// 이벤트 위임을 사용하여 tap-cont 클릭 시 처리
	$(".tap-wrap").on("click", ".tap-cont", function() {
		// 모든 탭에서 active 클래스를 제거
        $(".tap-cont").removeClass("active");

        // 클릭한 탭에만 active 클래스를 추가
        $(this).addClass("active");

        // 선택된 문의 유형을 가져와 셀렉트 박스 값 변경
        let selectedQsType = $(this).data("type");
        $("#delYn").val(selectedQsType);
        
     	// localStorage에 클릭된 탭의 정보를 저장
        localStorage.setItem('selectedQsType', selectedQsType);

        // 폼 자동 제출 (새로고침 방식)
        $("#searchForm").submit();
	});
	
	$("#searchBtn").on("click",function(event){
		let mbrNm = $("#mbrNm").val();
		let rgnNo = $("#rgnNo").val();
		let delYn = $("#delYn").val();
		let bgngYmd = $("#bgngYmd").val();
		let expYmd = $("#expYmd").val();
		let sortJoinYmd = $("#sortJoinYmd").val();
		
		let data = {
			"mbrNm":mbrNm,
			"rgnNo":rgnNo,
			"delYn":delYn, 
			"bgngYmd":bgngYmd, 
			"expYmd":expYmd, 
			"sortJoinYmd":sortJoinYmd
		};
		
		console.log("mbrNm : ", mbrNm);
		console.log("rgnNo: ", rgnNo);
		console.log("delYn: ", delYn);
		console.log("bgngYmd: ", bgngYmd);
		console.log("expYmd: ", expYmd);
		console.log("sortJoinYmd: ", sortJoinYmd);
		
		$("#searchForm").submit();
	});
	
	// 검색영역 초기화
	$('.search-reset').on('click', function(){
		$('.select-selected').text('전체');
		$('#mbrNm').val('');
		$('#rgnNo').val('').trigger('change');
		$('#delYn').val('');
		$('#bgngYmd').val('');
		$('#expYmd').val('');
		$('#sortJoinYmd').val('');
		
	    $('.tap-cont').removeClass('active');
		$('#tap-all').parent().addClass('active');
		
		// 새로고침하여 링크로 이동
	    window.location.href = "/hdofc/member/selectMemberList";
	})
	//.search-reset
	
	// 검색영역 요약보기
	$('.search-toggle').on('click',function(){
		
	   	if ($(this).hasClass('active')){
	   		$(this).removeClass('active');
	   		$('.search-toggle').html(`요약보기<span class="icon material-symbols-outlined">Add</span>`);
	   		$('.search-original').slideDown(300);
	   		$('.search-summary').slideUp(300);
	   	} else {
	   		$(this).addClass('active');
	   		$('.search-toggle').html(`전체보기<span class="icon material-symbols-outlined">Remove</span>`);
	   		$('.search-original').slideUp(300);
	   		$('.search-summary').slideDown(300);
	   	} 
		
	   	/* 아래 부분은 구현하는 페이지에 맞춰서 작성해주세요!! */
		// 인풋 데이터 가져오기
		let mbrNmSearch = $('#mbrNm').val();
		let rgnNoSearch = $('#rgnNo option:selected').text();
		let delYnSearch = $('#delYn').val();
		let bgngYmdSearch = $('#bgngYmd').val();
		let expYmdSearch = $('#expYmd').val();
		let sortSearch = $('#sortJoinYmd').val();
		
		dateStr = `\${bgngYmdSearch} ~ \${expYmdSearch}`;
		
		// 회원명 데이터 입력
		if(mbrNmSearch==''){
			$('#mbrNmSummary').text('전체');
		}else {
			$('#mbrNmSummary').text(mbrNmSearch);
		}
		// 지역 데이터 입력
		if(rgnNoSearch=='' || rgnNoSearch=='지역을 선택해주세요'){
			$('#rgnNoSummary').text('전체');
		}else {
			$('#rgnNoSummary').text(rgnNoSearch);
		}
		// 탈퇴여부 데이터 입력
		if (delYnSearch == 'N') {
			$('#delYnSummary').text('가입');
		} else if (delYnSearch == 'Y') {
			$('#delYnSummary').text('탈퇴');
		} else {
			$('#delYnSummary').text('전체');
		}
		// 가입일자 데이터 입력
		if(bgngYmdSearch=='' && expYmdSearch==''){
			$('#dateSummary').text('전체');
		}else {
			$('#dateSummary').text(dateStr);
		}
		// 가입순서 데이터 입력
		if (sortSearch == 'DESC') {
			$('#sortSummary').text('신규 가입순');
		} else if (sortSearch == 'ASC') {
			$('#sortSummary').text('과거 가입순');
		} else {
			$('#sortSummary').text('전체');
		}
	});
	
});
</script>

<div class="content-header">
	<div class="container-fluid">
 		<div class="row mb-2">
			<div class="col-sm-6">
				<h1 class="m-0">회원 관리</h1>
			</div><!-- /.col -->
		</div><!-- /.row -->
	</div><!-- /.container-fluid -->
</div>

<div class="wrap">
	<form id="searchForm" name="searchForm" action="/hdofc/member/selectMemberList" method="get">
	<div class="search-section">
		<!-- cont: 검색 영역 -->
		<div class="cont search-original" data-select2-id="7">
			<div class="search-wrap" data-select2-id="6">
				<!-- 회원명 검색조건 -->
				<div class="search-cont">
					<p class="search-title">회원명</p>
					<input type="text" id="mbrNm" name="mbrNm" placeholder="검색어를 입력하세요" value="${param.mbrNm}"> 
				</div>
				<!-- 지역 검색조건 -->
				<div class="search-cont">
					<p class="search-title">지역</p>
					<select class="select2-custom select-rgnNo" name="rgnNo" id="rgnNo">
						<option value="">지역을 선택해주세요</option>
						<c:forEach var="rgn" items="${rgn}">
							<option value="${rgn.comNo}" <c:if test="${param.rgnNo eq rgn.comNo}">selected</c:if>>${rgn.comNm}</option>
						</c:forEach>
					</select>
				</div>
				<!-- 탈퇴여부 검색조건 -->
				<div class="search-cont">
					<p class="search-title">탈퇴여부</p>
					<div class="select-custom" style="width:150px">
						<select name="delYn" id="delYn">
							<option value="">전체</option>
							<option value="N"
								<c:if test="${param.delYn == 'N'}">selected</c:if>>가입</option>
							<option value="Y"
								<c:if test="${param.delYn == 'Y'}">selected</c:if>>탈퇴</option>
						</select>
					</div>
				</div>
				<!-- 가입일자 검색조건 -->
				<div class="search-cont">
					<p class="search-title">가입일자</p>
					<div class="search-date-wrap">
						<input type="date" id="bgngYmd" name="bgngYmd" value="${param.bgngYmd}"> 
							~ 
						<input type="date" id="expYmd" name="expYmd" value="${param.expYmd}">
					</div>
				</div>
				<!-- 가입일자 sort정렬 -->
				<div class="search-cont">
					<p class="search-title">가입순서</p>
					<div class="select-custom" style="width:150px">
						<select name="sortJoinYmd" id="sortJoinYmd">
							<option value="DESC"
								<c:if test="${param.sortJoinYmd == 'DESC'}">selected</c:if>>신규 가입순</option>
							<option value="ASC"
								<c:if test="${param.sortJoinYmd == 'ASC'}">selected</c:if>>과거 가입순</option>
						</select>
					</div>
				</div>
			</div>
			<!-- /.search-wrap -->
		</div>
		<!-- /.cont: 검색 영역 -->
		
		<!-- cont:  검색 접기 영역 -->
		<div class="cont search-summary">
			<div class="search-wrap">
				<!-- 회원명 검색조건 -->
				<div class="search-cont">
					<p class="search-title">회원명 <span class="summary" id="mbrNmSummary">회원명</span></p>
				</div>
				<div class="divide-border"></div>
				<!-- 지역 검색조건 -->
				<div class="search-cont">
					<p class="search-title">지역 <span class="summary" id="rgnNoSummary">지역</span></p>
				</div>
				<div class="divide-border"></div>
				<!-- 탈퇴여부 검색조건 -->
				<div class="search-cont">
					<p class="search-title">탈퇴여부 <span class="summary" id="delYnSummary">탈퇴여부</span></p>
				</div>
				<div class="divide-border"></div>
				<!-- 가입일자 검색조건 -->
				<div class="search-cont">
					<p class="search-title">가입일자 <span class="summary" id="dateSummary">가입일자</span></p>
				</div>
				<div class="divide-border"></div>
				<!-- 가입일자 검색조건 -->
				<div class="search-cont">
					<p class="search-title">가입순서 <span class="summary" id="sortSummary">가입순서</span></p>
				</div>
			</div>
			<!-- /.search-wrap -->
		</div>
		<!-- /.cont: 검색 영역 -->
		
		<!-- 검색 버튼 영역 -->
		<div class="search-control">
			<div class="search-control-btns">
				<div class="search-toggle">
					요약보기<span class="icon material-symbols-outlined">Add</span>
				</div>
				<div class="search-reset">
					초기화<span class="icon material-symbols-outlined">restart_alt</span>
				</div>
				<div>
					<button class="btn btn-default search" id="searchBtn">검색 <span class="icon material-symbols-outlined">search</span></button>
				</div>		
			</div>
		</div>
		<!-- /.검색 버튼 영역 -->
		<!-- /.search-section: 검색어 영역 -->
	</div>
	</form>
	
	<div class="cont">
<!-- 		<div class="cont-title">회원 목록</div>  -->
		<!-- table-wrap -->
		<div class="table-wrap">
			<div class="tap-wrap">
				<div data-type="" class="tap-cont ${param.delYn == null || param.delYn == '' ? 'active' : ''}">
					<span class="tap-title">전체</span>
					<span class="bge bge-default" id="tap-all">${tapMaxTotal.TAPALL}</span>
				</div>
				<div data-type="N" class="tap-cont ${param.delYn == 'N' ? 'active' : ''}">
					<span class="tap-title">가입</span>
					<span class="bge bge-active" id="tap-waiting">${tapMaxTotal.TAPWAITING}</span>
				</div>
				<div data-type="Y" class="tap-cont ${param.delYn == 'Y' ? 'active' : ''}">
					<span class="tap-title">탈퇴</span>
					<span class="bge bge-danger" id="tap-progress">${tapMaxTotal.TAPPROGRESS}</span>
				</div>
			</div>
			<table class="table-default">
				<thead>
					<tr>
						<th class="center">번호</th>
						<th class="center">이름</th>
						<th class="center">아이디</th>
						<th class="center">생년월일</th>
						<th class="center">연락처</th>
						<th class="center">가입일자</th>
<!-- 						<th class="center sort active" data-sort="wrtrDtSort" style="width: 100px"> -->
<!-- 							가입일자 -->
<!-- 							<div class="sort-icon"> -->
<!-- 								<div class="sort-arrow"> -->
<!-- 									<span class="sort-asc active">▲</span> -->
<!-- 									<span class="sort-desc">▼</span> -->
<!-- 								</div> -->
<!-- 							</div> -->
<!-- 						</th> -->
						<th class="center">탈퇴여부</th>
					</tr>
				</thead>
				<c:choose>
					<c:when test="${empty articlePage.content}">
						<tbody id="table-body" class="table-error">
							<tr>
								<td class="error-info" colspan="7">
									<span class="icon material-symbols-outlined">error</span>
									<div class="error-msg">검색 결과가 없습니다</div>
								</td>
							</tr>
						</tbody>
					</c:when>
					
					<c:otherwise>
						<tbody>
							<c:forEach var="memberVOList" items="${articlePage.content}" varStatus="stat">
								<tr onclick="window.location='/hdofc/member/selectMemberDetail?mbrId=${memberVOList.mbrId}'">
									<td class="center">${memberVOList.rnum}</td>
									<td class="center">${memberVOList.mbrNm}</td>
									<td class="center">${memberVOList.mbrId}</td>
									<td class="center">
										<c:out value="${fn:substring(memberVOList.mbrBrdt, 0, 4)}-${fn:substring(memberVOList.mbrBrdt, 4, 6)}-${fn:substring(memberVOList.mbrBrdt, 6, 8)}" />
									</td>
									<td class="center">
										<c:out value="${fn:substring(memberVOList.mbrTelno, 0, 3)}-${fn:substring(memberVOList.mbrTelno, 3, 7)}-${fn:substring(memberVOList.mbrTelno, 7, 11)}" />
									</td>
									<td class="center">
										<c:out value="${fn:substring(memberVOList.joinYmd, 0, 4)}-${fn:substring(memberVOList.joinYmd, 4, 6)}-${fn:substring(memberVOList.joinYmd, 6, 8)}" />
									</td>
									<td class="center">
										<c:choose>
									        <c:when test="${memberVOList.delYn == 'N'}">
									            <span class="bge bge-active">가입</span>
									        </c:when>
									        <c:when test="${memberVOList.delYn == 'Y'}">
									            <span class="bge bge-danger">탈퇴</span>
									        </c:when>
									        <c:otherwise>
									            <span class="bge">미확인</span> <!-- 예외 처리용 (optional) -->
									        </c:otherwise>
									    </c:choose>
									</td>
								</tr>
							</c:forEach>
						</tbody>
					</c:otherwise>
				</c:choose>
					
			</table>
			<!-- pagination-wrap -->
			<c:if test="${not empty articlePage.content}">
				<div class="pagination-wrap">
					<div class="pagination">
						<c:if test="${articlePage.startPage gt 5}">
							<a href="/hdofc/member/selectMemberList?mbrNm=${param.mbrNm}&rgnNo=${param.rgnNo}&delYn=${param.delYn}&bgngYmd=${param.bgngYmd}&expYmd=${param.expYmd}&sortJoinYmd=${param.sortJoinYmd}&currentPage=${articlePage.startPage-5}" class="page-link">
								<span class="icon material-symbols-outlined">chevron_left</span>
							</a>
						</c:if>
						<!-- 선택한 페이지만 class="active"가 설정되게 한다 -->
						<c:forEach var="pNo" begin="${articlePage.startPage}" end="${articlePage.endPage}">
							<a href="/hdofc/member/selectMemberList?mbrNm=${param.mbrNm}&rgnNo=${param.rgnNo}&delYn=${param.delYn}&bgngYmd=${param.bgngYmd}&expYmd=${param.expYmd}&sortJoinYmd=${param.sortJoinYmd}&currentPage=${pNo}" class="page-link 
		        				<c:if test="${pNo == articlePage.currentPage}">active</c:if>">
		        				${pNo}
		    				</a>
						</c:forEach>
						<!-- endPage < totalPages일때만 [다음] 활성 -->
						<c:if test="${articlePage.endPage lt articlePage.totalPages}">
							<a href="/hdofc/member/selectMemberList?mbrNm=${param.mbrNm}&rgnNo=${param.rgnNo}&delYn=${param.delYn}&bgngYmd=${param.bgngYmd}&expYmd=${param.expYmd}&sortJoinYmd=${param.sortJoinYmd}&currentPage=${articlePage.startPage+5}" class="page-link">
								<span class="icon material-symbols-outlined">chevron_right</span>
							</a>
						</c:if>
					</div>
				</div>
			</c:if>
			<!-- pagination-wrap -->
		</div>
		<!-- table-wrap -->
	</div>
</div>