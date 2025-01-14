<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<meta name="_csrf" content="${_csrf.token}">
<meta name="_csrf_header" content="${_csrf.headerName}">
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script src="/resources/js/jquery-3.6.0.js"></script>
<link href="/resources/cnpt/css/main.css" rel="stylesheet">
<script src="/resources/cnpt/js/main.js"></script>
<script>
let bzentNo = '${bzentNo}';
console.log("bzentNo : ", bzentNo);
let currentPage = 1;
const size = 4;
let deliType = 'DELI04';
let sort = 'poNo';
let orderby = 'desc';
let type = 'po';
// 매출 조회 시 사용.
let period = 'year';

const csrfToken = document.querySelector('meta[name="_csrf"]').getAttribute('content');
const csrfHeader = document.querySelector('meta[name="_csrf_header"]').getAttribute('content');

$(document).ready(function(){
	
	// 거래처 재고 확인
 	checkStock();
	
	let totalAmt = parseInt("${totalAmt}") || 0;
	console.log("초기 totalAmt : ", totalAmt);
	
	
	// 초기 매출 데이터 로드
	loadSalesData('year');
	loadProductSalesData('year');
	$("#yearChartTitle").show();
	
	// 페이지 로드 시 미승인 발주 내역을 가져오는 함수 호출
    selectDealAjax();

    // 페이지 링크 클릭 시 이벤트 처리
    $(document).on('click', '.page-link', function (e) {
        e.preventDefault();  // 페이지 새로고침 방지
        currentPage = $(this).data('page');  // 선택한 페이지 번호 설정
        selectDealAjax();  // 해당 페이지의 데이터 로드
    });

    // 테이블 행 클릭 시 상세 페이지 이동
    $(document).on('click', '.dealDtl', function () {
        const poNo = $(this).data('no');  // 발주 번호 가져오기
        location.href = '/cnpt/deal/dtl?poNo=${poNo}';  // 상세 페이지로 이동
    });
	
	
	// 라디오 버튼 변경시 매출 데이터 가져오기
	$('input[name="period"]').change(function(){
		const selectedPeriod = $(this).val();
		console.log("선택된 기간: ", selectedPeriod);
		
		// 선택된 기간에 따라 데이터 로드
		loadSalesData(selectedPeriod);
		loadProductSalesData(selectedPeriod);
		
		// 차트 제목 표시 설정
		$("#yearChartTitle").hide();
		$("#monthChartTitle").hide();
		$("#dayChartTitle").hide();
		
		if(selectedPeriod === 'day'){
			$("#dayChartTitle").show();
		} else if(selectedPeriod === 'month'){
			$("#monthChartTitle").show();
		} else if(selectedPeriod === 'year'){
			$("#yearChartTitle").show();
		}
		
		// 선택된 라디오 버튼의 상태를 체크
        $('input[name="period"][value="' + selectedPeriod + '"]').prop('checked', true);
		
	});
	
	// 기본적으로 'year'를 선택
    $('input[name="period"][value="year"]').prop('checked', true);
	
 	// 상세로 이동
	$(document).on('click','.dealDtl',function(){
		let poNo = $(this).data('no');
		location.href='/cnpt/deal/dtl?poNo='+poNo;
	})
	

	
})
</script>


<div class="wrap home-wrap">
	<div class="crow">
		<!--  
		<div class="main-cont w350 fcol" style="width: 400px; justify-content: space-evenly;">
			<div class="cont-title" style="position:relative; bottom:12px;">상품 관리</div>
				<div class="btnBox-wrap2">
					<div class="fcol" style="width:300px;">
						<div class="frow btnBox-cont2" onclick="location.href='/cnpt/gds/list'" style="width:356px;">
							<div class="btnBox-dtl2">
								<div class="btnBox-num">
									<fmt:formatNumber value="${cnt.sellingCnt}" type="number" groupingUsed="true"/>
								</div>
								<div class="btnBox-title2">판매중 상품 수</div>
							</div>
							<div class="btnBox-icon">
								<span class="material-symbols-outlined icon-cnt">shopping_cart</span>
							</div>
						</div>
						<div class="frow btnBox-cont2" onclick="location.href='/cnpt/gds/list'" style="width:356px;">
							<div class="btnBox-dtl2">
								<div class="btnBox-num">
									<fmt:formatNumber value="${cnt.notSellingCnt}" type="number" groupingUsed="true"/>
								</div>
								<div class="btnBox-title2">미판매 상품 수</div>
							</div>
							<div class="btnBox-icon">
								<span class="material-symbols-outlined icon-cnt">shopping_cart_off</span>
							</div>
						</div>
					</div>
				</div>
		</div>
		-->
		
		<div class="fcol main-cont back-green">
			<div class="cont-title">상품 관리</div>
			<!-- amt-cont시작 -->
			<div class="amt-cont" onclick="window.location.href='/cnpt/sls/selectSales'">
				<div class="amt-cont-dtl">
					<div class="amt-title">
						판매중 상품 수
					</div>
					<div class="amt-dtl">
						<p class="amt-amt">
							 <fmt:formatNumber value="${cnt.sellingCnt}" type="number" groupingUsed="true"/>
						</p>
					</div>
				</div>
				<!-- amt-cont-dtl끝 -->
				<div class="amt-icon">
					<span class="material-symbols-outlined icon-amt" style="color: var(--bge--active)">shopping_cart</span>
				</div>
			</div>
			<!-- amt-cont끝 -->
			<div class="amt-cont">
				<div class="amt-cont-dtl">
					<div class="amt-title">
						미판매 상품 수
					</div>
					<div class="amt-dtl">
						<p class="amt-amt">
						 	<fmt:formatNumber value="${cnt.notSellingCnt}" type="number" groupingUsed="true"/>
						</p>
					</div>
				</div>
				<!-- amt-cont-dtl끝 -->
				<div class="amt-icon">
					<span class="material-symbols-outlined icon-amt" style="color: var(--bge--active)">shopping_cart_off</span>
				</div>
			</div>
			<!-- amt-cont끝 -->
		</div>
		
		<!-- 상품 및 발주 끝 -->
		
		<!-- 최근 1년 매출 -->
		<div class="fcol main-cont back-red">
			<div class="cont-title">최근 1년간 내역</div>
			<!-- amt-cont시작 -->
			<div class="amt-cont" onclick="window.location.href='/cnpt/sls/selectSales'">
				<div class="amt-cont-dtl">
					<div class="amt-title">
						매출 금액
					</div>
					<div class="amt-dtl">
						<p class="amt-amt">
							 <fmt:formatNumber value="${totalAmt}" type="number" groupingUsed="true"/>
						</p>
						<p> 원</p>
					</div>
				</div>
				<!-- amt-cont-dtl끝 -->
				<div class="amt-icon">
					<span class="material-symbols-outlined icon-amt" style="color: #fbe1e1">trending_up</span>
				</div>
			</div>
			<!-- amt-cont끝 -->
			<div class="amt-cont">
				<div class="amt-cont-dtl">
					<div class="amt-title">
						미정산 금액
					</div>
					<div class="amt-dtl">
						<p class="amt-amt">
							 <fmt:formatNumber value="${totalNotClclnAmt}" type="number" groupingUsed="true"/>
						</p>
						<p> 원</p>
					</div>
				</div>
				<!-- amt-cont-dtl끝 -->
				<div class="amt-icon">
					<span class="material-symbols-outlined icon-amt" style="color: #fbe1e1">toll</span>
				</div>
			</div>
			<!-- amt-cont끝 -->
		</div>
		
		
		<!-- 상품 및 발주 -->
	<div class="main-cont fcol" style="width: -webkit-fill-available;">
		<div class="cont-title">납품 현황</div>
			<div class="btnBox-wrap">
			<!-- fcol시작 -->
				<div class="fcol w-fill">
					<div class="frow btnBox-cont" onclick="location.href='/cnpt/deal/list'">
						<div class="btnBox-dtl">
							<div class="btnBox-title">승인대기 건수</div>
							<div class="btnBox-num">
								<fmt:formatNumber value="${cnt.waitApproveCnt}" type="number" groupingUsed="true"/>
							</div>
						</div>
						<div class="btnBox-icon">
							<span class="material-symbols-outlined icon-cnt">hourglass_empty</span>
						</div>
					</div>
					
					<div class="frow btnBox-cont">
						<div class="btnBox-dtl">
							<div class="btnBox-title">배송완료 건수</div>
							<div class="btnBox-num" onclick="location.href='/cnpt/deal/list'">
								<fmt:formatNumber value="${cnt.deliCompleteCnt}" type="number" groupingUsed="true"/>
							</div>
						</div>
						<div class="btnBox-icon">
							<span class="material-symbols-outlined icon-cnt">package_2</span>
						</div>
					</div>
				</div>
				<!-- fcol끝 -->
			
			<!-- fcol시작 -->
				<div class="fcol w-fill">
					<div class="frow btnBox-cont" onclick="location.href='/cnpt/deal/list'">
						<div class="btnBox-dtl">
							<div class="btnBox-title">미승인 건수</div>
							<div class="btnBox-num">
								<fmt:formatNumber value="${cnt.notApproveCnt}" type="number" groupingUsed="true"/>
							</div>
						</div>
						<div class="btnBox-icon">
							<span class="material-symbols-outlined icon-cnt">hourglass_disabled</span>
						</div>
					</div>
					
					<div class="frow btnBox-cont" onclick="location.href='/cnpt/deal/list'">
						<div class="btnBox-dtl">
							<div class="btnBox-title">배송중 건수</div>
							<div class="btnBox-num">
								<fmt:formatNumber value="${cnt.deliIngCnt}" type="number" groupingUsed="true"/>
							</div>
						</div>
						<div class="btnBox-icon">
							<span class="material-symbols-outlined icon-cnt">local_shipping</span>
						</div>
					</div>
				</div>
			</div>
			<!-- fcol끝 -->
		</div>
	</div>
	<!-- 3번째줄 매출 -->
	<div class="">
		<!-- 매출 금액 -->
		<div class="main-cont sls-chart">
			<!-- 매출 차트 -->
			<div class="fcol" style="flex-grow: 1; padding: var(--gap--s);">
				<!-- cont-title시작 -->
				<div class="cont-title">
					<!-- sls-wrap시작 -->
					<div class="sls-wrap">
						<!-- sls-cont시작 -->
						<div class="sls-cont">
							<div class="sls-icon">
								<span class="material-symbols-outlined">send_money</span>
							</div>
							<div class="sls-dtl">
								<div class="sls-title">기간별 매출</div>
								<div class="sls-cn" id="totalAmt"></div>
							</div>
						</div>
						<!-- sls-cont 끝 -->
						
					</div>
					<!-- sls-wrap 끝 -->
				</div>
				<!-- cont-title -->
				
				<div class="sls-chart">
					<div class="ordr-chart">
						<canvas id="myChart" style="display: block; box-sizing: border-box; height: 300px; width: 100%;">
						</canvas>
					</div>
				</div>	
			</div>
			<!-- 매출차트 끝 -->
			
			<!-- 상품별 매출 +radio -->
			<div class="fcol">
				<div class="radio">
					<div class="form_toggle row-vh d-flex flex-row" style="gap:var(--gap--s);">
						<div class="form_radio_btn radio_male">
							<input id="radio-day" type="radio" name="period" value="day">
							<label for="radio-day">일간</label>
						</div>
						<div class="form_radio_btn">
							<input id="radio-month" type="radio" name="period" value="month">
							<label for="radio-month">월간</label>
						</div>
						<div class="form_radio_btn">
							<input id="radio-year" type="radio" name="period" value="year" checked>
							<label for="radio-year">년간</label>
						</div>
					</div>
				</div>
				
				<div class="cont-title">
					<div class="table-title">
						<div class="cont-title chart-title" id="yearChartTitle" style="display: none">
					        <span class="material-symbols-outlined title-icon">bar_chart</span><p id="chart-title-text">년간 상품 매출 현황</p>
					    </div>
						<div class="cont-title chart-title" id="monthChartTitle" style="display: none">
					        <span class="material-symbols-outlined title-icon">bar_chart</span><p id="chart-title-text">월간 상품 매출 현황</p>
					    </div>
						<div class="cont-title chart-title" id="dayChartTitle" style="display: none">
					        <span class="material-symbols-outlined title-icon">bar_chart</span><p id="chart-title-text">월간 상품 매출 현황</p>
					    </div>
					</div>
				</div>
				<div class="gds-chart" style="position: relative; bottom:35px;">
					<canvas id="gdsChart" width="300" height="210"></canvas>
				</div>
			</div>
			<!-- radio끝 -->
			
		</div>
		<!-- 매출끝 -->
	</div>
<!-- wrap 끝 -->	
</div>

