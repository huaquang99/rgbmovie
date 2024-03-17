package com.rgbmovie.config;


import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.jetbrains.annotations.NotNull;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.ProviderManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.access.channel.ChannelProcessingFilter;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.stereotype.Component;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import org.springframework.web.filter.CorsFilter;
import org.springframework.web.filter.OncePerRequestFilter;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import com.rgbmovie.security.JwtTokenFilter;

import java.io.IOException;
import java.util.Arrays;


@Configuration
@EnableWebSecurity
@EnableMethodSecurity(jsr250Enabled = true, prePostEnabled = true, securedEnabled = true) // Setup for role annotation
public class WebSecurityConfig implements WebMvcConfigurer {

    @Autowired
    private JwtTokenFilter jwtTokenFilter;


    @Bean
    UserDetailsService userDetailsService() {
        return new CustomUserDetailServiceImpl();
    }

    @Bean
    public BCryptPasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    AuthenticationManager authenticationManager() {
        DaoAuthenticationProvider provider = new DaoAuthenticationProvider();
        provider.setUserDetailsService(userDetailsService());
        provider.setPasswordEncoder(passwordEncoder());
        return new ProviderManager(provider);
    }

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        //For request static and template file
        http.authorizeHttpRequests((auth) -> auth.requestMatchers("/assets/**", "/error/**", "/403", "/admin/403").permitAll());
        //For request not require auth
        http.csrf(AbstractHttpConfigurer::disable).cors(AbstractHttpConfigurer::disable).authorizeHttpRequests((auth) -> auth.requestMatchers("/api/auth", "/api/theater/**", "/api/movie/**", "/api/signup", "/api/screening", "/admin/auth/recover", "/admin/auth/changePassword", "/docs/**", "/api/customer/recover", "/api/customer/resetPassword", "/api/customer/changePassword").permitAll());
        // Filter for api only
        http.authorizeHttpRequests((auth) -> auth.requestMatchers("/api/**")).addFilterBefore(new CorsFilter(), ChannelProcessingFilter.class)
                .addFilterBefore(jwtTokenFilter, UsernamePasswordAuthenticationFilter.class).csrf(AbstractHttpConfigurer::disable).cors(AbstractHttpConfigurer::disable).sessionManagement((session) -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS));
        //For request require auth
        http.authorizeHttpRequests((auth) -> auth.requestMatchers("/admin/**")
                .hasAnyRole("ADMIN", "MANAGER").anyRequest().authenticated()).formLogin(form -> form.loginPage("/admin/auth/login").loginProcessingUrl("/admin/auth/login").permitAll()
                .usernameParameter("username").passwordParameter("password").defaultSuccessUrl("/admin/home", true)
                .failureUrl("/admin/auth/login?error=true")).rememberMe(rememberMe ->
                rememberMe.key("uniqueAndSecret").tokenValiditySeconds(86400).userDetailsService(userDetailsService())).sessionManagement((session) -> session.sessionCreationPolicy(SessionCreationPolicy.ALWAYS)).exceptionHandling(exp -> exp.accessDeniedPage("/admin/403"));
        http.logout(l -> l.logoutUrl("/admin/auth/logout").logoutSuccessUrl("/admin/auth/login"));
        return http.build();
    }

    @Component
    @Order(Ordered.HIGHEST_PRECEDENCE)
    public static class CorsFilter extends OncePerRequestFilter {
        @Override
        protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
            response.setHeader("Access-Control-Allow-Origin", "*");
            response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
            response.setHeader("Access-Control-Max-Age", "3600");
            response.setHeader("Access-Control-Allow-Headers", "authorization, content-type, xsrf-token");
            response.addHeader("Access-Control-Expose-Headers", "xsrf-token");
            if ("OPTIONS".equals(request.getMethod())) {
                response.setStatus(HttpServletResponse.SC_OK);
            } else {
                filterChain.doFilter(request, response);
            }
        }
    }
}

