package com.authServer.ModelController;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;

@Controller
public class WebMvcConfiguration {
	
//	@RequestMapping("/login")
//    public String greeting(Model model) {
//        return "login";
//    }

	@RequestMapping("/login")
	 public String home() {
	  return "index";
	 }
}
