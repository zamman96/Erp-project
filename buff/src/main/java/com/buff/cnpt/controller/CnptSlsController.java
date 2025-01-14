package com.buff.cnpt.controller;

import java.security.Principal;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.buff.cnpt.service.CnptSlsService;
import com.buff.cust.mapper.MemberMapper;
import com.buff.util.ArticlePage;
import com.buff.vo.MemberVO;
import com.buff.vo.PoClclnVO;

import lombok.extern.slf4j.Slf4j;

@PreAuthorize("hasRole('ROLE_CNPT')")
@Slf4j
@RequestMapping("/cnpt")
@Controller
public class CnptSlsController {
	
	@Autowired
	private CnptSlsService cnptSlsService;
	
	@Autowired
	private MemberMapper memberMapper;
	
	/**
	* @methodName  : selectSales
	* @author      : 이병훈
	* @date        : 2024.10.08
	* @param model
	* @param principal
	* @return      : 페이지 이동
	*/
	@GetMapping("/sls/selectSales")
	public String selectSales(Model model, Principal principal){
		String mbrId = principal.getName();
		MemberVO memberVO = this.memberMapper.getLogin(mbrId);
		String bzentNo = memberVO.getBzentNo();
		int allSales = this.cnptSlsService.selectAllSales(bzentNo);
		
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("bzentNo", bzentNo);
		
		// 총 매출 금액 가져오기
		long totalSalesAmount = this.cnptSlsService.selectTotalSalesAmount(map);
		
		// model에 거래처 번호와 조회한 매출 데이터를 담아 jsp로 전달
		model.addAttribute("bzentNo", bzentNo);
		model.addAttribute("allSales", allSales);
		model.addAttribute("totalSalesAmount", totalSalesAmount);
		
		// 매출 조회 페이지로 이동 
		return "cnpt/sls/selectCnptSls";
	}
	
	
	/**
	* @methodName  : selectSalesAjax
	* @author      : 이병훈
	* @date        : 2024.10.08
	* @param map   
	* @param principal  : 로그인된 사용자 인증정보
	* @return      : 매출 데이터 전송
	*/
	@GetMapping("/sls/selectSalesAjax")
	@ResponseBody
	public Map<String, Object> selectSalesAjax(@RequestParam Map<String, Object> map, 
											   Principal principal){
		String mbrId = principal.getName();
		MemberVO memberVO = this.memberMapper.getLogin(mbrId);
		String bzentNo = memberVO.getBzentNo();
		
		int size = 10;
		int total = this.cnptSlsService.selectTotalSls(map);
	    
		map.put("size", size);
		map.put("bzentNo", bzentNo);
		
	    // 페이지당 데이터 수 추가
	    int currentPage = map.get("currentPage")!= null ? Integer.parseInt((String) map.get("currentPage")) : 1;
	    
	    // 전체 매출 데이터 수 계산
	    int allSales = this.cnptSlsService.selectAllSales(bzentNo);
	    log.debug("allSales : " + allSales);
	    
	    // 매개변수로 받은 검색 조건을 Map에 추가
	    String selectedYear = map.get("selectedYear") != null ? map.get("selectedYear").toString() : ""; 
	    String startMonth = map.get("startMonth") != null ? map.get("startMonth").toString() : ""; 
	    String endMonth = map.get("endMonth") != null ? map.get("endMonth").toString() : ""; 
	    
	    map.put("selectedYear", selectedYear);
	    map.put("startMonth", startMonth);
	    map.put("endMonth", endMonth);
	    
	    // 총 매출 개수 조회
	    List<PoClclnVO> selectSalesList = this.cnptSlsService.selectSales(map);
	    log.debug("selectSalesList: " + selectSalesList);
	    
	    
	    // 결과를 담을  Map 객체 생성
	    Map<String, Object> response = new HashMap<>();
	    response.put("articlePage", new ArticlePage<PoClclnVO>(total, currentPage, size, selectSalesList, map));
	    response.put("allSales", allSales);
	    
	    log.debug("response : " + response);
	    
	    return response;
	}
	
	
	/**
	* @methodName  : selectDailySales
	* @author      : 이병훈
	* @date        : 2024.10.10
	* @param model
	* @param principal
	* @return      : 일간 매출 현황 페이지로 이동
	*/
	@GetMapping("/sls/selectDailySales")
	public String selectDailySales(@RequestParam String selectedDate,
									Model model, Principal principal) {
		String mbrId = principal.getName();
		MemberVO memberVO = this.memberMapper.getLogin(mbrId);
		String bzentNo = memberVO.getBzentNo();
		
		// 오늘 날짜로 초기화
		model.addAttribute("selectedDate", selectedDate);
		model.addAttribute("bzentNo", bzentNo);
		
		// 데이터 수집을 위한 Map 생성
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("bzentNo", bzentNo);
		map.put("selectedDate", selectedDate);
		
		// 총 매출 금액 계산
		long totalSalesAmount = this.cnptSlsService.selectTotalSalesAmount(map);
		model.addAttribute("totalSalesAmount", totalSalesAmount);
		
		// 오늘 날짜에 해당하는 매출 데이터 로딩
		List<PoClclnVO> dailySalesList = this.cnptSlsService.selectDailySales(map);
		model.addAttribute("dailySalesList", dailySalesList);
		
		// 동일 JSP 페이지로 이동
		return "cnpt/sls/selectSales";
		
	}
	
	
	/**
	* @methodName  : selectDailySalesAjax
	* @author      : 이병훈
	* @date        : 2024.10.10
	* @param map
	* @param principal
	* @return      : 일간 매출 데이터 전송 
	*/
	@GetMapping("/sls/selectDailySalesAjax")
	@ResponseBody
	public Map<String, Object> selectDailySalesAjax(@RequestParam Map<String, Object> map,
													Principal principal){
		String mbrId = principal.getName();
		MemberVO memberVO = this.memberMapper.getLogin(mbrId);
		String bzentNo = memberVO.getBzentNo();
		
		// 데이터 수집
		map.put("bzentNo", bzentNo);
		map.put("size", 10);
		
		// 페이지당 데이터 수 추가
	    int currentPage = map.get("currentPage")!= null ? Integer.parseInt((String) map.get("currentPage")) : 1;
		
		// 일간 매출 데이터 수 계산
		int total = this.cnptSlsService.selectTotalDailySales(map);
		
		// 매개변수로 받은 검색조건(일자)을 Map에 추가
		String selectedDate = map.get("selectedDate") != null ? map.get("selectedDate").toString() : "";
		map.put("selectedDate", selectedDate);
		
		// 일간 매출 데이터 조회
		List<PoClclnVO> dailySalesList = this.cnptSlsService.selectDailySales(map);
		
		// 결과를 담을 Map 객체 생성
		Map<String, Object> response = new HashMap<String, Object>();
		response.put("articlePage", new ArticlePage<PoClclnVO>(total, currentPage, 10, dailySalesList, map));
		
		return response;
		
	}
	
	/**
	* @methodName  : selectSalesAmountAjax
	* @author      : 이병훈
	* @date        : 2024.10.11
	* @param map
	* @param principal
	* @return      : 검색조건에 따른 총 금액 업데이트
	*/
	@GetMapping("/sls/selectSalesAmountAjax")
	@ResponseBody
	public long selectSalesAmountAjax(@RequestParam Map<String, Object> map, Principal principal) {
		String mbrId = principal.getName();
		MemberVO memberVO = this.memberMapper.getLogin(mbrId);
		String bzentNo = memberVO.getBzentNo();
		
		map.put("bzentNo", bzentNo);
		
		// 총 매출 금액 조회
		long totalSalesAmount = this.cnptSlsService.selectTotalSalesAmount(map);
		
		// 총 금액 반환
		return totalSalesAmount;
		
	}
	
	
	@GetMapping("/sls/selectChartDataAjax")
	@ResponseBody
	public Map<String, Object> selectChartDataAjax(@RequestParam Map<String, Object> map, Principal principal) {
	    String mbrId = principal.getName();
	    MemberVO memberVO = this.memberMapper.getLogin(mbrId);
	    String bzentNo = memberVO.getBzentNo();

	    map.put("bzentNo", bzentNo);

	    // 차트에 사용될 전체 매출 데이터를 가져오기
	    List<PoClclnVO> allSalesData = this.cnptSlsService.selectAllSalesData(map);

	    Map<String, Object> response = new HashMap<>();
	    response.put("chartData", allSalesData);
	    
	    return response;
	}
	
	
	
}