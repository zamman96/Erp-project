<meta name="_csrf" content="${_csrf.token}">
<meta name="_csrf_header" content="${_csrf.headerName}">
<%@page import="com.buff.util.Telno"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>  
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11.4.10/dist/sweetalert2.min.css">
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.4.10/dist/sweetalert2.min.js"></script>
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script src='/resources/js/global/value.js'></script>
<script type="text/javascript" src="/resources/js/jquery.min.js"></script>
<sec:authentication property="principal.MemberVO" var="user"/>
<link href="/resources/cnpt/css/gds.css" rel="stylesheet">
<script type="text/javascript">
$(function(){
	select2Custom(); 
	
	// 	비밀번호 확인 버튼 클릭시 이벤트 핸들러
	$("#ModalBtnCheck").on("click", function(){
		
		var inputPswd = $("#pswdInput").val();
		$("#pswdInput").val('');
		
		console.log("inputPswd : " + inputPswd);
		
		// 비밀번호 검증 Ajax 비동기 처리
		$.ajax({
			url : "/find/checkPswd",
			type : "POST",
			data : { inputPswd : inputPswd },
			dataType:"text",
			beforeSend : function(xhr){ 
				xhr.setRequestHeader("${_csrf.headerName}","${_csrf.token}"); 
			},
			success : function(res){
				console.log("res : ", res);
				
				if(res === "success"){
					// 	비밀번호 일치 -> 모달창 닫고 수정모드로 전환
					$("#pswdCheck").modal("hide");
					$("#ModalBtnCancel").click();
					
					/* 비밀번호 추가 시작*/
					$('.pwChange').show();
					/* 비밀번호 추가 끝*/
					
					// 정보 수정모드 전환
					$("#div1").css("display","none");
					$("#div2").css("display","block");
					
					$(".input-tel").removeAttr("disabled");
					$(".input-zip").removeAttr("disabled");
					$(".input-addr").removeAttr("disabled");
					$(".w-150").removeAttr("disabled");
					$(".text-input").removeAttr("disabled");
					
					$("#btnPost1").removeAttr("disabled");
					$("#btnPost2").removeAttr("disabled");
					$("#bzentBankType").prop("disabled", false); // 은행 선택 활성화
					
					<sec:authorize access="!hasRole('ROLE_CEO')">
						$(".bzentInput").prop("disabled", true); // CEO아니면 수정불가
					</sec:authorize>
				} else {
					// 	비밀번호 불일치
					Swal.fire({
					      icon: 'error',
					      title: 'Error!',
					      text: '비밀번호가 일치하지 않습니다..'
					    });
					
				}
			},
			error : function(xhr, status, error){
					console.log("xhr: ", xhr);
			    	console.log("status: ", status);
			    	console.log("error: ", error);
			}
			
		});
		
	// 모달창 이벤트 핸들러 끝.	
	});
	
	// 업체 정보 수정 비동기 처리 Ajax
	$("#btnSave").on("click", function(){
		
		/* 비밀번호 추가 시작*/
		let mbrPswd = $('#mbrPswd1').val();
		let mbrPswd2 = $('#mbrPswd2').val();
		
		if((mbrPswd || mbrPswd2) && (mbrPswd != mbrPswd2)){
			Swal.fire({
			      icon: 'error',
			      title: '오류',
			      text: '비밀번호가 일치하지 않습니다.'
			    });
			return;
		}
		
		$('.pwChange').hide();
		$('#mbrPswd1').val('');
		$('#mbrPswd2').val('');
		/* 비밀번호 추가 끝*/
		
		let bzentNo = $("#bzentNo").val();
		let bzentNm = $("#bzentNm").val();
		let bzentZip = $("#bzentZip").val();
		let bzentAddr = $("#bzentAddr").val();
		let bzentDaddr = $("#bzentDaddr").val();
		let bzentTelno1 = $("#bzentTelno1").val();
		let bzentTelno2 = $("#bzentTelno2").val();
		let bzentTelno3 = $("#bzentTelno3").val();
		let bzentTelno = bzentTelno1 + bzentTelno2 + bzentTelno3;
		let bankType = $("#bzentBankType").val();
		let actno = $("#bzentActno").val();
		
		let cnptObj = {
				
				"bzentNo" : bzentNo,
				"bzentNm" : bzentNm,
				"bzentZip" : bzentZip,
				"bzentAddr" : bzentAddr,
				"bzentDaddr" : bzentDaddr,
				"bzentTelno" : bzentTelno,
				"bankType" : bankType,
				"actno" : actno,
		}
		
		console.log("cnptObj : " + cnptObj);
		
		$.ajax({
			url : "/hdofc/myPage/updateHdofc",
			type : "POST",
			data : JSON.stringify(cnptObj),
			dataType : "text",
			contentType: "application/json; charset=utf-8",
			beforeSend : function(xhr){
		    	 xhr.setRequestHeader("${_csrf.headerName}","${_csrf.token}");
		     },
			success : function(res){
				
				if(res.trim() === "success"){
					let mbrNm = $("#mbrNm").val();
					let mbrZip = $("#mbrZip").val();
					let mbrAddr = $("#mbrAddr").val();
					let mbrDaddr = $("#mbrDaddr").val();
					let mbrTelno1 = $("#mbrTelno1").val();
					let mbrTelno2 = $("#mbrTelno2").val();
					let mbrTelno3 = $("#mbrTelno3").val();
					let mbrTelno = mbrTelno1 + mbrTelno2 + mbrTelno3;
					let mbrEmlAddr = $("#mbrEmlAddr").val();
					
					let dataObj = {
						"mbrNm" : mbrNm,
						"mbrZip" : mbrZip,
						"mbrAddr" : mbrAddr,
						"mbrDaddr" : mbrDaddr,
						"mbrTelno" : mbrTelno,
						"mbrEmlAddr" : mbrEmlAddr,
						"mbrPswd" : mbrPswd
					}/* 비밀번호 추가로 꼭 넣기*/
					
					console.log("dataObj : " , dataObj);
					
					$.ajax({
						url : "/hdofc/myPage/updateMbr",
						data: JSON.stringify(dataObj),
						type : "POST",
						dataType : "text",
						contentType:"application/json; charset=utf-8",
						beforeSend : function(xhr){
					    	 xhr.setRequestHeader("${_csrf.headerName}","${_csrf.token}");
					     },
					    success : function(res){
					    	if(res.trim() === "success"){
									Swal.fire({
									      icon: 'success',
									      title: '성 공!',
									      text: '정보 수정 완료'
									    });
								
								// 일반모드로 전환
								$("#div1").css("display","block");
								$("#div2").css("display","none");
								
								$(".input-tel").attr("disabled",true);
								$(".input-zip").attr("disabled",true);
								$(".input-addr").attr("disabled",true);
								$(".w-150").attr("disabled",true);
								$(".text-input").attr("disabled",true);
								
								$("#btnPost1").attr("disabled",true);
								$("#btnPost2").attr("disabled",true);
								$("#bzentBankType").attr("disabled", true);
									
					    	} else {
					    		Swal.fire({
								      icon: 'error',
								      title: 'Error!',
								      text: '거래처 담당자 정보 수정에 실패했습니다.'
					    		});		    		
					    	}
				},    
					    error : function(xhr, status, error){
						    	console.log("xhr: ", xhr);
							    console.log("status: ", status);
							    console.log("error: ", error);
						    
						    	Swal.fire({
								      icon: 'error',
								      title: 'Error!',
								      text: '서버 오류가 발생했습니다.'
								    });	
				}  	
						
			// 두번째 ajax 비동기 처리 끝	
			});
			// 첫번째 ajax success if문 끝
			}
			// 첫번째 ajax success 끝	
			}	
			// 첫번째 ajax 비동기 처리 끝	!			
			})
		// btnSave 이벤트 끝	
		})
		
	// 주소 현재 값 저장할 변수들
	var originBzentZip, originBzentAddr, originBzentDaddr, originBzentTelno, originBzentActno;
	var originMbrZip, originMbrAddr, originMbrDaddr, originMbrTelno, originMbrEmlAddr;
	
	// 거래처 수정모드로 전환
	$("#btnEdit").on("click",function(){
		
		
		//	비밀번호 체크 모달창 띄우기
		//$("#pswdCheck").modal("show");
		
		// 수정모드로 전환
		
		$("#div1").css("display","none");
		$("#div2").css("display","block");
		
		$(".input-tel").removeAttr("disabled");
		$(".input-zip").removeAttr("disabled");
		$(".input-addr").removeAttr("disabled");
		$(".w-150").removeAttr("disabled");
		$(".text-input").removeAttr("disabled");
		
		$("#btnPost1").removeAttr("disabled");
		$("#btnPost2").removeAttr("disabled");
		$("#bzentBankType").removeAttr("disabled");
		
		// 현재 값을 저장
		originBzentZip = $("#bzentZip").val();
		originBzentAddr = $("#bzentAddr").val();
		originBzentDaddr = $("#bzentDaddr").val();
		originBzentTelno = $("#bzentTelno").val();
		originBzentActno = $("#bzentActno").val();
		
		// 현재 값을 저장
		originMbrZip = $("#mbrZip").val();
		originMbrAddr = $("#mbrAddr").val();
		originMbrDaddr = $("#mbrDaddr").val();
		originMbrTelno = $("#mbrTelno").val();
		originMbrEmlAddr = $("#mbrEmlAddr").val();
	});
	
	
	// 모달 취소버튼 클릭-> 일반모드 전환
	$("#ModalBtnCancel, .modal-close, #btnCancel").on("click", function(){
		
		$("#pswdInput").val("");
		
		$("#div1").css("display","block");
		$("#div2").css("display","none");
		
		$(".input-tel").attr("disabled",true);
		$(".input-zip").attr("disabled",true);
		$(".input-addr").attr("disabled",true);
		$(".w-150").attr("disabled",true);
		$(".text-input").attr("disabled",true);
		
		$("#btnPost1").attr("disabled",true);
		$("#btnPost2").attr("disabled",true);
		$("#bzentBankType").attr("disabled", true);
		
		// 	저장된 값으로 복원
		$("#bzentZip").val(originBzentZip);
		$("#bzentAddr").val(originBzentAddr);
		$("#bzentDaddr").val(originBzentDaddr);
		$("#bzentTelno").val(originBzentTelno);
		$("#bzentActno").val(originBzentActno);
		
		$("#mbrZip").val(originMbrZip);
		$("#mbrAddr").val(originMbrAddr);
		$("#mbrDaddr").val(originMbrDaddr);
		$("#mbrTelno").val(originMbrTelno);
		$("#mbrEmlAddr").val(originMbrEmlAddr);
		
		$("#pswdCheck").modal("hide");
		
	})
	
	// 우편번호 검색 API 사용 
	$("#btnPost1").on("click", function(){
		 new daum.Postcode({
			 	// 다음 창에서 검색이 완료되어 클릭하면 콜백함수에 의해 
			 	// 결과 데이터가 data객체로 들어옴
		        oncomplete: function(data) {
		        	
		        		$("#bzentZip").val(data.zonecode);
		        		$("#bzentAddr").val(data.address);
		        		$("#bzentDaddr").val(data.buildingName);
		        		$("#bzentDaddr").focus();
		        }
		    }).open();
	})
	
	$("#btnPost2").on("click", function(){
		 new daum.Postcode({
			 	// 다음 창에서 검색이 완료되어 클릭하면 콜백함수에 의해 
			 	// 결과 데이터가 data객체로 들어옴
		        oncomplete: function(data) {
		        	
		        	$("#mbrZip").val(data.zonecode);
	        		$("#mbrAddr").val(data.address);
	        		$("#mbrDaddr").val(data.buildingName);
	        		$("#mbrDaddr").focus();
		        }
		    }).open();
	})
	

});
</script>
<!-- content-header: 페이지 이름 -->
<div class="content-header">
  <div class="container-fluid">
    <div class="row mb-2 justify-content-between">
      <div class="row align-items-center">
        <h1 class="m-0">마이 페이지</h1>
      </div><!-- /.col -->
	    <div class="btn-wrap">
			<!-- 일반 모드 시작 -->
			<div id="div1">
				<button type="button" class="btn-active" 
				        id="btnEdit"
				        data-toggle="modal" data-target="#pswdCheck">정보 수정
				</button>
			</div>
			<!-- 일반 모드 끝 -->
			<!-- 수정 모드 시작 -->
			<div id="div2" style="display: none;">
				<button type="button" id="btnCancel" class="btn-default">취소</button>
				<button type="submit" id="btnSave" class="btn-active">저장</button>
			</div>
		</div> 
    </div><!-- /.row -->
  </div><!-- /.container-fluid -->
</div>
<!-- /.content-header -->


<div class="wrap">
	<!-- cont: 해당 영역의 설명 -->
	<div class="cont">
		<!-- table-wrap 가맹점 정보-->
		<div class="table-wrap" style="overflow-x: inherit;">
			<div class="table-title">
					<div class="cont-title"><span class="material-symbols-outlined title-icon">domain</span>본사 정보</div>
			</div>
			<table class="table-blue">
				<tr>
					<th width="15%;">업체 명</th>
					<td>
						<input type="text" id="bzentNm" 
							   name="bzentNm" value="${bzentVO.bzentNm}" class="bzentInput" disabled readonly />
						<input type="hidden" id="bzentNo" name="bzentNo" value="${bzentVO.bzentNo}" />
					</td>
					<c:set var="phoneNumber" value="${bzentVO.bzentTelno}" />
					<%
						String phoneNumber = (String) pageContext.getAttribute("phoneNumber");
					
						// 전화번호를 분할하여 저장할 배열
						String[] telParts = {"","",""}; 	// 빈 값으로 기본 설정
						if(phoneNumber != null && !phoneNumber.isEmpty()){
							telParts = Telno.splitTel(phoneNumber);
						}
						
					%>
					<th>전화번호</th>
					<td>
						<div class="tel-wrap">
							<input id="bzentTelno1" name="bzentTelno1"
								   value="<%= telParts[0] %>" disabled type="text" class="input-tel bzentInput">-
							<input id="bzentTelno2" name="bzentTelno2"
								   value="<%= telParts[1] %>" disabled type="text" class="input-tel bzentInput">-
							<input id="bzentTelno3" name="bzentTelno3"
								   value="<%= telParts[2] %>" disabled type="text" class="input-tel bzentInput">
						</div>
					</td>
				</tr>
				<tr>
					<th>주소</th>
					<td colspan="3">
						<div class="addr-zip-wrap">
							<div class="addr-wrap">
								<input class="input-zip bzentInput" id="bzentZip" name="bzentZip"
									   value="${bzentVO.bzentZip}"disabled type="text"/>
								<button class="btn-default btn-click bzentInput" type="button" id="btnPost1" disabled>우편번호 검색</button>
							</div>
							<div class="addr-wrap">
								<input class="input-addr bzentInput" id="bzentAddr" name="bzentAddr"
									   value="${bzentVO.bzentAddr}" disabled type="text"/>
								<input class="input-addr bzentInput" id="bzentDaddr" name="bzentDaddr"
									   value="${bzentVO.bzentDaddr}" disabled type="text"/>
							</div>
						</div>
					</td>
				</tr>
				<tr>
					<th>은행 명</th>
					<td>
						<div class="select-custom">
							<select class="select-bank bzentInput" name="bzentBankType" id="bzentBankType" disabled>
								<!-- 미선택 기본 옵션 -->
					            <option value="">미선택</option>
					            
					            <!-- bankVO 리스트에서 bzentVO.bankType과 일치하는 comNo를 찾아서 해당 comNm 출력 -->
					            <c:forEach var="bankVO" items="${bankVO}">
					                <c:choose>
					                    <c:when test="${bankVO.comNo == bzentVO.bankType}">
					                        <option value="${bankVO.comNo}" selected>${bankVO.comNm}</option>
					                    </c:when>
					                    <c:otherwise>
					                        <option value="${bankVO.comNo}">${bankVO.comNm}</option>
					                    </c:otherwise>
					                </c:choose>
					            </c:forEach>
							</select>
						</div>
					</td>
					<th width="15%;">계좌번호</th>
					<td>
						<input type="text" class="text-input bzentInput" 
							   id="bzentActno" name="bzentActno"
							   value="${bzentVO.actno}" disabled />
					</td>
				</tr>
			</table>
		<!-- table-wrap 끝 -->
		</div>
	<!-- 첫번째 cont 끝 -->	
	</div>	
	
	<!-- cont: 해당 영역의 설명 -->
	<div class="cont">
		<!-- table-wrap 가맹점 정보-->
		<div class="table-wrap">
			<div class="table-title">
					<div class="cont-title"><span class="material-symbols-outlined title-icon">manage_accounts</span>사원 개인 정보</div>
			</div>
			<table class="table-blue">
				<tr>
					<th width="15%;">담당자 명</th>
					<td>
						<input type="text" id="mbrNm" name="mbrNm"
							   value="${mngr.memberVO.mbrNm}" disabled readonly />
					</td>
										<c:set var="phoneNumber2" value="${mngr.memberVO.mbrTelno}" />
					<%
						String phoneNumber2 = (String) pageContext.getAttribute("phoneNumber2");
					
						// 전화번호를 분할하여 저장할 배열
						String[] telParts2 = {"","",""}; 	// 빈 값으로 기본 설정
						if(phoneNumber2 != null && !phoneNumber2.isEmpty()){
							telParts2 = Telno.splitTel(phoneNumber2);
						}
						
					%>
					<th>전화번호</th>
					<td>
						<div class="tel-wrap">
							<input id="mbrTelno1" name="mbrTelno1"
								   value="<%= telParts2[0] %>" disabled type="text" class="input-tel">-
							<input id="mbrTelno2" name="mbrTelno2"
								   value="<%= telParts2[1] %>" disabled type="text" class="input-tel">-
							<input id="mbrTelno3" name="mbrTelno3"
								   value="<%= telParts2[2] %>" disabled type="text" class="input-tel">
						</div>
					</td>
				</tr>
				<!-- 비밀번호 추가 시작 -->
				<tr class="pwChange"  style="display: none;">
					<th>
						비밀번호 변경
					</th>
					<td class="pwChange" colspan="3">
						<div class="addr-zip-wrap">
							<div class="addr-wrap">
								<input class="input-addr" id="mbrPswd1" name="mbrPswd1"
									   disabled type="password" placeholder="비밀번호"/>
								<input class="input-addr" id="mbrPswd2" name="mbrPswd2"
									   disabled type="password" placeholder="비밀번호 확인"/>
							</div>
						</div>
					</td>
				</tr>
				<!-- 비밀번호 추가 끝 -->
				<tr>
					<th>주소</th>
					<td colspan="3">
						<div class="addr-zip-wrap">
							<div class="addr-wrap">
								<input class="input-zip" id="mbrZip" name="mbrZip"
									   value="${mngr.memberVO.mbrZip}" disabled type="text"/>
								<button class="btn-default btn-click" type="button" id="btnPost2" disabled>우편번호 검색</button>
							</div>
							<div class="addr-wrap">
								<input class="input-addr" id="mbrAddr" name="mbrAddr"
									   value="${mngr.memberVO.mbrAddr}" disabled type="text"/>
								<input class="input-addr" id="mbrDaddr" name="mbrDaddr"
									   value="${mngr.memberVO.mbrDaddr}" disabled type="text"/>
							</div>
						</div>
					</td>
				</tr>
				<tr>
					<th>이메일</th>
					<td>
						<input type="text" class="text-input" 
							   id="mbrEmlAddr" type="text" 
							   value="${mngr.memberVO.mbrEmlAddr}" disabled />
					</td>
				</tr>
			</table>
		<!-- table-wrap 끝 -->	
		</div>
	<!-- 두번째 cont 끝 -->
	</div>
	<!-- cont: 해당 영역의 설명 -->
	<div class="cont">
		<!-- table-wrap 가맹점 정보-->
		<div class="table-wrap">
			<div class="table-title">
					<div class="cont-title"><span class="material-symbols-outlined title-icon">manage_accounts</span>사원 정보</div>
			</div>
			<table class="table-blue">
				<tr>
					<th width="15%;">구분</th>
					<td>
						<span class="bge bge-default-border">${mngr.mngrTypeNm}</span>
					</td>
					<th width="15%;">입사 일자</th>
					<td>
					<c:set var="jncmp" value="${mngr.jncmpYmd.substring(0,4)}-${mngr.jncmpYmd.substring(4,6)}-${mngr.jncmpYmd.substring(6,8)}" />
						${jncmp}
					</td>
				</tr>
 				<tr>
					<th>담당 가맹점</th>
					<td colspan="3">
						<c:if test="${mngr.frcsNames!=null}">
							<span>${mngr.frcsNames}</span>
						</c:if>
						<c:if test="${mngr.frcsNames==null}">
							<span>-</span>
						</c:if>
					</td>
				</tr>
 				<tr>
					<th>담당 거래처</th>
					<td colspan="3">
					<c:if test="${mngr.cnptNames!=null}">
						<span>${mngr.cnptNames}</span>
					</c:if>
					<c:if test="${mngr.cnptNames==null}">
						<span>-</span>
					</c:if>
					</td>
				</tr>
			</table>
		<!-- table-wrap 끝 -->	
		</div>
	<!-- 두번째 cont 끝 -->
	</div>
	
</div>	

 <!-- 비밀번호 확인 모달 -->
 <div class="modal fade" id="pswdCheck" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content">
<!-- Modal Header -->
				<div class="modal-header">
					<h4 class="modal-title">비밀번호 확인</h4>
					<div class="btn-wrap">
						<button type="button" class="modal-close" data-bs-dismiss="modal">닫기</button>
						<button type="button" id="ModalBtnCheck" class="btn-active">확인</button>
					</div>
				</div>
<!-- Modal body -->
				<div class="modal-body">
					<div class="form-group">
						<label for="pswdInput">비밀번호를 입력하세요.</label>
						<input type="password" class="text-input" id="pswdInput" 
							   name="pswdInput" placeholder="비밀번호를 입력하세요." />
					</div>
				</div>
<!-- Modal footer -->
			</div>
		</div>
<!-- modal창 끝--> 
</div>













