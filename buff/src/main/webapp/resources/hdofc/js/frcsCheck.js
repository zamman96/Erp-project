/*******************************************
  @fileName    : frcsCheck.js
  @author      : 송예진
  @date        : 2024. 09. 19
  @description : 가맹점 점검 코드
********************************************/
document.write("<script src='/resources/js/global/value.js'></script>");

// @methodName  : selectFrcsListAjax
// @author      : 송예진
// @date        : 2024.09.19
// @jsp         : hdofc/frcs/insertFrcsCheck
// @description : 가맹점 점검에 따른 점검해야될 가맹점 조회(최근 점검만 조회)
function selectFrcsListAjax(){
	let mngrId = $('#mngrId').val();
	let rgnNo = $('#rgnNo').val();
	let gubun = $('#gubun').val();
	let keyword = $('#keyword').val();
	
	let data = {};

	// 값이 빈 문자열이 아니면 data 객체에 추가
	if (mngrId) {
	    data.mngrId = mngrId;
	}
	if (rgnNo) {
	    data.rgnNo = rgnNo;
	}
	if (gubun) {
	    data.gubun = gubun;
	}
	if (keyword) {
	    data.keyword = keyword;
	}
	
	data.sort = sort;
	data.orderby = orderby;
	data.currentPage = currentPage;
	data.chk = chk;
	
	//console.log(data);  // 최종적으로 빈 값이 제외된 data 객체
	
	// 서버전송
	$.ajax({
		url : "/hdofc/frcs/check/frcsList",
		type : "GET",
		data : data,
		success : function(res){
			console.log(res);
			// 분류 처리
			$('#tap-all').text(res.all);
			$('#tap-check').text(res.chk);
			
			// 테이블 처리
			let strTbl = '';
			
			if(res.articlePage.total == 0){ // 검색 결과가 0인 경우
				strTbl+= `
							<tr>
								<td class="error-info" colspan="7"> 
									<span class="icon material-symbols-outlined">error</span>
									<div class="error-msg">검색 결과가 없습니다</div>
								</td>
							</tr>
				`;
				
				$('#table-body').html(strTbl);
				$('.pagination').html('');
				return;
			}
			
			res.articlePage.content.forEach(list => {
			// 점검 일자
			let chckYmd = strToDate(list.chckYmd);
			
    		strTbl += `
			    <tr class="frcsDtl" data-no="${list.frcsVO.frcsNo}" data-nm="${list.frcsVO.bzentVO.bzentNm}"  data-rgn="${list.frcsVO.bzentVO.rgnNm}">
			        <td class="center">${list.rnum}</td>
			        <td>${list.frcsVO.bzentVO.bzentNm}</td>
			        <td class="center">${list.frcsVO.bzentVO.mbrVO ? list.frcsVO.bzentVO.mbrVO.mbrNm : '-'}</td>
			        <td class="center">${list.frcsVO.bzentVO.mngrVO && list.frcsVO.bzentVO.mngrVO.mbrNm ? list.frcsVO.bzentVO.mngrVO.mbrNm : '-'}</td>
			        <td class="center">${chckYmd}</td>
			        <td class="center">${list.chckYmd ? list.totScr : '-'}</td>
			        <td>${list.frcsVO.bzentVO.rgnNm}</td>
			    </tr>
			`;
			
			});
			$('#table-body').html(strTbl)
			
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
		});			
}

// @methodName  : insertFrcsCheck
// @author      : 송예진
// @date        : 2024.09.20
// @jsp         : hdofc/frcs/insertFrcsCheck
// @description : 점검 항목 insert
function insertFrcsCheck(){
	let frcsCheckVO = {};
	let clngood = $('.cln.good:checked').length;
	let clnnomal = $('.cln.nomal:checked').length;
	let chckCn = $('#chckCn').val();
	let srvgood = $('.srv.good:checked').length;
	let srvnomal = $('.srv.nomal:checked').length;
	
	frcsCheckVO.mngrId = mngrId;
	frcsCheckVO.clenScr = clngood*10+clnnomal*5;
	frcsCheckVO.srvcScr = srvgood*10+srvnomal*5;
	
	if(chckCn){
		frcsCheckVO.chckCn = chckCn;
	}
	frcsCheckVO.frcsNo = $('#bzentNo').val();
	
	console.log(frcsCheckVO);
		
			// 서버전송
	$.ajax({
		url : "/hdofc/frcs/check/registAjax",
		type : "POST",
		data: JSON.stringify(frcsCheckVO),
		contentType: "application/json",  // JSON 형식으로 전송
	// csrf설정 secuity설정된 경우 필수!!
		beforeSend:function(xhr){ 
			xhr.setRequestHeader(csrfHeader, csrfToken); // CSRF 헤더와 토큰을 설정
		},
		success : function(res){
			if(res=='clsbiz'){
				Swal.fire({
				  html: `<p>해당 가맹점의 경고 횟수가 3회를 넘겼습니다.</p>
				  		 <p>가맹점을 폐업조치하였습니다</p>
				  		 <p>가맹점은 이번 달까지 운영하며 이후엔 폐업 처리 됩니다</p>`,
				  icon: "warning"
				})
				.then(function(result){
					location.href='/hdofc/frcs/check/list';
				})
			}else{
				setTimeout(function() {
					location.href='/hdofc/frcs/check/list';
				}, 1000);
			}
		},
		error: function(xhr, status, error) {
        	console.error("에러 발생: ", error);
        }
		});		
}


// @methodName  : insertFrcsCheck
// @author      : 송예진
// @date        : 2024.09.20
// @jsp         : hdofc/frcs/insertFrcsCheck
// @description : 점검 항목 insert
function selectFrcsCheckAjax(){
	let mngrId = $('#mngrId').val();
	let rgnNo = $('#rgnNo').val();
	let bgngYmdDt = $('#bgngYmd').val();
	let endYmdDt = $('#endYmd').val();
	let mbrNm = $('#mbrNm').val();
	let bzentNm = $('#bzentNm').val();
	let frcsType = $('#frcsType').val();
	let warnCnt = $('#warnCnt').val();
	let totScr = $('#totScr').val();
	let insctrNm = $('#insctrNm').val();
	
	let data = {};

	// 값이 빈 문자열이 아니면 data 객체에 추가
	if (mngrId) {
	    data.mngrId = mngrId;
	}
	if (insctrNm) {
	    data.insctrNm = insctrNm;
	}
	if (rgnNo) {
	    data.rgnNo = rgnNo;
	}
	if (mbrNm) {
	    data.mbrNm = mbrNm;
	}
	if (bzentNm) {
	    data.bzentNm = bzentNm;
	}
	if (frcsType) {
	    data.frcsType = frcsType;
	}
	if (warnCnt) {
	    data.warnCnt = warnCnt;
	}
	if (totScr) {
	    data.totScr = totScr;
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
	
	console.log(data);
	
	// 서버전송
	$.ajax({
		url : "/hdofc/frcs/check/listAjax",
		type : "GET",
		data : data,
		success : function(res){
			// 분류 처리
			$('#tap-all').text(res.total);
			
			// 테이블 처리
			let strTbl = '';
			
			if(res.total == 0){ // 검색 결과가 0인 경우
				strTbl+= `
							<tr>
								<td class="error-info" colspan="10"> 
									<span class="icon material-symbols-outlined">error</span>
									<div class="error-msg">검색 결과가 없습니다</div>
								</td>
							</tr>
				`;
				$('.pagination').html('');
				$('#table-body').html(strTbl);
				return;
			}
			
			res.content.forEach(list => {
			// 점검 일자
			let check = strToDate(list.chckYmd);
			// 경고
			let warn = list.frcsVO.warnCnt >= 3 ? `<span class='es'>${list.frcsVO.warnCnt}</span>` : list.frcsVO.warnCnt;
			
    		strTbl += `
			    <tr class="frcsChkDtl" data-no="${list.frcsNo}" data-seq="${list.chckSeq}">
			        <td class="center">${list.rnum}</td>
			        <td>${list.frcsVO.bzentVO.bzentNm}</td>
			        <td class="center">${warn}</td>
			        <td class="center">${list.frcsVO.bzentVO.mbrVO ? list.frcsVO.bzentVO.mbrVO.mbrNm : '-'}</td>
			        <td class="center">${list.frcsVO.bzentVO.mngrVO && list.frcsVO.bzentVO.mngrVO.mbrNm ? list.frcsVO.bzentVO.mngrVO.mbrNm : '-'}</td>
			        <td class="center">${list.insctrVO.mbrNm}</td>
			        <td class="center">${check}</td>
			        <td class="center">${list.totStr}</td>
			        <td class="center">${list.frcsVO.bzentVO.rgnNm}</td>
			        <td class="center">
			            <span class="bge ${list.frcsVO.frcsType === 'FRS01' ? 'bge-active' : list.frcsVO.frcsType === 'FRS02' ? 'bge-danger' : 'bge-warning'}">
						  ${list.frcsVO.frcsTypeNm}
						</span>
			        </td>
			    </tr>
			`;
			
			});
			$('#table-body').html(strTbl)
			
			// 페이징 처리
			let page = '';
			
			if (res.startPage > res.blockSize) {
			    page += `
			        <a href="#page" class="page-link" data-page="${res.startPage - res.blockSize}">
			            <span class="icon material-symbols-outlined">chevron_left</span>
			        </a>
			    `;
			}
			
			// 페이지 번호 링크들 추가
			for (let pnum = res.startPage; pnum <= res.endPage; pnum++) {
			    if (res.currentPage === pnum) {
			        page += `<a href="#page" class="page-link active" data-page="${pnum}">${pnum}</a>`;
			    } else {
			        page += `<a href="#page" class="page-link" data-page="${pnum}">${pnum}</a>`;
			    }
			}
			
			// 'chevron_right' 아이콘 및 다음 페이지 링크 추가
			if (res.endPage < res.totalPages) {
			    page += `
			        <a href="#page" class="page-link" data-page="${res.startPage + res.blockSize}">
			            <span class="icon material-symbols-outlined">chevron_right</span>
			        </a>
			    `;
			}
			$('.pagination').html(page);
			}
		});			
}

function frcsCheckDtlAjax(){
	let frcsCheckVO = {};
	
	frcsCheckVO.frcsNo = frcsNo;
	frcsCheckVO.chckSeq = chckSeq;

	console.log(frcsCheckVO);

	// 서버전송
	$.ajax({
		url : "/hdofc/frcs/check/dtlAjax",
		type : "POST",
		data: JSON.stringify(frcsCheckVO),
		contentType: "application/json",  // JSON 형식으로 전송
		// csrf설정 secuity설정된 경우 필수!!
		beforeSend:function(xhr){ 
			xhr.setRequestHeader(csrfHeader, csrfToken); // CSRF 헤더와 토큰을 설정
		},
		success : function(res){
			console.log(res);
			let bge = `<span class="bge ${res.frcsVO.frcsType === 'FRS01' ? 'bge-active' : res.frcsVO.frcsType === 'FRS02' ? 'bge-danger' : 'bge-warning'}">
						  ${res.frcsVO.frcsTypeNm}
						</span>`;
			$('#storelink').html(`<span class="material-symbols-outlined icon" onclick="location.href='/hdofc/frcs/list/dtl?frcsNo=${res.frcsNo}'" style='cursor:pointer;'>open_in_new</span>`);
			$('#modal-bzentNm').text(res.frcsVO.bzentVO.bzentNm);
			$('#modal-frcsType').html(bge);
			$('#modal-mbrNm').text(res.frcsVO.bzentVO.mbrVO.mbrNm);
			
			$('#modal-rgnNm').text(res.frcsVO.bzentVO.rgnNm);
			let bzentTelNo = splitTel(res.frcsVO.bzentVO.bzentTelno);
			$('#modal-bzentTelno').text(bzentTelNo[0]+"-"+bzentTelNo[1]+"-"+bzentTelNo[2]);
			//$('#modal-bzentTelno1').val(bzentTelNo[0]);
			//$('#modal-bzentTelno2').val(bzentTelNo[1]);
			//$('#modal-bzentTelno3').val(bzentTelNo[2]);
			
			
			let mbrTelNo = splitTel(res.frcsVO.bzentVO.mbrVO.mbrTelno);
			$('#modal-mbrTelno').text(mbrTelNo[0]+"-"+mbrTelNo[1]+"-"+mbrTelNo[2]);
			//$('#modal-mbrTelno1').val(mbrTelNo[0]);
			//$('#modal-mbrTelno2').val(mbrTelNo[1]);
			//$('#modal-mbrTelno3').val(mbrTelNo[2]);
			
			if(res.frcsVO.bzentVO.mngrVO){
				$('#modal-mngrNm').text(res.frcsVO.bzentVO.mngrVO.mbrNm);
				let mngrTelNo = splitTel(res.frcsVO.bzentVO.mngrVO.mbrTelno);
				$('#modal-mngrTelno').text(mngrTelNo[0]+"-"+mngrTelNo[1]+"-"+mngrTelNo[2]);
			} else{
				$('#modal-mngrNm').text('-');
				$('#modal-mngrTelno').text('-');
			}
			
			$('#modal-insctrNm').text(res.insctrVO.mbrNm);
			
			let insctrTelNo = splitTel(res.insctrVO.mbrTelno);
			$('#modal-insctrTelno').text(insctrTelNo[0]+"-"+insctrTelNo[1]+"-"+insctrTelNo[2]);
			//$('#modal-insctrTelno1').val(insctrTelNo[0]);
			//$('#modal-insctrTelno2').val(insctrTelNo[1]);
			//$('#modal-insctrTelno3').val(insctrTelNo[2]);
			
			let chckYmd = strToDate(res.chckYmd)
			$('#modal-chckYmd').text(chckYmd);
			$('#modal-totStr').text(res.totStr);
			$('#modal-clenScr').text(res.clenScr);
			$('#modal-srvcScr').text(res.srvcScr);
			
			let chckCn = '-'
			if(res.chckCn){
				chckCn = res.chckCn
			}
			$('#modal-chckCn').html(chckCn);
			
			}
		});			
}

function deletefrcsCheck(){
	let frcsCheckVO = {};
	
	frcsCheckVO.frcsNo = frcsNo;
	frcsCheckVO.chckSeq = chckSeq;
	frcsCheckVO.totStr = $('#modal-totStr').text();

	//console.log(frcsCheckVO);

	// 서버전송
	$.ajax({
		url : "/hdofc/frcs/check/delete",
		type : "POST",
		data: JSON.stringify(frcsCheckVO),
		contentType: "application/json",  // JSON 형식으로 전송
		// csrf설정 secuity설정된 경우 필수!!
		beforeSend:function(xhr){ 
			xhr.setRequestHeader(csrfHeader, csrfToken); // CSRF 헤더와 토큰을 설정
		},
		success : function(res){
			if(res=='clsbiz'){
				Swal.fire({
				  html: `<p>경고 횟수가 2회로 변경되어</p>
				  		 <p>가맹점을 폐업조치를 취소처리되었습니다</p>`,
				  icon: "info"
				})
				.then(function(result){
					location.reload();
				})
			} else {
			Swal.fire({
				  title: "완료",
				  html: "삭제가 완료되었습니다",
				  icon: "success",
				  confirmButtonColor: "#00C157",
				  confirmButtonText: "확인",
				}).then((result) => {
					location.reload();
				});
			}
		}
	});
}
