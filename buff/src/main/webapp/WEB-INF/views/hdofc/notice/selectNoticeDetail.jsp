<%--
 	@fileName    : selectEventDetail
 	@programName : 공지사항 상세
 	@description : 공지사항 상세를 위한 페이지
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
<link rel="stylesheet" href="/resources/hdofc/css/notice.css"/>
<link rel="stylesheet" href="/resources/css/sweetalert2.min.css">

<sec:authentication property="principal.memberVO" var="user"/>

<script type="text/javascript">
const urlNtcSeq = '${param.ntcSeq}';
var ntcSeq; // 고정순번
var mngrId; // 담당자 아이디
var ntcTtl; // 제목
var ntcCn; // 내용
var wrtrDt; // 등록일자
var inqCnt; // 조회수
var fixdSeq;// 고정글순번
var fileGroupNo; // 파일번호
let deleteFileGroupNo = ''; // 삭제 할 파일그룹번호
var uploadFile; // 파일 업로드를 위한 속성
var mngrVO; // 공지사항 : 담당자 = 1 : 1
var memberVO; // 담당자 : 회원 = 1 : 1
var noticeVO = '${noticeVO}';
var originalntcCn = '${noticeVO.ntcCn}';
var fileSaveLocate = '';
var saveFiles = [];
$(function(){
	/* 부스트랩 툴팁 사용 */
	tooltipCustom();
	
	/* CKEditor5 시작 -------------------------------------------------------------------------*/
	ClassicEditor.create( document.querySelector('#TEXTAREATEMP'),{ckfinder:{uploadUrl:'/image/upload?${_csrf.parameterName}=${_csrf.token}'}})
		.then(editor=>{
			window.editor=editor;
			if (${param.ntcSeq != null}) {
				window.editor.setData(originalntcCn);
				editor.enableReadOnlyMode('TEXTAREATEMP');
		   }
		})
		.catch(err=>{console.error(err.stack);});
	$(".ck-blurred").keydown(function(){
		console.log("str : "+window.editor.getData());
		$("#ntcCn").val(window.editor.getData());
	})
	
	$(".ck-blurred").on("focusout",function(){ // CKEditor로부터 커서 및 마우스 이동 시 마지막 단어까지 출력 되도록 처리
		$("#ntcCn").val(window.editor.getData());
	})
	/* CKEditor5 끝 */
	
	/* 일반관리자: 등록 페이지 시작  ****************************************************************************/
	if(!urlNtcSeq){
		$('#uploadFile').css('display','block'); // 파일업로드 인풋박스 보이기
		$('.chk-wrap').css('display','block'); // 파일업로드 인풋박스 보이기
	}
	
	$('#resetBtn').on('click',function(){ // 초기화 버튼 클릭 시
		$('#ntcTtl').val('');
		$('.check_btn:checked').prop('checked', false);
		// CKEditor
		$("#ntcCn").val(window.editor.getData());
		if (window.editor) { // 에디터 활성화
			window.editor.setData(originalntcCn);
	    } 
	})
	
	$('#submitBtn').on('click',function(){ // 공지사항 등록 저장 클릭 시
		mngrId = '${user.mbrId}';
		console.log("mngrId -> ",mngrId);
		ntcCn = $("#ntcCn").val(window.editor.getData());
		noticeInsert();
	})
	/* 일반관리자: 등록 페이지 끝 */
	
	/* 일반관리자: 상세 페이지 시작 ****************************************************************************/	
	ntcSeq = '${param.ntcSeq}';
	//selectFileImgList(ntcSeq); // 첨부파일 이미지 불러오기 공지사항

	// 공지사항 상세 정보 인풋 비활성화
	if (${param.ntcSeq != null}) { 
		$('#menuBtn').css({
			'pointer-events':'none',
			'background-color':'var(--gray--1)',
			'color':'var(--text--primary)'
		});
		$('#menuBtn').find('.icon').css('color','var(--text--primary)');
		$('#ntcTtl, #bgngYmd, #expYmd, #couponNm, #dscntAmt, #issuQty').attr('disabled', true);
		$('.fixdSeq-wrap').css('display','block');
    }
	
	/* 공지사항 수정-------------------------------------------------------------------------------------------- */
	$('#modifyHM01').on('click',function(){ 
		$('.modify').css('display','none'); // 수정버튼 숨기기
		$('.modifing').css('display','block'); // 취소, 저장버튼 보이기
		$('.fixdSeq-wrap').css('display','none'); // 고정 여부 숨기기

		if($('#fileDelete').data('fileGroupNo')>0){
			$('#fileDelete').css('display','block'); // 파일 삭제 버튼 보이기
		} else{
			$('#uploadFile').css('display','block'); // 파일업로드 인풋박스 보이기
		}
		
		$('.chk-wrap').css('display','block'); // 고정 선택 보이기
		
		// 메뉴 선택 버튼 보이기
		$('#menuBtn').css({
			'pointer-events':'auto',
			'background-color':'var(--gray--0)',
			'color':'var(--text--secondary)'
		});
		$('#menuBtn').find('.icon').css('color','var(--text--secondary)');
		// 인풋 입력 활성화
		$('#ntcTtl, #bgngYmd, #expYmd, #couponNm, #dscntAmt, #issuQty').removeAttr('disabled', true);

		// CKEditor
		$("#ntcCn").val(window.editor.getData());
		if (window.editor) { // 에디터 활성화
			window.editor.disableReadOnlyMode('TEXTAREATEMP');
			window.editor.setData("${noticeVO.ntcCn}");
	    } 
		$(".ck-blurred").keydown(function(){
			console.log("str : "+window.editor.getData());
			$("#ntcCn").val(window.editor.getData());
		})
		$(".ck-blurred").on("focusout",function(){ // CKEditor로부터 커서 및 마우스 이동 시 마지막 단어까지 출력 되도록 처리
			$("#ntcCn").val(window.editor.getData());
		})
	});
	
	// 파일 삭세 버튼 클릭 시
	$('#fileDelete').on('click',function(){ 
		$('#uploadFile').css('display','block'); // 파일업로드 인풋박스 보이기
		$('.file-wrap').css('display','none'); // 이미지 영역 숨김
		deleteFileGroupNo = $('#fileDelete').data('fileGroupNo'); // let 변수에 파일그룹번호 재할당. 
	})
	
	/* 수정 취소-------------------------------------------------------------------------------------------- */
	$('#cancleHM01').on('click',function(){
		$('.file-wrap').css('display','block');
		$('#uploadFile, #fileDelete').css('display','none');
		$('#ntcTtl, #bgngYmd, #expYmd, #couponNm, #dscntAmt, #issuQty').attr('disabled', true);
		$('.modifing').css('display','none');
		$('.modify').css('display','block');
		$('#uploadFile').val('');
		// CKEditor
		if (window.editor) { 
			window.editor.enableReadOnlyMode('TEXTAREATEMP'); // 읽기 모드
			window.editor.setData(originalntcCn);
	    } 
	});
	
	/* 수정 내용 저장-------------------------------------------------------------------------------------------- */
	$('#submitHM01').on('click',function(){ 
		ntcSeq = '${param.ntcSeq}';
		updateNoticeDtlAjax(); // 공지사항 수정 공지사항
	});
	
	/* 공지사항 삭제-------------------------------------------------------------------------------------------- */
	$('#deleteHM01').on('click',function(){
		ntcSeq = '${param.ntcSeq}';
		fileGroupNo = '${noticeVO.fileGroupNo}';
		noticeDelete();		
	});
	
	/* 일반관리자: 상세 페이지 끝 */
	
	// 파일 다운로드
	$('#downloadBtn').on('click',function(){
		fileSaveLocate = $(this).data('fileLocate');
		fileOriginalName = $(this).data('fileName');
		console.log(fileSaveLocate);
		console.log(fileOriginalName);
		fileDownloadAjax(fileSaveLocate, fileOriginalName);
	})
	
	// 공지사항 미리 작성
	$('#noticeWrite').on('click',function(){
		$('#ntcTtl').val('알레르기 유발 성분 표시 안내');
		
		let str = `
			저희 버프는 고객님들의 건강과 안전을 최우선으로 생각하며, 
			이번에 알레르기 유발 성분 표시를 강화한 정책을 시행하게 되었습니다. 
			앞으로 버프의 모든 메뉴에는 알레르기 유발 가능성이 있는 성분을 더 명확하게 표시하여, 
			고객님들이 안전하게 메뉴를 선택하실 수 있도록 도와드릴 예정입니다. 
			매장 내 메뉴판과 웹사이트에서 각 메뉴에 포함된 주요 알레르기 유발 성분을 쉽게 확인하실 수 있습니다. 
			<br><br>
			또한, 알레르기 정보는 글루텐, 땅콩, 우유, 달걀, 대두, 갑각류 등 주요 알레르기 항목을 포함하며, 
			메뉴 제작 과정에서 발생할 수 있는 교차오염 가능성도 명시하였습니다. 
			알레르기 정보를 참고하신 후 주문하시기 전에는 매장 직원에게 해당 성분이 포함된 메뉴가 있는지 다시 한번 확인해 주시기 바랍니다. 
			저희 버프는 앞으로도 고객님들의 안전한 식사 경험을 위해 지속적으로 정보를 업데이트할 계획입니다. 
			만약 추가로 궁금한 사항이 있으시거나 특정 메뉴에 대해 문의하고 싶으신 경우, 언제든지 매장 직원에게 문의해 주세요.
			<br><br>
			감사합니다.
		`;
		
		if (window.editor) { // 에디터 활성화
			window.editor.setData(str);
	    } 
	})
	
})
</script>

<!-- content-header: 공지사항 관리 -->
<div class="content-header">
  <div class="container-fluid">
    <div class="row mb-2 justify-content-between">
      	<div class="row align-items-center">
	      	<button type="button" class="btn btn-default mr-3" onclick="window.location.href='/hdofc/notice/selectNoticeList'"><span class="icon material-symbols-outlined">keyboard_backspace</span> 목록으로</button>
	        <h1 class="m-0" id="noticeWrite">공지사항 상세</h1>
      	</div>
      	<c:choose>
		    <c:when test="${param.ntcSeq!=null}">
				<c:if test="${user.mbrId == noticeVO.mngrId}">
			    	<div class="btn-wrap modify">
			    		<button type="button" class="btn-danger" id="deleteHM01">삭제</button>
						<button type="button" class="btn-active" id="modifyHM01">수정</button>
					</div>
			    	<div class="btn-wrap modifing" style="display:none;">
						<button type="button" class="btn-default" id="cancleHM01">취소</button>
						<button type="button" class="btn-active" id="submitHM01">저장 <span class="icon material-symbols-outlined">East</span></button>
					</div>
				</c:if>
		    </c:when>
		    <c:otherwise>
		    	<div class="btn-wrap modify">
		    		<button type="button" class="btn-default" id="resetBtn">초기화</button>
					<button type="button" class="btn-active" id="submitBtn">등록 <span class="icon material-symbols-outlined">East</span></button>
				</div>
		    </c:otherwise>
		</c:choose>
    </div><!-- /.row -->
  </div><!-- /.container-fluid -->
</div>
<!-- /.content-header -->

<!-- wrap -->
<div class="wrap">
	<!-- cont: 공지사항 상세를 위한 테이블 -->
	<div class="cont">
		<div class="table-wrap">
			<div class="table-title">
				<div class="cont-title">
					<c:choose>
					    <c:when test="${param.ntcSeq!=null}">
							<span class="material-symbols-outlined title-icon">assignment</span>공지사항 등록
					    </c:when>
					    <c:otherwise>
					        <span class="material-symbols-outlined title-icon">assignment</span>공지사항 정보
					    </c:otherwise>
					</c:choose>
				</div> 
			</div>
			<!-- table: 공지사항 상세 정보 영역 -->
			<table class="table-blue eventDtl event-detail">
				<tbody>
					<tr>
						<th style="width: 175px;">작성자</th>
						<td style="width: 345px;">
							<c:choose>
							    <c:when test="${param.ntcSeq!=null}">
							        ${noticeVO.memberVO.mbrNm}
							    </c:when>
							    <c:otherwise>
							        ${user.mbrNm}
							    </c:otherwise>
							</c:choose>
						</td>
						<th>등록일자</th>
						<td id="wrtrDt">
							<c:choose>
							    <c:when test="${param.ntcSeq!=null}">
							        ${noticeVO.wrtrDt}
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
						<td colspan="5">
							<input type="text" id="ntcTtl" name="ntcTtl" class="text-input" placeholder="입력해주세요" value="${noticeVO.ntcTtl}" required>
						</td>
					</tr>
					<tr>
						<th style="vertical-align: baseline;padding-top: 25px;">내용</th>
						<td colspan="5">
							<div id="TEXTAREATEMP"></div>
							<textarea rows="3" id="ntcCn" cols="" style="display:none;" name="ntcCn" required></textarea>
						</td>
					</tr>
					<tr>
						<th>첨부파일</th>
						<td colspan="5">
							<div class="file-wrap">
					    		<div class="file-cont" style="display: ruby;">
						    		<c:forEach var="fileDetailVO" items="${noticeVO.fileDetailVOList}" >
					    				<c:if test="${fileDetailVO.fileGroupNo != null && fileDetailVO.fileGroupNo != 0}">
					    					<span class="img-info">${fileDetailVO.fileOriginalName}</span>
						    				<button type="button" class="btn btn-download" id="downloadBtn" data-file-locate="${fileDetailVO.fileSaveLocate}" data-file-name="${fileDetailVO.fileOriginalName}">
			                                    다운로드<span class="icon material-symbols-outlined" style="color: var(--text--placeholder);">Download</span> 
			                                </button>
			                                <button type="button" id="fileDelete" class="btn-default" data-file-group-no="${fileDetailVO.fileGroupNo}" data-file-sn="${fileDetailVO.fileSn}" style="display:none; width: fit-content;">삭제</button>
					    				</c:if>
						    		</c:forEach> 
						    		<c:if test="${fileDetailVO.fileGroupNo == null && fileDetailVO.fileGroupNo == 0}">-</c:if>
					    		</div>
				        	</div>
				       		 <input type="file" id="uploadFile" name="uploadFile" multiple style="display:none;" />
						</td>
					</tr>
					<tr>
						<th>상단고정</th>
						<td colspan="5">
							<div class="sticky-board-wrap">
								<div class="chk-wrap" style="display: none;">
							       	<input type="checkbox" class="check-btn" id="fixdSeq" name="fixdSeq">
							       	<label for="fixdSeq"><span>선택</span></label>
						    	</div>
					    		<div class="fixdSeq-wrap" style="display: none;">
							    	<c:if test="${noticeVO.fixdSeq != null}">고정</c:if>
						        	<c:if test="${noticeVO.fixdSeq == null}">미고정</c:if>
						       	</div>
							</div>
						</td>
					</tr>
				</tbody>
			</table>
			<!-- /.table: 공지사항 상세 정보 영역 -->
		</div>
		<!-- /.table-wrap -->
	</div>
	<!-- /.cont: 공지사항 상세를 위한 테이블 -->
	
</div>
<!-- /.wrap -->	



<script type="text/javascript" src="/resources/hdofc/js/notice.js"></script>
















