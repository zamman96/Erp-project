/*******************************************
  @fileName    : frcsDscsn.js
  @author      : 송예진
  @date        : 2024. 09. 23
  @description : 가맹점 상담
********************************************/
document.write("<script src='/resources/js/global/value.js'></script>");

// 상담 조회 리스트
function selectFrcsDscsnAjax(){
	let mngrNm = $('#mngrNm').val();
	let rgnNo = $('#rgnNo').val();
	let bgngYmdDt = $('#bgngYmd').val();
	let endYmdDt = $('#endYmd').val();
	let mbrNm = $('#mbrNm').val();
	
	let frcsOpen = $('#frcsOpen').val();
	
	
	let data = {};

	// 값이 빈 문자열이 아니면 data 객체에 추가
	if (mngrNm) {
	    data.mngrNm = mngrNm;
	}
	if (frcsOpen) {
	    data.frcsOpen = frcsOpen;
	}
	if (rgnNo) {
	    data.rgnNo = rgnNo;
	}
	if (mbrNm) {
	    data.mbrNm = mbrNm;
	}
	if (bgngYmdDt) {
	    data.bgngYmd = dateToStr(bgngYmdDt);
	}
	if (endYmdDt) {
	    data.endYmd = dateToStr(endYmdDt);
	}
	
	data.sort = sort;
	data.orderby = orderby;
	data.currentPage = currentPage;
	data.dscsnType = dscsnType;
	
	console.log(data);  // 최종적으로 빈 값이 제외된 data 객체
	
	// 서버전송
	$.ajax({
		url : "/hdofc/frcs/dscsn/listAjax",
		type : "GET",
		data : data,
		success : function(res){
			// 분류 처리
			$('#tap-all').text(res.all);
			$('#tap-dsc01').text(res.dsc01);
			$('#tap-dsc02').text(res.dsc02);
			$('#tap-dsc03').text(res.dsc03);
			$('#tap-dsc04').text(res.dsc04);
			
			//console.log(res);
			// 테이블 처리
			let strTbl = '';
			
			if(res.total == 0){ // 검색 결과가 0인 경우
				strTbl+= `
							<tr>
								<td class="error-info" colspan="9"> 
									<span class="icon material-symbols-outlined">error</span>
									<div class="error-msg">검색 결과가 없습니다</div>
								</td>
							</tr>
				`;
				$('.pagination').html('');
			} else {
				res.articlePage.content.forEach(list => {
				// 상담 일자
				let dscsnPlanYmd = strToDate(list.dscsnPlanYmd);
				// 전화번호
				let telNo = telToStr(list.mbrVO.mbrTelno);
				// 상담 유형
				let dscsnTypeBge = list.dscsnType == 'DSC01' ? `<span class='bge bge-info'>상담대기</span>` 
               : list.dscsnType == 'DSC02' ? `<span class='bge bge-danger'>상담취소</span>` 
               : list.dscsnType == 'DSC03' ? `<span class='bge bge-warning'>상담예정</span>` 
               : `<span class='bge bge-active'>상담완료</span>`;
               
				// 개업여부
				let opbiz = list.frcsNo!=null ? `<span class='bge bge-active-border'>개업완료</span>` 
				: list.dscsnType=='DSC04' ? `<span class='bge bge-warning-border'>개업예정</span>` : `<span class='bge bge-default-border'>해당없음</span>`;
				
	    		strTbl += `
				    <tr class="dscsnDtl" data-code="${list.dscsnCode}" data-type="${list.dscsnType}">
				        <td class="center">${list.rnum}</td>
				        <td class="center">${list.mbrVO ? list.mbrVO.mbrNm : '-'}</td>
				        <td class="center">${list.mngrVO && list.mngrVO.mbrNm ? list.mngrVO.mbrNm : '-'}</td>
				        <td class="center">${dscsnPlanYmd}</td>
				        <td class="center">${telNo}</td>
				        <td class="center">${list.mbrVO.mbrEmlAddr}</td>
				        <td class="center">${list.rgnNm}</td>
				        <td class="center">${dscsnTypeBge}</td>
				        <td class="center">${opbiz}</td>
				    </tr>
				`;
				
				});
				
				// 페이징 처리
				let page = '';
				
				if (res.articlePage.startPage > res.articlePage.blockSize) {
				    page += `
				        <a href="#page" class="page-link" data-page="${res.articlePage.startPage - res.articlePage.blockSize}">
				            <span class="icon material-symbols-outlined">chevron_left</span>
				        </a>
				    `;
				}
				
				// 페이지 번호 링크들 추가
				for (let pnum = res.articlePage.startPage; pnum <= res.articlePage.endPage; pnum++) {
				    if (res.articlePage.currentPage === pnum) {
				        page += `<a href="#page" class="page-link active" data-page="${pnum}">${pnum}</a>`;
				    } else {
				        page += `<a href="#page" class="page-link" data-page="${pnum}">${pnum}</a>`;
				    }
				}
				
				// 'chevron_right' 아이콘 및 다음 페이지 링크 추가
				if (res.articlePage.endPage < res.articlePage.totalPages) {
				    page += `
				        <a href="#page" class="page-link" data-page="${res.articlePage.startPage + res.articlePage.blockSize}">
				            <span class="icon material-symbols-outlined">chevron_right</span>
				        </a>
				    `;
				}
				$('.pagination').html(page);
				}
			$('#table-body').html(strTbl)
			}
		});			
}


// 상담 상세
function selectFrcsDscsnDtlAjax(){
// 서버전송
	$.ajax({
		url : "/hdofc/frcs/dscsn/dtlAjax",
		type : "GET",
		data: { dscsnCode: dscsnCode },  // 객체 형태로 전송
		// csrf설정 secuity설정된 경우 필수!!
		beforeSend:function(xhr){ 
			xhr.setRequestHeader(csrfHeader, csrfToken); // CSRF 헤더와 토큰을 설정
		},
		success : function(res){
			dscsnType=res.dscsnType;
		
			let dscsnPlanYmd = strToDate(res.dscsnPlanYmd);
			$('#dscsn-dscsnPlanYmd').val(dscsnPlanYmd);
		
			if(res.dscsnType=='DSC01'){
				$('#dscsn-rgnNm').prop("disabled", true);
				$('#dscsn-dscsnPlanYmd').prop("disabled", true);
				
				$('.dscsn-dsc01').show();
				$('.modal-dsc').hide();
				
				$('#dscsn-mngrId').val(mbrId)
				$('#dscsn-mngrNm').val(mbrNm);
				let mbrTelArr = splitTel(mbrTelno);
				
				$('#dscsn-mngrTelno1').val(mbrTelArr[0]);
				$('#dscsn-mngrTelno2').val(mbrTelArr[1]);
				$('#dscsn-mngrTelno3').val(mbrTelArr[2]);
			} else {
				$('.dscsn-save').show();
				$('.modal-dsc01').hide();
				
				// 현재 날짜 (시간 정보는 제외하고 비교)
				var currentDate = new Date();
				currentDate.setHours(0, 0, 0, 0); // 현재 날짜에서 시간 정보를 제거
				
				// dscsnPlanYmd를 Date 객체로 변환
				var planDate = new Date(dscsnPlanYmd);
				planDate.setHours(0, 0, 0, 0); // 현재 날짜에서 시간 정보를 제거
				
				if (planDate <= currentDate || res.dscsnType=='DSC02') { // 이전인 경우
					date = true;
					$('.modal-dsc').show();
					if(res.dscsnType=='DSC03'|| res.dscsnType=='DSC04'){
						$('.dscsn-dsc03').show();
					}
				} 
			}
		
		
			$('#dscsn-mbrNm').text(res.mbrVO.mbrNm);
			$('#dscsn-mbrId').text(res.mbrVO.mbrId);
			$('#dscsn-mbrTelno').text(telToStr(res.mbrVO.mbrTelno));
			$('#dscsn-mbrEmlAddr').text(res.mbrVO.mbrEmlAddr);
			
			if(res.mngrVO){
				$('#dscsn-mngrId').val(res.mngrVO.mbrId);
				$('#dscsn-mngrNm').val(res.mngrVO.mbrNm);
				let mbrTelArr = splitTel(res.mngrVO.mbrTelno);
				$('#dscsn-mngrTelno1').val(mbrTelArr[0]);
				$('#dscsn-mngrTelno2').val(mbrTelArr[1]);
				$('#dscsn-mngrTelno3').val(mbrTelArr[2]);
			}
			
		    // select 요소에서 값 설정 후 select2에 반영
		    $('#dscsn-rgnNm').val(res.rgnNo).trigger('change');
		    
			// 상담 유형
			let dscsnTypeBge = res.dscsnType == 'DSC01' ? `<span class='bge bge-info'>상담대기</span>` 
           : res.dscsnType == 'DSC02' ? `<span class='bge bge-danger'>상담취소</span>` 
           : res.dscsnType == 'DSC03' ? `<span class='bge bge-warning'>상담예정</span>` 
           : `<span class='bge bge-active'>상담완료</span>`;
           $('#dscsn-dscsnType').html(dscsnTypeBge)
			// 개업여부
			let opbiz = res.frcsNo!=null ? `<span class='bge bge-active-border'>개업완료</span> <span class="material-symbols-outlined icon" onclick="location.href='/hdofc/frcs/list/dtl?frcsNo=${res.frcsNo}'" style='cursor:pointer;'>open_in_new</span>` 
			: res.dscsnType=='DSC04' ? `<span class='bge bge-warning-border'>개업예정</span>` : `<span class='bge bge-default-border'>해당없음</span>`;
			$('#dscsn-frcs').html(opbiz)
			
			let dscsnCn = '';
			if(res.dscsnCn){
				dscsnCn = res.dscsnCn;
			}
			$('#dscsn-dscsnCn').val(dscsnCn);
			
			}
		});		
}

function updateFrcsDscsnAjax(dscsnType){
	let frcsDscsnVO = {};
	
	let mngrId = $('#dscsn-mngrId').val();
	let rgnNo = $('#dscsn-rgnNm').val();
	let dscsnPlanYmdDt = $('#dscsn-dscsnPlanYmd').val();
	let dscsnCn = $('#dscsn-dscsnCn').val();
	
	console.log(dscsnCn);
	frcsDscsnVO.mngrId = mngrId;
	frcsDscsnVO.dscsnType = dscsnType;
	frcsDscsnVO.rgnNo = rgnNo;
	frcsDscsnVO.dscsnPlanYmd = dateToStr(dscsnPlanYmdDt);
	frcsDscsnVO.dscsnCode = dscsnCode;
	if(dscsnCn){
		frcsDscsnVO.dscsnCn = dscsnCn;
	}
	console.log(frcsDscsnVO);
	
	// 서버전송
	$.ajax({
		url : "/hdofc/frcs/dscsn/updateAjax",
		type : "POST",
		data: JSON.stringify(frcsDscsnVO),
		contentType: "application/json",  // JSON 형식으로 전송
		// csrf설정 secuity설정된 경우 필수!!
		beforeSend:function(xhr){ 
			xhr.setRequestHeader(csrfHeader, csrfToken); // CSRF 헤더와 토큰을 설정
		},
		success : function(res){
				Swal.fire({
				  title: "완료",
				  html : `저장되었습니다.`,
				  confirmButtonColor: "#3085d6",
				  confirmButtonText: "확인",
				}).then((result) => {
				  if (result.isConfirmed) {
				  	location.reload();
				  } 
				});
			}
		});		
	
}