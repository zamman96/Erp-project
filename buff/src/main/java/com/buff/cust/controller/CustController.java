package com.buff.cust.controller;

import java.security.Principal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import com.buff.cust.mapper.MemberMapper;
import com.buff.cust.service.CustHomeService;
import com.buff.util.Telno;
import com.buff.vo.BzentVO;
import com.buff.vo.EventVO;
import com.buff.vo.MenuVO;

import lombok.extern.slf4j.Slf4j;


/**
 * 
 *  * 고객이 메인화면에 들어왔을 때, 보이는 화면의 controller
 * 
 * 메뉴 조회, 매장 조회, 이벤트 조회, 이벤트 상세 조회를 할 수 잇음.
 * 
* @packageName  : com.buff.controller.cust
* @fileName     : CustController.java
* @author       : 
* @date         : 2024.09.13
* @description  :
* ===========================================================
* DATE              AUTHOR             NOTE
* -----------------------------------------------------------
* 2024.09.13        이름     	  			최초 생성
*/
@Slf4j
@RequestMapping("/buff")
@Controller
public class CustController {
	
	
	
	@Autowired
	CustHomeService HomeService;
	
	@Autowired
	MemberMapper memberMapper;
	
	
	/**
	* @methodName  : home
	* @author      : 서윤정
	* @date        : 2024.09.12
	* @param : BzentVO
	* @return 메인화면에 가맹점 카드 조회
	*/
	
	@GetMapping("/home")
	public String home(Model model) {
		
		List<BzentVO> bzentVOList = HomeService.selectBzentInfo();
		List<MenuVO> menuVOList = this.HomeService.selectMainMenu();
		
		model.addAttribute("bzentVOList", bzentVOList);
		model.addAttribute("menuVOList", menuVOList);
		log.info("bzentVOList", bzentVOList);
		log.info("menuVOList", menuVOList);
		
		return "cust/main/home";
	}
	
	
	/**
	* @methodName  : selectStore
	* @author      : 서윤정
	* @date        : 2024.09.12
	* @param : BzentVO
	* @return 가맹지점 조회
	*/
	@GetMapping("/selectStore")
	public String selectStore(@RequestParam Map<String, Object> map, Model model, Principal principal) {

	   // int total = HomeServcie.getTotal(map);
	    
	   // log.info("selectStore -> total :" + total);
		if (principal != null) { 
	        String mbrId = principal.getName();
	        map.put("mbrId", mbrId);
	    } 
		
	    List<BzentVO> bzentVOList = HomeService.selectStore(map);
	    
	    // 핸드폰 처리, 시간 처리
	    List<BzentVO> bze = new ArrayList<BzentVO>();
	    for(BzentVO bzentVO : bzentVOList) {
	    	String telno = bzentVO.getBzentTelno();
	    	telno = Telno.splitTelStr(telno);
	    	bzentVO.setBzentTelno(telno);
	    	
	    	String open = bzentVO.getOpenTm();
	    	String ddln = bzentVO.getDdlnTm();
	    	
	    	open = open.substring(0, 2) + ":" + open.substring(2);
	    	if(ddln.equals("0000")) {
	    		ddln = "2400";
	    	}
	    	ddln = ddln.substring(0, 2) + ":" + ddln.substring(2);
	    	
	    	bzentVO.setOpenTm(open);
	    	bzentVO.setDdlnTm(ddln);
	    	
	    	bze.add(bzentVO);
	    }
	    
	    model.addAttribute("bzentVOList", bze);
	    return "cust/main/selectStore";

	}
	
	
	/**
	* @methodName  : selectMenu
	* @author      : 서윤정
	* @date        : 2024.09.12
	* @param : BzentVO
	* @return 본사 메뉴 조회
	*/
	@GetMapping("/selectMenu")
	public String selectMenu(Model model, @RequestParam(value = "menuGubun", defaultValue = "MENU01") String menuGubun){
		List<MenuVO> menuVOList = this.HomeService.selectMenu(menuGubun);
		
		model.addAttribute("menuGubun", menuGubun);
		model.addAttribute("menuVOList", menuVOList);
		
		
		return "cust/main/selectMenu";
	}
	
	
	
	/**
	* @methodName  : insertDscsn
	* @author      : 서윤정
	* @date        : 2024.09.12
	* @param : BzentVO
	* @return 가맹점 문의 화면
	*/
	
	@GetMapping("/insertDscsn")
	public String insertDscsn() {
		
		return "cust/main/insertDscsn";
	}
	
	/**
	 * @methodName  : insertDscsn
	 * @author      : 정기쁨
	 * @date        : 2024.10.08
	 * @param : mbrId
	 * @return 가맹점 문의 조회 결과 (신청날짜, 지역번호, 지역이름)
	 */
	@ResponseBody
	@GetMapping("/selectDscsn")
	public Map<String, Object> selectDscsn(
		@RequestParam(value = "mbrId", required = false, defaultValue = "") String mbrId
	){
		Map<String, Object> map = this.HomeService.selectFrcsDscsn(mbrId);
		return map;
	}
	
	/**
	* @methodName  : selectStore
	* @author      : 서윤정
	* @date        : 2024.09.16
	* @param : BzentVO
	* @return 이벤트 조회
	*/
	
	@GetMapping("/selectEvent")
	public String selectEvent(Model model) {
		List<EventVO> eventVOList = HomeService.selectEvent();
		
		model.addAttribute("eventVOList", eventVOList);
		
		return "cust/main/selectEvent";
	}
	
	

	/**
	* @methodName  : selectEventAjax
	* @author      : 서윤정
	* @date        : 2024.10.10
	* @param : BzentVO
	* @return 진행중인 이벤트 조회
	*/
	@GetMapping("/selectEventAjax")
	@ResponseBody
	public Map<String, Object> selectEventAjax() {
	    log.info("selectEventAjax 호출");

	    List<EventVO> eventVOList = HomeService.selectEvent(); 

	    Map<String, Object> response = new HashMap<>();
	    response.put("eventVOList", eventVOList);
	    
	   log.info("selectEventAjax -> eventVOList : " + eventVOList );
	    return response;
	}


	/**
	* @methodName  : selectEndEventAjax
	* @author      : 서윤정
	* @date        : 2024.10.10
	* @param : BzentVO
	* @return 종료된 이벤트 조회
	*/
	@GetMapping("/selectEndEventAjax")
	@ResponseBody
	public Map<String, Object> selectEndEventAjax() {
	    log.info("selectEventAjax 호출");

	    List<EventVO> eventVOList = HomeService.selectEndEventAjax(); 

	    Map<String, Object> response = new HashMap<>();
	    response.put("eventVOList", eventVOList);
	    
	   log.info("selectEndEventAjax -> eventVOList : " + eventVOList );
	    return response;
	}
	
	
	/**
	* @methodName  : insertEventCoupon
	* @author      : 서윤정
	* @date        : 2024.10.01
	* @param : BzentVO
	* @return 이벤트 상세조회 (쿠폰 발급 받는 페이지)
	*/
	  @GetMapping("/insertEventCoupon")
	  public String insertEventCoupon(@RequestParam(value="eventNo") String eventNo, Model model) {
	      log.info("insertEventCoupon -> eventNo: {}", eventNo);
	      
	      EventVO eventVO = HomeService.insertEventCoupon(eventNo);
	      log.info("insertEventCoupon -> eventVO: {}", eventVO);
	      
	      model.addAttribute("eventVO", eventVO);
	      
	      return "cust/main/insertEventCoupon";
	  }

	
}
