<%@ page language="java" contentType="text/html; charset=UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c"%>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script type="text/javascript" src="/resources/js/jquery.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
<link rel="stylesheet" href="/resources/frcs/css/myPage.css">
<script src='/resources/js/global/value.js'></script>
<link href="https://cdn.jsdelivr.net/npm/select2@4.1.0-beta.1/dist/css/select2.min.css" rel="stylesheet" />
<script src="https://cdnjs.cloudflare.com/ajax/libs/select2/4.0.8/js/select2.min.js" defer></script>

<sec:authentication property="principal.MemberVO" var="user"/>
<%--
	@fileName    : myPage.jsp
	@programName : 마이페이지 정보 조회 화면
	@description : 가맹점과 가맹점주를 위한 마이페이지 정보 조회 및 수정, 폐업신청 화면, 가맹점 관리자 정보
	@author      : 김 현 빈
	@date        : 2024. 09. 12
--%>

<script type="text/javascript">

// 회원 아이디 시큐리티
let data = '${user.mbrId}';
// 가맹점 번호 시큐리티
let frcsNo = '${user.bzentNo}';

//다음 api
function openHomeSearch(){
	new daum.Postcode({
	    oncomplete: function(data) {
	    	$('#bzentZip').val(data.zonecode);
	    	$('#bzentAddr').val(data.address);
	    	$('#bzentDaddr').val(data.buildingName);
	    	$('#bzentDaddr').focus();
	    }
	}).open();
}
function goToHomePage() {
    window.location.href = "/frcs/main"; // 경로에 맞게 이동
}
$(document).ready(function(){
	// 처음에는 비밀번호 변경 행을 숨김
    $("#pwChangeTr").hide();
	
	$("#div2").hide();
	
	$("#ModalBtnCheck").on("click", function(){
		
		var inputPswd = $("#pswdInput").val();
		
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
// 					$("#ModalBtnCancel").click();
					
					// 정보 수정모드 전환
					$("#div1").css("display","none");
					$("#div2").css("display","block");
					
					$("#bzentTelno1").removeAttr("disabled");
					$("#bzentTelno2").removeAttr("disabled");
					$("#bzentTelno3").removeAttr("disabled");
					$("#openTm").removeAttr("disabled");
					$("#ddlnTm").removeAttr("disabled");
					$("#bzentZip").removeAttr("disabled");
					$("#bzentAddr").removeAttr("disabled");
					$("#bzentDaddr").removeAttr("disabled");
					$("#mbrNm").removeAttr("disabled");
					$("#mbrTelno1").removeAttr("disabled");
					$("#mbrTelno2").removeAttr("disabled");
					$("#mbrTelno3").removeAttr("disabled");
					$("#mbrEmlAddr").removeAttr("disabled");
					$("#bankType").removeAttr("disabled");
					$("#actno").removeAttr("disabled");

					
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
	
	// 마이페이지 관리자 정보 출력 Ajax
	$.ajax({
		url:"/frcs/selectFrcsMngrAjax",
		contentType:"application/json;charset=utf-8",
		data:data,
		type:"post",
		dataType:"json",
		beforeSend:function(xhr){
			xhr.setRequestHeader("${_csrf.headerName}","${_csrf.token}");
		},
		success:function(res){
			if (res && res.bzentVO && res.bzentVO.mbrVO) {
	            console.log("res(관리자 정보) : ", res);
	            
	            // 관리자 이름 출력 (null 또는 빈 값일 경우 '-' 표시)
	            let mngrNm = res.bzentVO.mbrVO.mbrNm;
	            $("#mngrNm").text(mngrNm ? mngrNm : '-');
	            
	            // 관리자 전화번호 출력 (null 또는 빈 값일 경우 '-' 표시)
	            let telno = res.bzentVO.mbrVO.mbrTelno;
	            let telno1, telno2, telno3;

	            if (!telno) {
	                $("#mngrTelno").text('-');
	            } else if (telno.length === 10) {
	                telno1 = telno.substring(0, 2);
	                telno2 = telno.substring(2, 6);
	                telno3 = telno.substring(6);
	                $("#mngrTelno").text(telno1 + "-" + telno2 + "-" + telno3);
	            } else if (telno.length === 11) {
	                telno1 = telno.substring(0, 3);
	                telno2 = telno.substring(3, 7);
	                telno3 = telno.substring(7);
	                $("#mngrTelno").text(telno1 + "-" + telno2 + "-" + telno3);
	            } else {
	                $("#mngrTelno").text('-');
	            }
	            
	            // 관리자 이메일 출력 (null 또는 빈 값일 경우 '-' 표시)
	            let mngrEmlAddr = res.bzentVO.mbrVO.mbrEmlAddr;
	            $("#mngrEmlAddr").text(mngrEmlAddr ? mngrEmlAddr : '-');
	        } else {
	            // 담당 관리자 정보가 없을 경우
	            $("#mngrNm").text('-');
	            $("#mngrTelno").text('-');
	            $("#mngrEmlAddr").text('-');
	        }
	    },
	    error: function(xhr, status, error) {
	        // 오류 발생 시에도 기본값 '-'를 표시
	        $("#mngrNm").text('-');
	        $("#mngrTelno").text('-');
	        $("#mngrEmlAddr").text('-');
	        console.log("오류 발생: ", error);
	    }
	});
	
	// 마이페이지 가맹점, 가맹점주 정보 출력 Ajax
	$.ajax({
		url:"/frcs/myPageAjax",
		contentType:"application/json;charset=utf-8",
		data:data,
		type:"post",
		dataType:"json",
		beforeSend:function(xhr){
			xhr.setRequestHeader("${_csrf.headerName}","${_csrf.token}");
		},
		success:function(result){
			console.log("result(가맹점, 가맹점주 정보) : ", result);
			
            //<label>가맹점 이름</label>
            //<input id="bzentNm" type="text" value="">
            // id 설정 후, 선택자로 셀렉트 해와서 result -> bzentVO -> bzentNm 순으로 프로퍼티 접근
			
			$("#bzentNm").text(result.bzentVO.bzentNm);
			$("#bzentZip").val(result.bzentVO.bzentZip);
			$("#bzentAddr").val(result.bzentVO.bzentAddr);
			$("#bzentDaddr").val(result.bzentVO.bzentDaddr);
// 			$("#rgnNo").text(result.bzentVO.rgnNo);
// 			$("#rgnNm").val(result.bzentVO.rgnNm);
			
// 			$("#openTm").val(result.openTm);
// 			$("#ddlnTm").val(result.ddlnTm);

			// openTm과 ddlnTm을 "0800"에서 "08:00" 형식으로 포맷팅
			let openTmFormatted = result.openTm.substring(0, 2) + ':' + result.openTm.substring(2);
			let ddlnTmFormatted = result.ddlnTm.substring(0, 2) + ':' + result.ddlnTm.substring(2);
			
			$("#openTm").val(openTmFormatted);
			$("#ddlnTm").val(ddlnTmFormatted);
			
			$("#warnCnt").text(result.warnCnt);
			$("#mbrNm").val(result.bzentVO.mbrVO.mbrNm);
			$("#bzentNm2").text(result.bzentVO.bzentNm);
			$("#bankType").val(result.bzentVO.bankType);
			$("#bankTypeNm").val(result.bzentVO.bankTypeNm);
			$("#actno").val(result.bzentVO.actno);
			$("#mbrEmlAddr").val(result.bzentVO.mbrVO.mbrEmlAddr);
			
			let telno = result.bzentVO.bzentTelno;
			
			let telno1, telno2, telno3;
			
			if (telno.length === 10) {
				// 전화번호가 10자리인 경우에는 2자리, 4자리, 4자리로 나누어 출력합니다.
			    telno1 = telno.substring(0, 2);
			    telno2 = telno.substring(2, 6);
			    telno3 = telno.substring(6);
			} else {
			    // 전화번호가 11자리인 경우에는 3자리, 4자리, 4자리로 나누어 출력합니다.
			    telno1 = telno.substring(0, 3);
			    telno2 = telno.substring(3, 7);
			    telno3 = telno.substring(7);
			}
			
			$("#bzentTelno1").val(telno1);
			$("#bzentTelno2").val(telno2);
			$("#bzentTelno3").val(telno3);
			
			// DB에서 가져온 개업일자를 YYYYMMDD 형식으로 가정
			let dbDate = result.opbizYmd;

			// YYYYMMDD 형식을 YYYY-MM-DD 형식으로 변환
			let formattedDate = dbDate.replace(/(\d{4})(\d{2})(\d{2})/, '$1-$2-$3');

			// input 필드에 값을 설정
			$("#opbizYmd").text(formattedDate);
			
			let telNum = result.bzentVO.mbrVO.mbrTelno;
			
			let telNum1, telNum2, telNum3;
			
			if (telNum.length === 10) {
				telNum1 = telNum.substring(0, 2);
				telNum2 = telNum.substring(2, 6);
				telNum3 = telNum.substring(6);
			} else {
			    // 전화번호가 11자리인 경우에는 3자리, 4자리, 4자리로 나누어 출력합니다.
			    telNum1 = telNum.substring(0, 3);
			    telNum2 = telNum.substring(3, 7);
			    telNum3 = telNum.substring(7);
			}
			
			$("#mbrTelno1").val(telNum1);
			$("#mbrTelno2").val(telNum2);
			$("#mbrTelno3").val(telNum3);
			
			// 서버 응답에서 받아온 값에 따라 가맹점 상태를 결정합니다.
			let frcsTypeNm = "";
			switch(result.frcsType) {
				case "FRS01":
					frcsTypeNm = "운영";
					break;
				case "FRS02":
					frcsTypeNm = "폐업";
					break;
				case "FRS03":
					frcsTypeNm = "폐업 예정";
					break;
				default:
					frcsTypeNm = "알 수 없음";
			}
			
			$("#frcsType").text(frcsTypeNm);
			
		}
	});
	
	$("#btnEdit").on("click", function() {
        $("#bankTypeViewMode").hide(); // 일반 모드 숨기기
        $("#bankTypeEditMode").show(); // 수정 모드 보이기
    });

    // 수정 모드에서 일반 모드로 전환
    $("#btnCancel").on("click", function() {
        $("#bankTypeEditMode").hide(); // 수정 모드 숨기기
        $("#bankTypeViewMode").show(); // 일반 모드 보이기
    });
	
	// 가맹점, 가맹점주 수정 클릭이벤트 시작!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
	$("#updateFrcsBtn").on("click", function() {
		
		let mbrPswd = $("#mbrPswd").val();
		let mbrPswdCheck = $("#mbrPswdCheck").val();
		
		// 비밀번호와 비밀번호 확인이 일치하는지 체크
		if (mbrPswd !== mbrPswdCheck) {
			Swal.fire({
				icon: "error",
				title: "비밀번호가 다릅니다"
			});
			return; // 비밀번호가 일치하지 않으면 더 이상 진행하지 않음
		}
		
// 		let openTm = $("#openTm").val();
// 		let ddlnTm = $("#ddlnTm").val();
		// "08:00" 형식을 "0800"으로 변환
		let openTm = $("#openTm").val().replace(":", "");
 		let ddlnTm = $("#ddlnTm").val().replace(":", "");
		let actno = $("#actno").val();
		let bankType = $("#bankType").val();
			
		let bzentTelno1 = $("#bzentTelno1").val();
		let bzentTelno2 = $("#bzentTelno2").val();
		let bzentTelno3 = $("#bzentTelno3").val();
		let bzentZip = $("#bzentZip").val();
		let bzentAddr = $("#bzentAddr").val();
		let bzentDaddr = $("#bzentDaddr").val();
		let rgnNo = $("#bzentDaddr").val();
			
		let mbrNm = $("#mbrNm").val();
		let mbrTelno1 = $("#mbrTelno1").val();
		let mbrTelno2 = $("#mbrTelno2").val();
		let mbrTelno3 = $("#mbrTelno3").val();
		let mbrEmlAddr = $("#mbrEmlAddr").val();
		
		let dataObj = {
                "openTm":openTm,
                "ddlnTm":ddlnTm,
                "bzentVO":{
                	"bzentTelno":bzentTelno1 + bzentTelno2 + bzentTelno3,
                	"bzentZip":bzentZip,
                	"bzentAddr":bzentAddr,
                	"bzentDaddr":bzentDaddr,
                	"actno":actno,
            		"bankType":bankType,
            		"rgnNo":rgnNo,
                	"mbrId":data,
                	"mbrVO": {
        	        	"mbrNm":mbrNm,
        	        	"mbrTelno":mbrTelno1 + mbrTelno2 + mbrTelno3,
        	        	"mbrEmlAddr":mbrEmlAddr,
        	        	"mbrPswd":mbrPswd,
        	        	"mbrId":data
                	}
                }
            };
		console.log(dataObj);
		
		 // AJAX 요청
        $.ajax({
            url:"/frcs/updateMyPageAjax",
            contentType:"application/json;charset=utf-8",
            data:JSON.stringify(dataObj),
            type: "post",
            dataType: "json",
            beforeSend: function(xhr) {
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
            success: function(result) {
                console.log("수정 결과 : ", result);
				Swal.fire({
 					icon: "success",
					title: "수정하였습니다",
					showConfirmButton: false,
  					timer: 1500
  					
  					
				});
				// 수정된 데이터를 바로 화면에 반영하는 부분
// 		        $("#bzentTelno1").val(result.bzentVO.bzentTelno.substring(0, 3));
// 		        $("#bzentTelno2").val(result.bzentVO.bzentTelno.substring(3, 7));
// 		        $("#bzentTelno3").val(result.bzentVO.bzentTelno.substring(7));
// 		        $("#openTm").val(result.openTm.substring(0, 2) + ":" + result.openTm.substring(2));
// 		        $("#ddlnTm").val(result.ddlnTm.substring(0, 2) + ":" + result.ddlnTm.substring(2));
// 		        $("#bzentZip").val(result.bzentVO.bzentZip);
// 		        $("#bzentAddr").val(result.bzentVO.bzentAddr);
// 		        $("#bzentDaddr").val(result.bzentVO.bzentDaddr);
// 		        $("#mbrNm").val(result.bzentVO.mbrVO.mbrNm);
// 		        $("#mbrTelno1").val(result.bzentVO.mbrVO.mbrTelno.substring(0, 3));
// 		        $("#mbrTelno2").val(result.bzentVO.mbrVO.mbrTelno.substring(3, 7));
// 		        $("#mbrTelno3").val(result.bzentVO.mbrVO.mbrTelno.substring(7));
// 		        $("#mbrEmlAddr").val(result.bzentVO.mbrVO.mbrEmlAddr);
// 		        $("#bankType").val(result.bzentVO.bankType);
// 		        $("#actno").val(result.bzentVO.actno);
            },
            error: function(xhr, status) {
                console.error("AJAX 오류:", status);
				Swal.fire({
					icon: "error",
					title: "수정에 실패했습니다"
				});
            }
        });
		
	});
	// 가맹점, 가맹점주 수정 클릭이벤트 끝!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
	
	// 기존 정보를 저장할 변수들 선언
	var originBzentTelno1, originBzentTelno2, originBzentTelno3, originOpenTm, originDdlnTm;
	var originBzentZip, originBzentAddr, originBzentDaddr, originMbrNm, originMbrTelno1;
	var originMbrTelno2, originMbrTelno3, originMbrEmlAddr, originBankType, originActno;
	
	// 가맹점, 가맹점주 수정모드로 전환
	$("#btnEdit").on("click",function(){
		
		$("#div1").css("display","none");
		$("#div2").css("display","block");
		
		
		
		$("#bzentTelno1").removeAttr("disabled");
		$("#bzentTelno2").removeAttr("disabled");
		$("#bzentTelno3").removeAttr("disabled");
		$("#openTm").removeAttr("disabled");
		$("#ddlnTm").removeAttr("disabled");
		$("#bzentZip").removeAttr("disabled");
		$("#bzentAddr").removeAttr("disabled");
		$("#bzentDaddr").removeAttr("disabled");
		$("#mbrNm").removeAttr("disabled");
		$("#mbrTelno1").removeAttr("disabled");
		$("#mbrTelno2").removeAttr("disabled");
		$("#mbrTelno3").removeAttr("disabled");
		$("#mbrEmlAddr").removeAttr("disabled");
		$("#bankType").removeAttr("disabled");
		$("#actno").removeAttr("disabled");
		
		// 우편번호 검색 버튼을 활성화
        $("#openHomeSearchBtn").attr("onclick", "openHomeSearch()");
		
		// 비밀번호 변경 행 표시
        $("#pwChangeTr").show();
		
		// 현재 값을 저장
		originBzentTelno1 = $("#bzentTelno1").val();
		originBzentTelno2 = $("#bzentTelno2").val();
		originBzentTelno3 = $("#bzentTelno3").val();
		originOpenTm = $("#openTm").val();
		originDdlnTm = $("#ddlnTm").val();
		originBzentZip = $("#bzentZip").val();
		originBzentAddr = $("#bzentAddr").val();
		originBzentDaddr = $("#bzentDaddr").val();
		originMbrNm = $("#mbrNm").val();
		originMbrTelno1 = $("#mbrTelno1").val();
		originMbrTelno2 = $("#mbrTelno2").val();
		originMbrTelno3 = $("#mbrTelno3").val();
		originMbrEmlAddr = $("#mbrEmlAddr").val();
		originBankType = $("#bankType").val();
		originActno = $("#actno").val();
		
	});
	
	//취소버튼 클릭->일반모드로 전환
	$("#btnCancel").on("click",function(){
		
		
		$("#div1").css("display","block");
		$("#div2").css("display","none");
		
		$("#bzentTelno1").attr("disabled",true);
		$("#bzentTelno2").attr("disabled",true);
		$("#bzentTelno3").attr("disabled",true);
		$("#openTm").attr("disabled",true);
		$("#ddlnTm").attr("disabled",true);
		$("#bzentZip").attr("disabled", true);
		$("#bzentAddr").attr("disabled", true);
		$("#bzentDaddr").attr("disabled", true);
		$("#mbrNm").attr("disabled", true);
		$("#mbrTelno1").attr("disabled", true);
		$("#mbrTelno2").attr("disabled", true);
		$("#mbrTelno3").attr("disabled", true);
		$("#mbrEmlAddr").attr("disabled", true);
		$("#bankType").attr("disabled", true);
		$("#actno").attr("disabled", true);
		
		// 우편번호 검색 버튼을 비활성화
        $("#openHomeSearchBtn").removeAttr("onclick");
		
		// 비밀번호 변경 행 숨기기
        $("#pwChangeTr").hide();
		
		// 	저장된 값으로 복원
		$("#bzentTelno1").val(originBzentTelno1);
		$("#bzentTelno2").val(originBzentTelno2);
		$("#bzentTelno3").val(originBzentTelno3);
		$("#openTm").val(originOpenTm);
		$("#ddlnTm").val(originDdlnTm);
		$("#bzentZip").val(originBzentZip);
		$("#bzentAddr").val(originBzentAddr);
		$("#bzentDaddr").val(originBzentDaddr);
		$("#mbrNm").val(originMbrNm);
		$("#mbrTelno1").val(originMbrTelno1);
		$("#mbrTelno2").val(originMbrTelno2);
		$("#mbrTelno3").val(originMbrTelno3);
		$("#mbrEmlAddr").val(originMbrEmlAddr);
		$("#bankType").val(originBankType);
		$("#actno").val(originActno);
		
		location.reload();
	});
	
	// 모달 취소버튼 클릭-> 일반모드 전환
	$("#ModalBtnCancel").on("click", function(){
		
		$("#pswdInput").val("");
		
		$("#div1").css("display","block");
		$("#div2").css("display","none");
		
		$("#bzentTelno1").attr("disabled",true);
		$("#bzentTelno2").attr("disabled",true);
		$("#bzentTelno3").attr("disabled",true);
		$("#openTm").attr("disabled",true);
		$("#ddlnTm").attr("disabled",true);
		$("#bzentZip").attr("disabled", true);
		$("#bzentAddr").attr("disabled", true);
		$("#bzentDaddr").attr("disabled", true);
		$("#mbrNm").attr("disabled", true);
		$("#mbrTelno1").attr("disabled", true);
		$("#mbrTelno2").attr("disabled", true);
		$("#mbrTelno3").attr("disabled", true);
		$("#mbrEmlAddr").attr("disabled", true);
		$("#bankType").attr("disabled", true);
		$("#actno").attr("disabled", true);
		
		// 	저장된 값으로 복원
		$("#bzentTelno1").val(originBzentTelno1);
		$("#bzentTelno2").val(originBzentTelno2);
		$("#bzentTelno3").val(originBzentTelno3);
		$("#openTm").val(originOpenTm);
		$("#ddlnTm").val(originDdlnTm);
		$("#bzentZip").val(originBzentZip);
		$("#bzentAddr").val(originBzentAddr);
		$("#bzentDaddr").val(originBzentDaddr);
		$("#mbrNm").val(originMbrNm);
		$("#mbrTelno1").val(originMbrTelno1);
		$("#mbrTelno2").val(originMbrTelno2);
		$("#mbrTelno3").val(originMbrTelno3);
		$("#mbrEmlAddr").val(originMbrEmlAddr);
		$("#bankType").val(originBankType);
		$("#actno").val(originActno);
		
		location.reload();
	})
	
	select2Custom(); // 셀렉트 디자인 라이브러리. common.js에서 호출 됨
	
	$('#bankType').select2({
        width: '180px', // width 속성 설정
    });
	
	
	
	// 가맹점 폐업신청 모달 시작!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
	// 모달 열기
    $("#insertFrcsClsbizBtn").on("click", function() {
        $("#frcsClsbizModal").modal("show"); // 모달 열기
    });

    // 모달 닫기
    $("#deleteClsbizBtn").on("click", function() {
        $("#frcsClsbizModal").modal("hide"); // 모달 닫기
    });
	
	$("#insertClsbizBtn").on("click", function() {
		event.preventDefault(); // 기본 폼 제출 방지
		
		// 폐업 예정일 값 가져오기
// 		const clsbizPrnmntYm = $("#clsbizPrnmntYm").val();
		const clsbizPrnmntYm = $("#clsbizPrnmntYm").val().replace("-", "");
		const clsbizRsnType = $("#clsbizRsnType").val();
		const clsbizRsn = $("#clsbizRsn").val();
		
		// YYYYMMDD 형식으로 현재 날짜 가져오기
	    const currentDate = new Date();
	    const currentYear = currentDate.getFullYear();
	    const currentMonth = String(currentDate.getMonth() + 1).padStart(2, '0'); // 월은 0부터 시작하므로 +1
	    const currentYm = currentYear + currentMonth; // 현재 날짜를 YYYYMM 형식으로 변환
	    
		if (clsbizPrnmntYm < currentYm) {
			Swal.fire({
				icon: 'error',
				title: 'Error!',
				text: '수정할 수 없습니다. 선택한 날짜가 현재 날짜보다 이전입니다.'
			});
// 	        alert("수정할 수 없습니다. 선택한 날짜가 현재 날짜보다 이전입니다.");
	        return; // AJAX 요청 중단
	    }
		
		let dataClsbiz = {
				"frcsClsbizVO": {
					"frcsNo":frcsNo,
					"clsbizPrnmntYm":clsbizPrnmntYm, 
					"clsbizRsnType":clsbizRsnType, 
					"clsbizRsn":clsbizRsn
				},
				"clsbizYmd":clsbizPrnmntYm + "20",
				"bzentVO":{
                	"mbrId":data
                }
		};
		
		console.log("dataClsbiz : ", dataClsbiz);
        console.log("${_csrf.headerName}");
        console.log("${_csrf.token}");
        
        $.ajax({
        	url:"/frcs/insertFrcsClsbizAjax",
        	contentType:"application/json;charset=utf-8",
        	data:JSON.stringify(dataClsbiz),
        	type:"post",
        	dataType:"json",
        	beforeSend: function(xhr) {
                xhr.setRequestHeader("${_csrf.headerName}", "${_csrf.token}");
            },
        	success:function(result){
        		console.log("수정 결과 : ", result);
                if (result > 0) {
                	Swal.fire({
     					icon: "success",
    					title: "폐업 신청이 완료되었습니다.",
    					showConfirmButton: false,
      					timer: 3000
    				});
                    location.reload(); // 페이지 새로고침
                } else {
                	Swal.fire({
        				icon: 'error',
        				title: 'Error!',
        				text: '폐업 신청에 실패하셨습니다.'
        			});
                }
        	},
            error: function(xhr, status) {
                console.error("AJAX 오류:", status);
                alert("AJAX 요청에 실패했습니다. 콘솔을 확인하세요.");
            }
        });
	});
	// 가맹점 폐업신청 모달 끝!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
});

</script>
<div class="content-header">
	<div class="container-fluid">
		<div class="row mb-2 justify-content-between">
			<div class="row align-items-center">
<!-- 				<button type="button" class="btn btn-default mr-3" onclick="goToHomePage()"> -->
<!-- 					<span class="icon material-symbols-outlined">keyboard_backspace</span> -->
<!-- 					메인페이지 -->
<!-- 				</button> -->
				<h1 class="m-0">마이 페이지</h1>
			</div>
			<div id="div1" class="btn-wrap">
				<button type="button" class="btn-active" id="btnEdit" data-toggle="modal" data-target="#pswdCheck">정보 수정 및 폐업 신청</button>
			</div>
			<div id="div2" class="btn-wrap">
				<button type="button" class="btn-default" id="btnCancel">취소</button>
				<button type="button" class="btn-active" id="updateFrcsBtn">수정</button>
				<button type="button" class="btn-danger" id="insertFrcsClsbizBtn">폐업 신청</button>
			</div>
		</div>
		<!-- /.row -->
	</div>
	<!-- /.container-fluid -->
</div>


<div class="wrap">
    <%-- 마이페이지 가맹점 정보 시작!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --%>
    <div class="cont">
		<!-- table-wrap -->
		<div class="table-wrap">
			<div class="table-title">
				<div class="cont-title"><span class="material-symbols-outlined title-icon">store</span>가맹점 정보</div>
			</div>
			<table class="table-blue">
				<tbody><tr>
					<th>지점명</th>
					<td><span id="bzentNm"></span></td>
					<th>전화번호</th>
					<td>
						<input type="text" id="bzentTelno1" class="input-tel" disabled> -
						<input type="text" id="bzentTelno2" class="input-tel" disabled> -
						<input type="text" id="bzentTelno3" class="input-tel" disabled>
					</td>
				</tr>
				<tr>
					<th>개업일자</th>
					<td><span id="opbizYmd"></span></td>
					<th>영업시간</th>
					<td>
						<input type="time" id="openTm" class="text-input" disabled> ~
						<input type="time" id="ddlnTm" class="text-input" disabled>
					</td>
				</tr>
				<tr>
					<th>주소</th>
					<td colspan="3">
						<div class="addr-zip-wrap">
							<div class="addr-wrap">
								<input class="input-zip" id="bzentZip" readonly="readonly" type="text" disabled>
								<button class="btn-default" type="button" id="openHomeSearchBtn">우편번호 검색</button>
							</div>
							<div class="addr-wrap">
								<input class="input-addr" id="bzentAddr" readonly="readonly" type="text" disabled>
								<input class="input-addr" id="bzentDaddr" type="text" disabled>
							</div>
						</div>
					</td>
				</tr>
				<tr>
					<th>운영 상태</th>
					<td><span id="frcsType"></span></td>
					<th>경고 횟수</th>
					<td><span id="warnCnt"></span></td>
				</tr>
<!-- 				<tr> -->
<!-- 					<th>지역번호</th> -->
<!-- 					<td><span id="rgnNo"></span></td> -->
<!-- 				</tr> -->
			</tbody></table>
		</div>
		<!-- table-wrap -->
	</div>
    <%-- 마이페이지 가맹점 정보 끝!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --%>
    
    <%-- 마이페이지 가맹점주 정보 시작!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --%>
    <div class="cont">
		<!-- table-wrap -->
		<div class="table-wrap">
			<div class="table-title">
				<div class="cont-title"><span class="material-symbols-outlined title-icon">person</span>가맹점주 정보</div>
			</div>
			<table class="table-blue">
				<tbody>
				<tr>
					<th>이름</th>
					<td><input type="text" id="mbrNm" class="text-input" disabled></td>
					<th>지점명</th>
					<td><span id="bzentNm2"></span></td>
				</tr>
				<tr class="pwChange" id="pwChangeTr">
					<th>비밀번호 변경</th>
					<td class="pwChange" colspan="3">
						<div class="addr-zip-wrap">
							<div class="addr-wrap">
								<input type="password" id="mbrPswd" class="input-addr" placeholder="비밀번호">
								<input type="password" id="mbrPswdCheck" class="input-addr" placeholder="비밀번호 확인">
							</div>
						</div>
					</td>
				</tr>
				<tr>
					<th>전화번호</th>
					<td>
						<input type="text" id="mbrTelno1" class="input-tel" disabled> -
						<input type="text" id="mbrTelno2" class="input-tel" disabled> -
						<input type="text" id="mbrTelno3" class="input-tel" disabled>
					</td>
					<th>이메일</th>
					<td>
						<div>
							<input type="text" id="mbrEmlAddr" class="text-input" disabled>
 						</div>
 					</td>
				</tr>
				<tr>
					<th>계좌 번호</th>
					<td colspan="3">
						<div class="flex-container">
							<div class="select-wrapper">
								<div id="bankTypeViewMode" style="display:block;">
								    <input type="text" id="bankTypeNm" class="text-input" disabled>
								</div>
								<div id="bankTypeEditMode" style="display:none;">
								    <select class="select2-custom" name="bankType" id="bankType" style="width: 120px;">
								        <c:forEach var="bk" items="${bk}">
								            <option value="${bk.comNo}" <c:if test="${bk.comNo == bzentVO.bankType}">selected</c:if>>${bk.comNm}</option>
								        </c:forEach>
								    </select>
								</div>
							</div>
							<div class="input-wrapper">
					            <input type="text" id="actno" class="text-input" disabled>
					        </div>
				        </div>
					</td>
				</tr>
			</tbody></table>
		</div>
		<!-- table-wrap -->
	</div>
    <%-- 마이페이지 가맹점주 정보 끝!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --%>
	
	<%-- 마이페이지 가맹점 관리자 정보 시작!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --%>
	<div class="cont">
		<!-- table-wrap -->
		<div class="table-wrap">
			<div class="table-title">
				<div class="cont-title"><span class="material-symbols-outlined title-icon">manage_accounts</span>담당 관리자 정보</div>
			</div>
			<table class="table-blue">
				<tbody>
					<tr>
						<th>이름</th>
						<td><span id="mngrNm"></span></td>
						<th>전화번호</th>
						<td>
							<span id="mngrTelno"></span>
						</td>
					</tr>
					<tr>
						<th>이메일</th>
						<td>
							<span id="mngrEmlAddr"></span>
						</td>
					</tr>
				</tbody>
			</table>
		</div>
		<!-- table-wrap -->
	</div>
	<%-- 마이페이지 가맹점 관리자 정보 끝!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! --%>
	
	
	<!-- 가맹점 폐업 신청 모달 창 -->
	<div class="modal fade" id="frcsClsbizModal" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
		<div class="modal-dialog modal-xl">
			<div class="modal-content">
				<div class="modal-header row align-items-center justify-content-between">
					<div>
						<h4 class="modal-title">가맹점 폐업 신청</h4>
					</div>
					<div>
						<button type="button" class="btn btn-danger" id="insertClsbizBtn">폐업</button>
						<button type="button" class="btn btn-default" data-dismiss="modal">취소</button>
					</div>
				</div>
				<div class="modal-body wrap">
				<!-- 폐업 정보 -->
					<div class="cont modal-frcs">
						<div class="table-wrap">
							<div class="table-title">
								<div class="cont-title">
									<span class="material-symbols-outlined title-icon">list_alt</span>폐업 정보
								</div>
							</div>
							<table class="table-blue modal-table">
								<tr>
									<th style="width:130px;">폐업 예정일</th>
									<td>
										<input type="month" id="clsbizPrnmntYm" class="form-control">
									</td>
									<th style="width:130px;">폐업 유형</th>
									<td>
										<div class="select-custom" style="width:200px;">
											<select id="clsbizRsnType" class="form-control">
												<option value="CR01">재정</option>
												<option value="CR02">운영 미숙</option>
												<option value="CR03">개인</option>
												<option value="CR04">재난</option>
												<option value="CR05">기타</option>
											</select>
										</div>
									</td>
								</tr>
								<tr>
									<th style="width:130px;">폐업 사유</th>
									<td colspan="3">
										<textarea id="clsbizRsn" class="form-control" style="width: 100%; height: 150px;"></textarea>
									</td>
								</tr>
							</table>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
	<!-- 가맹점 폐업 신청 모달 창 끝 -->
</div>





<div class="modal fade" id="pswdCheck" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="staticBackdropLabel" aria-hidden="true">
		<div class="modal-dialog modal-dialog-centered">
			<div class="modal-content">
<!-- Modal Header -->
				<div class="modal-header">
					<h4 class="modal-title">비밀번호 확인</h4>
					<div class="btn-wrap">
						<button type="button" id="ModalBtnCancel" data-dismiss="modal" class="modal-close">취소</button>
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