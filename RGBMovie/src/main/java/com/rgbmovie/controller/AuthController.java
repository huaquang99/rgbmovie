package com.rgbmovie.controller;

import javax.validation.constraints.Null;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequestMapping("/admin/auth")
public class AuthController {
    @GetMapping("/login")
    public String login(@RequestParam(value = "error", defaultValue = "", required = false) String error, Model model) {
        if (!error.isEmpty()) {
            model.addAttribute("message", "Incorrect username or password");
        }
        return "auth/login";
    }

    @GetMapping("/recover")
    public String recover(@RequestParam(value = "error", defaultValue = "", required = false) String error, Model model) {
        if (!error.isEmpty()) {
            model.addAttribute("message", "Email not valid");
        }
        return "auth/forgetPassword";
    }
}
