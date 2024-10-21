<%--
 	@fileName    : insertEventCoupon.jsp
 	@programName : 이벤트 쿠폰 발급, 이벤트 상세 확인
 	@description : 사용자가 이벤트 상세를 확인  쿠폰을 발급 받는 화면 
 	@author      : 서윤정
 	@date        : 2024. 09. 11
--%>

<meta name="_csrf" content="${_csrf.token}">
<meta name="_csrf_header" content="${_csrf.headerName}">


<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="tiles" uri="http://tiles.apache.org/tags-tiles"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>
<%@ taglib prefix="sec"
	uri="http://www.springframework.org/security/tags"%>
<script type="text/javascript" src="/resources/js/jquery.min.js"></script>
<link href="/resources/cust/css/selectEventDtl.css" rel="stylesheet">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

<sec:authorize access="isAuthenticated()">
	<sec:authentication property="principal.memberVO" var="user" />
</sec:authorize>

<style>
.content-cont {
    font-size: 1.2rem;
    line-height: 1.4;
}
</style>


<script type="text/javascript">
	let mbrId = "${user.mbrId}";
	// 로그인한 회원만 쿠폰 발급 가능
	function noLogin() {
		Swal.fire({
			icon : "info",
			title : "로그인 후 이용 가능합니다.",
			showConfirmButton : true,
			confirmButtonText : "확인"
		});

	} //noLogin 끝

	function dupChkEventCoupon() {
		let jsonData = {
			"mbrId" : mbrId,
			"couponCode" : $("#couponCode").val(),
			"useYn" : "N",
			"eventNo" : "${param.eventNo}"
		};

		console.log("jsonData : ", jsonData);

		$.ajax({
			url : "/cust/dupChkEventCouponPost",
			type : "post",
			contentType : "application/json;charset=utf-8", // JSON 형식으로 전송
			data : JSON.stringify(jsonData), // JSON 문자열로 변환
			dataType : "json", // 응답받는 데이터 형식을 JSON으로 설정
			beforeSend : function(xhr) {
				xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
			},
			success : function(response) {
				console.log("response : ", response);

				if (response.isDuplicate === "Y") {
					$(".coupon-btn").html("<p>이미 발급 받은 쿠폰입니다.</p>");
					$(".coupon-btn").attr("disabled", true);
				}
			},
			error : function(err) {
				console.log("쿠폰 발급 실패(err): ", err);
			}
		});//end ajax
	}

	$(function() {

		//쿠폰 중복 체크 
		dupChkEventCoupon();

		let isDuplicate = "${isDuplicate}"; //Y(중복됨) or N(중복안됨)

		console.log("isDuplicate : " + isDuplicate);

		$(".coupon-btn")
				.on(
						"click",
						function() {
							console.log("쿠폰 발급 클릭!");

							let jsonData = {
								"mbrId" : mbrId,
								"couponCode" : $("#couponCode").val(),
								"useYn" : "N",
								"eventNo" : "${param.eventNo}"
							};

							console.log("jsonData : ", jsonData);

							$
									.ajax({
										url : "/cust/insertEventCouponPost",
										type : "post",
										contentType : "application/json;charset=utf-8", // JSON 형식으로 전송
										data : JSON.stringify(jsonData), // JSON 문자열로 변환
										dataType : "json", // 응답받는 데이터 형식을 JSON으로 설정
										beforeSend : function(xhr) {
											xhr.setRequestHeader(
													"${_csrf.headerName}",
													"${_csrf.token}");
										},
										success : function(response) {
											console
													.log("response : ",
															response);

											if (response.isDuplicate === "N") {
												Swal.fire({
													icon : 'success',
													title : '쿠폰 발급 완료',
													text : '쿠폰 발급이 완료되었습니다'
												});
												$(".coupon-btn")
														.html(
																"<p>이미 발급 받은 쿠폰입니다.</p>");
												$(".coupon-btn").attr(
														"disabled", true);
											} else {
												Swal
														.fire({
															icon : 'error',
															title : '쿠폰 발급 실패',
															text : '이미 발급된 쿠폰이 있습니다. 마이페이지에서 확인하세요.'
														});
											}
										},
										error : function(err) {
											console.log("쿠폰 발급 실패(err): ", err);
										}
									});//end ajax
						});//end coupon-btn

	}); // 전체 끝
</script>

<div class="wrap menu-wrap">

	<form id="insertEventCouponAjax" action="/cust/insertEventCouponPost"
		method="post">


		<!-- 공통 컨테이너 영역 -->
		<div class="wrap-cont">

			<!-- 공통 타이틀 영역 -->
			<div class="eventDtl-title">
				<span class="icon-backspace material-symbols-outlined"
					onclick="window.location.href='/buff/selectEvent'">keyboard_backspace</span>
				<div class="event-nm">${eventVO.eventTtl}</div>
				<div class="event-date">
					<c:if test="${not empty eventVO.bgngYmd}">
						<c:set var="formattedDate"
							value="${fn:substring(eventVO.bgngYmd, 0, 4)}-${fn:substring(eventVO.bgngYmd, 4, 6)}-${fn:substring(eventVO.bgngYmd, 6, 8)}" />
					</c:if>
					<c:if test="${not empty eventVO.expYmd}">
						<c:set var="formattedExpDate"
							value="${fn:substring(eventVO.expYmd, 0, 4)}-${fn:substring(eventVO.expYmd, 4, 6)}-${fn:substring(eventVO.expYmd, 6, 8)}" />
					</c:if>
					${formattedDate} ~ ${formattedExpDate}
				</div>
			</div>
			<!-- /.wrap-title -->

			<!-- 메뉴 영역 -->
			<div class="eventDtl-content">
				<div class="content-cont">
					<img alt="이벤트이미지" src="/resources/images/eventDtl01.png">
				</div>

				<div class="content-cont">
					${eventVO.eventCn}
										<p>&nbsp;</p>
				</div>
				<c:forEach var="couponGroupVO" items="${eventVO.couponGroupVOList}">
					<c:forEach var="couponVO" items="couponGroupVO.couponVOList">
						<input type="text" id="couponCode" name="couponCode" value="${couponGroupVO.couponCode}" style="display: none" />
						<input type="text" name="mbrId" value="${user.mbrId}" 	style="display: none" />
						<input type="text" name="useYn" value="N" style="display: none" />
						<input type="text" name="eventNo" value="${param.eventNo}" style="display: none" />
						<div class="coupon-cont">
							<div class="coupon-box block left"></div>
							<div class="coupon-box dashed">
								<div class="circle-top"></div>
								<div class="border-dot"></div>
								<div class="circle-bom"></div>
							</div>
							<div class="coupon-box center">

								<div class="coupon-nm">${couponGroupVO.couponNm}</div>

								<div class="coupon-price">${couponGroupVO.dscntAmt}원</div>

								<div class="coupon-btn-wrap">
									<sec:authorize access="isAuthenticated()">
										<div class="coupon-btn" id="btnCoupon">
											쿠폰 다운로드 받기<span class="material-symbols-outlined">download</span>
										</div>
									</sec:authorize>

									<sec:authorize access="isAnonymous()">
										<div class="coupon-btn" onclick="noLogin()">
											쿠폰 다운로드 받기<span class="material-symbols-outlined">download</span>
										</div>
									</sec:authorize>
								</div>
							</div>
							<div class="coupon-box dashed">
								<div class="circle-top"></div>
								<div class="border-dot"></div>
								<div class="circle-bom"></div>
							</div>

							<div class="coupon-box block right"></div>
						</div>
					</c:forEach>
				</c:forEach>
			</div>
			<!-- /.event-content -->

			<div class="view-more">
				<div class="more-btn"
					onclick="window.location.href='/buff/selectEvent'">
					<span class="material-symbols-outlined">add</span>목록으로
				</div>
			</div>
			<!-- /.view-more -->

		</div>
		<!--  /.wrap-cont -->
		<sec:csrfInput />

	</form>

</div>
<!-- wrap -->


<script
	src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>




