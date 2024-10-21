package com.buff.hdofc.service.impl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.buff.hdofc.mapper.HdofcFrcsCheckMapper;
import com.buff.hdofc.service.HdofcFrcsCheckService;
import com.buff.util.CheckScore;
import com.buff.vo.FrcsCheckVO;

/**
* @packageName  : com.buff.hdofc.service.impl
* @fileName     : HdofcFrcsCheckServiceImpl.java
* @author       : 송예진
* @date         : 2024.09.16
* @description  : 가맹점 점검 Service impl
* ===========================================================
* DATE              AUTHOR             NOTE
* -----------------------------------------------------------
* 2024.09.16        송예진     	  			최초 생성
*/
@Service
public class HdofcFrcsCheckServiceImpl implements HdofcFrcsCheckService{
	
	@Autowired
	HdofcFrcsCheckMapper checkMapper;
	
	/**
	* @methodName  : selectFrcs
	* @author      : 송예진
	* @date        : 2024.09.19
	* @param map   : 페이징 + 검색조건
	* @return      : 점검이 필요한 가맹점 조회
	*/
	public List<FrcsCheckVO> selectFrcs(Map<String, Object> map){
		List<FrcsCheckVO> FrcsCheckList = new ArrayList<FrcsCheckVO>();
		List<FrcsCheckVO> list = this.checkMapper.selectFrcs(map);
		for(FrcsCheckVO vo : list) {
			int totScr = vo.getTotScr();
			String totStr = CheckScore.evaluateGrade(totScr);
			vo.setTotStr(totStr);
			FrcsCheckList.add(vo);
		}
		return FrcsCheckList;
	};
	
	/**
	* @methodName  : selectTotalFrcs
	* @author      : 송예진
	* @date        : 2024.09.19
	* @param map   : 검색 조건
	* @return      : 페이징에 필요한 전체 페이지 갯수
	*/
	public Map<String, Object> selectTotalFrcs(Map<String, Object> map) {
		Map<String, Object> cnt = new HashMap<String, Object>();
		cnt.put("total", this.checkMapper.selectTotalFrcs(map));
		
		map.put("chk", "chk");
		cnt.put("chk", this.checkMapper.selectTotalFrcs(map));
		map.remove("chk");
		cnt.put("all", this.checkMapper.selectTotalFrcs(map));
		return cnt;
	};

	
	/**
	* @methodName  : insertFrcsCheck
	* @author      : 송예진
	* @date        : 2024.09.20
	* @return      : 점검 항목 추가
	*/
	public String insertFrcsCheck(FrcsCheckVO frcsCheckVO) {
		// 점검 추가
		int cnt = this.checkMapper.insertFrcsCheck(frcsCheckVO);
		// 총 점수 확인
		int totScr = frcsCheckVO.getClenScr() + frcsCheckVO.getSrvcScr();
		// 점수 영어 등급으로 변환
		String totStr = CheckScore.evaluateGrade(totScr);
		// F점일 경우인지 확인
		if(totStr.equals("F")) {
			String frcsNo = frcsCheckVO.getFrcsNo();
			// 경고 횟수 추가
			this.updateWarn(frcsNo);
			// 경고 총 갯수 확인
			int warnCnt = this.selectWarn(frcsNo);
			// 경고 횟수가 3회 되었을 경우 폐업 처리
			if(warnCnt>=3) {
				this.updateFrcsCls(frcsNo);
				this.insertFrcsClsbiz(frcsNo);
				return "clsbiz";
			}
		}
		return "ok";
	};
	
	/**
	* @methodName  : updateWarn
	* @author      : 송예진
	* @date        : 2024.09.20
	* @return      : 60점 미만 시 경고 추가
	*/
	public int updateWarn(String frcsNo) {
		return this.checkMapper.updateWarn(frcsNo);
	};
	
	/**
	* @methodName  : selectWarn
	* @author      : 송예진
	* @date        : 2024.09.20
	* @return      : 경고 추가 시 경고 확인
	*/
	public int selectWarn(String frcsNo) {
		return this.checkMapper.selectWarn(frcsNo);
	};
	
	/**
	* @methodName  : updateFrcsCls
	* @author      : 송예진
	* @date        : 2024.09.20
	* @return      : 폐업 예정 상태와 폐업일 추가
	*/
	public int updateFrcsCls(String frcsNo) {
		return this.checkMapper.updateFrcsCls(frcsNo);
	};
	
	/**
	* @methodName  : insertFrcsClbiz
	* @author      : 송예진
	* @date        : 2024.09.20
	* @return      : 폐업 테이블 추가
	*/
	public int insertFrcsClsbiz(String frcsNo) {
		return this.checkMapper.insertFrcsClsbiz(frcsNo);
	};
	
	/////////////// 가맹점 점검 조회
	
	/**
	* @methodName  : selectFrcsCheck
	* @author      : 송예진
	* @date        : 2024.09.20
	* @param map   : 검색조건 + 페이징
	* @return      : 점검 조회
	*/
	public List<FrcsCheckVO> selectFrcsCheck(Map<String, Object> map){
		List<FrcsCheckVO> FrcsCheckList = new ArrayList<FrcsCheckVO>();
		List<FrcsCheckVO> list = this.checkMapper.selectFrcsCheck(map);
		// 총 점수 영어로 변환하여 추가
		for(FrcsCheckVO vo : list) {
			int totScr = vo.getTotScr();
			String totStr = CheckScore.evaluateGrade(totScr);
			vo.setTotStr(totStr);
			FrcsCheckList.add(vo);
		}
		return FrcsCheckList;
	};
	
	/**
	* @methodName  : selectTotalFrcsCheck
	* @author      : 송예진
	* @date        : 2024.09.20
	* @param map   : 검색 조건	
	* @return      : 조건에 대한 총 갯수
	*/
	public int selectTotalFrcsCheck(Map<String, Object> map) {
		return this.checkMapper.selectTotalFrcsCheck(map);
	};
	
	//////////////// 가맹점 상세
	
	/**
	* @methodName  : selectFrcsCheckDtl
	* @author      : 송예진
	* @date        : 2024.09.20
	* @param       : frcsCheckVO(frcsNo, chckSeq)
	* @return      : 점검 상세
	*/
	public FrcsCheckVO selectFrcsCheckDtl(FrcsCheckVO frcsCheckVO) {
		frcsCheckVO = this.checkMapper.selectFrcsCheckDtl(frcsCheckVO);
		int totScr = frcsCheckVO.getTotScr();
		String totStr = CheckScore.evaluateGrade(totScr);
		frcsCheckVO.setTotStr(totStr);
		return frcsCheckVO;
	};
	
	/**
	* @methodName  : deleteFrcsCheck
	* @author      : 송예진
	* @date        : 2024.09.20
	* @param       : frcsCheckVO(frcsNo, chckSeq)
	* @return      : 점검 삭제
	*/
	public String deleteFrcsCheck(FrcsCheckVO frcsCheckVO) {
		// 점검 삭제
		int cnt = this.checkMapper.deleteFrcsCheck(frcsCheckVO);
		String frcsNo = frcsCheckVO.getFrcsNo();
		String totStr = frcsCheckVO.getTotStr();
		// 삭제하는 항목의 점검 점수가 F인 경우
		if(totStr.equals("F")) {
			// 경고 횟수 확인
			int warnCnt = this.checkMapper.selectWarn(frcsNo);
			// 경고 차감
			this.checkMapper.deleteWarn(frcsNo);
			// 폐업 취소 처리
			if(warnCnt>=3) {
				// 이미 폐업이 된 상태인지 조회
				String frcsType = this.checkMapper.selectFrcsType(frcsNo);
				// 이미 폐업된 상태라면 폐업이 취소되지 않음
				if(frcsType.equals("FRS02")) {
					return "ok";
				}
				// 본사가 강제 폐업 조치를 한경우에만 삭제
				this.checkMapper.cancelFrcsClsbiz(frcsNo);
				
				// 본사가 강제 폐업을 해서 폐업을 당한 경우에 frcs운영타입 변경
				if(cnt>0) {
					// 상태 운영과 폐업일 변경
					this.checkMapper.cancelFrcs(frcsNo);
					return "clsbiz";
				}
			} 
		}
		return "ok";
		
	};
	
	/**
	* @methodName  : cancelFrcs
	* @author      : 송예진
	* @date        : 2024.09.20
	* @return      : 폐업 취소 frcs
	*/
	public int cancelFrcs(String frcsNo) {
		return this.checkMapper.cancelFrcs(frcsNo);
	};
	
	/**
	* @methodName  : cancelFrcsClbiz
	* @author      : 송예진
	* @date        : 2024.09.20
	* @return      : 폐업 취소 frcs_clb
	*/
	public int cancelFrcsClsbiz(String frcsNo) {
		return this.checkMapper.cancelFrcsClsbiz(frcsNo);
	};
	
	/**
	* @methodName  : deleteWarn
	* @author      : 송예진
	* @date        : 2024.09.20
	* @return      : 경고 삭제
	*/
	public int deleteWarn(String frcsNo) {
		return this.checkMapper.deleteWarn(frcsNo);
	};
	
	/**
	* @methodName  : selectFrcsType
	* @author      : 송예진
	* @date        : 2024.09.20
	* @param frcsNo
	* @return     : 가맹점의 타입을 확인
	*/
	public String selectFrcsType(String frcsNo) {
		return this.checkMapper.selectFrcsType(frcsNo);
	};
	
	/////////////////// 가맹점 상세
	
	/**
	* @methodName  : selectFrcsDtlCheckList
	* @author      : 송예진
	* @date        : 2024.09.24
	* @param frcsNo
	* @return      : 가맹점 하나의 점검리스트 전체
	*/
	public List<FrcsCheckVO> selectFrcsDtlCheckList(String frcsNo){
	    List<FrcsCheckVO> FrcsCheckList = new ArrayList<FrcsCheckVO>();
		List<FrcsCheckVO> list = this.checkMapper.selectFrcsDtlCheckList(frcsNo);
		// NullPointerException 방지
		if (list == null) {
			return null; // 또는 예외 처리 등 필요에 따라 다른 처리를 할 수 있습니다.
		}
		// 총 점수 영어로 변환하여 추가
		for(FrcsCheckVO vo : list) {
			int totScr = vo.getTotScr();
			String totStr = CheckScore.evaluateGrade(totScr);
			vo.setTotStr(totStr);
			FrcsCheckList.add(vo);
		}
		return FrcsCheckList;
	};
	
	
	/**
	* @methodName  : selectAvgScr
	* @author      : 송예진
	* @date        : 2024.09.24
	* @param frcsNo
	* @return      : 한 가맹점의 평균 점수
	*/
	public String selectAvgScr(String frcsNo) {
		int totScr = this.checkMapper.selectAvgScr(frcsNo);
		String totStr = CheckScore.evaluateGrade(totScr);
		return totStr;
	};
}