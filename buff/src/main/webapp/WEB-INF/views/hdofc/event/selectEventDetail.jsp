<%--
 	@fileName    : selectEventDetail
 	@programName : 이벤트 상세
 	@description : 이벤트 상세를 위한 페이지
 	@author      : 정기쁨
 	@date        : 2024. 09. 20
--%>
<meta name="_csrf" content="${_csrf.token}">
<meta name="_csrf_header" content="${_csrf.headerName}">
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="tiles" uri="http://tiles.apache.org/tags-tiles" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<link rel="stylesheet" href="/resources/hdofc/css/event.css"/>
<link rel="stylesheet" href="/resources/css/sweetalert2.min.css">

<sec:authentication property="principal.memberVO" var="user"/>
<c:forEach var="couponGroupVO" items="${eventVO.couponGroupVOList}">
	<c:set var="couponCode" value="${couponGroupVO.couponCode}"></c:set>
	<c:set var="couponNm" value="${couponGroupVO.couponNm}"></c:set>
	<c:set var="dscntAmt" value="${couponGroupVO.dscntAmt}"></c:set>
	<c:set var="issuQty" value="${couponGroupVO.issuQty}"></c:set>
	<c:set var="menuNm" value="${couponGroupVO.menuVO.menuNm}"></c:set>
	<c:set var="menuNo" value="${couponGroupVO.menuVO.menuNo}"></c:set>
</c:forEach>

<script type="text/javascript">
var mbrNm = '';
var wrtrYmd = '';
var eventTtl = '';
var bgngYmd = '';
var expYmd = '';
var couponNm = '';
var dscntAmt = '';
var issuQty = '';
var menuNm = '';
var menuNo = '';
var eventCn = '';
var eventNo = '';
var mbrNm = '';
var menuType = '';
var evnetNo = '';
var mngrId = '';
var str = '';
var sn = '';
const urlEventNo = '${param.eventNo}';
let deleteFileGroupNo = '';
const originalEventCn = '${eventVO.eventCn}';
var fileGroupNo = '';
var imgLocation;
var saveFiles = [];

$(function(){
	/* CKEditor5 시작 -------------------------------------------------------------------------*/
	ClassicEditor.create( document.querySelector('#TEXTAREATEMP'),{ckfinder:{uploadUrl:'/image/upload?${_csrf.parameterName}=${_csrf.token}'}})
		.then(editor=>{
			window.editor=editor;
			if (${param.eventNo != null}) {
				window.editor.setData(originalEventCn);
				editor.enableReadOnlyMode('TEXTAREATEMP');
		   }
		})
		.catch(err=>{console.error(err.stack);});
	$(".ck-blurred").keydown(function(){
		console.log("str : "+window.editor.getData());
		$("#eventCn").val(window.editor.getData());
	})
	
	$(".ck-blurred").on("focusout",function(){ // CKEditor로부터 커서 및 마우스 이동 시 마지막 단어까지 출력 되도록 처리
		$("#eventCn").val(window.editor.getData());
	})
	/* CKEditor5 끝 */
	
	/* 일반관리자: 등록 페이지 시작  ****************************************************************************/
	// 시작 날짜의 최소값을 오늘 날짜 + 1로 설정
	$('#bgngYmd').attr('min', new Date(new Date().setDate(new Date().getDate() + 1)).toISOString().substring(0, 10));
	$('#expYmd').on('click', function() {
	    if (!$('#bgngYmd').val()) {
	        // 클릭 이벤트를 막음
	        event.preventDefault();
	        $(this).css('cursor','not-allowed');
	    } else {
	    	$(this).css('cursor','default');
	        // 종료 날짜의 최소값을 시작일자 + 1로 설정
	        let bgngYmd = new Date($('#bgngYmd').val());
	        bgngYmd.setDate(bgngYmd.getDate() + 1);
	        $(this).attr('min', bgngYmd.toISOString().substring(0, 10));
	    }
	});
	
	if(urlEventNo==0){
		$('#uploadFile').css('display','block'); // 파일업로드 인풋박스 보이기
	}
	
	$('#resetBtn').on('click',function(){ // 초기화 버튼 클릭 시
		$('#eventTtl, #bgngYmd, #expYmd, #couponNm, #dscntAmt, #issuQty, #menuNm').val('');
		// CKEditor
		$("#eventCn").val(window.editor.getData());
		if (window.editor) { // 에디터 활성화
			window.editor.setData(originalEventCn);
	    } 
	})
	
	$('#submitBtn').on('click',function(){ // 이벤트 등록 저장 클릭 시
		mngrId = '${user.mbrId}';
		eventCn = $("#eventCn").val(window.editor.getData());
		//console.log("eventCn ->",eventCn);
		eventInsert();
	})
	/* 일반관리자: 등록 페이지 끝 */
	
	/* 일반관리자: 상세 페이지 시작 ****************************************************************************/	
	eventNo = '${param.eventNo}';
	selectFileImgList(eventNo); // 첨부파일 이미지 불러오기 이벤트
	menuModalAjax(); // 메뉴 모달페이지 이벤트
	selectCouponList(); // 쿠폰 발급 리스트 이벤트

	// 테이블 탭-------------------------------------------------------------------------------------------- */
	$('.page-tap-cont').on('click', function(){
		// 모든 tap-cont에서 active 클래스를 제거
	    $('.page-tap-cont').removeClass('active');
	    // 클릭된 tap-cont에 active 클래스를 추가
	    $(this).addClass('active');
	})
	
	$('.page-tap-cont.coupon').on('click', function(){ // 이벤트 상세 관리 보이기
	    $('.coupon-detail').css('display','table');
	    $('.event-detail').css('display','none');
	})
	
	$('.page-tap-cont.event').on('click', function(){ // 쿠폰 발급 조회 보이기
	    $('.event-detail').css('display','table');
	    $('.coupon-detail').css('display','none');
	})
	
	// 이벤트 상세 정보 인풋 비활성화
	if (${param.eventNo != null}) {
		$('.updateFile').css('display','none');
		$('#menuBtn').css({
			'pointer-events':'none',
			'background-color':'var(--gray--1)',
			'color':'var(--text--primary)'
		});
		$('#menuBtn').find('.icon').css('color','var(--text--primary)');
		$('#eventTtl, #bgngYmd, #expYmd, #couponNm, #dscntAmt, #issuQty').attr('disabled', true);
    }
	
	// 메뉴 모달창-------------------------------------------------------------------------------------------- */
	$('.tap-cont').on('click', function(){
		// 모든 tap-cont에서 active 클래스를 제거
	    $('.tap-cont').removeClass('active');
	    // 클릭된 tap-cont에 active 클래스를 추가
	    $(this).addClass('active');
	    menuType = $(this).data('type');
	    //console.log(menuType);
	    menuModalAjax();
	})
	
	// 메뉴 tr 클릭 시 menuNo 가져오기
	$(document).on('click','#menuNo',function(){
		$('#menuNm').val($(this).data('nm'));
		$('#menuNo').val($(this).data('no'));
	})
	/* 메뉴 모달창 끝 */
	
	/* 이벤트 수정-------------------------------------------------------------------------------------------- */
	$('#modifyHM01').on('click',function(){ 
		$('.modify').css('display','none'); // 수정버튼 숨기기
		$('.modifing').css('display','block'); // 취소, 저장버튼 보이기
		$('.deleteFile').css('display','table-row');
		$('.selectFile').css('display','none');

		/* if($('.fileDelete').data('fileGroupNo')>0){
			$('.fileDelete').css('display','block'); // 파일 삭제 버튼 보이기
		} else{
			$('.updateFile').css('display','table-row'); // 파일업로드 인풋박스 보이기
		} */
		
		// 메뉴 선택 버튼 보이기
		$('#menuBtn').css({
			'pointer-events':'auto',
			'background-color':'var(--gray--0)',
			'color':'var(--text--secondary)'
		});
		$('#menuBtn').find('.icon').css('color','var(--text--secondary)');
		// 인풋 입력 활성화
		$('#eventTtl, #bgngYmd, #expYmd, #couponNm, #dscntAmt, #issuQty').removeAttr('disabled', true);

		// CKEditor
		$("#eventCn").val(window.editor.getData());
		if (window.editor) { // 에디터 활성화
			window.editor.disableReadOnlyMode('TEXTAREATEMP');
			window.editor.setData("${eventVO.eventCn}");
	    } 
		$(".ck-blurred").keydown(function(){
			console.log("str : "+window.editor.getData());
			$("#eventCn").val(window.editor.getData());
		})
		$(".ck-blurred").on("focusout",function(){ // CKEditor로부터 커서 및 마우스 이동 시 마지막 단어까지 출력 되도록 처리
			$("#eventCn").val(window.editor.getData());
		})
	});
	
	// 파일 삭세 버튼 클릭 시
	$(document).on('click','.fileDelete',function(){ 
		$('.deleteFile').css('display','none');
		$('.updateFile').css('display','table-row'); // 파일업로드 인풋박스 보이기
		$('.file-wrap').css('display','none'); // 이미지 영역 숨김
		deleteFileGroupNo = $('.fileDelete').data('fileGroupNo'); // let 변수에 파일그룹번호 재할당. 
	})
	
	/* 수정 취소-------------------------------------------------------------------------------------------- */
	$('#cancleHM01').on('click',function(){
		$('.file-wrap').css('display','block');
		$('.updateFile').css('display','none');
		$('#eventTtl, #bgngYmd, #expYmd, #couponNm, #dscntAmt, #issuQty').attr('disabled', true);
		$('.modifing').css('display','none');
		$('.modify').css('display','block');
		$('.selectFile').css('display','table-row');
		$('.deleteFile').css('display','none');
		// CKEditor
		if (window.editor) { 
			window.editor.enableReadOnlyMode('TEXTAREATEMP'); // 읽기 모드
			window.editor.setData(originalEventCn);
	    } 
	});
	
	/* 수정 내용 저장-------------------------------------------------------------------------------------------- */
	$('#submitHM01').on('click',function(){ 
		eventNo = '${param.eventNo}';
		menuNo = $('#menuNo').val();
		updateEventDtlAjax(); // 이벤트 수정 이벤트
	});
	
	/* 이벤트 삭제-------------------------------------------------------------------------------------------- */
	$('#deleteHM01').on('click',function(){
		eventNo = '${param.eventNo}';
		fileGroupNo = '${eventVO.fileGroupNo}';
		eventDelete();		
	});
	
	/* 일반관리자: 상세 페이지 끝 */
	
	/* 최상위관리자: 상세 페이지 시작  ****************************************************************************/	
	$('#aprvYn').on('change',function(){ // 승인여부 셀렉트 박스 중 반려 클릭 시
		if($(this).val()=='N'){
			$('#rjctRsn').css('display','block');
		}else {
			$('#rjctRsn').css('display','none');
		}
	});
 	$('#resetHM02').on('click',function(){ // 초기화 클릭 시
 		$('#aprvYn').val('');
 		$('#rjctRsn').val('');
 		$('#rjctRsn').css('display','none');
 	})
 	$('#submitHM02').on('click',function(){ // 저장버튼 클릭 시
 		eventNo = '${param.eventNo}';
 		updateEventAjax(); // 승인/반려 업데이트 이벤트
 	})
 	/* 최상위관리자: 상세 페이지 끝  */	
	
	// 파일 다운로드
	$('.downloadBtn').on('click',function(){
		fileSaveLocate = $(this).data('fileLocate');
		fileOriginalName = $(this).data('fileName');
		console.log(fileSaveLocate);
		console.log(fileOriginalName);
		fileDownloadAjax(fileSaveLocate, fileOriginalName);
	})

	// 이미지 파일 선택 버튼 클릭 시
	$('#mainImgBtn').on('click',function(){
		// '_buff_event_main'이 포함된 파일 삭제
	    saveFiles = saveFiles.filter(save => {
	        return !save.name.includes('_buff_event_main');
	    });
		// 버튼 위치 가져오기
		 imgLocation  = $(this).data('imgLocation');
		// 인풋 파일 실행하기
		$('#uploadFile').click();
	})

	// 이미지 파일 선택 버튼 클릭 시
	$('#dtlImgBtn').on('click',function(){
		//'_buff_event_detail'이 포함된 파일 삭제
	    saveFiles = saveFiles.filter(save => {
	        return !save.name.includes('_buff_event_detail');
	    });
		
		// 버튼 위치 가져오기
		imgLocation  = $(this).data('imgLocation');
		// 인풋 파일 실행하기
		$('#uploadFile').click();
	})
	
	// 파일 이미지 선택 시 이름 가져오기
	$('#uploadFile').on('change', function() {
	    const fileName = $(this).val().split('\\').pop(); // 파일 경로에서 파일 이름만 가져옴
	    const imgExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp']; // 이미지 확장자 목록
		
		const originfile = this.files[0];
		
	    // 확장자 추출
	    const fileExtension = originfile.name.split('.').pop().toLowerCase();

	    // 이미지 파일인지 확인
	    if (!imgExtensions.includes(fileExtension)) {
	    	var Toast = Swal.mixin({
    		  toast: true,
    		  position: 'center',
    		  showConfirmButton: false,
    		  timer: 3000 //3초간 유지
    		});
    		
    		Toast.fire({
    			icon:'warning',
    			title:'이미지 파일이 아닙니다'
    		});
	        return; // 이미지가 아닐 경우 리턴
	    }
	   	
	 	// 파일 이름 표시하기
	    if (fileName) {
	    	console.log()
	        $('#' + imgLocation + 'Img').text(fileName);
	    } else {
	        $('#' + imgLocation + 'Img').text("선택된 파일이 없습니다.");
	    }
	    
	   	// 원본 파일 이름 가져오기
	   	newName = originfile.name.slice(0, -4) + '_buff_event_' + imgLocation;
	   	// 원본 파일 타입 문자열로 가져오기
	   	fileType = originfile.name.substr(-4);
	   	
	   	// 새로운 파일 생성
	   	const newFile = new File([originfile], newName + fileType, { type: originfile.type });
	   	
	    // 파일 리스트에 추가함
		saveFiles.push(newFile);
		
		for (var i = 0; i < saveFiles.length; i++) {
		    var file = saveFiles[i];
		}

	    console.log("saveFiles -> ",saveFiles);
	    
	});
 	
 	// 이벤트 미리 작성
 	$('#eventWrite').on('click',function(){
 		$('#eventTtl').val('이벤트 등록');
 		$('#bgngYmd').val('2024-10-22');
 		$('#expYmd').val('2024-11-22');
 		$('#couponNm').val('이벤트 쿠폰 등록');
 		$('#dscntAmt').val('2000');
 		$('#issuQty').val('999');
 		
 		let str = `
 			<b>더블 비프 치~즈 버거 이벤트</b>를 통해 고소한 치즈와 두툼한 비프 패티가 더블로 들어간 맛있는 버거를 놀라운 가격에 즐길 수 있는 기회! 친구나 가족과 함께 방문해서 더블의 맛을 경험해 보세요.
 			<br><br>
 			1. 이벤트 내용
 			<br><br>
 			이벤트 메뉴: 더블 비프 치즈 버거
 			<br>
 			할인 쿠폰: 더블 비프 치즈 버거 할인
 			<br>
 			할인 가격: 1,200원 할인
 			<br>
 			이용 가능한 매장: 전국 buff 매장
 			<br><br>
 			2. 이벤트 기간
 			<br><br>
 			이벤트는 10월 31일까지 진행되며, 매장 사정에 따라 조기 종료될 수 있습니다.
 			<br><br>
 			지금 바로 buff에 방문해서 더블의 맛을 느껴보세요!
 		`;
		if (window.editor) { // 에디터 활성화
			window.editor.setData(str);
	    } 
 	});
	
})

// 세션 객체를 이용하여 리스트 페이지로 이동
function moveList(){
	sessionValue = sessionStorage.getItem('sessionValue');
	window.location.href = '/hdofc/event/selectEventList?dtlEventType=' + sessionValue;
}

</script>

<!-- content-header: 이벤트 관리 -->
<div class="content-header">
  <div class="container-fluid">
    <div class="row mb-2 justify-content-between">
      	<div class="row align-items-center">
	      	<button type="button" class="btn btn-default mr-3" onclick="moveList()"><span class="icon material-symbols-outlined">keyboard_backspace</span> 목록으로</button>
	        <h1 class="m-0" id="eventWrite">이벤트 상세</h1>
      	</div>
      	<c:choose>
		    <c:when test="${param.eventNo!=null}">
				<c:if test="${user.mngrType == 'HM01' && eventVO.aprvYn == null && user.mbrId == eventVO.mngrId && eventVO.aprvYn == null}">
			    	<div class="btn-wrap modify">
						<button type="button" class="btn-danger" id="deleteHM01">삭제</button>
						<button type="button" class="btn-active" id="modifyHM01">수정</button>
					</div>
			    	<div class="btn-wrap modifing" style="display:none;">
						<button type="button" class="btn-default" id="cancleHM01">취소</button>
						<button type="button" class="btn-active" id="submitHM01">저장 <span class="icon material-symbols-outlined">East</span></button>
					</div>
				</c:if>
				<c:if test="${user.mngrType == 'HM02' && eventVO.aprvYn == null}">
			    	<div class="btn-wrap">
						<button type="button" class="btn-default" id="resetHM02">초기화</button>
						<button type="button" class="btn-active" id="submitHM02">저장 <span class="icon material-symbols-outlined">East</span></button>
					</div>
				</c:if>
		    </c:when>
		    <c:otherwise>
				<c:if test="${user.mngrType == 'HM01'}">
			    	<div class="btn-wrap modify">
			    		<button type="button" class="btn-default" id="resetBtn">초기화</button>
						<button type="button" class="btn-active" id="submitBtn">등록 <span class="icon material-symbols-outlined">East</span></button>
					</div>
				</c:if>
		    </c:otherwise>
		</c:choose>
    </div><!-- /.row -->
  </div><!-- /.container-fluid -->
</div>
<!-- /.content-header -->

<!-- wrap -->
<div class="wrap event-wrap">
	<!-- 이벤트상세관리 & 쿠폰 발급 조회 탭 영역 -->
	<c:if test="${user.mngrType == 'HM01' && param.eventNo != null}">
	<div class="page-tap-wrap">
		<div class="page-tap-cont event active">
			<span class="material-symbols-outlined title-icon">festival</span>이벤트 상세 관리
		</div>
		<div class="page-tap-cont coupon">
			<span class="material-symbols-outlined title-icon">confirmation_number</span>쿠폰 발급 조회
		</div>
	</div>
	</c:if>
	<!-- cont: 이벤트 상세를 위한 테이블 -->
	<div class="cont event-cont">
		<div class="table-wrap">
			<c:if test="${user.mngrType == 'HM01' && param.eventNo == null}">
			<div class="table-title">
				<div class="cont-title">
					<span class="material-symbols-outlined title-icon mr-2">festival</span>이벤트 작성
				</div>
			</div>
			</c:if>
			<!-- table: 이벤트 상세 정보 영역 -->
			<table class="table-blue eventDtl event-detail">
				<tbody>
					<c:if test="${user.mngrType == 'HM01' && param.eventNo != null}">
						<tr>
							<th style="width: 175px;">승인 여부</th>
							<td colspan="3">
								<c:if test="${eventVO.aprvYn == null}">
									승인 대기 중
								</c:if>						
								<c:if test="${eventVO.aprvYn == 'N'}">
									<span class="bge bge-danger mr-2" style="font-weight: bold">반려</span> ${eventVO.rjctRsn}
								</c:if>						
								<c:if test="${eventVO.aprvYn == 'Y'}">
									<span class="bge bge-active mr-2" style="font-weight: bold">승인</span>
								</c:if>						
							</td>
						</tr>
					</c:if>
					<c:if test="${user.mngrType == 'HM02'  && param.eventNo != null}">
							<tr>
								<th style="width: 175px;">승인 여부</th>
								<td colspan="3">
									<c:if test="${eventVO.aprvYn == null}">
										<div class="row">
											<div class="select-custom" style="width:100px;">
												<select class="w-100 mr-2" name="aprvYn" id="aprvYn">
													<option value="" selected hidden="hidden">선택</option>
													<option value="Y">승인</option>
													<option value="N">반려</option>
												</select>
											</div>
											<input id="rjctRsn" name="rjctRsn" placeholder="반려사유를 입력해주세요" style="display:none; width: 700px;">
										</div>
									</c:if>						
									<c:if test="${eventVO.aprvYn == 'N'}">
										<span class="bge bge-danger mr-2" style="font-weight: bold">반려</span> ${eventVO.rjctRsn}
									</c:if>						
									<c:if test="${eventVO.aprvYn == 'Y'}">
										<span class="bge bge-active mr-2" style="font-weight: bold">승인</span>
									</c:if>						
								</td>
							</tr>
					</c:if>
					<tr>
						<th style="width: 175px;">담당자</th>
						<td style="width: 345px;">
							<c:choose>
							    <c:when test="${param.eventNo!=null}">
							        ${eventVO.mbrNm}
							    </c:when>
							    <c:otherwise>
							        ${user.mbrNm}
							    </c:otherwise>
							</c:choose>
						</td>
						<th>등록일자</th>
						<td id="wrtrYmd">
							<c:choose>
							    <c:when test="${param.eventNo!=null}">
							        ${eventVO.wrtrYmd}
							    </c:when>
							    <c:otherwise>
							    	<c:set var="now" value="<%=new java.util.Date()%>" />
							        <fmt:formatDate value="${now}" pattern="yyyy-MM-dd" />
							    </c:otherwise>
							</c:choose>
						</td>
					</tr>
					<tr>
						<th>제목</th>
						<td colspan="3">
							<input type="text" id="eventTtl" name="eventTtl" class="text-input" placeholder="입력해주세요" value="${eventVO.eventTtl}" required>
						</td>
					</tr>
					<tr>
						<th>기간</th>
						<td colspan="3">
							<input type="date" id="bgngYmd" name="bgngYmd" value="${eventVO.bgngYmd}" required> 
								~ 
							<input type="date" id="expYmd" name="expYmd" value="${eventVO.expYmd}" required>
						</td>
					</tr>
					<tr>
						<th>쿠폰명</th>
						<td>
							<input type="text" id="couponCode" name="couponCode" value="${couponCode}"  hidden="hidden">
							<input type="text" id="couponNm" name="couponNm" class="text-input" placeholder="입력해주세요" value="${couponNm}" required>
						</td>
						<th>할인 가격</th>
						<td  style="width: 267px;">
							<input type="number" id="dscntAmt" name="dscntAmt" class="text-input" placeholder="0" value="${dscntAmt}" required>
						</td>
					</tr>
					<tr>
						<th>쿠폰 발급 수량</th>
						<td>
							<input type="number" value="${issuQty}" id="issuQty" name="issuQty" class="text-input" placeholder="0" required>
						</td>
					</tr>
					<tr>
						<th>메뉴</th>
						<td colspan="3">
							<div class="menu-wrap">
								<div class="menu-cont">
									<input type="text" id="menuNm" name="menuNm" class="text-input" placeholder="메뉴를 선택해주세요" disabled value="${menuNm}" required>
									<input type="text" id="menuNo" name="menuNo" hidden="hidden" value="${menuNo}">
								</div>
								<div class="menu-cont">
									<button type="button" id="menuBtn" class="btn btn-default" data-toggle="modal" data-target="#modalMenu">메뉴 선택 <span class="icon material-symbols-outlined">East</span></button>
								</div>
							</div>
						</td>
					</tr>
					<tr>
						<th style="vertical-align: baseline;padding-top: 25px;">내용</th>
						<td colspan="3">
							<div id="TEXTAREATEMP"></div>
							<textarea rows="3" id="eventCn" cols="" style="display:none;" name="eventCn" required></textarea>
						</td>
					</tr>
	        		<c:forEach var="fileDetailVO" items="${eventVO.fileDetailVOList}" >
						<c:if test="${fileDetailVO.fileGroupNo != null 
								    && fn:contains(fileDetailVO.fileSaveName, 'buff_event_main') 
								    || fn:contains(fileDetailVO.fileSaveName, 'buff_event_detail')}">
							<tr class="selectFile">
								<th>
									<c:if test="${fn:contains(fileDetailVO.fileSaveName, 'buff_event_main')}">메인 이미지</c:if>
									<c:if test="${fn:contains(fileDetailVO.fileSaveName, 'buff_event_detail')}">상세 이미지</c:if>
								</th>
								<td colspan="3">
									<div class="file-wrap">
							    		<div class="file-cont">
							        		<!-- 파일 이미지가 출력 될 selectFileImgList() 영역 -->
			                                <img alt="파일이미지" src="${fileDetailVO.fileSaveLocate}" style="max-height:100px;max-width:100px">
						    				<button type="button" class="btn btn-download downloadBtn" data-file-locate="${fileDetailVO.fileSaveLocate}" data-file-name="${fileDetailVO.fileOriginalName}">
			                                    다운로드<span class="icon material-symbols-outlined" style="color: var(--text--placeholder);">Download</span> 
			                                </button>
							    		</div>
						        	</div>
					        	</td>
							</tr>
						</c:if>
		    		</c:forEach> 
		    		<c:if test="${eventVO.fileGroupNo > 0}">
		    			<tr class="deleteFile" style="display:none;">
							<th>이벤트 이미지</th>
							<td colspan="3">
		                    	<button type="button" class="btn-default fileDelete" data-file-group-no="${eventVO.fileGroupNo}" data-file-sn="${fileDetailVO.fileSn}">재등록</button>
				        	</td>
						</tr>
		    		</c:if>
					<tr class="updateFile">
						<th>메인 이미지</th>
						<td colspan="3">
							<div class="input-file-wrap">
								<button type="button" class="btn btn-default" id="mainImgBtn" data-img-location="main">파일 선택</button>
								<span id="mainImg" class="img-info">선택된 파일이 없습니다</span>
								<input type="file" id="uploadFile" name="uploadFile" multiple style="visibility: hidden;"/>
							</div>
						</td>
					</tr>
					<tr class="updateFile">
						<th>상세 이미지</th>
						<td colspan="3">
							<div class="input-file-wrap">
								<button type="button" class="btn btn-default"  id="dtlImgBtn"  data-img-location="detail">파일 선택</button>
								<span id="detailImg" class="img-info">선택된 파일이 없습니다</span>
							</div>
						</td>
					</tr>
				</tbody>
			</table>
			<!-- /.table: 이벤트 상세 정보 영역 -->
			
			<!-- table: 쿠폰 발급 정보 영역 -->
			<table class="table-blue coupon-detail">
				<tbody>
					<tr>
						<th style="width: 239.79px;">쿠폰명</th>
						<td>${couponNm}</td>
						<th style="width: 239.79px;">할인 가격</th>
						<td>${dscntAmt}</td>
					</tr>
					<tr>
						<th>쿠폰 발급 수량</th>
						<td> <span class="coupon-total"></span> / ${issuQty}</td>
						<th>메뉴명</th>
						<td>${menuNm}</td>
					</tr>
				</tbody>
			</table>
			<!-- /.table-wrap: 쿠폰 발급 정보 -->
		</div>
		<!-- /.table-wrap -->
		
		<table class="table-default coupon-detail table">
			<thead>
				<tr>
					<th class="center" style="width: 15%">번호</th>
					<th class="center" style="width: 15%">고객명</th>
					<th style="width: 15%">아이디</th>
					<th class="center" style="width: 14%">사용일자</th>
					<th>사용 가맹점명</th>
					<th class="center" style="width: 25%">사용여부</th>
				</tr>
			</thead>
			<tbody class="select-coupon-list table-error" id="table-body">
				<!-- selectCouponList()로 쿠폰리스트가 호출 될 위치 -->
			</tbody>
		</table>
		
	</div>
	<!-- /.cont: 이벤트 상세를 위한 테이블 -->
	
</div>
<!-- /.wrap -->	

<div class="modal fade" id="modalMenu">
	<div class="modal-dialog modal-m">
		<div class="modal-content">
			<div class="modal-header row align-items-center justify-content-between">
				<div>
					<h4 class="modal-title">메뉴 선택</h4>
				</div>
				<div>
				  	<button type="button" class="btn btn-default" data-dismiss="modal">취소</button>
				</div>
      		</div>
      	<div class="modal-body">
			<div class="table-wrap">
				<div class="tap-wrap">
					<div data-type='' class="tap-cont active">
						<span class="tap-title">전체</span>
						<span class="bge bge-default" id="tap-total">1021</span>
					</div>
					<div data-type='MENU01' class="tap-cont">
						<span class="tap-title">세트</span>
						<span class="bge bge-warning" id="tap-set">1021</span>
					</div>
					<div data-type='MENU02' class="tap-cont">
						<span class="tap-title">햄버거</span>
						<span class="bge bge-active" id="tap-hambur">1021</span>
					</div>
					<div data-type='MENU03' class="tap-cont">
						<span class="tap-title">사이드</span>
						<span class="bge bge-danger" id="tap-side">1021</span>
					</div>
					<div data-type='MENU04' class="tap-cont">
						<span class="tap-title">음료</span>
						<span class="bge bge-info" id="tap-drink">1021</span>
					</div>
				</div>
			
				<table class="table-default event-menu-table">
					<!-- menuModalAjax()로 출력 될 영역 -->
				</table>
			</div>
			<!-- table-wrap -->
		</div>
		<!-- /.modal-body -->
	</div>
    <!-- /.modal-content -->
	</div>
  <!-- /.modal-dialog -->
</div>


<script src="/resources/js/sweetalert2.min.js"></script>
<script type="text/javascript" src="/resources/ckeditor5/ckeditor.js"></script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.6.0/jquery.min.js"></script>
<script type="text/javascript" src="/resources/hdofc/js/event.js"></script>














